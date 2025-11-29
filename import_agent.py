#!/usr/bin/env python3
"""
Dialogflow CX Agent Import Script
Automatically imports the Keidar Real Estate agent to Dialogflow CX
"""

import os
import json
import time
from google.cloud.dialogflowcx_v3 import (
    AgentsClient,
    IntentsClient,
    FlowsClient,
    SessionEntityTypesClient,
    Agent,
    Intent,
    Flow,
    Page,
    TransitionRoute,
    EventHandler,
    Fulfillment,
    ResponseMessage,
)
from google.cloud.dialogflowcx_v3.types import NluSettings
from google.api_core import exceptions

# Configuration
PROJECT_ID = os.getenv("PROJECT_ID", "your-project-id")
LOCATION = os.getenv("LOCATION", "global")
AGENT_DISPLAY_NAME = "test_for_intents"

# API endpoint
API_ENDPOINT = f"{LOCATION}-dialogflow.googleapis.com"


class DialogflowCXImporter:
    """Import Dialogflow CX agent from JSON files"""

    def __init__(self, project_id, location):
        self.project_id = project_id
        self.location = location
        self.parent = f"projects/{project_id}/locations/{location}"

        # Initialize clients
        self.agents_client = AgentsClient(
            client_options={"api_endpoint": API_ENDPOINT}
        )
        self.intents_client = IntentsClient(
            client_options={"api_endpoint": API_ENDPOINT}
        )
        self.flows_client = FlowsClient(
            client_options={"api_endpoint": API_ENDPOINT}
        )

        self.agent_name = None
        self.intent_map = {}
        self.flow_map = {}

    def load_json(self, filepath):
        """Load JSON file"""
        with open(filepath, 'r', encoding='utf-8') as f:
            return json.load(f)

    def create_agent(self):
        """Create Dialogflow CX agent"""
        print("📦 Creating agent...")

        # Load agent configuration
        agent_config = self.load_json("agent.json")

        agent = Agent(
            display_name=agent_config.get("displayName", AGENT_DISPLAY_NAME),
            default_language_code=agent_config.get("defaultLanguageCode", "he-il"),
            time_zone=agent_config.get("timeZone", "Asia/Yekaterinburg"),
            description="Real Estate Lead Qualification Agent for Keidar",
        )

        try:
            response = self.agents_client.create_agent(
                parent=self.parent,
                agent=agent
            )
            self.agent_name = response.name
            print(f"✅ Agent created: {self.agent_name}")
            return response
        except exceptions.AlreadyExists:
            print("⚠️  Agent already exists, getting existing agent...")
            # List agents and find ours
            agents = self.agents_client.list_agents(parent=self.parent)
            for agent in agents:
                if agent.display_name == AGENT_DISPLAY_NAME:
                    self.agent_name = agent.name
                    print(f"✅ Found existing agent: {self.agent_name}")
                    return agent
            raise Exception("Agent exists but couldn't be found")

    def create_intents(self):
        """Create all intents from intents directory"""
        print("\n🎯 Creating intents...")

        intents_dir = "intents"
        intent_count = 0

        for intent_folder in os.listdir(intents_dir):
            intent_path = os.path.join(intents_dir, intent_folder)
            if not os.path.isdir(intent_path):
                continue

            intent_file = os.path.join(intent_path, f"{intent_folder}.json")
            if not os.path.exists(intent_file):
                continue

            print(f"  Creating intent: {intent_folder}")

            # Load intent configuration
            intent_config = self.load_json(intent_file)

            # Load training phrases if available
            training_phrases_file = os.path.join(
                intent_path, "trainingPhrases", "he-il.json"
            )
            training_phrases = []

            if os.path.exists(training_phrases_file):
                tp_data = self.load_json(training_phrases_file)
                training_phrases_list = tp_data.get("trainingPhrases", [])

                for tp in training_phrases_list:
                    parts = []
                    for part in tp.get("parts", []):
                        parts.append(
                            Intent.TrainingPhrase.Part(text=part.get("text", ""))
                        )

                    training_phrases.append(
                        Intent.TrainingPhrase(
                            parts=parts,
                            repeat_count=tp.get("repeatCount", 1)
                        )
                    )

            # Create intent
            intent = Intent(
                display_name=intent_config.get("displayName", intent_folder),
                training_phrases=training_phrases,
                priority=intent_config.get("priority", 500000),
            )

            try:
                response = self.intents_client.create_intent(
                    parent=self.agent_name,
                    intent=intent,
                    language_code="he-il"
                )
                self.intent_map[intent_folder] = response.name
                intent_count += 1
                print(f"    ✅ Created: {intent_folder}")
            except Exception as e:
                print(f"    ⚠️  Error creating {intent_folder}: {str(e)}")

        print(f"✅ Created {intent_count} intents")

    def create_flows(self):
        """Create flows from flows directory"""
        print("\n🌊 Creating flows...")

        flows_dir = "flows"

        # Get Default Start Flow (already exists)
        flows = self.flows_client.list_flows(parent=self.agent_name)
        for flow in flows:
            if flow.display_name == "Default Start Flow":
                self.flow_map["Default Start Flow"] = flow.name
                print(f"  ✅ Found Default Start Flow: {flow.name}")
                break

        # Create Lead Qualification Flow
        for flow_folder in os.listdir(flows_dir):
            flow_path = os.path.join(flows_dir, flow_folder)
            if not os.path.isdir(flow_path):
                continue

            if flow_folder == "Default Start Flow":
                continue  # Skip, already exists

            flow_file = os.path.join(flow_path, f"{flow_folder}.json")
            if not os.path.exists(flow_file):
                continue

            print(f"  Creating flow: {flow_folder}")

            flow_config = self.load_json(flow_file)

            # Create flow with basic config first
            flow = Flow(
                display_name=flow_config.get("displayName", flow_folder),
                description=flow_config.get("description", ""),
                nlu_settings=NluSettings(
                    model_type=NluSettings.ModelType.MODEL_TYPE_ADVANCED,
                    classification_threshold=0.3
                )
            )

            try:
                response = self.flows_client.create_flow(
                    parent=self.agent_name,
                    flow=flow
                )
                self.flow_map[flow_folder] = response.name
                print(f"    ✅ Created flow: {flow_folder}")

                # Update with routes (done separately due to API limitations)
                self.update_flow_routes(response.name, flow_config)

            except Exception as e:
                print(f"    ⚠️  Error creating flow: {str(e)}")

        print(f"✅ Created flows")

    def update_flow_routes(self, flow_name, flow_config):
        """Update flow with transition routes"""
        print(f"    Adding routes to flow...")

        # Get the flow
        flow = self.flows_client.get_flow(name=flow_name)

        # Build transition routes
        transition_routes = []

        for route_config in flow_config.get("transitionRoutes", []):
            intent_name = route_config.get("intent")

            # Find intent ID
            intent_full_name = None
            if intent_name in self.intent_map:
                intent_full_name = self.intent_map[intent_name]

            # Build fulfillment
            fulfillment_config = route_config.get("triggerFulfillment", {})
            messages = []

            for msg_config in fulfillment_config.get("messages", []):
                if "playbook" in msg_config:
                    # Playbook invocation
                    messages.append(
                        ResponseMessage(
                            conversation_success=ResponseMessage.ConversationSuccess(
                                metadata={
                                    "playbook": msg_config["playbook"]["displayName"]
                                }
                            )
                        )
                    )
                elif "text" in msg_config:
                    # Text response
                    messages.append(
                        ResponseMessage(
                            text=ResponseMessage.Text(
                                text=msg_config["text"]["text"]
                            )
                        )
                    )

            # Set parameter actions
            set_param_actions = []
            for param_action in fulfillment_config.get("setParameterActions", []):
                set_param_actions.append(
                    Fulfillment.SetParameterAction(
                        parameter=param_action.get("parameter"),
                        value=param_action.get("value")
                    )
                )

            fulfillment = Fulfillment(
                messages=messages,
                set_parameter_actions=set_param_actions
            )

            # Create route
            route = TransitionRoute(
                intent=intent_full_name,
                trigger_fulfillment=fulfillment
            )

            transition_routes.append(route)

        # Build event handlers
        event_handlers = []
        for event_config in flow_config.get("eventHandlers", []):
            messages = []
            for msg_config in event_config.get("triggerFulfillment", {}).get("messages", []):
                if "text" in msg_config:
                    messages.append(
                        ResponseMessage(
                            text=ResponseMessage.Text(
                                text=msg_config["text"]["text"]
                            )
                        )
                    )

            handler = EventHandler(
                event=event_config.get("event"),
                trigger_fulfillment=Fulfillment(messages=messages)
            )
            event_handlers.append(handler)

        # Update flow
        flow.transition_routes = transition_routes
        flow.event_handlers = event_handlers

        try:
            self.flows_client.update_flow(flow=flow)
            print(f"      ✅ Added {len(transition_routes)} routes")
        except Exception as e:
            print(f"      ⚠️  Error updating routes: {str(e)}")

    def create_playbook(self):
        """Create playbook (Note: Playbooks require REST API)"""
        print("\n📚 Playbook creation...")
        print("  ⚠️  Playbooks require REST API or manual creation")
        print("  📝 Playbook file: playbook/Keidar Real Estate Assistant/Keidar Real Estate Assistant.json")
        print("  ℹ️  Please create playbook manually in console or use REST API")

    def run(self):
        """Run the complete import process"""
        print("=" * 60)
        print("🚀 Dialogflow CX Agent Import")
        print("=" * 60)
        print(f"Project: {self.project_id}")
        print(f"Location: {self.location}")
        print("=" * 60)

        try:
            # Step 1: Create agent
            self.create_agent()
            time.sleep(2)

            # Step 2: Create intents
            self.create_intents()
            time.sleep(2)

            # Step 3: Create flows
            self.create_flows()
            time.sleep(2)

            # Step 4: Playbook (manual for now)
            self.create_playbook()

            print("\n" + "=" * 60)
            print("✅ Import completed successfully!")
            print("=" * 60)
            print(f"\n🌐 Agent Console URL:")
            agent_id = self.agent_name.split("/")[-1]
            print(f"https://dialogflow.cloud.google.com/cx/projects/{self.project_id}/locations/{self.location}/agents/{agent_id}")
            print("\n📝 Next steps:")
            print("1. Create playbook manually in console")
            print("2. Test intents in Test Agent panel")
            print("3. Configure webhooks if needed")

        except Exception as e:
            print(f"\n❌ Error during import: {str(e)}")
            raise


def main():
    """Main entry point"""
    # Check environment variables
    if PROJECT_ID == "your-project-id":
        print("❌ Error: Please set PROJECT_ID environment variable")
        print("   export PROJECT_ID=your-google-cloud-project-id")
        return

    # Check if we're in the right directory
    if not os.path.exists("agent.json"):
        print("❌ Error: agent.json not found")
        print("   Please run this script from the agent_intent directory")
        return

    # Create importer and run
    importer = DialogflowCXImporter(PROJECT_ID, LOCATION)
    importer.run()


if __name__ == "__main__":
    main()
