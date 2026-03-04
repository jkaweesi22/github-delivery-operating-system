# GitHub Delivery Operating System

> A GitHub-native Delivery Governance Framework for structured sprint execution, QA review, and collaborative production release control.

**Repository:** [https://github.com/jkaweesi22/github-delivery-operating-system](https://github.com/jkaweesi22/github-delivery-operating-system)

---

## Why This Exists

Engineering teams often rely on informal coordination inside GitHub — manual approvals, inconsistent sprint tracking, reactive QA engagement, and socially enforced production releases.

As teams scale, this creates:

* Delivery ambiguity
* QA bottlenecks
* Unclear accountability
* Release risk
* Cross-team misalignment

GitHub provides powerful primitives (issues, labels, workflows, Actions), but it does not provide a structured delivery governance layer.

The **GitHub Delivery Operating System (Delivery OS)** introduces that layer.

It embeds structured intake, sprint orchestration, QA governance, and collaborative release gates directly into engineering repositories — without replacing CI/CD pipelines or disrupting developer workflows.

It strengthens delivery discipline while preserving team autonomy.

---

## Designed for Teams That Want Structure Without Expanding Tooling

Many teams already use GitHub for:

* Issues
* Pull requests
* Labels
* GitHub Actions
* Project boards

However:

* Some teams underutilize these capabilities
* Some are unaware of what GitHub natively supports
* Some use them inconsistently without governance structure

The problem is often not missing tools — it is missing structure.

The Delivery OS enables teams to achieve operational order and structured delivery using the tools they already have — without purchasing additional SaaS platforms or introducing process-heavy overhead.

---

## System Features

The Delivery OS includes the following core capabilities:

---

### 1. Reusable Governance Workflows (`workflow_call` Based)

* Centralized reusable workflow library
* Consumer repositories integrate via lightweight trigger workflows
* No duplication of workflow files
* Non-destructive integration
* Executed in consumer repository context

---

### 2. Lifecycle Label Governance

Standardized lifecycle flow:

```
intake → sprint → qa → production → approved / rejected
  bug
```

* Automatic intake labeling
* Label-driven automation triggers
* Consistent lifecycle enforcement across repositories

---

### 3. Structured Issue Templates

Predefined templates for:

* Sprint planning (features one per line, sprint goal, approval status)
* Task (owner, priority, status, acceptance criteria)
* Bug report (platform, severity, steps to reproduce)
* QA request (related issue, test scope, artifacts)
* Production release & QA sign-off (sprint reference, version, QA recommendation)

Templates capture:

* Risk classification
* Acceptance criteria
* QA recommendation
* Dual approval (release approver + QA lead) — configurable usernames

No hardcoded users — fully configurable.

---

### 4. Sprint Orchestration Engine

* Detects sprint planning issues (title "SPRINT -" or labels)
* Parses Sprint Features (one per line, no bullets)
* Optionally generates structured child issues with "Parent Sprint: #N"
* Prevents duplicate orchestration
* Supports milestone propagation
* Posts sprint health summaries
* Auto-close sprint when 100% complete (with burn-down tracking)

Optional features (disabled by default):

* Child task creation
* Milestone assignment
* Auto-close sprint when all children complete

---

### 5. QA Governance Workflow

* Requires QA recommendation documentation
* Supports QA reviewer tagging
* Formalizes QA-to-production handoffs
* Ensures QA visibility before release

---

### 6. Release Control & Approval Gates

* Triggered by production label
* Parses sprint reference from issue body
* Parses QA recommendation
* Dynamically resolves Release Approver
* Tags approver automatically
* Requires explicit approval comment
* Creates auditable approval record

Approval resolution order:

1. Issue body
2. `default_release_approver`
3. `release_approver` input
4. Fallback notification if none found

---

### 7. Optional Operational Alerting

Modular integrations:

* Telegram notifications
* WhatsApp notifications (Meta or Twilio)
* PR merge visibility
* Production label alerts

Alerting is:

* Optional
* Secret-driven
* Non-blocking
* Disabled by default

Governance does not depend on external messaging tools.

---

### 8. Non-Destructive Integration Model

* Never overwrites existing workflows
* Installer aborts on conflict
* Additive adoption only
* Fully reversible

---

### 9. Security & Access Control

* No hardcoded tokens
* No hardcoded usernames
* All secrets injected via `${{ secrets.* }}`
* Minimal required workflow permissions
* Public-safe architecture

---

### 10. Semantic Versioning & Stability

* Tagged releases (`v1.x`)
* Consumers use `@main` for latest, or pin to `@v1.0.0` for production
* Backward compatibility within major versions

Ensures governance stability across repositories.

---

## Leadership & Collaboration Impact

This system was designed to:

* Strengthen collaboration between Engineering, QA, and Program teams
* Clarify ownership and approval accountability
* Reduce reliance on tribal knowledge
* Support TPM oversight without micromanagement
* Scale governance consistently across repositories

It transforms coordination from informal conversation into structured collaboration.

---

## What It Is

A GitHub-native delivery governance framework that embeds structured sprint discipline, QA workflows, and production approval gates directly into engineering repositories.

---

## What It Is Not

* Not a CI/CD replacement
* Not a project management tool
* Not a SaaS dashboard
* Not a rigid workflow engine

It enhances governance — it does not replace tooling.

---

## Architecture Overview

```
Consumer Repository
    │
    ├─ Lightweight Trigger Workflow
    │
    ▼
Central Delivery OS Repository
    ├─ Intake Governance
    ├─ Sprint Orchestration
    ├─ QA & Release Control
    └─ Optional Alerting Layer
```

Reusable workflows execute in the consumer repository context with no disruption to existing pipelines.

---

## Intended Audience

* Technical Program Managers
* QA Leaders
* Engineering Managers
* Platform Teams
* Organizations seeking structured delivery governance without expanding tooling

---

## Installation

### Option A: Safe Installer

```bash
gh repo clone https://github.com/jkaweesi22/github-delivery-operating-system
cd github-delivery-operating-system

REPO_ORG=jkaweesi22 ./scripts/install.sh --with-templates --with-labels /path/to/your-repo
```

Add `--with-templates` and/or `--with-labels` as needed. For labels: **Actions → Setup Labels → Run workflow** (no token needed).

### Option B: Manual Copy

1. Copy trigger files from `examples/` to `.github/workflows/` in your repo
2. Replace `your-org` with your org/username
3. Workflows use `@main` by default; optionally create a tag for pinning

**See [Consumer Setup Guide](docs/consumer-setup.md)** for full integration steps, secret configuration, and uninstall instructions.

---

## Documentation

| Document | Description |
|----------|-------------|
| [Consumer Setup](docs/consumer-setup.md) | Integration, triggers, secrets, uninstall |
| [How To Guide](docs/how-to.md) | Step-by-step: submit intake, create sprint, request approval, enable alerts, uninstall |
| [Architecture](docs/architecture.md) | System design, reusable workflow flow |
| [Governance Model](docs/governance-model.md) | Lifecycle, approval gates |
| [Release Lifecycle](docs/release-lifecycle.md) | Intake → Sprint → QA → Production |
| [Alerting Integrations](docs/alerting-integrations.md) | Telegram, WhatsApp setup |
| [QA & Approval Workflow](docs/qa-approval-workflow.md) | QA forms, dynamic tagging, approver config |
| [System Design](docs/system-design.md) | Detailed architecture, components, data flows |

---

## Short Positioning Summary

The GitHub Delivery Operating System is a reusable governance framework that embeds structured sprint execution, QA review workflows, and collaborative production approval gates into engineering repositories — improving delivery clarity, accountability, and cross-functional alignment without expanding the tooling footprint.

---

## License

MIT License. See [LICENSE](LICENSE) for details.
