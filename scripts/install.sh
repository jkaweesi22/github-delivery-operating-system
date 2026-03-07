#!/usr/bin/env bash
# GitHub Delivery Operating System — Installer
# Copies workflows and templates directly (Phanerooapp-style).
# Use --overwrite to replace existing files.

set -e

# Parse args: [--with-templates] [--with-labels] [--overwrite] [target_dir]
TARGET_DIR="."
WITH_TEMPLATES=false
WITH_LABELS=false
OVERWRITE=false
while [ $# -gt 0 ]; do
  case "$1" in
    --with-templates) WITH_TEMPLATES=true; shift ;;
    --with-labels) WITH_LABELS=true; shift ;;
    --overwrite) OVERWRITE=true; shift ;;
    *) TARGET_DIR="$1"; shift ;;
  esac
done

# Resolve paths (script can be run from any directory)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKFLOWS_SRC="${REPO_ROOT}/.github/workflows"
TEMPLATES_SRC="${REPO_ROOT}/.github/ISSUE_TEMPLATE"
TARGET_ABS="$(cd "$TARGET_DIR" && pwd)"

echo "=== GitHub Delivery Operating System ==="
echo "Target: ${TARGET_ABS}"
echo ""

# 1. Ensure target .github structure
mkdir -p "${TARGET_ABS}/.github/workflows"
mkdir -p "${TARGET_ABS}/.github/ISSUE_TEMPLATE"

# 2. Copy workflows
WORKFLOWS=(sprint-child-creator auto-close-sprint notify-release-approver authorize-deployment auto-assign-qa telegram-issues setup-labels)
WORKFLOWS_COPIED=0
for wf in "${WORKFLOWS[@]}"; do
  src="${WORKFLOWS_SRC}/${wf}.yml"
  dest="${TARGET_ABS}/.github/workflows/${wf}.yml"
  if [ ! -f "$src" ]; then
    echo "  Warning: source not found: ${wf}.yml"
    continue
  fi
  if [ -f "$dest" ] && [ "$OVERWRITE" != "true" ]; then
    echo "  Skipped (exists): ${wf}.yml"
  else
    cp "$src" "$dest"
    echo "  Created: ${wf}.yml"
    WORKFLOWS_COPIED=$((WORKFLOWS_COPIED + 1))
  fi
done

# 3. Optionally copy issue templates
TEMPLATES_COPIED=0
if [ "$WITH_TEMPLATES" = true ] && [ -d "$TEMPLATES_SRC" ]; then
  for tpl in "$TEMPLATES_SRC"/*.yml; do
    [ -f "$tpl" ] || continue
    name=$(basename "$tpl")
    dest="${TARGET_ABS}/.github/ISSUE_TEMPLATE/${name}"
    if [ -f "$dest" ] && [ "$OVERWRITE" != "true" ]; then
      echo "  Skipped (exists): ${name}"
    else
      cp "$tpl" "$dest"
      echo "  Created template: ${name}"
      TEMPLATES_COPIED=$((TEMPLATES_COPIED + 1))
    fi
  done
fi

# 4. Optionally create labels via gh CLI (must match setup-labels.yml)
LABELS_CREATED=0
LABELS_SKIP_REASON=""
if [ "$WITH_LABELS" = true ]; then
  if ! command -v gh &>/dev/null; then
    LABELS_SKIP_REASON="gh CLI not installed. Install from https://cli.github.com/"
    echo "  Skipped labels: $LABELS_SKIP_REASON"
  elif [ ! -d "${TARGET_ABS}/.git" ]; then
    LABELS_SKIP_REASON="Target is not a git repository."
    echo "  Skipped labels: $LABELS_SKIP_REASON"
  else
    if ! (cd "$TARGET_ABS" && gh auth status &>/dev/null); then
      LABELS_SKIP_REASON="gh CLI not authenticated. Run: gh auth login"
      echo "  Skipped labels: $LABELS_SKIP_REASON"
    elif ! (cd "$TARGET_ABS" && gh repo view &>/dev/null); then
      LABELS_SKIP_REASON="Target repo not on GitHub or no push access."
      echo "  Skipped labels: $LABELS_SKIP_REASON"
    else
      LABELS=(
        "intake:0E8A16"
        "bug:D93F0B"
        "sprint:1D76DB"
        "sprint-active:1D76DB"
        "planning:5319E7"
        "sprint-planning:5319E7"
        "task:7057FF"
        "qa:FBCA04"
        "qa-request:FBCA04"
        "production:D93F0B"
        "release:B60205"
        "approval:0E8A16"
        "ready-for-deploy:0E8A16"
        "declined:B60205"
        "risk:B60205"
      )
      for entry in "${LABELS[@]}"; do
        name="${entry%%:*}"
        color="${entry##*:}"
        err=$(cd "$TARGET_ABS" && gh label create "$name" --color "$color" 2>&1)
        if [ $? -eq 0 ]; then
          echo "  Created label: $name"
          LABELS_CREATED=$((LABELS_CREATED + 1))
        elif echo "$err" | grep -qi "already exists"; then
          echo "  Skipped (exists): $name"
        else
          echo "  Failed to create label '$name': $err"
        fi
      done
    fi
  fi
fi

echo ""
if [ $WORKFLOWS_COPIED -gt 0 ] || [ $TEMPLATES_COPIED -gt 0 ] || [ $LABELS_CREATED -gt 0 ]; then
  [ $WORKFLOWS_COPIED -gt 0 ] && echo "Installed ${WORKFLOWS_COPIED} workflow(s)."
  [ $TEMPLATES_COPIED -gt 0 ] && echo "Copied ${TEMPLATES_COPIED} issue template(s)."
  [ $LABELS_CREATED -gt 0 ] && echo "Created ${LABELS_CREATED} label(s)."
  echo ""
  echo "Next steps:"
  echo "  1. Create labels: Actions → Setup Labels → Run workflow"
  [ -n "$LABELS_SKIP_REASON" ] && echo "     (Labels skipped: $LABELS_SKIP_REASON)"
  echo "  2. Configure repo variables (Settings → Secrets and variables → Actions):"
  echo "     - RELEASE_APPROVER: GitHub username of release approver"
  echo "     - QA_APPROVER: GitHub username of QA approver"
  echo "     - QA_ASSIGNEES: Comma-separated usernames for QA assignment"
  echo "  3. Add secrets (optional, for Telegram): TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID"
  if [ "$WITH_TEMPLATES" = false ]; then
    echo "  4. Copy templates: re-run with --with-templates"
  fi
  echo ""
  echo "See docs/consumer-setup.md for full configuration."
else
  echo "No new files created (existing files were skipped)."
  echo "Use --overwrite to replace existing workflows/templates."
fi
echo ""
echo "=== Installation complete ==="
