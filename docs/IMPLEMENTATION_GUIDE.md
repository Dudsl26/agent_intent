# Implementation Guide - Dialogflow CX Real Estate Agent

This guide provides detailed implementation instructions for developers.

## Architecture Overview

### Components

1. **Dialogflow CX Agent**
   - 10 custom intents for lead qualification
   - Hebrew language processing
   - Session parameter management
   - Flow-based conversation design

2. **WhatsApp Integration**
   - Twilio as messaging platform
   - Webhook for incoming messages
   - Real-time conversation handling

3. **Playbook Handoff**
   - Webhook for qualifying leads
   - Automatic transition logic
   - Context preservation

### Data Flow

```
User (WhatsApp)
  → Twilio Platform
    → WhatsApp Webhook (Cloud Function)
      → Dialogflow CX Agent
        → Intent Detection
          → Response Generation
            → Session Parameter Update
              → [If qualified] Playbook Handoff Webhook
                → Playbook System
```

## Intent Implementation Details

### Intent Structure

Each intent consists of:

1. **Intent Definition** (`intent.json`)
   - name: Unique identifier
   - displayName: Human-readable name
   - priority: Intent matching priority
   - labels: Metadata for analytics
   - description: Intent purpose

2. **Training Phrases** (`trainingPhrases/he-il.json`)
   - Array of example user inputs
   - Hebrew language variations
   - Different phrasings of same intent

3. **Flow Route**
   - Intent trigger
   - Response messages
   - Parameter actions
   - Transition logic

### Example: Implementing a New Intent

```javascript
// 1. Create intent directory
mkdir -p intents/new_intent/trainingPhrases

// 2. Create intent definition
{
  "name": "new_intent",
  "displayName": "new_intent",
  "priority": 500000,
  "labels": {
    "category": "qualification"
  },
  "description": "Description of what triggers this intent"
}

// 3. Add training phrases
[
  {
    "id": "unique-id-1",
    "parts": [{"text": "Hebrew phrase"}],
    "repeatCount": 1,
    "languageCode": "he-il"
  }
]

// 4. Add route to flow
{
  "intent": "new_intent",
  "triggerFulfillment": {
    "messages": [{
      "text": {
        "text": ["Hebrew response"]
      },
      "languageCode": "he-il"
    }],
    "setParameterActions": [{
      "parameter": "param_name",
      "value": "param_value"
    }]
  }
}
```

## Session Parameter Management

### Parameter Types

1. **User Information**
   - phone_number: From WhatsApp
   - user_name: Extracted from conversation

2. **Qualification Metrics**
   - interest_level: Scored based on interactions
   - lead_status: Current lead state
   - *_important flags: User priorities

3. **Conversation Tracking**
   - messages_count: Number of exchanges
   - conversation_start: Timestamp
   - topics_discussed: Array of subjects

### Parameter Lifecycle

```javascript
// 1. Parameter initialization (first message)
sessionParams = {
  phone_number: extractedFromWhatsApp,
  messages_count: 0,
  interest_level: "unknown"
}

// 2. Parameter updates (each intent)
setParameterActions: [
  {
    parameter: "interest_level",
    value: "high"
  }
]

// 3. Parameter usage (handoff decision)
if (sessionParams.interest_level === "high" ||
    sessionParams.messages_count >= 3) {
  triggerPlaybookHandoff();
}
```

## Webhook Development

### WhatsApp Integration Webhook

**Purpose**: Bridge between Twilio and Dialogflow CX

**Key Functions**:

1. **detectIntent(userPhone, userMessage, sessionParams)**
   - Calls Dialogflow CX API
   - Returns intent and response

2. **extractResponseText(dialogflowResponse)**
   - Parses response messages
   - Returns text for WhatsApp

3. **whatsappWebhook(req, res)**
   - Main HTTP handler
   - Validates Twilio signature
   - Processes messages

**Error Handling**:

```javascript
try {
  const response = await detectIntent(phone, message);
  sendToWhatsApp(response);
} catch (error) {
  // Fallback response
  sendToWhatsApp("מצטער, נתקלתי בבעיה. נסה שוב.");
  logError(error);
}
```

### Playbook Handoff Webhook

**Purpose**: Qualify and transfer leads to detailed conversation system

**Key Functions**:

1. **shouldHandoffToPlaybook(sessionParams)**
   - Evaluates qualification criteria
   - Returns boolean decision

2. **preparePlaybookData(sessionParams)**
   - Structures data for Playbook API
   - Includes full context

3. **playbookHandoff(req, res)**
   - Main HTTP handler
   - Calls Playbook API
   - Updates session state

**Handoff Logic**:

```javascript
function shouldHandoffToPlaybook(params) {
  return (
    params.messages_count >= 3 ||
    ['medium-high', 'high'].includes(params.interest_level) ||
    (params.detail_oriented && params.messages_count >= 2)
  );
}
```

## Testing Strategy

### Unit Tests

Test individual components:

```javascript
// Test intent detection
describe('Intent Detection', () => {
  it('should recognize interested intent', async () => {
    const result = await detectIntent('כן אשמח');
    expect(result.intent.displayName).to.equal('interested');
  });
});
```

### Integration Tests

Test full flows:

```javascript
// Test conversation flow
describe('Conversation Flow', () => {
  it('should qualify high-interest lead', async () => {
    await sendMessage('כן אשמח');
    await sendMessage('מה המחיר?');
    await sendMessage('מתי כניסה?');

    const session = await getSession();
    expect(session.interest_level).to.equal('high');
    expect(session.handed_off).to.be.true;
  });
});
```

### Manual Testing

Use test cases from `tests/intent-test-cases.json`:

1. Test each intent individually
2. Test conversation flows
3. Test edge cases (fallback, confusion)
4. Test parameter tracking

## Deployment Process

### Development Environment

```bash
# Local testing
npm install
npm start

# Test locally
curl -X POST localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{"body": "test message"}'
```

### Staging Environment

```bash
# Deploy to staging
gcloud functions deploy whatsappWebhook-staging \
  --runtime nodejs18 \
  --trigger-http

# Test with staging Twilio number
```

### Production Environment

```bash
# Deploy to production
./deploy.sh

# Monitor deployment
gcloud functions logs read whatsappWebhook --limit 100
```

## Monitoring and Observability

### Logging

```javascript
// Structured logging
console.log(JSON.stringify({
  severity: 'INFO',
  message: 'Intent detected',
  intent: intentName,
  phone: userPhone,
  timestamp: new Date().toISOString()
}));
```

### Metrics to Track

1. **Intent Recognition**
   - Total intents detected
   - Intent distribution
   - Fallback rate

2. **Conversation Quality**
   - Average conversation length
   - Handoff success rate
   - Response time

3. **Lead Qualification**
   - Interest level distribution
   - Conversion to Playbook
   - Lead status breakdown

### Alerts

Set up alerts for:

- High error rate (>5%)
- Slow response time (>5s)
- High fallback rate (>20%)
- Webhook failures

## Performance Optimization

### Response Time

```javascript
// Use Promise.all for parallel operations
const [userProfile, projectData] = await Promise.all([
  getUserProfile(phone),
  getProjectData()
]);
```

### Caching

```javascript
// Cache frequently accessed data
const NodeCache = require('node-cache');
const cache = new NodeCache({ stdTTL: 600 });

function getProjectInfo() {
  const cached = cache.get('project_info');
  if (cached) return cached;

  const info = fetchFromDatabase();
  cache.set('project_info', info);
  return info;
}
```

### Memory Management

```javascript
// Limit session data size
function pruneSessionData(params) {
  // Keep only essential parameters
  return {
    phone_number: params.phone_number,
    interest_level: params.interest_level,
    // ... other essential params
  };
}
```

## Security Best Practices

### 1. Validate Twilio Requests

```javascript
const twilio = require('twilio');

function validateTwilioRequest(req) {
  const signature = req.headers['x-twilio-signature'];
  const url = getFullUrl(req);

  return twilio.validateRequest(
    TWILIO_AUTH_TOKEN,
    signature,
    url,
    req.body
  );
}
```

### 2. Secure Environment Variables

```bash
# Use Secret Manager
gcloud secrets create TWILIO_AUTH_TOKEN \
  --data-file=- < token.txt

# Reference in function
--set-secrets=TWILIO_AUTH_TOKEN=TWILIO_AUTH_TOKEN:latest
```

### 3. Rate Limiting

```javascript
// Simple rate limiting
const rateLimiter = new Map();

function checkRateLimit(phone) {
  const now = Date.now();
  const userRequests = rateLimiter.get(phone) || [];

  // Clean old requests
  const recent = userRequests.filter(t => now - t < 60000);

  if (recent.length >= 10) {
    return false; // Too many requests
  }

  recent.push(now);
  rateLimiter.set(phone, recent);
  return true;
}
```

### 4. Input Sanitization

```javascript
function sanitizeInput(text) {
  // Remove potentially harmful content
  return text
    .trim()
    .substring(0, 1000) // Limit length
    .replace(/<script>/gi, ''); // Basic XSS prevention
}
```

## Troubleshooting Guide

### Intent Not Recognized

**Symptoms**: Agent responds with fallback message

**Diagnosis**:
```bash
# Check intent training phrases
cat intents/INTENT_NAME/trainingPhrases/he-il.json

# Check classification threshold
grep classificationThreshold flows/*/
```

**Solution**:
1. Add more training phrases
2. Lower classification threshold
3. Check for typos in Hebrew

### Webhook Timeout

**Symptoms**: "Function execution took too long"

**Diagnosis**:
```bash
# Check function logs
gcloud functions logs read whatsappWebhook --limit 50

# Check timeout setting
gcloud functions describe whatsappWebhook --format="value(timeout)"
```

**Solution**:
1. Increase timeout: `--timeout 60s`
2. Optimize API calls
3. Add caching

### Session Parameters Not Persisting

**Symptoms**: Parameters reset between messages

**Diagnosis**:
- Check session ID consistency
- Verify parameter actions in flow
- Check for session clearing events

**Solution**:
1. Use consistent session ID (phone number)
2. Implement external session storage
3. Verify parameter setting in flows

## Contributing

When adding new features:

1. Create feature branch
2. Add intent/flow definitions
3. Add training phrases (minimum 20)
4. Add test cases
5. Update documentation
6. Submit for review

## Maintenance Schedule

### Daily
- Monitor error logs
- Check response times
- Review fallback messages

### Weekly
- Analyze intent distribution
- Add new training phrases
- Update response templates

### Monthly
- Review session parameters
- Optimize performance
- Update documentation
- Retrain ML models

## Additional Resources

- [Dialogflow CX Documentation](https://cloud.google.com/dialogflow/cx/docs)
- [Twilio WhatsApp API](https://www.twilio.com/docs/whatsapp/api)
- [Google Cloud Functions](https://cloud.google.com/functions/docs)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
