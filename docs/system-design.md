# System Design: GitHub Delivery Operating System

A comprehensive technical design document describing architecture, components, data flows, and operational behavior.

---

## 1. Executive Summary

The **GitHub Delivery Operating System** (Delivery OS) is a **centralized governance engine** implemented as a library of reusable GitHub Actions workflows. It standardizes:

- Project governance (label-based lifecycle)
- Sprint execution (optional child issue creation)
- Quality intake (structured issue forms)
- Release approvals (production gates with dynamic approver tagging)
- Operational alerting (Telegram, WhatsApp — optional and non-blocking)

**Core architectural properties:**

| Property | Implementation |
|----------|----------------|
| **Reusability** | `workflow_call` — consumer repos invoke workflows from a central repository |
| **Non-destructiveness** | Never overwrites files; additive integration only |
| **Versioning** | Semantic versioning; consumers reference `@v1` or `@v1.0.0`, never `@main` |
| **Configurability** | All governance behavior driven by workflow inputs; no hardcoded org/user names |
| **Modularity** | Alerting and child task creation are optional, disabled by default |

---

## 2. System Context & Boundaries

### 2.1 What the System Is

- A **workflow library** hosted in a central repository
- **Consumer repositories** add thin trigger workflows that call these reusable workflows
- Workflows execute in the **consumer's repository context** (same `github.repository`, `github.event`)
- No database, no external service beyond GitHub API and optional alert channels

### 2.2 What the System Is NOT

- Not a SaaS dashboard or web UI
- Not a replacement for Jira, Linear, or other project tools (it can coexist)
- Not a CI/CD pipeline (it orchestrates governance, not builds)
- Not a monolith — each workflow is independently callable

### 2.3 System Boundaries

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONSUMER REPOSITORY                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │ Trigger         │  │ Trigger         │  │ Trigger         │  │
│  │ intake-gov      │  │ sprint-orch     │  │ release-control │  │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘  │
│           │                    │                    │            │
│           │  uses: org/repo/   │  uses: org/repo/   │  uses:     │
│           │  .github/workflows  │  .github/workflows │  org/repo/ │
│           │  /intake-*.yml@v1  │  /sprint-*.yml@v1  │  ...@v1    │
└───────────┼────────────────────┼────────────────────┼────────────┘
            │                    │                    │
            ▼                    ▼                    ▼
┌─────────────────────────────────────────────────────────────────┐
│            CENTRAL REPOSITORY (Delivery OS)                      │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ Reusable Workflows (workflow_call)                            ││
│  │ intake-governance | sprint-orchestration | release-control    ││
│  │ telegram-alerts | whatsapp-alerts                             ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────┐
│  EXTERNAL (Optional)                                              │
│  Telegram Bot API | Meta WhatsApp API | Twilio WhatsApp API     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Layered Architecture

### 3.1 Layer Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│  LAYER 1: TRIGGERS (Consumer Repo)                                │
│  Event binding: issues, pull_request, workflow_dispatch           │
│  Condition filtering: if: contains(label, 'production')           │
└──────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────┐
│  LAYER 2: REUSABLE WORKFLOWS (Central Repo)                       │
│  workflow_call with inputs + secrets                              │
│  Runs in caller's context (consumer repo)                         │
└──────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────┐
│  LAYER 3: GOVERNANCE LOGIC                                        │
│  Label application | Body parsing | Comment posting              │
│  GitHub REST API (issues, comments, labels)                       │
└──────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────┐
│  LAYER 4: ALERTING (Optional, Non-Blocking)                      │
│  Telegram | WhatsApp                                              │
│  continue-on-error: true | Secrets-based                          │
└──────────────────────────────────────────────────────────────────┘
```

### 3.2 Execution Context

When a consumer trigger runs `uses: org/repo/.github/workflows/release-control.yml@v1`:

1. **Trigger workflow** runs in consumer repo; receives `github.event` (issue, PR, labels)
2. **Reusable workflow** is invoked; it receives the **same** `github.event` and `github.repository`
3. All API calls (comments, labels) target the **consumer's** repository
4. Secrets are passed via `secrets: inherit` from consumer (or org) to the reusable workflow

---

## 4. Component Deep Dive

### 4.1 Intake Governance Workflow

**File:** `.github/workflows/intake-governance.yml`  
**Trigger:** Called by consumer on `issues` / `pull_request` (opened, edited, labeled)

| Step | Action | Condition |
|------|--------|-----------|
| Determine context | Extract issue/PR number, labels from `github.event` | Always |
| Apply intake label | Add `intake_label` if not present | `action == 'opened'` |
| Post acknowledgment | Comment with governance table | `action == 'opened'` |

**Inputs:**

| Input | Default | Purpose |
|-------|---------|---------|
| `intake_label` | `"intake"` | Label applied to new items |

**Idempotency:** Checks `labels.includes(intakeLabel)` before adding; no duplicate labels.

---

### 4.2 Sprint Orchestration Workflow

**File:** `.github/workflows/sprint-orchestration.yml`  
**Trigger:** Called by consumer on `issues` (opened, edited, labeled) or `workflow_dispatch`

**Step Sequence:**

| Step | Action | Condition |
|------|--------|-----------|
| Resolve issue number | From `inputs.issue_number` or `github.event.issue.number` | Always |
| Fetch sprint issue | GET `/repos/{owner}/{repo}/issues/{number}` | Always |
| Validate sprint planning | Label check + optional body check | Always; body required only if child creation enabled |
| Check prior orchestration | Scan comments for "Sprint Health Summary" | `enable_child_task_creation == true` |
| Parse and create child issues | Split body by lines, create issues | `enable_child_task_creation && !already_run` |
| Update sprint issue | Post health summary comment | `enable_child_task_creation && !already_run` |

**Deliverable Parsing Logic:**

- Lines matching `^[-*]\s+.+` or `^\d+\.\s+.+` (bullet or numbered list)
- Trim bullets/numbers; filter out `#`-prefixed and `---`
- Deduplicate via `Set`
- Create one issue per unique entry; body includes parent reference

**Inputs:**

| Input | Default | Purpose |
|-------|---------|---------|
| `sprint_planning_label` | `"sprint-planning"` | Label that triggers orchestration |
| `sprint_label` | `"sprint"` | Label on child issues |
| `intake_label` | `"intake"` | Label on child issues |
| `issue_number` | From event | Override for `workflow_dispatch` |
| `enable_child_task_creation` | `false` | Create child issues from lines |
| `enable_milestone_assignment` | `false` | Assign parent milestone to children |

**Duplicate Prevention:** `already_run` is true if any comment contains "Sprint Health Summary". Prevents re-creation on edit.

---

### 4.3 Release Control Workflow

**File:** `.github/workflows/release-control.yml`  
**Trigger:** Called when `production` label is added (consumer filter)

**Jobs:**

| Job | Purpose | Condition |
|-----|---------|-----------|
| `delivery-os-release-gate` | Parse body, post approval comment with @mention | Always |
| `delivery-os-block-merge-check` | Advisory check for approval phrase in comments | `event_name == 'pull_request'` |
| `delivery-os-telegram-alert` | Send Telegram message | `enable_alerts && enable_telegram` |
| `delivery-os-whatsapp-alert` | Send WhatsApp message | `enable_alerts && enable_whatsapp` |

**Body Parsing:**

1. **Sprint reference:** Regex `/#\d+/` → first `#12`-style reference
2. **QA recommendation:** Regex `/(Approve|Reject|Conditional)/i` → first match
3. **Release approver:** Section `### Release Approver GitHub Username` → next line value; normalized to `@username`

**Approver Resolution Order:**

1. Parsed from issue body
2. `default_release_approver` (workflow input)
3. `release_approver` (legacy input)
4. If none: post "Approver Assignment Required" comment

**Approval Detection:** Comments scanned for `approved for production` or `release approved` (case-insensitive). Advisory only; branch protection can enforce.

---

### 4.4 Telegram Alerts Workflow

**File:** `.github/workflows/telegram-alerts.yml`  
**Trigger:** PR merged, or `production` / `sprint-planning` / `risk` label added

| Step | Action |
|------|--------|
| Determine event type | Map event to "PR Merged", "Production Label Added", etc. |
| Build and send | Construct Markdown message; POST to `api.telegram.org/bot{token}/sendMessage` |

**Guard:** `if (enable_telegram == true)`; `continue-on-error: true`; skip if secrets missing.

---

### 4.5 WhatsApp Alerts Workflow

**File:** `.github/workflows/whatsapp-alerts.yml`  
**Trigger:** PR merged, or `production` label added

**Providers:** Meta Cloud API (preferred if `WHATSAPP_ACCESS_TOKEN` set) or Twilio. Each step checks its secrets and skips if unset. Both may run if both configured (documented as configure-one).

---

### 4.6 Issue Templates

| Template | Labels | Key Fields |
|----------|--------|------------|
| `delivery-intake.yml` | `intake` | Type, Summary, Description, Priority, Acceptance Criteria |
| `sprint-planning.yml` | `intake`, `sprint-planning` | Sprint Name, Deliverables (textarea), Target Date |
| `risk-review.yml` | `intake`, `risk`, `production` | Sprint Ref, QA Rec, Release Notes, Risk Mitigation |
| `qa-request.yml` | `intake`, `qa` | Feature Ref, Environment, Test Scope, Risk Assessment, QA Rec, **QA Reviewer GitHub Username** |
| `release-approval.yml` | `intake`, `production`, `risk` | Sprint Ref, QA Rec, Risk Summary, **Release Approver GitHub Username** |

All approver fields use placeholder hints (`@release-approver`, `@qa-reviewer`); no hardcoded usernames.

---

### 4.7 Installer Script

**File:** `scripts/install.sh`

| Phase | Action |
|-------|--------|
| 1 | Ensure `.github/workflows` exists in target |
| 2 | Check for existing `delivery-os-*.yml` files — **abort if any exist** |
| 3 | Copy `trigger-*.yml` → `delivery-os-*.yml`, substitute `REPO_ORG`, `VERSION` |
| 4 | Print next steps (tag, secrets, labels) |

**Non-destructive:** Never overwrites; exits with error on conflict.

---

## 5. Data Flows

### 5.1 Intake Flow

```
User submits issue (form or blank)
         │
         ▼
┌─────────────────────┐
│ Trigger: issues     │
│ opened              │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ intake-governance   │
│ 1. Check labels     │
│ 2. Add intake       │
│ 3. Post comment     │
└─────────────────────┘
```

### 5.2 Sprint Flow (Child Creation Enabled)

```
User creates sprint issue with deliverables
         │
         ▼
┌─────────────────────┐
│ Add sprint-planning │
│ label               │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ sprint-orchestration│
│ 1. Fetch issue       │
│ 2. Validate label    │
│ 3. Check prior run   │
│ 4. Parse lines       │
│ 5. Create children   │
│ 6. Post summary      │
└─────────────────────┘
```

### 5.3 Release Approval Flow

```
User adds production label (or uses release-approval form)
         │
         ▼
┌─────────────────────┐
│ Trigger: label      │
│ production          │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ release-control     │
│ 1. Parse body        │
│ 2. Resolve approver  │
│ 3. Post @mention     │
│ 4. (Optional) alerts  │
└─────────────────────┘
           │
           ▼
┌─────────────────────┐
│ block-merge-check   │
│ Scan comments for    │
│ approval phrase      │
└─────────────────────┘
```

---

## 6. State Machine: Lifecycle Labels

```
                    ┌─────────┐
                    │ (new)   │
                    └────┬────┘
                         │ opened
                         ▼
                    ┌─────────┐
              ┌─────│ intake │─────┐
              │     └────────┘     │
              │                    │
    sprint-   │                    │  qa
    planning  │                    │  label
              │                    │
              ▼                    ▼
         ┌─────────┐          ┌─────────┐
         │ sprint  │          │   qa    │
         └────┬────┘          └────┬────┘
              │                    │
              │    production      │
              │    label           │
              └────────┬───────────┘
                       ▼
                ┌─────────────┐
                │ production  │
                └──────┬──────┘
                       │
            ┌──────────┴──────────┐
            ▼                     ▼
      ┌──────────┐          ┌──────────┐
      │ approved │          │ rejected │
      └──────────┘          └──────────┘
```

Labels are applied manually or by issue templates; workflows react to their presence rather than driving all transitions.

---

## 7. Event-to-Workflow Matrix

| GitHub Event | Consumer Trigger Condition | Workflow Called |
|--------------|----------------------------|-----------------|
| `issues.opened` | Always | intake-governance |
| `issues.edited` | Always | intake-governance |
| `issues.labeled` | Always | intake-governance |
| `issues.labeled` | Label = sprint-planning | sprint-orchestration |
| `issues.labeled` | Label = production | release-control |
| `issues.labeled` | Label = production/sprint/risk | telegram-alerts |
| `issues.labeled` | Label = production | whatsapp-alerts |
| `pull_request.opened` | Always | intake-governance |
| `pull_request.closed` | merged == true | telegram-alerts, whatsapp-alerts |
| `pull_request.labeled` | Label = production | release-control |
| `workflow_dispatch` | Manual | sprint-orchestration (with issue_number) |

---

## 8. Configuration Model

### 8.1 Workflow Inputs (Complete)

| Workflow | Input | Default | Type |
|----------|-------|---------|------|
| intake-governance | `intake_label` | `intake` | string |
| sprint-orchestration | `sprint_planning_label` | `sprint-planning` | string |
| sprint-orchestration | `sprint_label` | `sprint` | string |
| sprint-orchestration | `intake_label` | `intake` | string |
| sprint-orchestration | `issue_number` | (from event) | number |
| sprint-orchestration | `enable_child_task_creation` | `false` | boolean |
| sprint-orchestration | `enable_milestone_assignment` | `false` | boolean |
| release-control | `release_approver` | `@release-approver` | string |
| release-control | `default_release_approver` | — | string |
| release-control | `production_label` | `production` | string |
| release-control | `enable_alerts` | `false` | boolean |
| release-control | `enable_telegram` | `false` | boolean |
| release-control | `enable_whatsapp` | `false` | boolean |
| telegram-alerts | `production_label` | `production` | string |
| telegram-alerts | `sprint_planning_label` | `sprint-planning` | string |
| telegram-alerts | `risk_label` | `risk` | string |
| telegram-alerts | `enable_telegram` | `false` | boolean |
| whatsapp-alerts | `production_label` | `production` | string |
| whatsapp-alerts | `enable_whatsapp` | `false` | boolean |

### 8.2 Secrets (All Optional)

| Secret | Used By |
|--------|---------|
| `TELEGRAM_BOT_TOKEN` | telegram-alerts, release-control |
| `TELEGRAM_CHAT_ID` | telegram-alerts, release-control |
| `WHATSAPP_ACCESS_TOKEN` | whatsapp-alerts, release-control |
| `WHATSAPP_PHONE_NUMBER_ID` | whatsapp-alerts, release-control |
| `WHATSAPP_RECIPIENT_NUMBER` | whatsapp-alerts, release-control |
| `TWILIO_ACCOUNT_SID` | whatsapp-alerts, release-control |
| `TWILIO_AUTH_TOKEN` | whatsapp-alerts, release-control |
| `TWILIO_WHATSAPP_NUMBER` | whatsapp-alerts, release-control |

---

## 9. Failure Modes & Recovery

| Failure Mode | Behavior |
|--------------|----------|
| Missing secrets (alerts) | Step exits 0; logs notice |
| Alert API failure | `continue-on-error: true`; workflow succeeds |
| Empty sprint body (child creation on) | Validation fails; exit 1 |
| Duplicate sprint orchestration | Prior check skips create/summary steps |
| No release approver | Posts "Approver Assignment Required" comment; no crash |
| Reusable workflow not found | Consumer workflow fails; fix by correcting `uses:` path/tag |
| GitHub API rate limit | Retried by Actions; eventual consistency |

---

## 10. Security Architecture

- **No hardcoded tokens** — All via `${{ secrets.* }}`
- **No hardcoded usernames** — Approvers from forms or inputs
- **Public-safe** — No org-specific or private data in repo
- **Least privilege** — Workflows request only `issues: write`, `pull-requests: write`, `contents: read` as needed
- **Secrets inheritance** — Consumer controls what is passed; org-level secrets optional

---

## 11. Versioning & Upgrade

| Aspect | Design |
|--------|--------|
| Tag format | `v1.0.0`, `v1.1.0`, `v2.0.0` |
| Consumer reference | `@v1` or `@v1.0.0` |
| Prohibited | `@main` in production |
| Upgrade path | Update `uses:` to new tag; test in staging |
| Backward compat | v1.x maintains input compatibility |

---

## 12. Extension Points

1. **New workflows** — Add `workflow_call` YAML; consumer adds trigger
2. **New labels** — Inputs for label names; no code change for new labels
3. **New alert channels** — Add job with `continue-on-error`; optional secrets
4. **New issue templates** — Add YAML to `.github/ISSUE_TEMPLATE/`; consumers copy manually
5. **Custom parsing** — Extend `actions/github-script` blocks with new regex/logic

---

## 13. Sequence Diagram: Full Release Path

```
User          GitHub         Consumer          Central Repo       Telegram
  │              │              │                    │                │
  │ Create       │              │                    │                │
  │ release-     │              │                    │                │
  │ approval     │              │                    │                │
  │ issue        │              │                    │                │
  │─────────────>│              │                    │                │
  │              │ issues.      │                    │                │
  │              │ labeled      │                    │                │
  │              │─────────────>│                    │                │
  │              │              │ if: production    │                │
  │              │              │ release-control   │                │
  │              │              │──────────────────>│                │
  │              │              │                    │ Parse body     │
  │              │              │                    │ Resolve @user  │
  │              │              │                    │ POST comment  │
  │              │              │                    │───────────────>│
  │              │              │                    │                │
  │              │              │                    │ (if enabled)  │
  │              │              │                    │ POST message  │
  │              │              │                    │───────────────────────────>│
  │              │              │                    │                │
  │              │              │<───────────────────│                │
  │              │              │                    │                │
  │              │              │ block-merge-check  │                │
  │              │              │──────────────────>│                │
  │              │              │                    │ List comments  │
  │              │              │                    │ Check approval│
  │              │              │<───────────────────│                │
```

---

*Document version: 1.0 | Last updated: 2026*
