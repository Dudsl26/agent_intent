# Importing to Dialogflow CX - API Method

Since Dialogflow CX's "Restore" feature only accepts binary blob exports, you need to create the agent using the **Dialogflow CX API**.

## Option 1: Manual Creation (Recommended for Now)

### Step 1: Create Agent Manually

1. Go to https://dialogflow.cloud.google.com/cx
2. Click **"Create agent"**
3. Enter:
   - Display name: `test_for_intents`
   - Location: `global`
   - Default language: `Hebrew (he-il)`
   - Time zone: `Asia/Yekaterinburg`

### Step 2: Import Intents

For each intent in `intents/` directory:

1. Go to **Manage** → **Intents**
2. Click **Create**
3. Copy the content from `intents/[intent-name]/[intent-name].json`
4. Fill in:
   - Display name from `displayName` field
   - Training phrases from `trainingPhrases/he-il.json`
5. Save

Repeat for all 11 intents.

### Step 3: Import Flows

1. Go to **Build** tab
2. For each flow in `flows/` directory:
   - Click **Create flow** (or edit Default Start Flow)
   - Copy structure from `flows/[flow-name]/[flow-name].json`
   - Add transition routes manually
   - Configure event handlers

### Step 4: Create Playbook

1. Go to **Playbooks** section
2. Click **Create playbook**
3. Use content from `playbook/Keidar Real Estate Assistant/Keidar Real Estate Assistant.json`:
   - Display name: `Keidar Real Estate Assistant`
   - Goal: Copy from `goal` field
   - Instructions: Copy all steps from `instruction.steps`
   - Input parameters: Add from `inputParameterDefinitions`
   - Output parameters: Add from `outputParameterDefinitions`

### Step 5: Add Session Parameters

1. Go to **Manage** → **Session parameters**
2. Copy content from `sessionParameters.json`
3. Add each parameter manually

---

## Option 2: Use Dialogflow CX REST API

The Dialogflow CX REST API allows you to create agents programmatically.

### Prerequisites

```bash
# Install required tools
pip install google-cloud-dialogflow-cx
pip install google-auth

# Authenticate
gcloud auth application-default login
```

### Python Script to Create Agent

```python
from google.cloud import dialogflowcx_v3beta1 as dialogflow
import json

# Configuration
PROJECT_ID = "your-project-id"
LOCATION = "global"

# Initialize client
client = dialogflow.AgentsClient(
    client_options={"api_endpoint": f"{LOCATION}-dialogflow.googleapis.com"}
)

# Create agent
parent = f"projects/{PROJECT_ID}/locations/{LOCATION}"

agent = dialogflow.Agent(
    display_name="test_for_intents",
    default_language_code="he-il",
    time_zone="Asia/Yekaterinburg",
)

response = client.create_agent(parent=parent, agent=agent)
print(f"Agent created: {response.name}")

# Now create intents, flows, playbooks using similar API calls
```

---

## Option 3: Export from Another Agent

If you have access to another Dialogflow CX agent:

1. Export that agent (Blob format)
2. Import it into your project
3. Then manually modify it using the console

---

## Recommended Approach for You

**For now, I recommend Option 1 (Manual Creation)** because:

1. ✅ Most straightforward
2. ✅ You can see exactly what you're creating
3. ✅ Good for learning Dialogflow CX
4. ✅ No API complexity

**Steps:**
1. Create agent manually in console
2. Create 11 intents from JSON files
3. Configure 2 flows
4. Create playbook
5. Test!

---

## Alternative: I Can Help Create a Python Script

If you prefer automation, I can create a complete Python script that uses the Dialogflow CX API to:

1. Create the agent
2. Import all 11 intents with training phrases
3. Create both flows with all routes
4. Create the playbook with parameters
5. Set up session parameters

Would you like me to create this automated import script?
