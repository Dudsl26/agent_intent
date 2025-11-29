#!/bin/bash

# Package Dialogflow CX Agent for Import
# This script creates a properly formatted agent package that can be imported to Dialogflow CX

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Dialogflow CX Agent Packager${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check required files
echo -e "${YELLOW}Validating agent structure...${NC}"

if [ ! -f "agent.json" ]; then
    echo -e "${RED}❌ agent.json not found${NC}"
    exit 1
fi

if [ ! -d "intents" ]; then
    echo -e "${RED}❌ intents directory not found${NC}"
    exit 1
fi

if [ ! -d "flows" ]; then
    echo -e "${RED}❌ flows directory not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Agent structure validated${NC}"
echo ""

# Create package directory
PACKAGE_DIR="agent_package"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PACKAGE_NAME="keidar_agent_${TIMESTAMP}"

echo -e "${YELLOW}Creating package: ${PACKAGE_NAME}${NC}"

# Clean old packages
rm -rf ${PACKAGE_DIR}
mkdir -p ${PACKAGE_DIR}/${PACKAGE_NAME}

# Copy agent files
echo -e "${YELLOW}Copying agent files...${NC}"

cp agent.json ${PACKAGE_DIR}/${PACKAGE_NAME}/
cp sessionParameters.json ${PACKAGE_DIR}/${PACKAGE_NAME}/ 2>/dev/null || true
cp -r intents ${PACKAGE_DIR}/${PACKAGE_NAME}/
cp -r flows ${PACKAGE_DIR}/${PACKAGE_NAME}/
cp -r generativeSettings ${PACKAGE_DIR}/${PACKAGE_NAME}/ 2>/dev/null || true
cp -r playbook ${PACKAGE_DIR}/${PACKAGE_NAME}/ 2>/dev/null || true

echo -e "${GREEN}✅ Files copied${NC}"
echo ""

# Create agent blob (Google format)
echo -e "${YELLOW}Creating agent blob...${NC}"

cd ${PACKAGE_DIR}

# Create tar.gz archive (Dialogflow CX compatible format)
tar -czf ${PACKAGE_NAME}.tar.gz ${PACKAGE_NAME}/

# Also create zip for convenience
zip -r ${PACKAGE_NAME}.zip ${PACKAGE_NAME}/ -q

cd ..

echo -e "${GREEN}✅ Agent packages created:${NC}"
echo -e "   📦 ${PACKAGE_DIR}/${PACKAGE_NAME}.tar.gz"
echo -e "   📦 ${PACKAGE_DIR}/${PACKAGE_NAME}.zip"
echo ""

# Create import script
cat > ${PACKAGE_DIR}/import_using_gcloud.sh << 'IMPORT_SCRIPT'
#!/bin/bash

# Import to Dialogflow CX using gcloud

set -e

# Check environment variables
if [ -z "$PROJECT_ID" ]; then
    echo "❌ Error: PROJECT_ID not set"
    echo "   export PROJECT_ID=your-project-id"
    exit 1
fi

if [ -z "$LOCATION" ]; then
    LOCATION="global"
fi

echo "Importing agent to Dialogflow CX..."
echo "Project: $PROJECT_ID"
echo "Location: $LOCATION"
echo ""

# Find the package file
PACKAGE_FILE=$(ls keidar_agent_*.tar.gz | head -n 1)

if [ -z "$PACKAGE_FILE" ]; then
    echo "❌ No package file found"
    exit 1
fi

echo "Package: $PACKAGE_FILE"
echo ""

# Check if agent exists
echo "Checking for existing agent..."
EXISTING_AGENT=$(gcloud alpha dialogflow agents list \
    --location=$LOCATION \
    --project=$PROJECT_ID \
    --filter="displayName:test_for_intents" \
    --format="value(name)" 2>/dev/null || true)

if [ -n "$EXISTING_AGENT" ]; then
    echo "⚠️  Agent 'test_for_intents' already exists"
    echo "Agent name: $EXISTING_AGENT"
    echo ""
    read -p "Do you want to restore/overwrite it? (y/n) " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Import cancelled"
        exit 1
    fi

    # Restore to existing agent
    echo "Restoring agent..."
    gcloud alpha dialogflow agents restore $EXISTING_AGENT \
        --agent-content-file=$PACKAGE_FILE \
        --location=$LOCATION \
        --project=$PROJECT_ID
else
    # Create new agent from package
    echo "Creating new agent..."

    # First create basic agent
    NEW_AGENT=$(gcloud alpha dialogflow agents create \
        --display-name="test_for_intents" \
        --default-language-code="he-il" \
        --time-zone="Asia/Yekaterinburg" \
        --location=$LOCATION \
        --project=$PROJECT_ID \
        --format="value(name)")

    echo "Agent created: $NEW_AGENT"

    # Then restore content
    echo "Importing agent content..."
    gcloud alpha dialogflow agents restore $NEW_AGENT \
        --agent-content-file=$PACKAGE_FILE \
        --location=$LOCATION \
        --project=$PROJECT_ID
fi

echo ""
echo "✅ Import completed!"
echo ""
echo "🌐 Open in console:"
AGENT_ID=$(echo $EXISTING_AGENT | rev | cut -d'/' -f1 | rev)
if [ -z "$AGENT_ID" ]; then
    AGENT_ID=$(echo $NEW_AGENT | rev | cut -d'/' -f1 | rev)
fi
echo "https://dialogflow.cloud.google.com/cx/projects/$PROJECT_ID/locations/$LOCATION/agents/$AGENT_ID"
IMPORT_SCRIPT

chmod +x ${PACKAGE_DIR}/import_using_gcloud.sh

# Create README
cat > ${PACKAGE_DIR}/README.md << 'README'
# Dialogflow CX Agent Package - Keidar Real Estate

This package contains a complete Dialogflow CX agent ready for import.

## Package Contents

- `keidar_agent_YYYYMMDD_HHMMSS.tar.gz` - Agent package (Google format)
- `keidar_agent_YYYYMMDD_HHMMSS.zip` - Agent package (ZIP format)
- `import_using_gcloud.sh` - Automated import script
- `README.md` - This file

## Method 1: Using gcloud CLI (Recommended)

### Prerequisites

```bash
# Install gcloud CLI
# https://cloud.google.com/sdk/docs/install

# Authenticate
gcloud auth login

# Enable Dialogflow CX API
gcloud services enable dialogflow.googleapis.com --project=your-project-id
```

### Import Steps

```bash
# Set environment variables
export PROJECT_ID="your-google-cloud-project-id"
export LOCATION="global"

# Run import script
./import_using_gcloud.sh
```

The script will:
1. Check if agent exists
2. Create new agent or restore to existing one
3. Import all intents, flows, and configuration
4. Provide console URL

## Method 2: Using Dialogflow CX Console

### Upload via Console

1. Go to https://dialogflow.cloud.google.com/cx
2. Click **Create Agent** or select existing agent
3. Click Settings (⚙️) → **Export and Import**
4. Click **Restore**
5. Select **Upload** and choose the `.tar.gz` or `.zip` file
6. Click **Restore**

**Note:** Console restore works best with packages exported from Dialogflow CX.
For this package, we recommend using the gcloud CLI method above.

## Method 3: Using REST API

```bash
# Get auth token
ACCESS_TOKEN=$(gcloud auth print-access-token)

# Base64 encode the package
AGENT_CONTENT=$(base64 -w 0 < keidar_agent_*.tar.gz)

# Create agent
curl -X POST \
  "https://${LOCATION}-dialogflow.googleapis.com/v3/projects/${PROJECT_ID}/locations/${LOCATION}/agents" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "displayName": "test_for_intents",
    "defaultLanguageCode": "he-il",
    "timeZone": "Asia/Yekaterinburg"
  }'

# Restore content (use agent name from above response)
curl -X POST \
  "https://${LOCATION}-dialogflow.googleapis.com/v3/projects/${PROJECT_ID}/locations/${LOCATION}/agents/${AGENT_ID}:restore" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"agentContent\": \"${AGENT_CONTENT}\"
  }"
```

## What Gets Imported

- ✅ Agent configuration (Hebrew, timezone)
- ✅ 11 Intents with Hebrew training phrases
- ✅ 2 Flows (Default Start + Lead Qualification)
- ✅ Transition routes with playbook invocations
- ✅ Event handlers
- ✅ Session parameters
- ✅ Generative settings
- ✅ Playbook structure

## After Import

1. **Verify import:**
   - Check that all 11 intents are present
   - Verify both flows exist
   - Test in Test Agent panel

2. **Configure playbook** (if not imported):
   - Go to Playbooks section
   - Create "Keidar Real Estate Assistant"
   - Use content from `playbook/` directory

3. **Test the agent:**
   ```
   כן אשמח לשמוע
   כמה זה עולה?
   איפה זה?
   ```

## Troubleshooting

### Error: "Permission denied"
```bash
gcloud auth login
gcloud auth application-default login
```

### Error: "API not enabled"
```bash
gcloud services enable dialogflow.googleapis.com --project=$PROJECT_ID
```

### Error: "Invalid agent content"
- Ensure you're using the `.tar.gz` file
- Try the gcloud CLI method instead of console upload

## Support

For issues:
1. Check agent structure in the package
2. Verify Google Cloud authentication
3. Use `import_using_gcloud.sh` for easiest import
4. See main repository README.md for details
README

echo -e "${GREEN}✅ Package created successfully!${NC}"
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Next Steps${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "1️⃣  Set environment variables:"
echo -e "   ${YELLOW}export PROJECT_ID=your-project-id${NC}"
echo -e "   ${YELLOW}export LOCATION=global${NC}"
echo ""
echo -e "2️⃣  Run import:"
echo -e "   ${YELLOW}cd ${PACKAGE_DIR}${NC}"
echo -e "   ${YELLOW}./import_using_gcloud.sh${NC}"
echo ""
echo -e "📦 Package location: ${GREEN}${PACKAGE_DIR}/${NC}"
echo -e "📄 See ${GREEN}${PACKAGE_DIR}/README.md${NC} for detailed instructions"
echo ""
