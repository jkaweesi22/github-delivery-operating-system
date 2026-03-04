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
    types: [opened, labeled]
  pull_request:
    types: [labeled]

jobs:
  call-release-control:
    if: |
      (github.event_name == 'pull_request' && contains(github.event.label.name, 'production')) ||
      (github.event_name == 'issues' && (
        (github.event.action == 'labeled' && github.event.label.name == 'production') ||
        (github.event.action == 'opened' && contains(join(github.event.issue.labels.*.name, ','), 'production'))
      ))
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

**Alternative – Sprint Child Creator (standalone):** For a simpler flow that creates children immediately when a sprint issue is opened (title "SPRINT -"), use the standalone workflow:

```yaml
# .github/workflows/delivery-os-sprint-child-creator.yml
name: Enable Delivery OS – Sprint Child Creator

on:
  issues:
    types: [opened]

jobs:
  call-sprint-child-creator:
    uses: your-org/github-delivery-operating-system/.github/workflows/sprint-child-creator.yml@v1
    with:
      title_prefix: "SPRINT -"
      sprint_label: "sprint"
      intake_label: "intake"
    secrets: inherit
```

#### Notify Release Approver (Optional)

Create `.github/workflows/delivery-os-notify-release-approver.yml` to ping the release approver when a production release issue is opened:

```yaml
name: Enable Delivery OS – Notify Release Approver

on:
  issues:
    types: [opened]

jobs:
  call-notify-release-approver:
    uses: your-org/github-delivery-operating-system/.github/workflows/notify-release-approver.yml@v1
    with:
      release_approver_username: "aMugabi"
      production_label: "production"
      project_name: "My Project"
```

#### Authorize Deployment – Dual Approval (Optional)

Create `.github/workflows/delivery-os-authorize-deployment.yml` for dual approval (release approver + QA lead):

```yaml
name: Enable Delivery OS – Authorize Deployment

on:
  issue_comment:
    types: [created]

jobs:
  call-authorize-deployment:
    uses: your-org/github-delivery-operating-system/.github/workflows/authorize-deployment.yml@v1
    with:
      release_approver_username: "aMugabi"
      qa_approver_username: "jkaweesi22"
      production_label: "production"
```

#### Auto Close Sprint (Optional)

Create `.github/workflows/delivery-os-auto-close-sprint.yml` to update burn-down and auto-close when all child tasks complete:

```yaml
name: Enable Delivery OS – Auto Close Sprint

on:
  issues:
    types: [closed]

jobs:
  call-auto-close-sprint:
    uses: your-org/github-delivery-operating-system/.github/workflows/auto-close-sprint.yml@v1
    with:
      enable_telegram_alert: false
    secrets: inherit
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

Create `.github/workflows/delivery-os-telegram-alerts.yml` (Phanerooapp-style: issues opened/closed/reopened, comments, PR merged):

```yaml
name: Enable Delivery OS – Telegram Alerts

on:
  issues:
    types: [opened, closed, reopened]
  issue_comment:
    types: [created]
  pull_request:
    types: [closed]

jobs:
  call-telegram-alerts:
    if: |
      github.event_name == 'issues' ||
      github.event_name == 'issue_comment' ||
      (github.event_name == 'pull_request' && github.event.pull_request.merged == true)
    uses: your-org/github-delivery-operating-system/.github/workflows/telegram-alerts.yml@v1
    with:
      bug_label: "bug"
      qa_label: "qa"
      qa_request_label: "qa-request"
      sprint_label: "sprint"
      planning_label: "planning"
      sprint_planning_label: "sprint-planning"
      sprint_active_label: "sprint-active"
      production_label: "production"
      release_approver_username: "aMugabi"
      timezone: "Africa/Nairobi"
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
| `title_prefix` | `SPRINT -` | Title prefix for sprint-child-creator |
| `release_approver_username` | (required) | Username for notify-release-approver, authorize-deployment |
| `qa_approver_username` | (required) | QA lead username for dual approval |
| `enable_telegram_alert` | `false` | Telegram alert when sprint 100% complete (auto-close-sprint) |
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
   - `delivery-os-sprint-child-creator.yml`
   - `delivery-os-intake-governance.yml`
   - `delivery-os-auto-close-sprint.yml`
   - `delivery-os-notify-release-approver.yml`
   - `delivery-os-authorize-deployment.yml`
   - `delivery-os-telegram-alerts.yml`
   - `delivery-os-whatsapp-alerts.yml`

2. **Remove secrets** (optional): If you added Delivery OS–specific secrets, remove them from Settings → Secrets.

3. **No central repo modifications required.** The `github-delivery-operating-system` repository is not modified when you uninstall.
