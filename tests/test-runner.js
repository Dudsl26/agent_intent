/**
 * Intent Test Runner
 *
 * Automated testing script for Dialogflow CX intents
 * Run with: node tests/test-runner.js
 */

const { SessionsClient } = require('@google-cloud/dialogflow-cx');
const fs = require('fs');
const path = require('path');

// Configuration
const PROJECT_ID = process.env.DIALOGFLOW_PROJECT_ID || 'your-project-id';
const LOCATION = process.env.DIALOGFLOW_LOCATION || 'us-central1';
const AGENT_ID = process.env.DIALOGFLOW_AGENT_ID || 'your-agent-id';
const TEST_SESSION_ID = 'test-session-' + Date.now();

// Load test cases
const testCasesPath = path.join(__dirname, 'intent-test-cases.json');
const testData = JSON.parse(fs.readFileSync(testCasesPath, 'utf8'));

// Initialize Dialogflow client
const sessionClient = new SessionsClient();

// Test results
const results = {
  passed: 0,
  failed: 0,
  total: 0,
  details: []
};

/**
 * Detect intent for a given input
 */
async function detectIntent(text, sessionId = TEST_SESSION_ID) {
  const sessionPath = sessionClient.projectLocationAgentSessionPath(
    PROJECT_ID,
    LOCATION,
    AGENT_ID,
    sessionId
  );

  const request = {
    session: sessionPath,
    queryInput: {
      text: {
        text: text,
      },
      languageCode: 'he-il',
    },
  };

  const [response] = await sessionClient.detectIntent(request);
  return response.queryResult;
}

/**
 * Check if response contains expected text
 */
function checkResponseContains(responseText, expectedPhrases) {
  for (const phrase of expectedPhrases) {
    if (responseText.includes(phrase)) {
      return true;
    }
  }
  return false;
}

/**
 * Run a single test case
 */
async function runTestCase(testCase) {
  console.log(`\nRunning: ${testCase.name} (${testCase.id})`);
  console.log(`Input: "${testCase.input}"`);

  try {
    const result = await detectIntent(testCase.input);

    // Extract intent name
    const intentName = result.intent?.displayName || 'no-match';
    const responseText = result.responseMessages?.[0]?.text?.text?.[0] || '';
    const parameters = result.parameters || {};

    console.log(`  Detected Intent: ${intentName}`);
    console.log(`  Expected Intent: ${testCase.expectedIntent}`);

    // Check intent match
    const intentMatch = intentName === testCase.expectedIntent;

    // Check response contains expected phrases
    const responseMatch = checkResponseContains(
      responseText,
      testCase.expectedResponseContains || []
    );

    // Check parameters (basic check)
    let paramsMatch = true;
    if (testCase.expectedParameters) {
      for (const [key, value] of Object.entries(testCase.expectedParameters)) {
        if (parameters[key] !== value) {
          paramsMatch = false;
          console.log(`  Parameter mismatch: ${key} = ${parameters[key]} (expected: ${value})`);
        }
      }
    }

    const passed = intentMatch && responseMatch;

    results.total++;
    if (passed) {
      results.passed++;
      console.log(`  ✓ PASSED`);
    } else {
      results.failed++;
      console.log(`  ✗ FAILED`);
      if (!intentMatch) console.log(`    - Intent mismatch`);
      if (!responseMatch) console.log(`    - Response doesn't contain expected phrases`);
    }

    results.details.push({
      id: testCase.id,
      name: testCase.name,
      passed,
      intentMatch,
      responseMatch,
      paramsMatch,
      detectedIntent: intentName,
      response: responseText
    });

    return passed;

  } catch (error) {
    console.error(`  ✗ ERROR: ${error.message}`);
    results.failed++;
    results.total++;

    results.details.push({
      id: testCase.id,
      name: testCase.name,
      passed: false,
      error: error.message
    });

    return false;
  }
}

/**
 * Run conversation flow test
 */
async function runConversationFlow(flow) {
  console.log(`\n\n=== Testing Conversation Flow: ${flow.name} (${flow.id}) ===`);

  const flowSessionId = `flow-test-${flow.id}-${Date.now()}`;
  let allPassed = true;

  for (const step of flow.steps) {
    console.log(`\nStep ${step.step}: "${step.userInput}"`);

    try {
      const result = await detectIntent(step.userInput, flowSessionId);
      const intentName = result.intent?.displayName || 'no-match';

      console.log(`  Detected Intent: ${intentName}`);
      console.log(`  Expected Intent: ${step.expectedIntent}`);

      const passed = intentName === step.expectedIntent;

      if (passed) {
        console.log(`  ✓ Step passed`);
      } else {
        console.log(`  ✗ Step failed`);
        allPassed = false;
      }

      // Small delay between steps to simulate real conversation
      await new Promise(resolve => setTimeout(resolve, 500));

    } catch (error) {
      console.error(`  ✗ Error in step: ${error.message}`);
      allPassed = false;
    }
  }

  console.log(`\nFlow Result: ${allPassed ? '✓ PASSED' : '✗ FAILED'}`);
  return allPassed;
}

/**
 * Main test runner
 */
async function runAllTests() {
  console.log('========================================');
  console.log('Dialogflow CX Intent Testing');
  console.log('========================================');
  console.log(`Project: ${PROJECT_ID}`);
  console.log(`Agent: ${AGENT_ID}`);
  console.log(`Location: ${LOCATION}`);
  console.log('========================================\n');

  // Run individual test cases
  console.log('Running Individual Test Cases...\n');
  for (const testCase of testData.testCases) {
    await runTestCase(testCase);
    // Small delay between tests
    await new Promise(resolve => setTimeout(resolve, 300));
  }

  // Run conversation flows
  console.log('\n\nRunning Conversation Flow Tests...\n');
  for (const flow of testData.conversationFlows) {
    await runConversationFlow(flow);
    await new Promise(resolve => setTimeout(resolve, 1000));
  }

  // Print summary
  console.log('\n\n========================================');
  console.log('TEST SUMMARY');
  console.log('========================================');
  console.log(`Total Tests: ${results.total}`);
  console.log(`Passed: ${results.passed}`);
  console.log(`Failed: ${results.failed}`);
  console.log(`Success Rate: ${((results.passed / results.total) * 100).toFixed(2)}%`);
  console.log('========================================\n');

  // Save detailed results
  const resultsPath = path.join(__dirname, 'test-results.json');
  fs.writeFileSync(
    resultsPath,
    JSON.stringify(results, null, 2),
    'utf8'
  );
  console.log(`Detailed results saved to: ${resultsPath}\n`);

  // Exit with appropriate code
  process.exit(results.failed > 0 ? 1 : 0);
}

// Run tests
runAllTests().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
