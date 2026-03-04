#!/usr/bin/env bash
# Create Delivery OS labels in the current repo. Run from consumer repo root.
# Requires: gh CLI, gh auth login

set -e

if ! command -v gh &>/dev/null; then
  echo "Error: gh CLI not installed. Install from https://cli.github.com/"
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo "Error: gh not authenticated. Run: gh auth login"
  exit 1
fi

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
  "risk:B60205"
)

CREATED=0
for entry in "${LABELS[@]}"; do
  name="${entry%%:*}"
  color="${entry##*:}"
  err=$(gh label create "$name" --color "$color" 2>&1)
  rv=$?
  if [ $rv -eq 0 ]; then
    echo "  Created: $name"
    CREATED=$((CREATED + 1))
  elif echo "$err" | grep -qi "already exists"; then
    echo "  Exists:  $name"
  else
    echo "  Failed:  $name - $err"
  fi
done

echo ""
echo "Created $CREATED label(s)."
