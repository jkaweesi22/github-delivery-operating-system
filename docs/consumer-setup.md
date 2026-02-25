# Consumer Setup Guide

This guide explains how to integrate the Delivery Operating System into your repository as a **reusable, non-destructive, additive** governance layer.

---

## Integration Model

The Delivery OS integrates via **trigger workflows** that call reusable workflows from this repository. It does **not**:

- Overwrite existing workflows
- Modify existing issue templates
- Delete or rename labels
- Alter branch protection rules

Integration is **additive**, **opt-in**, and **reversible**.

---

## Minimal Integration

### 1. Reference a Tagged Release

**Always use a version tag.** Do not reference `@main` in production.

```
uses: your-org/github-delivery-operating-system/.github/workflows/<workflow>.yml@v1
```

Create a `v1` tag before first use:
```bash
git tag v1.0.0
git push origin v1.0.0
```

### 2. Add Trigger Workflows

Create these files in your repository's `.github/workflows/` directory. Replace `your-org` with your org or username.

#### Release Control Trigger

Create `.github/workflows/delivery-os-release-control.yml`:

```yaml
name: Enable Delivery OS – Release Control

on:
  issues:
    types: [labeled]
  pull_request:
    types: [labeled]

jobs:
  call-release-control:
    if: contains(github.event.label.name, 'production')
    uses: your-org/github-delivery-operating-system/.github/workflows/release-control.yml@v1
    with:
      release_approver: "@release-approver"
      production_label: "production"
      enable_alerts: true
      enable_telegram: true
      enable_whatsapp: false
    secrets: inherit
```

#### Sprint Orchestration Trigger

Create `.github/workflows/delivery-os-sprint-orchestration.yml`:

```yaml
name: Enable Delivery OS – Sprint Orchestration

on:
  issues:
    types: [opened, edited, labeled]
  workflow_dispatch:
    inputs:
      issue_number:
        description: "Sprint planning issue number"
        required: true
        type: number

jobs:
  call-sprint-orchestration:
    if: |
      github.event_name == 'workflow_dispatch' ||
      github.event_name == 'issues'
    uses: your-org/github-delivery-operating-system/.github/workflows/sprint-orchestration.yml@v1
    with:
      sprint_planning_label: "sprint-planning"
      sprint_label: "sprint"
      intake_label: "intake"
      enable_child_task_creation: false
      enable_milestone_assignment: false
      issue_number: ${{ github.event.inputs.issue_number || github.event.issue.number }}
    secrets: inherit
```

**Without child tasks** (default): Sprint orchestration validates labels but does not create child issues. Use when teams rely on Jira, Linear, or other tools for task tracking.

**With child tasks enabled**: Add to your sprint trigger:

```yaml
    with:
      enable_child_task_creation: true
      enable_milestone_assignment: true
      # ... other inputs
```

#### Intake Governance Trigger

Create `.github/workflows/delivery-os-intake-governance.yml`:

```yaml
name: Enable Delivery OS – Intake Governance

on:
  issues:
    types: [opened, edited, labeled]
  pull_request:
    types: [opened, edited, labeled]

jobs:
  call-intake-governance:
    uses: your-org/github-delivery-operating-system/.github/workflows/intake-governance.yml@v1
    with:
      intake_label: "intake"
    secrets: inherit
```

#### Telegram Alerts Trigger

Create `.github/workflows/delivery-os-telegram-alerts.yml`:

```yaml
name: Enable Delivery OS – Telegram Alerts

on:
  pull_request:
    types: [closed]
  issues:
    types: [labeled]

jobs:
  call-telegram-alerts:
    if: |
      (github.event_name == 'pull_request' && github.event.pull_request.merged == true) ||
      (github.event_name == 'issues' && (contains(github.event.label.name, 'production') || contains(github.event.label.name, 'sprint-planning') || contains(github.event.label.name, 'risk')))
    uses: your-org/github-delivery-operating-system/.github/workflows/telegram-alerts.yml@v1
    with:
      production_label: "production"
      sprint_planning_label: "sprint-planning"
      risk_label: "risk"
      enable_telegram: true
    secrets: inherit
```

#### WhatsApp Alerts Trigger

Create `.github/workflows/delivery-os-whatsapp-alerts.yml`:

```yaml
name: Enable Delivery OS – WhatsApp Alerts

on:
  pull_request:
    types: [closed]
  issues:
    types: [labeled]

jobs:
  call-whatsapp-alerts:
    if: |
      (github.event_name == 'pull_request' && github.event.pull_request.merged == true) ||
      (github.event_name == 'issues' && contains(github.event.label.name, 'production'))
    uses: your-org/github-delivery-operating-system/.github/workflows/whatsapp-alerts.yml@v1
    with:
      production_label: "production"
      enable_whatsapp: true
    secrets: inherit
```

---

## Required Secrets

| Secret | Required | Description |
|--------|----------|-------------|
| None | — | Governance workflows require no secrets |

---

## Optional Secrets (Alerting)

| Secret | Used By | Description |
|--------|---------|-------------|
| `TELEGRAM_BOT_TOKEN` | Telegram Alerts | Bot token from @BotFather |
| `TELEGRAM_CHAT_ID` | Telegram Alerts | Chat or channel ID |
| `WHATSAPP_ACCESS_TOKEN` | WhatsApp (Meta) | Meta Graph API token |
| `WHATSAPP_PHONE_NUMBER_ID` | WhatsApp (Meta) | Phone number ID |
| `WHATSAPP_RECIPIENT_NUMBER` | WhatsApp (Meta/Twilio) | Recipient in E.164 |
| `TWILIO_ACCOUNT_SID` | WhatsApp (Twilio) | Twilio account SID |
| `TWILIO_AUTH_TOKEN` | WhatsApp (Twilio) | Twilio auth token |
| `TWILIO_WHATSAPP_NUMBER` | WhatsApp (Twilio) | Twilio WhatsApp number |

**Secrets inheritance:** Use `secrets: inherit` in your trigger workflows. The consumer repository's secrets are passed to the reusable workflow. Optionally, configure org-level secrets for cross-repo reuse.

---

## Optional Configuration Overrides

All governance behavior is configurable via workflow inputs:

| Input | Default | Description |
|-------|---------|-------------|
| `release_approver` | `@release-approver` | Legacy fallback for approval mention |
| `default_release_approver` | — | Fallback when issue body omits Release Approver |
| `production_label` | `production` | Label that triggers release gate |
| `sprint_label` | `sprint` | Label applied to child sprint issues |
| `sprint_planning_label` | `sprint-planning` | Label that triggers sprint orchestration |
| `intake_label` | `intake` | Label applied to new intake items |
| `enable_child_task_creation` | `false` | Create child issues from sprint deliverable lines |
| `enable_milestone_assignment` | `false` | Assign parent milestone to child issues |
| `risk_label` | `risk` | Label that triggers risk alerts |
| `enable_alerts` | `false` | Master switch for release-control alerts |
| `enable_telegram` | `false` | Enable Telegram notifications |
| `enable_whatsapp` | `false` | Enable WhatsApp notifications |

Override in your trigger workflow:

```yaml
with:
  release_approver: "@my-team/release-approvers"
  production_label: "ready-for-release"
  enable_alerts: true
  enable_telegram: true
  enable_whatsapp: false
```

---

## Safe Removal (Uninstalling Delivery OS)

1. **Delete trigger workflow files** from `.github/workflows/`:
   - `delivery-os-release-control.yml`
   - `delivery-os-sprint-orchestration.yml`
   - `delivery-os-intake-governance.yml`
   - `delivery-os-telegram-alerts.yml`
   - `delivery-os-whatsapp-alerts.yml`

2. **Remove secrets** (optional): If you added Delivery OS–specific secrets, remove them from Settings → Secrets.

3. **No central repo modifications required.** The `github-delivery-operating-system` repository is not modified when you uninstall.
