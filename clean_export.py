#!/usr/bin/env python3
"""
Dialogflow CX Repository Cleaner

This script creates a clean export of a Dialogflow CX agent repository,
containing only the essential files needed for JSON package sync.

Usage:
    python clean_export.py <path_to_original_repo>

Example:
    python clean_export.py /home/user/agent_intent
"""

import sys
import os
import shutil
from pathlib import Path


# Required files and directories for Dialogflow CX
REQUIRED_ITEMS = [
    'agent.json',
    'flows',
    'intents',
    'entityTypes',
    'playbooks',  # Note: Some repos may use 'playbook' (singular)
    'tools'
]

# Alternative names to check (for backwards compatibility)
ALTERNATIVE_NAMES = {
    'playbooks': 'playbook'  # Check for 'playbook' if 'playbooks' not found
}

# Files to exclude during copy (not part of Dialogflow CX agent structure)
EXCLUDE_FILES = {
    'README.md',
    '.gitignore',
    '.git',
    '__pycache__',
    '.DS_Store',
    'Thumbs.db'
}


def should_copy_file(file_path):
    """
    Determine if a file should be copied to clean export.

    Args:
        file_path: Path object to check

    Returns:
        bool: True if file should be copied, False otherwise
    """
    # Exclude specific filenames
    if file_path.name in EXCLUDE_FILES:
        return False

    # Exclude Python cache directories
    if '__pycache__' in file_path.parts:
        return False

    # Exclude git directories
    if '.git' in file_path.parts:
        return False

    return True


def clean_export_agent(source_path):
    """
    Create a clean export of Dialogflow CX agent files.

    Args:
        source_path: Path to the original repository
    """
    source = Path(source_path).resolve()

    # Validate source path
    if not source.exists():
        print(f"❌ Error: Source path does not exist: {source}")
        sys.exit(1)

    if not source.is_dir():
        print(f"❌ Error: Source path is not a directory: {source}")
        sys.exit(1)

    # Check for required agent.json
    if not (source / 'agent.json').exists():
        print(f"❌ Error: No agent.json found in {source}")
        print("   This doesn't appear to be a Dialogflow CX agent repository.")
        sys.exit(1)

    # Create clean_export directory
    export_dir = source / 'clean_export'

    print(f"🧹 Creating clean export from: {source}")
    print(f"📁 Export directory: {export_dir}")

    # Remove existing clean_export if it exists
    if export_dir.exists():
        print(f"⚠️  Removing existing clean_export directory...")
        shutil.rmtree(export_dir)

    export_dir.mkdir(exist_ok=True)

    # Copy required items
    copied_items = []
    missing_items = []

    for item_name in REQUIRED_ITEMS:
        item_path = source / item_name
        dest_path = export_dir / item_name

        # Check if item exists
        if item_path.exists():
            if item_path.is_dir():
                print(f"📂 Copying directory: {item_name}/")
                shutil.copytree(
                    item_path,
                    dest_path,
                    ignore=lambda dir, files: [f for f in files if not should_copy_file(Path(dir) / f)]
                )
            else:
                print(f"📄 Copying file: {item_name}")
                shutil.copy2(item_path, dest_path)
            copied_items.append(item_name)
        # Check for alternative name (e.g., 'playbook' instead of 'playbooks')
        elif item_name in ALTERNATIVE_NAMES:
            alt_name = ALTERNATIVE_NAMES[item_name]
            alt_path = source / alt_name
            if alt_path.exists():
                print(f"📂 Copying directory: {alt_name}/ → {item_name}/")
                if alt_path.is_dir():
                    shutil.copytree(
                        alt_path,
                        dest_path,
                        ignore=lambda dir, files: [f for f in files if not should_copy_file(Path(dir) / f)]
                    )
                else:
                    shutil.copy2(alt_path, dest_path)
                copied_items.append(item_name)
            else:
                missing_items.append(item_name)
        else:
            missing_items.append(item_name)

    # Verify clean_export only contains required items
    print(f"\n🔍 Verifying clean_export directory...")

    actual_items = set(item.name for item in export_dir.iterdir())
    required_set = set(REQUIRED_ITEMS)
    extra_items = actual_items - required_set

    if extra_items:
        print(f"⚠️  Found unexpected items, removing:")
        for extra in extra_items:
            extra_path = export_dir / extra
            if extra_path.is_dir():
                print(f"   🗑️  Removing directory: {extra}/")
                shutil.rmtree(extra_path)
            else:
                print(f"   🗑️  Removing file: {extra}")
                extra_path.unlink()

    # Print summary
    print(f"\n{'='*60}")
    print(f"✅ Clean export completed successfully!")
    print(f"{'='*60}")

    if copied_items:
        print(f"\n📦 Copied items ({len(copied_items)}):")
        for item in sorted(copied_items):
            item_path = export_dir / item
            if item_path.is_dir():
                # Count files in directory
                file_count = sum(1 for _ in item_path.rglob('*') if _.is_file())
                print(f"   ✓ {item}/ ({file_count} files)")
            else:
                print(f"   ✓ {item}")

    if missing_items:
        print(f"\n⚠️  Missing items ({len(missing_items)}):")
        for item in sorted(missing_items):
            print(f"   - {item}")

    print(f"\n📁 Clean export location:")
    print(f"   {export_dir}")

    print(f"\n🚀 Next steps:")
    print(f"   1. Review the clean_export/ directory")
    print(f"   2. Copy contents to your new repository:")
    print(f"      cp -r clean_export/* /path/to/new/repo/")
    print(f"   3. Commit and push to GitHub")

    return export_dir


def main():
    """Main entry point."""
    if len(sys.argv) != 2:
        print("Usage: python clean_export.py <path_to_original_repo>")
        print("\nExample:")
        print("  python clean_export.py /home/user/agent_intent")
        print("  python clean_export.py .")
        sys.exit(1)

    source_path = sys.argv[1]
    clean_export_agent(source_path)


if __name__ == '__main__':
    main()
