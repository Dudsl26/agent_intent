# Real Estate Lead Qualification Agent - Dialogflow CX

A Hebrew-language conversational AI agent for qualifying real estate leads through WhatsApp.

## What This Repository Contains

This is a **complete Dialogflow CX agent** following Google's official architecture with all 6 required directories.

📖 See **[ARCHITECTURE.md](ARCHITECTURE.md)** for complete technical documentation.

### Repository Structure

```
agent_intent/
├── 1️⃣  agent.json                    # Agent Metadata
├── 2️⃣  flows/                        # Structured Conversation Logic (2 flows)
│   ├── Default Start Flow/
│   └── Lead Qualification Flow/
├── 3️⃣  intents/                      # Standard NLU Training Data (11 intents)
│   ├── interested/
│   ├── request_price/
│   ├── request_details/
│   └── ... (+ 8 more)
├── 4️⃣  entityTypes/                  # Custom Data Types
│   ├── city/                       # 5 Israeli cities
│   └── room_count/                 # 2-8 rooms
├── 5️⃣  playbooks/                    # Generative AI Logic
│   └── Keidar Real Estate Assistant/
├── 6️⃣  tools/                        # External API Connection
│   ├── Keidar Property Lookup/
│   └── Calculate Mortgage/
├── sessionParameters.json          # Session parameters
└── generativeSettings/             # AI settings
```

**Complete Dialogflow CX Architecture:**
- ✅ Intent Recognition (NLU)
- ✅ Conversation Flows
- ✅ Generative Playbook
- ✅ Custom Entity Extraction
- ✅ External API Integration
- ✅ Session Management

## Features

- **6 Required Directories** (Google Dialogflow CX structure)
- **11 Intents** for lead qualification in Hebrew
- **130+ Training Phrases** in Hebrew (he-il)
- **2 Flows** with playbook invocations
- **2 Entity Types** (city, room_count)
- **1 Playbook** with comprehensive knowledge base
- **2 Tools** for external API integration
- **18 Session Parameters** for lead tracking
- **WhatsApp Integration** ready

## ⚡ Quick Import (Recommended)

**Step 1:** Create the package

```bash
./package_agent.sh
```

**Step 2:** Import using gcloud

```bash
export PROJECT_ID="your-google-cloud-project-id"
export LOCATION="global"

cd agent_package
./import_using_gcloud.sh
```

**Done!** Your agent will be imported in 1-2 minutes.

---

## How to Import This Agent

### Method 1: Using Package Script (Easiest)

This method creates a Google-compatible agent package:

```bash
# 1. Create package
./package_agent.sh

# This creates:
# - agent_package/keidar_agent_TIMESTAMP.tar.gz (Google format)
# - agent_package/keidar_agent_TIMESTAMP.zip (backup)
# - agent_package/import_using_gcloud.sh (import script)
# - agent_package/README.md (detailed instructions)

# 2. Set environment
export PROJECT_ID="your-project-id"
export LOCATION="global"

# 3. Import
cd agent_package
./import_using_gcloud.sh
```

**What gets imported:**
- ✅ Agent configuration
- ✅ All 11 intents with training phrases
- ✅ Both flows with playbook invocations
- ✅ Session parameters
- ✅ Event handlers

See `agent_package/README.md` after running package script for detailed options.

---

### Method 2: Using Python Script (Alternative)

Alternatively, use the Python API script:

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Authenticate
gcloud auth application-default login

# 3. Set environment
export PROJECT_ID="your-project-id"

# 4. Run import
python import_agent.py
```

See `IMPORT_SCRIPT_README.md` for details.

---

### Method 3: Manual Import

For manual import via console, see `IMPORT_GUIDE.md`

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
