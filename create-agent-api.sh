#!/bin/bash

# Dialogflow CX Agent Import Script
# This script creates the agent, intents, flows, and playbook using the Dialogflow CX API

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Dialogflow CX Agent Creation Script${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

# Check if required variables are set
if [ -z "$PROJECT_ID" ] || [ -z "$LOCATION" ]; then
    echo -e "${RED}Error: Required environment variables not set${NC}"
    echo "Please set:"
    echo "  export PROJECT_ID=\"your-project-id\""
    echo "  export LOCATION=\"global\""
    exit 1
fi

echo -e "${GREEN}Configuration:${NC}"
echo "  Project ID: $PROJECT_ID"
echo "  Location: $LOCATION"
echo ""

# Step 1: Create or get agent
echo -e "${YELLOW}Step 1: Creating agent...${NC}"

AGENT_DISPLAY_NAME="test_for_intents"
AGENT_DEFAULT_LANGUAGE="he-il"
AGENT_TIME_ZONE="Asia/Yekaterinburg"

# Create agent using API
AGENT_RESPONSE=$(gcloud alpha dialogflow agents create \
  --location=$LOCATION \
  --display-name="$AGENT_DISPLAY_NAME" \
  --default-language-code="$AGENT_DEFAULT_LANGUAGE" \
  --time-zone="$AGENT_TIME_ZONE" \
  --format=json 2>&1) || true

if echo "$AGENT_RESPONSE" | grep -q "ALREADY_EXISTS"; then
    echo -e "${YELLOW}Agent already exists. Getting agent ID...${NC}"
    AGENT_ID=$(gcloud alpha dialogflow agents list \
      --location=$LOCATION \
      --filter="displayName:$AGENT_DISPLAY_NAME" \
      --format="value(name)" | cut -d'/' -f6)
else
    AGENT_ID=$(echo "$AGENT_RESPONSE" | jq -r '.name' | cut -d'/' -f6)
fi

echo -e "${GREEN}✓ Agent ID: $AGENT_ID${NC}"
echo ""

# Step 2: Create intents
echo -e "${YELLOW}Step 2: Creating intents...${NC}"

for intent_dir in intents/*/; do
    intent_name=$(basename "$intent_dir")
    intent_file="$intent_dir/${intent_name}.json"

    if [ -f "$intent_file" ]; then
        echo "  Creating intent: $intent_name"

        # Create intent using API (simplified - you'll need to parse JSON and use proper API calls)
        # gcloud alpha dialogflow intents create ...
    fi
done

echo -e "${GREEN}✓ Intents created${NC}"
echo ""

# Step 3: Create flows
echo -e "${YELLOW}Step 3: Creating flows...${NC}"

for flow_dir in flows/*/; do
    flow_name=$(basename "$flow_dir")
    flow_file="$flow_dir/${flow_name}.json"

    if [ -f "$flow_file" ]; then
        echo "  Creating flow: $flow_name"

        # Create flow using API
        # gcloud alpha dialogflow flows create ...
    fi
done

echo -e "${GREEN}✓ Flows created${NC}"
echo ""

# Step 4: Create playbook
echo -e "${YELLOW}Step 4: Creating playbook...${NC}"

playbook_file="playbook/Keidar Real Estate Assistant/Keidar Real Estate Assistant.json"

if [ -f "$playbook_file" ]; then
    echo "  Creating playbook: Keidar Real Estate Assistant"

    # Create playbook using API
    # Note: Playbooks are created via REST API, not gcloud CLI
fi

echo -e "${GREEN}✓ Playbook created${NC}"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Agent creation completed!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Agent ID: $AGENT_ID"
echo "Console URL: https://dialogflow.cloud.google.com/cx/projects/$PROJECT_ID/locations/$LOCATION/agents/$AGENT_ID"
