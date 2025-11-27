#!/bin/bash

# Import Script for Dialogflow CX Agent
# This script imports the agent configuration to Dialogflow CX

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Dialogflow CX Agent Import${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    echo -e "${RED}Error: .env file not found${NC}"
    echo "Please create .env from .env.example and configure your settings"
    exit 1
fi

source .env

# Validate required variables
if [ -z "$PROJECT_ID" ] || [ -z "$DIALOGFLOW_AGENT_ID" ] || [ -z "$DIALOGFLOW_LOCATION" ]; then
    echo -e "${RED}Error: Missing required environment variables${NC}"
    echo "Please ensure .env contains:"
    echo "  - PROJECT_ID"
    echo "  - DIALOGFLOW_AGENT_ID"
    echo "  - DIALOGFLOW_LOCATION"
    exit 1
fi

echo -e "${GREEN}Configuration:${NC}"
echo "  Project ID: $PROJECT_ID"
echo "  Agent ID: $DIALOGFLOW_AGENT_ID"
echo "  Location: $DIALOGFLOW_LOCATION"
echo ""

# Create zip file
echo -e "${YELLOW}Creating agent zip file...${NC}"
cd ..
zip -r agent_intent.zip agent_intent \
  -x "*.git*" \
  -x "*node_modules*" \
  -x "*.env" \
  -x "*/.DS_Store" \
  -x "*/tests/*" \
  -x "*/webhooks/*" \
  -x "*.md" \
  -x "*.sh" \
  -x "*.yaml" \
  -q

echo -e "${GREEN}✓ Zip file created${NC}"
echo ""

# Import to Dialogflow CX
echo -e "${YELLOW}Importing agent to Dialogflow CX...${NC}"
echo "This may take 1-2 minutes..."
echo ""

gcloud dialogflow agents restore \
  "projects/$PROJECT_ID/locations/$DIALOGFLOW_LOCATION/agents/$DIALOGFLOW_AGENT_ID" \
  --agent-content="$(cat agent_intent.zip | base64 -w 0)" \
  --quiet

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ Agent imported successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Go to: https://dialogflow.cloud.google.com/cx"
    echo "2. Open your agent: $PROJECT_ID"
    echo "3. Verify all intents and flows are present"
    echo "4. Test in the 'Test Agent' panel"
    echo ""
else
    echo ""
    echo -e "${RED}✗ Import failed${NC}"
    echo "Please check the error message above"
    echo ""
    echo "You can also import manually:"
    echo "1. Go to Dialogflow CX Console"
    echo "2. Click agent settings (gear icon)"
    echo "3. Export and Import > Restore"
    echo "4. Upload: agent_intent.zip"
    exit 1
fi

# Cleanup
rm agent_intent.zip

cd agent_intent
