# Keidar Real Estate Playbook

This directory contains the Dialogflow CX Playbook for the Keidar real estate lead qualification agent.

## What is a Playbook?

A Playbook in Dialogflow CX is an AI-powered conversational guide that:
- Provides extended knowledge and context to the agent
- Defines conversation flows and scenarios
- Integrates with intents and session parameters
- Handles complex multi-turn conversations

## Files

- `keidar-real-estate-playbook.yaml` - Main playbook configuration for Inbar assistant

## Playbook Overview

### Character
- **Name:** ענבר (Inbar)
- **Role:** Real estate sales assistant from Keidar company
- **Tone:** Friendly, casual, professional (in Hebrew)
- **Language:** Hebrew (he-il)

### Conversation Flow

1. **Opening** - Reconnect with lead, check if still searching
2. **Area Filtering** - Present available cities (רעננה, כפר סבא, הוד השרון, הרצליה, תל אביב)
3. **Size Filtering** - Ask how many rooms (2-8 available)
4. **Information** - Provide project details, prices, features
5. **Handoff** - Connect to sales representative

### Knowledge Base

The playbook includes comprehensive information about:

#### Cities & Projects

**רעננה (Ra'anana)**
- המעלות, בורוכוב, מגרש 2034, ביאליק
- Prices: 3BR (3.2M+), 4BR (3.5M-3.9M), 5BR (4.2M-4.8M)

**כפר סבא (Kfar Saba)**
- גאולה, בן גוריון, חבצלת השרון
- Prices: 2-3BR (2.2M-3.2M), 4BR (3.1M-3.6M)

**הוד השרון (Hod HaSharon)**
- ההסתדרות 6-8
- Prices: 2BR (2.1M), Duplexes (5M-6M)

**הרצליה (Herzliya)**
- אחד העם, סולץ
- Prices: 4BR (4.1M+), 5BR (5M+)

**תל אביב (Tel Aviv)**
- בילטמור, שרת, בני אפרים
- Prices: 2-3BR (3.5M+), Family (6M-10M+)

#### Competitive Advantages

1. **Flexibility** - Custom planning with architect, wall modifications
2. **Mega-Apartments** - Ability to combine apartments (3+3, 4+2)
3. **Presale** - Early pricing in select projects

### Scenarios Handled

- Large apartments (6+ rooms) → Suggest mega-apartment combination
- Investment properties → Recommend 2-3BR in Kfar Saba/Hod HaSharon
- Immediate move-in → Mention limited options in Ra'anana, offer call
- General questions → Provide relevant project information

### Session Parameters

**Input Parameters** (from Dialogflow CX agent):
- phone_number, user_name
- interest_level, lead_status
- price_sensitivity, detail_oriented
- timing_important, location_important
- wants_catalog, needs_reintroduction
- follow_up_needed, handed_off

**Output Parameters** (set by Playbook):
- interest_level (updated based on responses)
- lead_status (qualified/hot/cold/not_interested)
- Various tracking flags (price_sensitivity, location_important, etc.)

### Rules

1. ❌ **NO emojis**
2. 💰 **Numbers:** Use "מיליון" or "M" format (3.5M not 3,500,000)
3. ✅ **Honesty:** If info missing, say "אני צריכה לבדוק במערכת"
4. 🏠 **Range:** 2-8 rooms available (don't dismiss requests)
5. 📍 **Cities only:** הוד השרון, כפר סבא, רעננה, הרצליה, תל אביב
6. ⏰ **No scheduling:** Just say "איש מכירות יחזור אליך בהקדם"
7. 🇮🇱 **Hebrew only:** All responses in Hebrew

## How to Import This Playbook

### Method 1: Dialogflow CX Console

1. Go to your Dialogflow CX agent
2. Navigate to **Playbooks** section
3. Click **Create Playbook**
4. Choose **Import from file**
5. Upload `keidar-real-estate-playbook.yaml`
6. Review and activate

### Method 2: Using gcloud CLI

```bash
# Set variables
PROJECT_ID="your-project-id"
LOCATION="global"
AGENT_ID="your-agent-id"

# Create playbook
gcloud dialogflow playbooks create \
  --agent="projects/$PROJECT_ID/locations/$LOCATION/agents/$AGENT_ID" \
  --display-name="Keidar Real Estate - Inbar Assistant" \
  --playbook-file=playbooks/keidar-real-estate-playbook.yaml
```

## Integration with Agent

The playbook integrates with your existing intents:

| Intent | Playbook Action |
|--------|----------------|
| **interested** | Set high interest, ask about area |
| **request_price** | Set price_sensitivity, provide prices |
| **request_details** | Set detail_oriented, share project info |
| **request_location** | Present area menu, use knowledge base |
| **not_interested** | Set lead_status, politely end |
| **not_now** | Set follow_up needed, offer future contact |
| **confusion** | Reintroduce company, check current search |
| **request_specs** | Provide technical details or callback |
| **timing_question** | Address move-in timing |

## Testing

### Test Phrases

After importing, test with these Hebrew phrases:

```
כן אשמח לשמוע → Should trigger interested flow
כמה זה עולה? → Should provide price information
איפה זה? → Should present area menu
תספר לי יותר פרטים → Should provide project details
לא מעניין אותי → Should politely end conversation
מי זה? → Should reintroduce Keidar
```

### Expected Behavior

1. Agent responds as "ענבר" (Inbar)
2. Follows 3-step flow: Opening → Area → Size
3. Provides specific project information
4. Uses Hebrew without emojis
5. Ends with sales handoff message

## Monitoring

Track these metrics in Dialogflow CX analytics:

- **Playbook activation rate** - How often playbook is triggered
- **Intent matching** - Which intents lead to playbook use
- **Session parameter updates** - Tracking interest_level, lead_status
- **Handoff success rate** - How many conversations reach sales handoff

## Customization

To customize the playbook:

1. Edit `keidar-real-estate-playbook.yaml`
2. Update knowledge base (cities, projects, prices)
3. Modify scenarios for specific situations
4. Adjust conversation examples
5. Re-import to Dialogflow CX

## Support

For issues or questions:
- Check Dialogflow CX Playbook documentation
- Review conversation logs in Dialogflow CX Console
- Test specific scenarios in Test Agent panel

## Version

v1.0.0 - Initial Release (2025-11-27)
- Complete knowledge base for 5 cities
- 10 conversation examples
- Integration with all 11 agent intents
- Hebrew language support
