/**
 * Playbook Handoff Webhook
 *
 * This webhook handles the transition from initial lead qualification
 * to the detailed conversation Playbook.
 *
 * Triggers when:
 * - User has exchanged 3+ messages
 * - Interest level is medium-high or high
 * - User asks complex questions
 */

const functions = require('@google-cloud/functions-framework');
const axios = require('axios');

// Configuration - Update these with your actual values
const PLAYBOOK_API_ENDPOINT = process.env.PLAYBOOK_API_ENDPOINT || 'https://your-playbook-endpoint.com/api/handoff';
const PLAYBOOK_API_KEY = process.env.PLAYBOOK_API_KEY || 'your_api_key_here';
const PROJECT_NAME = process.env.PROJECT_NAME || '[שם הפרויקט]';
const PROJECT_LOCATION = process.env.PROJECT_LOCATION || '[מיקום]';

/**
 * Check if conversation should be handed off to Playbook
 */
function shouldHandoffToPlaybook(sessionParams) {
  const messagesCount = sessionParams.messages_count || 0;
  const interestLevel = sessionParams.interest_level || 'unknown';

  // Conditions for handoff
  const hasEnoughMessages = messagesCount >= 3;
  const highInterest = ['medium-high', 'high'].includes(interestLevel);
  const complexQuestion = sessionParams.detail_oriented || sessionParams.timing_important;

  return hasEnoughMessages || highInterest || (complexQuestion && messagesCount >= 2);
}

/**
 * Prepare conversation context for Playbook
 */
function preparePlaybookData(sessionParams) {
  return {
    phone: sessionParams.phone_number,
    name: sessionParams.user_name,
    interest_level: sessionParams.interest_level,
    conversation_context: {
      initial_response: sessionParams.initial_response,
      messages_exchanged: sessionParams.messages_count,
      topics_discussed: sessionParams.topics_discussed || [],
      timestamp: sessionParams.conversation_start,
      project_name: PROJECT_NAME,
      project_location: PROJECT_LOCATION
    },
    lead_qualification: {
      status: sessionParams.lead_status,
      price_sensitivity: sessionParams.price_sensitivity,
      timing_important: sessionParams.timing_important,
      detail_oriented: sessionParams.detail_oriented,
      location_important: sessionParams.location_important,
      wants_catalog: sessionParams.wants_catalog,
      needs_reintroduction: sessionParams.needs_reintroduction,
      follow_up_needed: sessionParams.follow_up_needed,
      potential_referral: sessionParams.potential_referral
    }
  };
}

/**
 * Main webhook handler
 */
functions.http('playbookHandoff', async (req, res) => {
  try {
    const tag = req.body.fulfillmentInfo?.tag;

    // Only process if this is a handoff request
    if (tag !== 'playbook-handoff') {
      return res.status(200).json({});
    }

    const sessionInfo = req.body.sessionInfo || {};
    const sessionParams = sessionInfo.parameters || {};

    // Check if handoff is needed
    if (!shouldHandoffToPlaybook(sessionParams)) {
      return res.status(200).json({
        sessionInfo: {
          parameters: {
            messages_count: (sessionParams.messages_count || 0) + 1
          }
        }
      });
    }

    // Prepare data for Playbook
    const playbookData = preparePlaybookData(sessionParams);

    // Call Playbook API
    let playbookResponse;
    try {
      playbookResponse = await axios.post(
        PLAYBOOK_API_ENDPOINT,
        playbookData,
        {
          headers: {
            'Authorization': `Bearer ${PLAYBOOK_API_KEY}`,
            'Content-Type': 'application/json'
          },
          timeout: 10000 // 10 second timeout
        }
      );
    } catch (apiError) {
      console.error('Playbook API error:', apiError.message);

      // Fallback response if Playbook API fails
      return res.status(200).json({
        fulfillmentResponse: {
          messages: [{
            text: {
              text: ['מעולה! אשמח להמשיך ולעזור לך עם כל הפרטים.\n\nמה הכי חשוב לך לדעת קודם?']
            }
          }]
        },
        sessionInfo: {
          parameters: {
            handoff_attempted: true,
            handoff_failed: true
          }
        }
      });
    }

    // Successful handoff
    return res.status(200).json({
      fulfillmentResponse: {
        messages: [{
          text: {
            text: ['מעולה! יש לי כאן את כל הפרטים בשבילך.\n\nמה הכי חשוב לך לדעת קודם?\n- מחירים מדויקים\n- מפרט מלא\n- אפשרויות מימון\n- תיאום ביקור בדוגמא']
          }
        }]
      },
      sessionInfo: {
        parameters: {
          playbook_session_id: playbookResponse.data.session_id || null,
          handed_off: true,
          handoff_timestamp: new Date().toISOString()
        }
      }
    });

  } catch (error) {
    console.error('Webhook error:', error);

    // Return error response
    return res.status(500).json({
      fulfillmentResponse: {
        messages: [{
          text: {
            text: ['מצטער, נתקלתי בבעיה טכנית. אשמח אם תנסה שוב או תשאיר פרטים ליצירת קשר.']
          }
        }]
      }
    });
  }
});

module.exports = { playbookHandoff: functions.http('playbookHandoff') };
