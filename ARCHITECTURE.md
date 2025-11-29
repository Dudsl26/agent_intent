# Dialogflow CX Agent Architecture

Complete architecture documentation for the Keidar Real Estate Dialogflow CX agent.

## 📋 Repository Structure (6 Required Directories)

```
agent_intent/
├── 1️⃣  agent.json                    # Agent Metadata
├── 2️⃣  flows/                        # Structured Conversation Logic
├── 3️⃣  intents/                      # Standard NLU Training Data
├── 4️⃣  entityTypes/                  # Custom Data Types
├── 5️⃣  playbooks/                    # Generative AI Logic
└── 6️⃣  tools/                        # External API Connection
```

---

## 1️⃣ Agent Metadata (`agent.json`)

**Purpose:** Defines agent-level configuration

**Critical Fields:**
- `displayName`: Agent name
- `defaultLanguageCode`: Primary language (he-il)
- `timeZone`: Agent timezone
- `startFlow`: Initial conversation flow

**Example:**
```json
{
  "displayName": "test_for_intents",
  "defaultLanguageCode": "he-il",
  "timeZone": "Asia/Yekaterinburg",
  "startFlow": "Default Start Flow"
}
```

---

## 2️⃣ Flows Directory (`flows/`)

**Purpose:** Structured conversation logic using NLU

**Structure:**
```
flows/
├── Default Start Flow/
│   └── Default Start Flow.json
└── Lead Qualification Flow/
    └── Lead Qualification Flow.json
```

**Critical Rule - Flow to Playbook Handoff:**

A Flow's Page hands off to a Playbook using the **`playbook` message type** in `triggerFulfillment`:

```json
{
  "intent": "interested",
  "triggerFulfillment": {
    "messages": [
      {
        "playbook": {
          "displayName": "Keidar Real Estate Assistant"
        },
        "languageCode": "he-il"
      }
    ],
    "setParameterActions": [
      {
        "parameter": "interest_level",
        "value": "high"
      }
    ]
  }
}
```

**This is Rule 1 in the connection path:** Intent → Flow → **Playbook Invocation** → Playbook

---

## 3️⃣ Intents Directory (`intents/`)

**Purpose:** NLU training data for intent recognition

**Structure:**
```
intents/
├── interested/
│   ├── interested.json              # Intent metadata
│   └── trainingPhrases/
│       └── he-il.json                # Training phrases (separated)
├── request_price/
│   ├── request_price.json
│   └── trainingPhrases/he-il.json
└── ... (11 intents total)
```

**Critical Rule - Training Phrase Separation:**

Training phrases **MUST be separated** from intent metadata:
- Intent metadata: `intents/[intent-name]/[intent-name].json`
- Training phrases: `intents/[intent-name]/trainingPhrases/he-il.json`

**Intent Metadata Example** (`interested.json`):
```json
{
  "displayName": "interested",
  "priority": 500000
}
```

**Training Phrases Example** (`he-il.json`):
```json
{
  "trainingPhrases": [
    {
      "parts": [
        {"text": "כן אשמח לשמוע"}
      ],
      "repeatCount": 1
    },
    {
      "parts": [
        {"text": "בטח, מעניין אותי"}
      ],
      "repeatCount": 1
    }
  ]
}
```

---

## 4️⃣ Entity Types Directory (`entityTypes/`)

**Purpose:** Custom data types for entity extraction

**Structure:**
```
entityTypes/
├── city/
│   └── city.json
└── room_count/
    └── room_count.json
```

**Example - City Entity** (`city.json`):
```json
{
  "displayName": "city",
  "kind": "KIND_MAP",
  "entities": [
    {
      "value": "רעננה",
      "synonyms": ["רעננה", "raanana", "Ra'anana"]
    },
    {
      "value": "כפר סבא",
      "synonyms": ["כפר סבא", "kfar saba", "Kfar Saba"]
    }
  ],
  "enableFuzzyExtraction": false
}
```

**Usage:** Extract structured data from user input (e.g., city names, room counts)

---

## 5️⃣ Playbooks Directory (`playbooks/`)

**Purpose:** Generative AI logic for complex conversations

**Structure:**
```
playbooks/
└── Keidar Real Estate Assistant/
    └── Keidar Real Estate Assistant.json
```

**Critical Rule - Three Required Fields:**

A Playbook MUST contain these three fields for reasoning capability:

### 1. `goal` - Defines the objective
```json
{
  "goal": "מטרה: לסייע ללקוחות פוטנציאליים למצוא דירות..."
}
```

### 2. `instruction` - Defines the steps
```json
{
  "instruction": {
    "steps": [
      {"text": "התחל את השיחה כענבר..."},
      {"text": "אם הלקוח מעוניין, שאל על האזור..."},
      {"text": "לאחר בחירת אזור, שאל על מספר החדרים..."}
    ]
  }
}
```

### 3. `inputParameterDefinitions` & `outputParameterDefinitions` - Defines data flow
```json
{
  "inputParameterDefinitions": [
    {
      "name": "user_name",
      "description": "שם הלקוח",
      "type": "STRING"
    }
  ],
  "outputParameterDefinitions": [
    {
      "name": "interest_level",
      "description": "רמת עניין מעודכנת",
      "type": "STRING"
    }
  ]
}
```

**Referenced Tools:**
```json
{
  "referencedTools": [
    "Keidar Property Lookup",
    "Calculate Mortgage"
  ]
}
```

---

## 6️⃣ Tools Directory (`tools/`)

**Purpose:** Define external API integrations

**Structure:**
```
tools/
├── Keidar Property Lookup/
│   └── Keidar Property Lookup.json
└── Calculate Mortgage/
    └── Calculate Mortgage.json
```

**Critical Rule - OpenAPI Specification:**

Each tool JSON **MUST contain** an OpenAPI spec to enable API calls:

```json
{
  "displayName": "Keidar Property Lookup",
  "description": "Tool to lookup properties",
  "openApiSpec": {
    "schemaVersion": "3.0",
    "servers": [
      {"url": "https://api.keidar.example.com"}
    ],
    "paths": {
      "/properties": {
        "get": {
          "operationId": "getProperties",
          "parameters": [
            {
              "name": "city",
              "in": "query",
              "schema": {"type": "string"}
            }
          ],
          "responses": {
            "200": {
              "description": "List of properties"
            }
          }
        }
      }
    }
  },
  "authentication": {
    "type": "API_KEY_AUTH",
    "apiKeyConfig": {
      "keyName": "X-API-Key",
      "in": "header"
    }
  }
}
```

**This is Rule 2 in the connection path:** Tool → **OpenAPI Spec** → Webhook → API

---

## 🔗 Complete Connection Path

### User Request → Backend Action

```
User Input: "כן אשמח לשמוע"
   ↓
Intent Recognition: "interested" (intents/)
   ↓
Flow Page: Lead Qualification Flow
   ↓
[Rule 1] Playbook Invocation:
   triggerFulfillment.messages[].playbook
   ↓
Playbook: Keidar Real Estate Assistant
   - Reads inputParameters (user_name, interest_level)
   - Follows instruction steps
   - Can invoke referenced tools
   ↓
Tool: Keidar Property Lookup (if needed)
   ↓
[Rule 2] OpenAPI Spec:
   Defines API endpoint, parameters, auth
   ↓
Webhook: External API call
   ↓
External API: https://api.keidar.example.com/properties
   ↓
Response → Playbook → Flow → User
```

---

## 📊 Data Flow

### Session Parameters

**Input to Playbook:**
```json
{
  "user_name": "דני",
  "interest_level": "unknown",
  "lead_status": "new"
}
```

**Output from Playbook:**
```json
{
  "interest_level": "high",
  "lead_status": "qualified",
  "location_important": true,
  "handed_off": true
}
```

---

## 🎯 Integration Points

### 1. Intent → Flow
- Intent recognized via NLU training phrases
- Matched intent triggers flow transition route

### 2. Flow → Playbook
- Flow's `triggerFulfillment` contains playbook invocation
- Session parameters passed to playbook

### 3. Playbook → Tool
- Playbook references tool in `referencedTools`
- Tool invoked when needed during conversation

### 4. Tool → Webhook → API
- Tool's OpenAPI spec defines API endpoint
- Authentication configured (API key, OAuth, etc.)
- Request sent to external API

---

## 🛠️ Key Architecture Rules

### Rule 1: Flow-to-Playbook Handoff
Use `playbook` message type in flow's `triggerFulfillment`:
```json
{"playbook": {"displayName": "Playbook Name"}}
```

### Rule 2: Tool-to-API Connection
Tool JSON must contain `openApiSpec` with:
- `servers`: API base URL
- `paths`: API endpoints
- `authentication`: Auth method

### Rule 3: Training Phrase Separation
Training phrases live in separate file from intent metadata:
```
intents/[name]/[name].json          ← Metadata
intents/[name]/trainingPhrases/he-il.json  ← Phrases
```

### Rule 4: Playbook Reasoning
Playbook must have three critical fields:
1. `goal` - Objective
2. `instruction` - Steps
3. `inputParameterDefinitions` & `outputParameterDefinitions` - Data flow

---

## 📦 Complete File Inventory

### Core Configuration (1 file)
- `agent.json`

### Flows (2 files)
- `flows/Default Start Flow/Default Start Flow.json`
- `flows/Lead Qualification Flow/Lead Qualification Flow.json`

### Intents (22 files = 11 intents × 2 files each)
- `intents/[name]/[name].json` (×11)
- `intents/[name]/trainingPhrases/he-il.json` (×11)

### Entity Types (2 files)
- `entityTypes/city/city.json`
- `entityTypes/room_count/room_count.json`

### Playbooks (1 file)
- `playbooks/Keidar Real Estate Assistant/Keidar Real Estate Assistant.json`

### Tools (2 files)
- `tools/Keidar Property Lookup/Keidar Property Lookup.json`
- `tools/Calculate Mortgage/Calculate Mortgage.json`

**Total: 30 JSON files**

---

## ✅ Validation Checklist

- [ ] `agent.json` exists with required fields
- [ ] All flows have proper transition routes
- [ ] All intents have separated training phrases
- [ ] Entity types defined for custom data extraction
- [ ] Playbook has goal, instruction, and parameter definitions
- [ ] Playbook references tools (if using external APIs)
- [ ] Tools have valid OpenAPI specifications
- [ ] Flow properly invokes playbook via message type
- [ ] Session parameters flow from intent → flow → playbook → tool

---

## 🚀 Import Instructions

See `README.md` for complete import instructions using:
1. Package script (`./package_agent.sh`)
2. Python API script (`python import_agent.py`)
3. Manual import

---

## 📚 Additional Documentation

- **README.md** - Quick start guide
- **IMPORT_GUIDE.md** - Detailed import methods
- **IMPORT_SCRIPT_README.md** - Python script usage
- **playbook/README.md** - Playbook details
- **agent_package/README.md** - Package import guide (auto-generated)

---

## 🔍 Architecture Summary

This agent follows Dialogflow CX's complete architecture with:

✅ **6 Required Directories** (agent, flows, intents, entityTypes, playbooks, tools)
✅ **Proper Separation** (training phrases from intent metadata)
✅ **Generative AI** (playbook with goal, instruction, parameters)
✅ **External Integration** (tools with OpenAPI specs)
✅ **Complete Data Flow** (user → intent → flow → playbook → tool → API)

**Ready for GitHub integration and Dialogflow CX import.**
