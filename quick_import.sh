#!/bin/bash

# Quick Import Guide
# Run this after cloning from GitHub

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   Keidar Real Estate Agent - Dialogflow CX Import Guide     ║"
echo "╔══════════════════════════════════════════════════════════════╗"
echo ""

echo "📋 What you need:"
echo "  1. Google Cloud project with Dialogflow CX API enabled"
echo "  2. gcloud CLI installed and authenticated"
echo "  3. This repository cloned locally"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI not found!"
    echo ""
    echo "📥 Install it from: https://cloud.google.com/sdk/docs/install"
    echo ""
    exit 1
fi

echo "✅ gcloud CLI found"
echo ""

# Check if authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo "⚠️  Not authenticated with gcloud"
    echo ""
    echo "Run: gcloud auth login"
    echo ""
    exit 1
fi

echo "✅ Authenticated with gcloud"
echo ""

# Get project ID
if [ -z "$PROJECT_ID" ]; then
    echo "💡 Set your project ID:"
    echo ""
    read -p "Enter your Google Cloud Project ID: " PROJECT_ID
    export PROJECT_ID
fi

echo "✅ Project ID: $PROJECT_ID"
echo ""

# Get location
if [ -z "$LOCATION" ]; then
    LOCATION="global"
fi

echo "✅ Location: $LOCATION"
echo ""

echo "══════════════════════════════════════════════════════════════"
echo "Choose import method:"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "1) 📦 Package + gcloud import (RECOMMENDED - 2 minutes)"
echo "2) 🐍 Python API import (requires Python - 3 minutes)"
echo "3) 📖 Show manual instructions"
echo "4) ❌ Exit"
echo ""
read -p "Choose (1-4): " choice

case $choice in
    1)
        echo ""
        echo "══════════════════════════════════════════════════════════════"
        echo "📦 Method 1: Package + gcloud import"
        echo "══════════════════════════════════════════════════════════════"
        echo ""

        # Create package
        echo "Step 1/3: Creating package..."
        ./package_agent.sh

        echo ""
        echo "Step 2/3: Importing to Dialogflow CX..."
        cd agent_package

        # Export variables for the import script
        export PROJECT_ID
        export LOCATION

        # Run import
        ./import_using_gcloud.sh

        echo ""
        echo "✅ Done! Check your Dialogflow CX console"
        ;;

    2)
        echo ""
        echo "══════════════════════════════════════════════════════════════"
        echo "🐍 Method 2: Python API import"
        echo "══════════════════════════════════════════════════════════════"
        echo ""

        # Check Python
        if ! command -v python3 &> /dev/null; then
            echo "❌ Python 3 not found!"
            exit 1
        fi

        echo "Step 1/3: Installing dependencies..."
        pip install -q -r requirements.txt

        echo "Step 2/3: Authenticating..."
        gcloud auth application-default login

        echo "Step 3/3: Running import..."
        export PROJECT_ID
        python3 import_agent.py

        echo ""
        echo "✅ Done! Check your Dialogflow CX console"
        ;;

    3)
        echo ""
        echo "══════════════════════════════════════════════════════════════"
        echo "📖 Manual Instructions"
        echo "══════════════════════════════════════════════════════════════"
        echo ""
        echo "After cloning from GitHub, you CANNOT use Dialogflow CX Console's"
        echo "'Restore' button directly. Here's what works:"
        echo ""
        echo "▶ Quick Method (gcloud):"
        echo "  1. ./package_agent.sh"
        echo "  2. cd agent_package"
        echo "  3. export PROJECT_ID=your-project-id"
        echo "  4. ./import_using_gcloud.sh"
        echo ""
        echo "▶ Python Method:"
        echo "  1. pip install -r requirements.txt"
        echo "  2. gcloud auth application-default login"
        echo "  3. export PROJECT_ID=your-project-id"
        echo "  4. python import_agent.py"
        echo ""
        echo "📚 See IMPORT_GUIDE.md for detailed instructions"
        ;;

    4)
        echo "Exited"
        exit 0
        ;;

    *)
        echo "Invalid choice"
        exit 1
        ;;
esac
