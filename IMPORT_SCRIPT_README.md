# Automated Import Script

This script automatically imports the Dialogflow CX agent using the Google Cloud Dialogflow CX API.

## Prerequisites

1. **Google Cloud Project** with Dialogflow CX API enabled
2. **Python 3.8+** installed
3. **Authentication** set up

## Setup

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Authenticate

```bash
# Set up Application Default Credentials
gcloud auth application-default login

# Or use a service account
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
```

### 3. Set Environment Variables

```bash
export PROJECT_ID="your-google-cloud-project-id"
export LOCATION="global"  # or your preferred location
```

## Usage

### Run the Import Script

```bash
cd /path/to/agent_intent
python import_agent.py
```

### What It Does

The script automatically:

1. ✅ **Creates the agent** - `test_for_intents` with Hebrew language
2. ✅ **Imports all 11 intents** - With Hebrew training phrases
3. ✅ **Creates flows** - Default Start Flow and Lead Qualification Flow
4. ✅ **Sets up routes** - Connects intents to playbook invocations
5. ✅ **Configures parameters** - Session parameter updates
6. ℹ️  **Playbook** - Provides instructions for manual creation

### Expected Output

```
============================================================
🚀 Dialogflow CX Agent Import
============================================================
Project: your-project-id
Location: global
============================================================
📦 Creating agent...
✅ Agent created: projects/.../agents/...

🎯 Creating intents...
  Creating intent: interested
    ✅ Created: interested
  Creating intent: request_price
    ✅ Created: request_price
  ...
✅ Created 11 intents

🌊 Creating flows...
  ✅ Found Default Start Flow
  Creating flow: Lead Qualification Flow
    ✅ Created flow: Lead Qualification Flow
    Adding routes to flow...
      ✅ Added 9 routes
✅ Created flows

📚 Playbook creation...
  ⚠️  Playbooks require REST API or manual creation
  📝 Playbook file: playbook/Keidar Real Estate Assistant/...
  ℹ️  Please create playbook manually in console

============================================================
✅ Import completed successfully!
============================================================

🌐 Agent Console URL:
https://dialogflow.cloud.google.com/cx/projects/.../agents/...

📝 Next steps:
1. Create playbook manually in console
2. Test intents in Test Agent panel
3. Configure webhooks if needed
```

## Manual Steps After Import

### 1. Create Playbook

Since playbooks require the REST API (not available in the Python client library yet):

1. Go to your agent in Dialogflow CX Console
2. Navigate to **Playbooks** section
3. Click **Create playbook**
4. Use content from: `playbook/Keidar Real Estate Assistant/Keidar Real Estate Assistant.json`
   - Display name: `Keidar Real Estate Assistant`
   - Goal: Copy from JSON
   - Instructions: Copy all 7 steps
   - Input parameters: Add 6 parameters from `inputParameterDefinitions`
   - Output parameters: Add 10 parameters from `outputParameterDefinitions`

### 2. Test the Agent

1. Open **Test Agent** panel in console
2. Test with Hebrew phrases:
   ```
   כן אשמח לשמוע
   כמה זה עולה?
   איפה זה?
   ```
3. Verify intents are recognized
4. Check that playbook is invoked
5. Verify session parameters are updated

## Troubleshooting

### Error: "Permission denied"

```bash
# Re-authenticate
gcloud auth application-default login
```

### Error: "API not enabled"

```bash
# Enable Dialogflow CX API
gcloud services enable dialogflow.googleapis.com --project=your-project-id
```

### Error: "Agent already exists"

The script will automatically detect and use the existing agent.

### Error: "Intent already exists"

```bash
# Delete existing agent and re-run
# Or manually delete conflicting intents in console
```

## Script Features

- ✅ **Idempotent** - Safe to run multiple times
- ✅ **Error handling** - Continues on non-critical errors
- ✅ **Progress indicators** - Shows what's being created
- ✅ **Session parameters** - Automatically set up
- ✅ **Hebrew support** - Handles Hebrew training phrases
- ✅ **Playbook routes** - Connects intents to playbook

## Time Estimate

- **Setup**: 5 minutes (install dependencies, authenticate)
- **Script execution**: 2-3 minutes
- **Manual playbook**: 5-10 minutes
- **Total**: ~15-20 minutes

## Alternative: Manual Import

If you prefer manual import, see `IMPORT_GUIDE.md` for step-by-step instructions.

## Support

For issues:
1. Check script output for specific errors
2. Verify authentication is set up correctly
3. Ensure Dialogflow CX API is enabled
4. Check `IMPORT_GUIDE.md` for manual alternatives
