#!/usr/bin/env bash
# GitHub Delivery Operating System — Safe, Non-Destructive Installer
# Copies trigger examples only. Never overwrites. Fails safely.

set -e

REPO_ORG="${REPO_ORG:-your-org}"
REPO_NAME="${REPO_NAME:-github-delivery-operating-system}"
VERSION="${VERSION:-v1}"
TARGET_DIR="${1:-.}"

echo "=== GitHub Delivery Operating System ==="
echo ""

# 1. Check if .github/workflows exists in target
if [ ! -d "${TARGET_DIR}/.github" ]; then
  echo "Creating .github directory..."
  mkdir -p "${TARGET_DIR}/.github"
fi
if [ ! -d "${TARGET_DIR}/.github/workflows" ]; then
  echo "Creating .github/workflows directory..."
  mkdir -p "${TARGET_DIR}/.github/workflows"
fi

# 2. Delivery OS trigger file naming pattern
TRIGGER_PREFIX="delivery-os-"
EXAMPLES_DIR="$(dirname "$0")/../examples"

# 3. Check if examples exist
if [ ! -d "$EXAMPLES_DIR" ]; then
  echo "Error: examples/ directory not found. Run from repository root."
  exit 1
fi

# 4. Check for existing Delivery OS triggers — abort if duplicate
for example in "$EXAMPLES_DIR"/trigger-*.yml; do
  [ -f "$example" ] || continue
  basename=$(basename "$example" .yml)
  target_name="${TRIGGER_PREFIX}${basename#trigger-}"
  target_path="${TARGET_DIR}/.github/workflows/${target_name}.yml"
  if [ -f "$target_path" ]; then
    echo "Error: ${target_name}.yml already exists. Abort to prevent overwrite."
    echo "Remove existing file or use a different target directory."
    exit 1
  fi
done

# 5. Copy each example (non-destructive; we've confirmed no conflicts)
COPIED=0
for example in "$EXAMPLES_DIR"/trigger-*.yml; do
  [ -f "$example" ] || continue
  basename=$(basename "$example" .yml)
  target_name="${TRIGGER_PREFIX}${basename#trigger-}"
  target_path="${TARGET_DIR}/.github/workflows/${target_name}.yml"
  sed "s/your-org/${REPO_ORG}/g;s/@v1/@${VERSION}/g" "$example" > "$target_path"
  echo "  Created: ${target_name}.yml"
  COPIED=$((COPIED + 1))
done

echo ""
if [ $COPIED -gt 0 ]; then
  echo "Installed ${COPIED} trigger workflow(s)."
  echo ""
  echo "Next steps:"
  echo "  1. Create release tag in Delivery OS repo: git tag v1.0.0 && git push origin v1.0.0"
  echo "  2. Add labels in consumer repo:"
  echo "     gh label create intake --color 0E8A16"
  echo "     gh label create bug --color D93F0B"
  echo "     gh label create sprint --color 1D76DB"
  echo "     gh label create qa --color FBCA04"
  echo "     gh label create production --color D93F0B"
  echo "     gh label create risk --color B60205"
  echo "     gh label create sprint-planning --color 5319E7"
  echo "  3. Add secrets (optional, for alerts): gh secret set TELEGRAM_BOT_TOKEN"
  echo "  4. Copy issue templates (optional): From Delivery OS repo, run:"
  echo "     mkdir -p ${TARGET_DIR}/.github/ISSUE_TEMPLATE"
  echo "     cp .github/ISSUE_TEMPLATE/*.yml ${TARGET_DIR}/.github/ISSUE_TEMPLATE/"
  echo ""
  echo "See docs/consumer-setup.md and docs/how-to.md for full configuration."
else
  echo "No new files created. Delivery OS triggers may already exist."
  echo "To reinstall, remove existing delivery-os-*.yml files first."
fi
echo ""
echo "=== Installation complete ==="
