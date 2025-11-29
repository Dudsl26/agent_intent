# ⚠️ IMPORTANT: GitHub Import Instructions

## Why Direct Import Doesn't Work

**You CANNOT use Dialogflow CX Console's "Restore" button with files from GitHub.**

The Console's "Restore" feature only accepts:
- Binary blob files previously exported from Dialogflow CX
- Not raw JSON files from a repository

## ✅ What Actually Works

After cloning this repository, you have **2 working methods**:

---

## Method 1: Quick Import Script (Easiest!) ⚡

```bash
# Clone from GitHub
git clone https://github.com/Dudsl26/agent_intent.git
cd agent_intent

# Run the quick import script
./quick_import.sh
```

The script will guide you through the process interactively.

---

## Method 2: Manual Package + Import

```bash
# Clone from GitHub
git clone https://github.com/Dudsl26/agent_intent.git
cd agent_intent

# Create the package
./package_agent.sh

# Import using gcloud
cd agent_package
export PROJECT_ID="your-google-cloud-project-id"
export LOCATION="global"
./import_using_gcloud.sh
```

---

## Method 3: Python API Import

```bash
# Clone from GitHub
git clone https://github.com/Dudsl26/agent_intent.git
cd agent_intent

# Install dependencies
pip install -r requirements.txt

# Authenticate
gcloud auth application-default login

# Import
export PROJECT_ID="your-project-id"
python import_agent.py
```

---

## Common Issues & Solutions

### ❌ Issue: "Nothing happens" when using GitHub

**Problem:** You tried to use Dialogflow CX Console's "Restore" button with GitHub files

**Solution:** Use one of the 3 methods above. The Console's Restore doesn't work with raw files.

### ❌ Issue: "Permission denied" or "Not authenticated"

**Solution:**
```bash
gcloud auth login
gcloud auth application-default login
```

### ❌ Issue: "API not enabled"

**Solution:**
```bash
gcloud services enable dialogflow.googleapis.com --project=your-project-id
```

### ❌ Issue: Package script fails

**Solution:** Ensure you're in the correct directory:
```bash
cd /path/to/agent_intent
ls agent.json  # This should exist
./package_agent.sh
```

---

## What Each Method Does

### Package Method (Recommended)
1. Creates Google-compatible .tar.gz package
2. Uses gcloud CLI to import
3. Takes 2-3 minutes total

### Python Method (Alternative)
1. Uses Dialogflow CX Python API
2. Creates agent programmatically
3. Takes 3-5 minutes total

### Manual Method
See IMPORT_GUIDE.md for step-by-step console instructions

---

## After Successful Import

Your agent will have:
- ✅ 11 Intents with Hebrew training phrases
- ✅ 2 Flows with conversation logic
- ✅ 1 Playbook with Keidar knowledge
- ✅ 2 Entity Types (city, room_count)
- ✅ 2 Tools (property lookup, mortgage calculator)
- ✅ 18 Session parameters

**Open in Console:**
```
https://dialogflow.cloud.google.com/cx/projects/YOUR_PROJECT_ID/locations/global/agents/YOUR_AGENT_ID
```

---

## Quick Reference

| Method | Time | Difficulty | Requirements |
|--------|------|------------|--------------|
| quick_import.sh | 2 min | Easy | gcloud CLI |
| Package + gcloud | 2 min | Easy | gcloud CLI |
| Python API | 3 min | Medium | Python + gcloud |
| Manual Console | 30 min | Hard | Browser only |

**Recommendation:** Use `./quick_import.sh` for easiest experience!
