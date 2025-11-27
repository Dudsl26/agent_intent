# How to Import Your Agent to Dialogflow CX

## The Problem

When you look at your Dialogflow CX console, you only see the basic Default Start Flow because **the agent configuration files haven't been imported yet**.

Your repository contains:
- ✅ 11 intents (interested, request_price, etc.)
- ✅ 2 flows (Default Start Flow, Lead Qualification Flow)
- ✅ Session parameters
- ✅ Agent configuration

But these exist only in your code repository - not in Dialogflow CX yet!

## The Solution

You need to **import (restore)** the agent into Dialogflow CX. Here are two methods:

---

## Method 1: Using Dialogflow CX Console (Easiest)

### Step 1: Get your agent details
You need:
- **Agent ID**: `0b8d08be-74ce-4d49-8aae-a1832d47b9df` (from screenshot)
- **Project**: `AIAgentRealEstate` or `test_for_intents`

### Step 2: Import the agent

1. **Go to Dialogflow CX Console**
   - Open: https://dialogflow.cloud.google.com/cx/projects

2. **Select your agent**
   - Click on `test_for_intents` agent

3. **Open Agent Settings**
   - Click the ⚙️ gear icon next to the agent name (top left)

4. **Go to Export and Import**
   - Click the "Export and Import" tab

5. **Restore the agent**
   - Click **"Restore"**
   - Select **"Upload"**
   - Choose the file: `/home/user/agent_intent.zip` (already created for you)
   - Click **"Restore"**

6. **Wait for completion** (1-2 minutes)

### Step 3: Verify the import

After import completes:
1. Go back to the Build tab
2. Check "Intents" - you should see 11 intents
3. Check "Flows" - you should see 2 flows
4. Open "Default Start Flow" - you should see multiple routes now

---

## Method 2: Using Command Line (Automated)

### Prerequisites
First, create and configure your `.env` file:

```bash
cp .env.example .env
nano .env  # Edit with your settings
```

Required values in `.env`:
```
PROJECT_ID=aiagentrealestate
DIALOGFLOW_AGENT_ID=0b8d08be-74ce-4d49-8aae-a1832d47b9df
DIALOGFLOW_LOCATION=global
```

### Run the import script

```bash
# Make sure you're in the agent_intent directory
cd /home/user/agent_intent

# Run the import script
./import-agent.sh
```

The script will:
1. ✅ Validate your configuration
2. ✅ Create the agent zip file
3. ✅ Upload it to Dialogflow CX
4. ✅ Wait for import to complete

---

## What Gets Imported?

After successful import, you'll have:

### Intents (11 total)
- ✅ Default Welcome Intent
- ✅ Default Negative Intent
- ✅ interested
- ✅ request_price
- ✅ request_details
- ✅ request_location
- ✅ not_interested
- ✅ not_now
- ✅ already_purchased
- ✅ confusion
- ✅ request_specs
- ✅ timing_question

### Flows (2 total)
- ✅ Default Start Flow (with routes and event handlers)
- ✅ Lead Qualification Flow (with all pages and transitions)

### Session Parameters
All 18 session parameters for tracking:
- phone_number, user_name, interest_level, etc.

### Training Phrases
- 130+ Hebrew training phrases across all intents

---

## Verification Checklist

After import, verify:

- [ ] All 11 intents appear in the Intents list
- [ ] Training phrases loaded for each intent
- [ ] Both flows appear in the Flows list
- [ ] Default Start Flow has multiple routes (not just Default Welcome Intent)
- [ ] Lead Qualification Flow has pages and transitions
- [ ] Session parameters are configured
- [ ] Test Agent responds correctly to Hebrew phrases

---

## Test Your Agent

After import, test with these Hebrew phrases in the "Test Agent" panel:

```
כן אשמח לשמוע          → Should trigger: interested
כמה זה עולה?           → Should trigger: request_price
איפה זה?               → Should trigger: request_location
תספר לי יותר פרטים      → Should trigger: request_details
לא מעניין אותי          → Should trigger: not_interested
לא עכשיו                → Should trigger: not_now
מי זה?                  → Should trigger: confusion
```

---

## Troubleshooting

### Issue: Import fails with "Permission Denied"
**Solution:**
```bash
# Authenticate with Google Cloud
gcloud auth login

# Set the project
gcloud config set project aiagentrealestate
```

### Issue: "Agent ID not found"
**Solution:**
- Verify the Agent ID in Dialogflow CX Console
- Update `DIALOGFLOW_AGENT_ID` in `.env`

### Issue: Still only see Default Welcome Intent
**Solution:**
- The import may not have completed
- Check Agent Settings > Export and Import for status
- Try importing again
- Make sure you're looking at the correct agent

### Issue: Hebrew text not displaying
**Solution:**
- This is normal - Hebrew displays correctly
- The files are UTF-8 encoded
- Test in the Test Agent panel to verify

---

## After Successful Import

Once imported, you can:

1. **Deploy webhooks:**
   ```bash
   ./deploy.sh
   ```

2. **Run tests:**
   ```bash
   cd tests
   npm install
   node test-runner.js
   ```

3. **Configure WhatsApp:**
   - Follow QUICKSTART.md steps 5-7

4. **Update response variables:**
   - Replace placeholder text like `[שם החברה]`

---

## Need Help?

- Check the import status in Dialogflow CX Console
- Review logs: `gcloud functions logs read`
- See IMPORT_FIXES.md for detailed technical info
- See QUICKSTART.md for full setup guide

---

## Summary

**The key point:** Your agent files exist in the repository but haven't been uploaded to Dialogflow CX yet. The import/restore process uploads all intents, flows, and configuration to make them available in the Dialogflow CX console.

After import, you'll see all your intents and flows in the UI instead of just the empty Default Start Flow!
