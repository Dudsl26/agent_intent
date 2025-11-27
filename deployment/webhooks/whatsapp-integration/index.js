/**
 * WhatsApp Integration via Twilio
 *
 * This webhook handles incoming WhatsApp messages and integrates
 * with Google Dialogflow CX for conversation management.
 */

const functions = require('@google-cloud/functions-framework');
const twilio = require('twilio');
const { SessionsClient } = require('@google-cloud/dialogflow-cx');

// Configuration - Update these with your actual values
const TWILIO_ACCOUNT_SID = process.env.TWILIO_ACCOUNT_SID;
const TWILIO_AUTH_TOKEN = process.env.TWILIO_AUTH_TOKEN;
const DIALOGFLOW_PROJECT_ID = process.env.DIALOGFLOW_PROJECT_ID || 'your-project-id';
const DIALOGFLOW_LOCATION = process.env.DIALOGFLOW_LOCATION || 'us-central1';
const DIALOGFLOW_AGENT_ID = process.env.DIALOGFLOW_AGENT_ID || 'your-agent-id';

// Initialize Dialogflow CX client
const sessionClient = new SessionsClient();

/**
 * Detect intent using Dialogflow CX
 */
async function detectIntent(userPhone, userMessage, sessionParams = {}) {
  const sessionPath = sessionClient.projectLocationAgentSessionPath(
    DIALOGFLOW_PROJECT_ID,
    DIALOGFLOW_LOCATION,
    DIALOGFLOW_AGENT_ID,
    userPhone // Use phone number as session ID
  );

  const request = {
    session: sessionPath,
    queryInput: {
      text: {
        text: userMessage,
      },
      languageCode: 'he-il',
    },
    queryParams: {
      parameters: sessionParams
    }
  };

  try {
    const [response] = await sessionClient.detectIntent(request);
    return response;
  } catch (error) {
    console.error('Dialogflow CX error:', error);
    throw error;
  }
}

/**
 * Extract response text from Dialogflow response
 */
function extractResponseText(dialogflowResponse) {
  const messages = dialogflowResponse.queryResult?.responseMessages || [];

  for (const message of messages) {
    if (message.text && message.text.text && message.text.text.length > 0) {
      return message.text.text[0];
    }
  }

  return 'מצטער, לא הצלחתי לעבד את ההודעה. נסה שוב בבקשה.';
}

/**
 * Extract session parameters from Dialogflow response
 */
function extractSessionParams(dialogflowResponse) {
  return dialogflowResponse.queryResult?.parameters || {};
}

/**
 * Main webhook handler for WhatsApp messages
 */
functions.http('whatsappWebhook', async (req, res) => {
  try {
    // Validate Twilio request
    const twilioSignature = req.headers['x-twilio-signature'];
    const url = `${req.protocol}://${req.get('host')}${req.originalUrl}`;

    if (!twilio.validateRequest(TWILIO_AUTH_TOKEN, twilioSignature, url, req.body)) {
      console.error('Invalid Twilio signature');
      return res.status(403).send('Forbidden');
    }

    // Extract message details
    const userMessage = req.body.Body || '';
    const userPhone = req.body.From || '';
    const userProfileName = req.body.ProfileName || '';

    console.log(`Received message from ${userPhone}: ${userMessage}`);

    // Get existing session parameters if any
    // In production, you might want to retrieve these from a database
    const sessionParams = {
      phone_number: userPhone,
      user_name: userProfileName || null,
      messages_count: 0 // This should be incremented from stored value
    };

    // Send typing indicator (optional)
    // Note: Twilio WhatsApp doesn't support typing indicators directly

    // Call Dialogflow CX
    const dialogflowResponse = await detectIntent(userPhone, userMessage, sessionParams);

    // Extract bot reply
    const botReply = extractResponseText(dialogflowResponse);

    // Extract updated session parameters
    const updatedParams = extractSessionParams(dialogflowResponse);

    // TODO: Store session parameters in database for next interaction
    // await storeSessionParams(userPhone, updatedParams);

    // Create Twilio response
    const twiml = new twilio.twiml.MessagingResponse();
    twiml.message(botReply);

    // Log conversation for analytics
    console.log(`Bot reply to ${userPhone}: ${botReply}`);
    console.log('Session params:', updatedParams);

    // Send response
    res.type('text/xml');
    res.send(twiml.toString());

  } catch (error) {
    console.error('WhatsApp webhook error:', error);

    // Send error message to user
    const twiml = new twilio.twiml.MessagingResponse();
    twiml.message('מצטער, נתקלתי בבעיה טכנית. אנא נסה שוב מאוחר יותר.');

    res.type('text/xml');
    res.send(twiml.toString());
  }
});

/**
 * Health check endpoint
 */
functions.http('healthCheck', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    service: 'whatsapp-dialogflow-integration',
    timestamp: new Date().toISOString()
  });
});

module.exports = {
  whatsappWebhook: functions.http('whatsappWebhook'),
  healthCheck: functions.http('healthCheck')
};
