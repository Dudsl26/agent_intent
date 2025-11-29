# Real Estate Lead Qualification Agent - Dialogflow CX

A Hebrew-language conversational AI agent for qualifying real estate leads through WhatsApp.

## What This Repository Contains

This is a **Dialogflow CX agent export** with the following structure:

```
agent_intent/
├── agent.json              # Agent configuration
├── sessionParameters.json  # Session parameters
├── generativeSettings/     # Generative AI settings
├── intents/                # 11 intent definitions with Hebrew training phrases
│   ├── Default Welcome Intent/
│   ├── Default Negative Intent/
│   ├── interested/
│   ├── request_price/
│   ├── request_details/
│   ├── request_location/
│   ├── not_interested/
│   ├── not_now/
│   ├── already_purchased/
│   ├── confusion/
│   ├── request_specs/
│   └── timing_question/
├── flows/                  # 2 flow definitions
│   ├── Default Start Flow/
│   └── Lead Qualification Flow/
└── playbook/               # Dialogflow CX Playbook
    ├── Keidar Real Estate Assistant/
    │   └── Keidar Real Estate Assistant.json
    └── README.md
```

## Features

- **11 Intents** for lead qualification in Hebrew
- **130+ Training Phrases** in Hebrew (he-il)
- **2 Flows** with routing and event handlers
- **18 Session Parameters** for lead tracking
- **Playbook** with comprehensive knowledge base for Keidar real estate
- **WhatsApp Integration** ready

## How to Import This Agent

### Method 1: Dialogflow CX Console (Recommended)

1. **Go to Dialogflow CX Console**
   - Visit: https://dialogflow.cloud.google.com/cx

2. **Create or Select Agent**
   - Create a new agent or select an existing one
   - Set language to **Hebrew (he-il)**

3. **Import the Agent**
   - Click the ⚙️ **Settings** icon (next to agent name)
   - Go to **"Export and Import"** tab
   - Click **"Restore"**
   - Select **"Upload"**
   - Create a ZIP file of this repository:
     ```bash
     cd /path/to/agent_intent
     zip -r agent.zip . -x "*.git*"
     ```
   - Upload `agent.zip`
   - Click **"Restore"**

4. **Wait for Import** (1-2 minutes)

5. **Verify Import**
   - Check that all 11 intents are present
   - Check that both flows are configured
   - Test in "Test Agent" panel with Hebrew phrases

### Method 2: Using gcloud CLI

```bash
# Set your variables
PROJECT_ID="your-project-id"
LOCATION="global"
AGENT_ID="your-agent-id"

# Create zip file
zip -r agent.zip . -x "*.git*"

# Restore agent
gcloud dialogflow agents restore \
  "projects/$PROJECT_ID/locations/$LOCATION/agents/$AGENT_ID" \
  --agent-content="$(cat agent.zip | base64 -w 0)"
```

## Test Phrases (Hebrew)

After import, test these phrases in the "Test Agent" panel:

- `כן אשמח לשמוע` → interested
- `כמה זה עולה?` → request_price
- `איפה זה?` → request_location
- `תספר לי יותר פרטים` → request_details
- `לא מעניין אותי` → not_interested
- `לא עכשיו` → not_now
- `מי זה?` → confusion

## Session Parameters Tracked

The agent tracks these parameters during conversations:

- phone_number, user_name
- interest_level (none, low, medium, medium-high, high, unknown)
- lead_status (new, qualified, cold, hot, not_interested, converted_elsewhere)
- price_sensitivity, detail_oriented, timing_important, location_important
- wants_catalog, needs_reintroduction, follow_up_needed
- potential_referral, playbook_session_id, handed_off

## Requirements

- Google Cloud Platform account
- Dialogflow CX API enabled
- Agent language: Hebrew (he-il)

## Support

For issues with import:
1. Ensure Dialogflow CX API is enabled
2. Verify agent language is set to Hebrew (he-il)
3. Check Google Cloud Console for quota limits
4. Review import logs in Dialogflow CX Console

## License

[Your License]

## Version

v1.0.0 - Initial Release (2025-11-27)
