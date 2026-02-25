# How To Guide

Step-by-step instructions for common tasks with the Delivery Operating System.

---

## Prerequisites

- The Delivery OS is installed in your repository (see [Consumer Setup](consumer-setup.md))
- You have the required labels: `intake`, `sprint`, `qa`, `production`, `risk`, `sprint-planning`
- Issue templates are available (copy from `.github/ISSUE_TEMPLATE/` if needed)

---

## How to Submit a Feature Request or Bug Report

1. Go to your repository on GitHub.
2. Click **Issues** → **New issue**.
3. Select **Delivery Intake** (or the intake form your repo uses).
4. Fill in the required fields:
   - **Intake Type:** Feature Request or Bug Report
   - **Summary:** Short title
   - **Description:** Detailed description (for bugs: current vs expected behavior, steps to reproduce)
   - **Priority:** Low, Medium, High, or Critical
   - **Acceptance Criteria:** Testable conditions for done
5. Click **Submit new issue**.

**What happens:** The issue receives the `intake` label and a governance acknowledgment comment is posted.

---

## How to Create a Sprint

1. Go to **Issues** → **New issue**.
2. Select **Sprint Planning**.
3. Fill in:
   - **Sprint Name:** e.g., Sprint 12, Q1 Release
   - **Deliverables:** One item per line, using `-` or numbers:
     ```
     - Implement user authentication
     - Add API rate limiting
     - Refactor payment module
     ```
   - **Target End Date:** Expected sprint completion
4. Click **Submit new issue**.

**What happens:**

- The issue gets `intake` and `sprint-planning` labels.
- If **child task creation** is enabled in your trigger workflow, the Delivery OS will:
  - Parse each deliverable line
  - Create a child issue for each
  - Post a Sprint Health Summary comment with links to child issues.
- If child creation is disabled (default), the sprint issue is validated and no child issues are created.

---

## How to Request Release Approval

1. Ensure you have a sprint planning issue (e.g., #12).
2. Go to **Issues** → **New issue**.
3. Select **Release Approval**.
4. Fill in:
   - **Sprint Reference:** e.g., `#12`
   - **QA Recommendation:** Approve, Reject, or Conditional
   - **Risk Summary:** Risks and mitigations, rollback plan
   - **Release Approver GitHub Username:** e.g., `@your-release-approver`
5. Click **Submit new issue**.

**What happens:** The issue receives `intake`, `production`, and `risk` labels. The Delivery OS posts an approval comment mentioning the Release Approver and asks them to comment `Approved for production` or `Release approved` to sign off.

**Alternative:** Add the `production` label to an existing issue (e.g., from the Risk Review template) that already contains the required fields. The release-control workflow will parse it and post the approval gate.

---

## How to Approve a Release

If you are the Release Approver:

1. Open the release approval issue or PR with the `production` label.
2. Review the QA recommendation and risk summary in the approval comment.
3. Add a comment with one of:
   - `Approved for production`
   - `Release approved`
4. Merge the PR when ready (or close the issue if it was an issue-based release request).

**Note:** The Delivery OS posts an advisory notice if no approval comment is found. Use branch protection rules to require approvals before merge.

---

## How to Enable Telegram or WhatsApp Alerts

1. **Configure secrets** in your repository:
   - **Telegram:** `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`
   - **WhatsApp (Meta):** `WHATSAPP_ACCESS_TOKEN`, `WHATSAPP_PHONE_NUMBER_ID`, `WHATSAPP_RECIPIENT_NUMBER`
   - **WhatsApp (Twilio):** `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_WHATSAPP_NUMBER`, `WHATSAPP_RECIPIENT_NUMBER`

2. **Update your trigger workflows** to pass the enable flags:

   **Release Control** (alerts on production label):
   ```yaml
   with:
     enable_alerts: true
     enable_telegram: true    # or false
     enable_whatsapp: true   # or false
   ```

   **Standalone Telegram Alerts** (PR merged, production/sprint/risk labels):
   ```yaml
   with:
     enable_telegram: true
   ```

   **Standalone WhatsApp Alerts** (PR merged, production label):
   ```yaml
   with:
     enable_whatsapp: true
   ```

3. See [Alerting Integrations](alerting-integrations.md) for setup details (Telegram BotFather, Meta/Twilio accounts).

---

## How to Enable Child Task Creation for Sprints

By default, sprint orchestration does **not** create child issues. To enable:

1. Open `.github/workflows/delivery-os-sprint-orchestration.yml` in your repo.
2. Add or update the `with:` block:
   ```yaml
   with:
     enable_child_task_creation: true
     enable_milestone_assignment: true   # optional: assign parent milestone to children
   ```
3. Save and commit. New sprint issues with `sprint-planning` label will trigger child creation.

**When to use:** You manage tasks in GitHub Issues and want one child issue per deliverable.  
**When not to use:** You use Jira, Linear, or other tools for task tracking.

---

## How to Use a QA Request Form

1. Go to **Issues** → **New issue**.
2. Select **QA Request**.
3. Fill in:
   - **Title:** Brief summary
   - **Feature / Issue Reference:** e.g., `#42`
   - **Environment:** Development, Staging, Production, or All
   - **Test Scope:** What to test and how
   - **Risk Assessment:** Low, Medium, High, or Critical
   - **QA Recommendation:** Approve, Reject, or Conditional
   - **QA Reviewer GitHub Username:** e.g., `@qa-reviewer`
4. Click **Submit new issue**.

**What happens:** The issue is tagged for QA with `intake` and `qa` labels. The QA Reviewer is tagged for attention.

---

## How to Uninstall the Delivery OS

1. **Delete these workflow files** from `.github/workflows/`:
   - `delivery-os-release-control.yml`
   - `delivery-os-sprint-orchestration.yml`
   - `delivery-os-intake-governance.yml`
   - `delivery-os-telegram-alerts.yml`
   - `delivery-os-whatsapp-alerts.yml`

2. **Remove secrets** (optional): Settings → Secrets and variables → Actions. Remove `TELEGRAM_*`, `WHATSAPP_*`, `TWILIO_*` if you added them.

3. **Commit and push.** The workflows will stop running. Existing issues, labels, and comments are unchanged.

The central Delivery OS repository is not modified. You can reinstall later by running the installer or copying triggers again.

---

## Quick Reference

| Task | Action |
|------|--------|
| Submit feature/bug | New issue → Delivery Intake |
| Create sprint | New issue → Sprint Planning |
| Request release | New issue → Release Approval (or add `production` to existing) |
| Approve release | Comment `Approved for production` or `Release approved` |
| Enable alerts | Add secrets + set `enable_telegram` / `enable_whatsapp` in triggers |
| Enable child tasks | Set `enable_child_task_creation: true` in sprint trigger |
| Uninstall | Delete `delivery-os-*.yml` workflows |

---

For integration and configuration details, see [Consumer Setup](consumer-setup.md).
