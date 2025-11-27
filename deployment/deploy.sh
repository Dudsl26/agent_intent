#!/bin/bash

# Deployment Script for Real Estate Lead Qualification Agent
# This script automates the deployment process

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."

    # Check gcloud
    if ! command -v gcloud &> /dev/null; then
        print_error "gcloud CLI not found. Please install Google Cloud SDK."
        exit 1
    fi
    print_success "gcloud CLI found"

    # Check node
    if ! command -v node &> /dev/null; then
        print_error "Node.js not found. Please install Node.js 18 or higher."
        exit 1
    fi
    print_success "Node.js found"

    # Check npm
    if ! command -v npm &> /dev/null; then
        print_error "npm not found. Please install npm."
        exit 1
    fi
    print_success "npm found"
}

# Load configuration
load_config() {
    print_info "Loading configuration..."

    if [ ! -f ".env" ]; then
        print_error ".env file not found. Please create one from .env.example"
        exit 1
    fi

    source .env
    print_success "Configuration loaded"
}

# Enable required APIs
enable_apis() {
    print_info "Enabling required Google Cloud APIs..."

    gcloud services enable dialogflow.googleapis.com --project=$PROJECT_ID
    gcloud services enable cloudfunctions.googleapis.com --project=$PROJECT_ID
    gcloud services enable logging.googleapis.com --project=$PROJECT_ID

    print_success "APIs enabled"
}

# Deploy Playbook Handoff Webhook
deploy_playbook_webhook() {
    print_info "Deploying Playbook Handoff webhook..."

    cd webhooks/playbook-handoff

    # Install dependencies
    npm install

    # Deploy function
    gcloud functions deploy playbookHandoff \
        --runtime nodejs18 \
        --trigger-http \
        --allow-unauthenticated \
        --region $REGION \
        --project $PROJECT_ID \
        --set-env-vars PLAYBOOK_API_ENDPOINT=$PLAYBOOK_API_ENDPOINT,PLAYBOOK_API_KEY=$PLAYBOOK_API_KEY,PROJECT_NAME=$PROJECT_NAME,PROJECT_LOCATION=$PROJECT_LOCATION \
        --timeout 60s \
        --memory 256MB

    cd ../..

    print_success "Playbook webhook deployed"
}

# Deploy WhatsApp Integration Webhook
deploy_whatsapp_webhook() {
    print_info "Deploying WhatsApp Integration webhook..."

    cd webhooks/whatsapp-integration

    # Install dependencies
    npm install

    # Deploy function
    gcloud functions deploy whatsappWebhook \
        --runtime nodejs18 \
        --trigger-http \
        --allow-unauthenticated \
        --region $REGION \
        --project $PROJECT_ID \
        --set-env-vars TWILIO_ACCOUNT_SID=$TWILIO_ACCOUNT_SID,TWILIO_AUTH_TOKEN=$TWILIO_AUTH_TOKEN,DIALOGFLOW_PROJECT_ID=$DIALOGFLOW_PROJECT_ID,DIALOGFLOW_AGENT_ID=$DIALOGFLOW_AGENT_ID,DIALOGFLOW_LOCATION=$DIALOGFLOW_LOCATION \
        --timeout 30s \
        --memory 512MB

    cd ../..

    print_success "WhatsApp webhook deployed"

    # Print webhook URL
    WEBHOOK_URL=$(gcloud functions describe whatsappWebhook --region=$REGION --project=$PROJECT_ID --format='value(httpsTrigger.url)')
    echo ""
    print_info "WhatsApp Webhook URL: $WEBHOOK_URL"
    print_info "Configure this URL in your Twilio WhatsApp settings"
    echo ""
}

# Run tests
run_tests() {
    print_info "Running tests..."

    cd tests
    npm install
    node test-runner.js

    if [ $? -eq 0 ]; then
        print_success "All tests passed"
    else
        print_error "Some tests failed. Please review and fix before deploying."
        exit 1
    fi

    cd ..
}

# Main deployment flow
main() {
    echo "=========================================="
    echo "Real Estate Lead Qualification Agent"
    echo "Deployment Script"
    echo "=========================================="
    echo ""

    check_prerequisites
    load_config

    # Ask for confirmation
    echo ""
    print_info "Project: $PROJECT_ID"
    print_info "Region: $REGION"
    echo ""
    read -p "Continue with deployment? (y/n) " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Deployment cancelled"
        exit 1
    fi

    enable_apis
    deploy_playbook_webhook
    deploy_whatsapp_webhook

    echo ""
    echo "=========================================="
    print_success "Deployment completed successfully!"
    echo "=========================================="
    echo ""
    print_info "Next steps:"
    echo "1. Import Dialogflow CX agent from this directory"
    echo "2. Configure Twilio WhatsApp webhook with the URL above"
    echo "3. Update project-specific variables in flow responses"
    echo "4. Run tests: cd tests && node test-runner.js"
    echo "5. Monitor logs: gcloud functions logs read whatsappWebhook"
    echo ""
}

# Run main function
main
