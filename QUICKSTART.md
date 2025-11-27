# Quick Start Guide

Get your Real Estate Lead Qualification Agent running in 30 minutes.

## Prerequisites

- Google Cloud account with billing enabled
- Twilio account
- Node.js 18+ installed
- Git installed

## Step 1: Clone and Configure (5 minutes)

```bash
# Navigate to project directory
cd agent_intent

# Copy environment template
cp .env.example .env

# Edit .env with your credentials
nano .env  # or use your preferred editor
```

Required values in `.env`:
- PROJECT_ID: Your Google Cloud project ID
- TWILIO_ACCOUNT_SID: From Twilio Console
- TWILIO_AUTH_TOKEN: From Twilio Console
- DIALOGFLOW_AGENT_ID: Will get after import

## Step 2: Setup Google Cloud (10 minutes)

```bash
# Authenticate
gcloud auth login

# Set project
gcloud config set project YOUR_PROJECT_ID

# Enable APIs
gcloud services enable dialogflow.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
```

## Step 3: Import Dialogflow CX Agent (5 minutes)

### Option A: Using Console (Recommended)

1. Go to https://dialogflow.cloud.google.com/cx
2. Click "Create Agent" or select existing
3. Use agent settings to restore/import
4. Upload the agent configuration from this directory
5. Copy the Agent ID from settings
6. Update DIALOGFLOW_AGENT_ID in .env

### Option B: Manual Setup

1. Create new agent in Dialogflow CX Console
2. Set language to Hebrew (he-il)
3. Import intents manually from `intents/` directory
4. Import flows from `flows/` directory

## Step 4: Deploy Webhooks (5 minutes)

```bash
# Make deploy script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

This will:
- Deploy Playbook handoff webhook
- Deploy WhatsApp integration webhook
- Print webhook URL for Twilio

Copy the webhook URL from output.

## Step 5: Configure Twilio WhatsApp (5 minutes)

### Using WhatsApp Sandbox (Testing)

1. Go to Twilio Console
2. Navigate: Messaging > Try it out > Send a WhatsApp message
3. Follow instructions to join sandbox
4. Go to: Messaging > Settings > WhatsApp sandbox settings
5. Under "When a message comes in":
   - Paste your webhook URL
   - Method: POST
6. Save

### Using Production WhatsApp Number

1. Request WhatsApp Business API access from Twilio
2. Configure your WhatsApp Business number
3. Set webhook URL in number settings

## Step 6: Update Project Variables (2 minutes)

Edit `flows/Lead Qualification Flow/Lead Qualification Flow.json` and replace:

- `[שם החברה]` → Your company name
- `[שם הפרויקט]` → Project name
- `[מיקום]` → Location
- `[תאריך]` → Move-in date
- `[שלב בנייה]` → Construction stage
- `[PRICE_3BR]` → 3BR price
- `[PRICE_4BR]` → 4BR price
- `[PRICE_5BR]` → 5BR price

Then re-import the flow in Dialogflow CX Console.

## Step 7: Test (3 minutes)

### Test in Dialogflow Console

1. Open Dialogflow CX Console
2. Use "Test Agent" panel on right
3. Try Hebrew inputs:
   - "כן אשמח לשמוע"
   - "כמה זה עולה?"
   - "איפה זה?"

### Test via WhatsApp

1. Send WhatsApp message to Twilio sandbox number
2. Follow join instructions
3. Send: "כן אשמח לשמוע"
4. Agent should respond in Hebrew

## Verification Checklist

- [ ] Agent responds in Hebrew
- [ ] Intents are recognized correctly
- [ ] Session parameters are captured
- [ ] WhatsApp messages work both ways
- [ ] Responses don't contain emojis (as requested)
- [ ] Webhook logs show successful calls

## View Logs

```bash
# WhatsApp webhook logs
gcloud functions logs read whatsappWebhook --limit 50

# Playbook webhook logs
gcloud functions logs read playbookHandoff --limit 50
```

## Common Issues

### Issue: Agent not responding

**Check:**
1. Webhook URL correct in Twilio?
2. Function deployed successfully?
3. Environment variables set correctly?

**Fix:**
```bash
# Redeploy webhook
cd webhooks/whatsapp-integration
gcloud functions deploy whatsappWebhook --runtime nodejs18 --trigger-http
```

### Issue: Wrong language responses

**Check:**
1. Agent language set to he-il?
2. Training phrases in Hebrew?

**Fix:**
Update agent.json language setting and reimport.

### Issue: Intent not recognized

**Check:**
1. Training phrases uploaded?
2. Classification threshold too high?

**Fix:**
Lower threshold in flow settings (currently 0.3).

## Next Steps

After successful setup:

1. Run automated tests:
   ```bash
   cd tests
   npm install
   export DIALOGFLOW_PROJECT_ID=your-project-id
   export DIALOGFLOW_AGENT_ID=your-agent-id
   node test-runner.js
   ```

2. Monitor conversations:
   - Enable BigQuery export in Dialogflow settings
   - Track key metrics (see README.md)

3. Optimize:
   - Add more training phrases based on real conversations
   - Adjust response templates
   - Fine-tune session parameters

4. Scale:
   - Move from Twilio sandbox to production number
   - Set up monitoring and alerts
   - Implement database for session persistence

## Support

If you encounter issues:

1. Check logs: `gcloud functions logs read FUNCTION_NAME`
2. Review README.md for detailed documentation
3. Check test cases in `tests/intent-test-cases.json`
4. Verify environment variables in .env

## Production Readiness

Before going live:

- [ ] Replace all placeholder variables
- [ ] Test all 10 intents
- [ ] Set up monitoring and alerts
- [ ] Configure production WhatsApp number
- [ ] Enable BigQuery export
- [ ] Set up backup webhooks
- [ ] Test Playbook handoff integration
- [ ] Create runbook for common issues
- [ ] Train support team

Estimated time to production: 2-4 hours of testing and refinement.
