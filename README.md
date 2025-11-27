# Real Estate Lead Qualification Agent - Dialogflow CX

A conversational AI agent for WhatsApp that qualifies real estate leads in Hebrew, captures context, and seamlessly transitions to a Playbook for detailed conversation.

## Project Overview

This project implements a Google Dialogflow CX agent designed specifically for real estate lead qualification through WhatsApp. The agent:

- Qualifies leads through natural Hebrew conversation
- Captures essential context and user preferences
- Provides appropriate first responses based on user intent
- Seamlessly transitions to a detailed Playbook system
- Tracks session parameters for lead scoring

## Architecture

```
┌─────────────┐
│  WhatsApp   │
│   (Twilio)  │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  WhatsApp       │
│  Webhook        │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│  Dialogflow CX  │
│  Agent          │
│  - 10 Intents   │
│  - Session Mgmt │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│  Playbook       │
│  Handoff        │
│  Webhook        │
└─────────────────┘
```

## Features

### Intents Implemented

1. **interested** - User expresses interest (High priority)
2. **request_price** - Price inquiries (High priority)
3. **request_details** - Detailed information requests
4. **request_location** - Location questions
5. **not_interested** - Rejection/disinterest
6. **not_now** - Delayed interest
7. **already_purchased** - Already bought elsewhere
8. **confusion** - User doesn't remember/recognize
9. **request_specs** - Technical specifications
10. **timing_question** - Move-in dates and timeline

### Session Parameters Tracked

- phone_number
- user_name
- interest_level (none, low, medium, medium-high, high, unknown)
- initial_response
- initial_question
- lead_status (new, qualified, cold, hot, not_interested, converted_elsewhere)
- conversation_start
- messages_count
- price_sensitivity
- detail_oriented
- timing_important
- location_important
- wants_catalog
- needs_reintroduction
- follow_up_needed
- potential_referral
- playbook_session_id
- handed_off

## Directory Structure

```
agent_intent/
├── agent.json                      # Agent configuration
├── sessionParameters.json          # Session parameter definitions
├── generativeSettings/             # Generative AI settings
│   └── he-il.json
├── intents/                        # Intent definitions (11 intents)
│   ├── interested/
│   │   ├── interested.json
│   │   └── trainingPhrases/
│   │       └── he-il.json
│   ├── request_price/
│   ├── request_details/
│   ├── request_location/
│   ├── not_interested/
│   ├── not_now/
│   ├── already_purchased/
│   ├── confusion/
│   ├── request_specs/
│   └── timing_question/
├── flows/                          # Flow definitions
│   ├── Default Start Flow/
│   │   └── Default Start Flow.json
│   └── Lead Qualification Flow/
│       └── Lead Qualification Flow.json
├── deployment/                     # Deployment scripts and webhooks
│   ├── import-agent.sh             # Agent import script
│   ├── deploy.sh                   # Webhook deployment script
│   ├── deployment-config.yaml
│   ├── .env.example
│   ├── webhooks/
│   │   ├── playbook-handoff/
│   │   └── whatsapp-integration/
│   └── tests/                      # Test suite
│       ├── intent-test-cases.json
│       └── test-runner.js
├── docs/                           # Documentation
│   ├── HOW_TO_IMPORT.md            # Import guide
│   ├── QUICKSTART.md               # Quick setup guide
│   ├── IMPLEMENTATION_GUIDE.md     # Detailed implementation
│   └── IMPORT_FIXES.md             # Technical fixes
└── README.md
```

**Note:** The root directory contains ONLY Dialogflow CX agent files. This allows you to import the agent directly from the repository without extra files interfering.

## Prerequisites

- Google Cloud Platform account
- Dialogflow CX API enabled
- Twilio account with WhatsApp enabled
- Node.js 18 or higher
- Google Cloud SDK (gcloud CLI)

## Setup Instructions

### 1. Google Cloud Setup

```bash
# Authenticate with Google Cloud
gcloud auth login

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable dialogflow.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
```

### 2. Import Dialogflow CX Agent

**IMPORTANT:** The agent files must be imported into Dialogflow CX. Simply having them in the repository is not enough!

See **[docs/HOW_TO_IMPORT.md](docs/HOW_TO_IMPORT.md)** for detailed import instructions.

Quick method:
1. Go to [Dialogflow CX Console](https://dialogflow.cloud.google.com/cx)
2. Select your agent
3. Click ⚙️ (Settings) > Export and Import > Restore
4. Upload the repository as a ZIP file
5. Wait for import to complete

Or use the automated script:
```bash
cd deployment
./import-agent.sh
```

### 3. Deploy Webhooks

#### Playbook Handoff Webhook

```bash
cd deployment/webhooks/playbook-handoff

# Install dependencies
npm install

# Set environment variables
export PLAYBOOK_API_ENDPOINT="https://your-playbook-api.com/handoff"
export PLAYBOOK_API_KEY="your-api-key"

# Deploy to Google Cloud Functions
gcloud functions deploy playbookHandoff \
  --runtime nodejs18 \
  --trigger-http \
  --allow-unauthenticated \
  --set-env-vars PLAYBOOK_API_ENDPOINT=$PLAYBOOK_API_ENDPOINT,PLAYBOOK_API_KEY=$PLAYBOOK_API_KEY \
  --region us-central1
```

#### WhatsApp Integration Webhook

```bash
cd deployment/webhooks/whatsapp-integration

# Install dependencies
npm install

# Set environment variables
export TWILIO_ACCOUNT_SID="your-twilio-sid"
export TWILIO_AUTH_TOKEN="your-twilio-token"
export DIALOGFLOW_PROJECT_ID="your-project-id"
export DIALOGFLOW_AGENT_ID="your-agent-id"

# Deploy to Google Cloud Functions
gcloud functions deploy whatsappWebhook \
  --runtime nodejs18 \
  --trigger-http \
  --allow-unauthenticated \
  --set-env-vars TWILIO_ACCOUNT_SID=$TWILIO_ACCOUNT_SID,TWILIO_AUTH_TOKEN=$TWILIO_AUTH_TOKEN,DIALOGFLOW_PROJECT_ID=$DIALOGFLOW_PROJECT_ID,DIALOGFLOW_AGENT_ID=$DIALOGFLOW_AGENT_ID \
  --region us-central1
```

### 4. Configure Twilio WhatsApp

1. Log in to Twilio Console
2. Navigate to Messaging > Settings > WhatsApp sandbox
3. Set webhook URL to your deployed whatsappWebhook function
4. Method: POST
5. Save configuration

### 5. Configure Response Variables

Update the following placeholders in flow responses:

- `[שם החברה]` - Your company name
- `[שם הפרויקט]` - Project name
- `[מיקום]` - Project location
- `[תאריך]` - Move-in date
- `[שלב בנייה]` - Construction stage
- `[PRICE_3BR]` - 3 bedroom price
- `[PRICE_4BR]` - 4 bedroom price
- `[PRICE_5BR]` - 5 bedroom price

## Testing

### Run Automated Tests

```bash
cd deployment/tests

# Install dependencies
npm install @google-cloud/dialogflow-cx

# Set environment variables
export DIALOGFLOW_PROJECT_ID="your-project-id"
export DIALOGFLOW_LOCATION="us-central1"
export DIALOGFLOW_AGENT_ID="your-agent-id"

# Run tests
node test-runner.js
```

### Manual Testing via Dialogflow Console

1. Go to Dialogflow CX Console
2. Select your agent
3. Use the Test Agent panel on the right
4. Test with Hebrew inputs from test-cases.json

### Test Cases Coverage

- 18 individual intent test cases
- 3 conversation flow scenarios
- Covers all 10 primary intents
- Tests fallback handling
- Validates session parameter tracking

## Monitoring and Analytics

### Key Metrics to Track

1. Intent Recognition Rate (target: >85%)
2. Fallback Rate (target: <15%)
3. Average Response Time (target: <3s)
4. Conversation Completion Rate (target: >40%)
5. Lead Qualification Rate

### Enable Logging

```bash
# Enable Cloud Logging for your functions
gcloud functions logs read whatsappWebhook --limit 50
gcloud functions logs read playbookHandoff --limit 50
```

### BigQuery Integration

Export Dialogflow CX conversations to BigQuery for advanced analytics:

1. Go to Dialogflow CX Console
2. Navigate to Agent Settings > Logging
3. Enable BigQuery export
4. Configure dataset and table

## Deployment Checklist

### Pre-Launch

- [ ] All 10 primary intents configured
- [ ] Training phrases uploaded (50+ per intent)
- [ ] Fallback responses configured
- [ ] Session parameters validated
- [ ] Playbook integration tested
- [ ] WhatsApp webhook connected
- [ ] Hebrew text rendering verified
- [ ] Response timing optimized
- [ ] Error handling implemented
- [ ] Update all placeholder variables

### Launch

- [ ] Start with small user group (beta)
- [ ] Monitor intent recognition
- [ ] Check response quality
- [ ] Verify handoff to Playbook works
- [ ] Collect user feedback

### Post-Launch

- [ ] Daily monitoring for first week
- [ ] Weekly intent model retraining
- [ ] Monthly performance review
- [ ] Continuous A/B testing
- [ ] Regular updates based on conversations

## Maintenance

### Weekly Tasks

- Review unrecognized messages
- Add new training phrases
- Adjust confidence thresholds
- Update response templates if needed

### Monthly Tasks

- Analyze conversation patterns
- Retrain ML models
- Update Playbook integration
- Review and update pricing/details
- A/B test new response variations

### Quarterly Tasks

- Full agent performance review
- Major updates to responses
- New feature additions
- User satisfaction survey analysis

## Troubleshooting

### Common Issues

**Issue: Low intent recognition**
- Solution: Add more training phrases, especially edge cases
- Check classification threshold (currently 0.3)

**Issue: Webhook timeouts**
- Solution: Increase function timeout in Cloud Functions
- Optimize webhook response time

**Issue: Hebrew text not displaying correctly**
- Solution: Ensure UTF-8 encoding in all files
- Verify Twilio WhatsApp supports Hebrew (it does)

**Issue: Session parameters not persisting**
- Solution: Implement database storage for session state
- Use Cloud Firestore or similar

## Security Considerations

- Webhook endpoints should validate Twilio signatures
- Store API keys in Google Secret Manager
- Never commit credentials to git
- Use IAM for function access control
- Implement rate limiting on webhooks

## Cost Estimates

### Google Cloud Platform

- Dialogflow CX: Pay per session
- Cloud Functions: Pay per invocation
- Cloud Logging: Free tier available

### Twilio

- WhatsApp conversation pricing varies by region
- Check Twilio pricing for Israel/Hebrew markets

## Support and Contact

For issues or questions:

1. Check this README
2. Review test cases for examples
3. Check Google Cloud logs
4. Contact development team

## License

[Your License Here]

## Version History

- v1.0.0 (2025-11-27): Initial release
  - 10 primary intents
  - WhatsApp integration via Twilio
  - Playbook handoff webhook
  - Comprehensive test suite
  - Hebrew language support
