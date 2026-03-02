# How To Guide

Step-by-step instructions for common tasks with the Delivery Operating System.

---

## STEP-BY-STEP: Install Delivery OS Into Another Repo

You have 3 ways. The recommended path is Option A.

---

### OPTION A — Recommended (Installer Script)

Use this if you're comfortable with the terminal.

#### Step 1: Clone Both Repositories Locally

You need:

- The Delivery OS repo
- The repo you want to install it into (your consumer repo)

```bash
git clone https://github.com/jkaweesi22/github-delivery-operating-system
git clone https://github.com/YOUR-USERNAME/YOUR-CONSUMER-REPO
```

Replace `YOUR-USERNAME` and `YOUR-CONSUMER-REPO` with your GitHub username and repo name.

#### Step 2: Run the Installer

Go into the Delivery OS folder:

```bash
cd github-delivery-operating-system
```

Then run:

```bash
REPO_ORG=jkaweesi22 ./scripts/install.sh ../YOUR-CONSUMER-REPO
```

**What this does:**

- Copies all 5 trigger workflows into your consumer repo
- Replaces `your-org` with `jkaweesi22` in each file
- Installs workflow files automatically

**Optional — include issue templates** (Delivery Intake, Bug Report, Sprint Planning, etc.):

```bash
REPO_ORG=jkaweesi22 ./scripts/install.sh --with-templates ../YOUR-CONSUMER-REPO
```

If you're using a fork, replace `jkaweesi22` with your fork owner.

#### Step 3: Commit & Push in Consumer Repo

```bash
cd ../YOUR-CONSUMER-REPO
git add .
git commit -m "Install Delivery OS"
git push
```

#### Step 4: Add Required Labels

In your consumer repo on GitHub:

1. Go to **Issues** → **Labels** → **New label**
2. Create these labels:

| Label | Color |
|-------|-------|
| intake | 0E8A16 |
| bug | D93F0B |
| sprint | 1D76DB |
| qa | FBCA04 |
| production | D93F0B |
| risk | B60205 |
| sprint-planning | 5319E7 |

Or via terminal (from your consumer repo): `gh label create intake --color 0E8A16` (repeat for each).

#### Step 5: Ensure a Tag Exists in Delivery OS Repo

In the [Delivery OS repo](https://github.com/jkaweesi22/github-delivery-operating-system):

1. Go to **Releases** → **Create new release**
2. Tag: `v1.0.0`
3. Publish

Workflows reference `@v1`. Without a tag, workflows will fail.

---

### OPTION B — No Terminal (GitHub Web Only)

Use this if you don't want to use the command line.

#### Step 1: Create Workflow Files in Consumer Repo

In your consumer repo:

1. Click **Add file** → **Create new file**
2. Create path: `.github/workflows/delivery-os-intake-governance.yml`
3. Go to [Delivery OS examples](https://github.com/jkaweesi22/github-delivery-operating-system/tree/main/examples)
4. Open each `trigger-*.yml` file
5. Click **Raw**
6. Copy the content
7. Paste into your new file
8. Replace `your-org` with `jkaweesi22` in the `uses:` line
9. Commit the file

Repeat for all 5 triggers: `trigger-intake-governance`, `trigger-sprint-orchestration`, `trigger-release-control`, `trigger-telegram-alerts`, `trigger-whatsapp-alerts`. Create files named `delivery-os-intake-governance.yml`, `delivery-os-sprint-orchestration.yml`, etc.

#### Step 2: Add Labels

Same as Option A, Step 4 — create all 7 labels via **Issues** → **Labels**.

#### Step 3: Ensure Tag Exists

Create `v1.0.0` release in the Delivery OS repo if it doesn't exist.

---

### OPTION C — Manual Copy (Command Line)

If you prefer to copy files yourself:

1. Create `.github/workflows/` in your consumer repo
2. Copy each `examples/trigger-*.yml` → `.github/workflows/delivery-os-*.yml`
3. In each file, replace `your-org` with `jkaweesi22`
4. Add labels (same as Option A, Step 4)

---

### After Installation — How It Works

Once installed:

| When you... | Delivery OS does... |
|-------------|---------------------|
| Create issue with intake | Governance comment posted |
| Create sprint issue | Validates sprint |
| Add `production` label | Triggers release approval logic |
| Approver comments "Approved for production" | Signals release approval |
| Enable alerts (Telegram/WhatsApp) | Sends notifications on key events |

---

### REPO_ORG (Reference)

`REPO_ORG` is the GitHub organization or username that owns the Delivery OS repo. The installer uses it to replace `your-org` in trigger files. For this repo: `REPO_ORG=jkaweesi22`.

---

### Other Cases

| Situation | What to do |
|-----------|------------|
| You forked the Delivery OS repo | Use your org as `REPO_ORG` (e.g. `REPO_ORG=my-org`). |
| You only want some workflows | Run the installer, then delete the `delivery-os-*.yml` files you don't need. |
| Consumer repo in a different folder | Use full path: `./scripts/install.sh /path/to/consumer-repo` |

---

### Installation Options: All vs Separate

#### Install all templates

```bash
REPO_ORG=jkaweesi22 ./scripts/install.sh --with-templates ../YOUR-CONSUMER-REPO
```

Copies all 7 templates: `delivery-intake.yml`, `bug-report.yml`, `sprint-planning.yml`, `risk-review.yml`, `qa-request.yml`, `release-approval.yml`, `config.yml`.

---

#### Install separate templates (only some)

The installer doesn't support picking individual templates. Use manual copy:

1. Go to [Delivery OS issue templates](https://github.com/jkaweesi22/github-delivery-operating-system/tree/main/.github/ISSUE_TEMPLATE)
2. Open each template you want (e.g. `bug-report.yml`), click **Raw**
3. In your consumer repo: **Add file** → **Create new file** → `.github/ISSUE_TEMPLATE/bug-report.yml`
4. Paste the content and commit

**Available templates:**

| Template | Use for |
|----------|---------|
| delivery-intake.yml | Feature requests and bugs (combined form) |
| bug-report.yml | Bug reports with steps to reproduce |
| sprint-planning.yml | Sprint creation with deliverables |
| risk-review.yml | Production release request with QA rec |
| qa-request.yml | QA review request with QA Reviewer |
| release-approval.yml | Release approval with Release Approver |
| config.yml | Blank issues + contact links (optional) |

---

#### Install separate workflows (only some)

**Option 1 — Install all, then remove**

```bash
REPO_ORG=jkaweesi22 ./scripts/install.sh ../YOUR-CONSUMER-REPO
cd ../YOUR-CONSUMER-REPO
rm .github/workflows/delivery-os-telegram-alerts.yml    # Remove ones you don't need
rm .github/workflows/delivery-os-whatsapp-alerts.yml
```

**Option 2 — Manual copy of specific triggers**

1. Go to [Delivery OS examples](https://github.com/jkaweesi22/github-delivery-operating-system/tree/main/examples)
2. Copy only the `trigger-*.yml` files you need
3. Save as `delivery-os-*.yml` in `.github/workflows/` of your consumer repo
4. Replace `your-org` with `jkaweesi22` in each file

**Available workflows:**

| Workflow | Trigger file | Purpose |
|----------|--------------|---------|
| Intake governance | trigger-intake-governance.yml | Apply intake label, post acknowledgment |
| Sprint orchestration | trigger-sprint-orchestration.yml | Parse sprint deliverables, optional child issues |
| Release control | trigger-release-control.yml | Approval gate, QA parsing, approver tagging |
| Telegram alerts | trigger-telegram-alerts.yml | Notifications (PR merged, production/sprint/risk labels) |
| WhatsApp alerts | trigger-whatsapp-alerts.yml | Notifications (PR merged, production label) |

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
