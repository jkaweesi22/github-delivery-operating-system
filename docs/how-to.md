# How To Guide

Step-by-step instructions for common tasks with the Delivery Operating System.

---

## First-Time Setup (Use in Another Repo)

### REPO_ORG

**REPO_ORG** is the GitHub organization or username that owns the Delivery OS repository. It appears in the `uses:` path of trigger workflows:

```
uses: REPO_ORG/github-delivery-operating-system/.github/workflows/<workflow>.yml@v1
```

- **This repository:** [https://github.com/jkaweesi22/github-delivery-operating-system](https://github.com/jkaweesi22/github-delivery-operating-system) → `REPO_ORG=jkaweesi22`
- **Organization example:** `https://github.com/acme-corp/github-delivery-operating-system` → `REPO_ORG=acme-corp`
- **Personal account example:** `https://github.com/johndoe/github-delivery-operating-system` → `REPO_ORG=johndoe`

The installer replaces `your-org` in trigger files with the value of `REPO_ORG`. If omitted, workflows will fail until you edit them manually.

---

Before you can use the Delivery OS in a repository:

1. **Install the trigger workflows** — From the Delivery OS repo, run:
   ```bash
   REPO_ORG=jkaweesi22 ./scripts/install.sh /path/to/your-repo
   ```
   Or `./scripts/install.sh .` when run from inside your consumer repo. Replace `jkaweesi22` with your GitHub org or username if using a different source repo. See [Consumer Setup](consumer-setup.md) for full instructions.
2. **Create a release tag** in the Delivery OS repo: `git tag v1.0.0 && git push origin v1.0.0`
3. **Add labels** in your consumer repo:
   ```bash
   gh label create intake --color "0E8A16"
   gh label create bug --color "D93F0B"
   gh label create sprint --color "1D76DB"
   gh label create qa --color "FBCA04"
   gh label create production --color "D93F0B"
   gh label create risk --color "B60205"
   gh label create sprint-planning --color "5319E7"
   ```
4. **Copy issue templates** (optional) — To use structured forms like "Delivery Intake", "Bug Report", or "Release Approval", copy `.github/ISSUE_TEMPLATE/*.yml` from this repo into your repo's `.github/ISSUE_TEMPLATE/`. Without templates, you can still use labels and workflows; forms just make data capture structured.

Once installed, the sections below show how to use the system day-to-day.

---

## Ways to Integrate

---

### Option A: Run the installer (most automated)

One command copies all workflow files with the correct names and org. Both repos must exist **locally** (cloned on your machine).

1. Clone both repos locally (if not already):

   ```bash
   git clone https://github.com/jkaweesi22/github-delivery-operating-system
   git clone https://github.com/you/your-project    # your consumer repo
   ```

2. From the Delivery OS folder, run the installer:

   ```bash
   cd github-delivery-operating-system
   REPO_ORG=jkaweesi22 ./scripts/install.sh ../your-project
   ```

   The installer creates all 5 trigger workflows in your consumer repo and substitutes `jkaweesi22`. `../your-project` is the path to your consumer repo (use a relative or absolute path).

3. Add labels in your consumer repo (via UI or `gh label create`), then commit and push.

---

### Option B: GitHub Web UI (no command line)

Integrate entirely in the browser:

1. **Create workflow files** in your consumer repo:
   - Go to your repo → **Add file** → **Create new file**
   - Enter `.github/workflows/delivery-os-intake-governance.yml` (create the folder if prompted)
   - Copy content from [Delivery OS examples](https://github.com/jkaweesi22/github-delivery-operating-system/tree/main/examples) — open each `trigger-*.yml`, click **Raw**, copy the text
   - Create files named `delivery-os-intake-governance.yml`, `delivery-os-sprint-orchestration.yml`, etc. (one per trigger)
   - In each file, replace `your-org` with `jkaweesi22` in the `uses:` line

2. **Create labels**:
   - Go to your repo → **Issues** → **Labels** → **New label**
   - Add: `intake` (0E8A16), `bug` (D93F0B), `sprint` (1D76DB), `qa` (FBCA04), `production` (D93F0B), `risk` (B60205), `sprint-planning` (5319E7)

3. **Ensure a tag exists** in the Delivery OS repo — the workflows reference `@v1`. If none exists, create one: **Releases** → **Create a new release** → tag `v1.0.0`.

4. **Optional:** Copy issue templates from `.github/ISSUE_TEMPLATE/` in the Delivery OS repo into your repo via **Add file** → **Upload files** or **Create new file**.

---

### Option C: Manual copy (command line)

Skip the installer and copy files yourself:

1. In your consumer repo, create `.github/workflows/` if it doesn't exist.
2. Copy each `examples/trigger-*.yml` → `.github/workflows/delivery-os-*.yml`.
3. In each file, replace `your-org` with `jkaweesi22` (or your fork's org).
4. Add labels in your consumer repo.

---

### Other cases

| Situation | What to do |
|-----------|------------|
| You forked the Delivery OS repo | Use your org as `REPO_ORG` when running the installer (e.g. `REPO_ORG=my-org`). |
| You only want some workflows | Run the installer, then delete the `delivery-os-*.yml` files you don't need. |
| Consumer repo is in a different folder | Use the full path: `./scripts/install.sh /Users/me/other-folder/my-project` |

---

## Prerequisites (For Day-to-Day Use)

- The Delivery OS is installed in your repository (see [Consumer Setup](consumer-setup.md))
- You have the required labels: `intake`, `bug`, `sprint`, `qa`, `production`, `risk`, `sprint-planning`
- Issue templates are available (copy from this repo's `.github/ISSUE_TEMPLATE/` if needed)

---

## How to Submit a Feature Request or Bug Report

### Option A: Delivery Intake (combined form)

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

### Option B: Bug Report (dedicated form)

1. Go to your repository on GitHub.
2. Click **Issues** → **New issue**.
3. Select **Bug Report**.
4. Fill in the required fields:
   - **Summary:** Brief title describing the bug
   - **Environment:** Development, Staging, Production, or All
   - **Steps to Reproduce:** Numbered steps to reproduce the bug
   - **Current Behavior:** What actually happens
   - **Expected Behavior:** What should happen
   - **Priority:** Low, Medium, High, or Critical
   - **Acceptance Criteria:** What "fixed" looks like (testable conditions)
5. Click **Submit new issue**.

**What happens:** The issue receives the `intake` and `bug` labels and a governance acknowledgment comment is posted.

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

**Alternative:** Add the `production` label to an existing issue (e.g., from the Risk Review template) that contains sprint reference and QA recommendation. The Release Approver will be taken from your workflow's `default_release_approver` or `release_approver` input, since Risk Review does not include that field.

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
| Install in another repo | Run installer (Option A) or use GitHub UI; add labels |
| Submit feature | New issue → Delivery Intake |
| Report bug | New issue → Bug Report (or Delivery Intake) |
| Create sprint | New issue → Sprint Planning |
| Request release | New issue → Release Approval (or add `production` to existing) |
| Approve release | Comment `Approved for production` or `Release approved` |
| Enable alerts | Add secrets + set `enable_telegram` / `enable_whatsapp` in triggers |
| Enable child tasks | Set `enable_child_task_creation: true` in sprint trigger |
| Uninstall | Delete `delivery-os-*.yml` workflows |

---

For integration and configuration details, see [Consumer Setup](consumer-setup.md).
