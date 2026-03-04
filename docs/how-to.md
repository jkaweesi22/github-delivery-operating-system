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

- Copies all trigger workflows into your consumer repo
- Replaces `your-org` with `jkaweesi22` in each file
- Installs workflow files automatically

**Optional flags:**
- `--with-templates` — include issue templates (Sprint Planning, Task, Bug Report, QA Request, Production Release)
- `--with-labels` — auto-create labels in consumer repo (requires `gh` CLI and target must be a git repo)

```bash
REPO_ORG=jkaweesi22 ./scripts/install.sh --with-templates ../YOUR-CONSUMER-REPO
REPO_ORG=jkaweesi22 ./scripts/install.sh --with-labels ../YOUR-CONSUMER-REPO
# Or both:
REPO_ORG=jkaweesi22 ./scripts/install.sh --with-templates --with-labels ../YOUR-CONSUMER-REPO
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
| planning | 5319E7 |
| sprint-planning | 5319E7 |
| task | 7057FF |
| qa | FBCA04 |
| qa-request | FBCA04 |
| production | D93F0B |
| release | B60205 |
| approval | 0E8A16 |
| ready-for-deploy | 0E8A16 |
| risk | B60205 |

Or via terminal (from your consumer repo):

```bash
# Option 1: Use the create-labels script (recommended)
cd /path/to/your-consumer-repo
bash /path/to/github-delivery-operating-system/scripts/create-labels.sh

# Option 2: Manual commands
gh label create intake --color 0E8A16
gh label create bug --color D93F0B
# ... (repeat for each label — see install.sh or create-labels.sh for full list)
```

#### Step 5: Ensure a Tag Exists in Delivery OS Repo

In the [Delivery OS repo](https://github.com/jkaweesi22/github-delivery-operating-system):

1. Go to **Releases** → **Create new release**
2. Tag: `v1.0.0`
3. Publish

Workflows reference `@main` by default and work immediately. Use `@v1.0.0` to pin to a tag for production stability.

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

Repeat for all triggers: `trigger-intake-governance`, `trigger-sprint-orchestration`, `trigger-sprint-child-creator`, `trigger-release-control`, `trigger-auto-close-sprint`, `trigger-notify-release-approver`, `trigger-authorize-deployment`, `trigger-telegram-alerts`, `trigger-whatsapp-alerts`. Create files named `delivery-os-intake-governance.yml`, `delivery-os-sprint-orchestration.yml`, etc.

#### Step 2: Add Labels

Same as Option A, Step 4 — create labels via **Issues** → **Labels**, or run `scripts/create-labels.sh` from your consumer repo.

#### Step 3: Ensure Tag Exists

Create `v1.0.0` release in the Delivery OS repo if it doesn't exist.

---

### OPTION C — Manual Copy (Command Line)

If you prefer to copy files yourself:

1. Create `.github/workflows/` in your consumer repo
2. Copy each `examples/trigger-*.yml` → `.github/workflows/delivery-os-*.yml`
3. In each file, replace `your-org` with `jkaweesi22`
4. Add labels: run `scripts/create-labels.sh` from consumer repo, or create manually (see Option A, Step 4)

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

#### Auto-create labels

Requires `gh` CLI and target must be a git repo with GitHub remote:

```bash
REPO_ORG=jkaweesi22 ./scripts/install.sh --with-labels ../YOUR-CONSUMER-REPO
```

If labels are skipped (e.g. `gh` not authenticated or repo not on GitHub), run the standalone script from your consumer repo:

```bash
cd ../YOUR-CONSUMER-REPO
bash /path/to/github-delivery-operating-system/scripts/create-labels.sh
```

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
| sprint-planning.yml | Sprint creation with features (one per line) |
| task.yml | Structured tasks with owner, priority, acceptance criteria |
| bug-report.yml | Bug reports with platform, severity, steps to reproduce |
| qa-request.yml | QA testing request for sprint tasks or bug fixes |
| production-release-qa-signoff.yml | Production release governance & QA sign-off |
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
| Sprint orchestration | trigger-sprint-orchestration.yml | Parse sprint features, optional child issues |
| Sprint child creator | trigger-sprint-child-creator.yml | Create child issues on sprint open (title "SPRINT -") |
| Release control | trigger-release-control.yml | Approval gate, QA parsing, approver tagging |
| Auto close sprint | trigger-auto-close-sprint.yml | Update burn-down, auto-close when 100% complete |
| Notify release approver | trigger-notify-release-approver.yml | Ping approver when production release opened |
| Authorize deployment | trigger-authorize-deployment.yml | Dual approval (release approver + QA lead) |
| Telegram alerts | trigger-telegram-alerts.yml | Notifications (PR merged, production/sprint labels) |
| WhatsApp alerts | trigger-whatsapp-alerts.yml | Notifications (PR merged, production label) |

---

## Prerequisites (For Day-to-Day Use)

- The Delivery OS is installed in your repository (see [Consumer Setup](consumer-setup.md))
- You have the required labels: `intake`, `bug`, `sprint`, `planning`, `sprint-planning`, `task`, `qa`, `qa-request`, `production`, `release`, `approval`
- Issue templates are available (copy from this repo's `.github/ISSUE_TEMPLATE/` if needed)

---

## How to Submit a Task or Bug Report

### Option A: Task (structured form)

1. Go to your repository on GitHub.
2. Click **Issues** → **New issue**.
3. Select **Task**.
4. Fill in the required fields:
   - **Task Summary:** One-line description
   - **Description:** Context and details
   - **Priority:** P0–P3
   - **Status:** Backlog, In Progress, Blocked, Ready for Review, or Done
   - **Acceptance Criteria:** What "done" looks like
5. Click **Submit new issue**.

**What happens:** The issue receives the `task` label and a governance acknowledgment comment is posted.

### Option B: Bug Report (dedicated form)

1. Go to your repository on GitHub.
2. Click **Issues** → **New issue**.
3. Select **Bug Report**.
4. Fill in the required fields:
   - **Platform(s) Affected:** Android, iOS, Web, or Backend/API
   - **Severity:** P0–P3 (Blocker, Critical, Major, Minor)
   - **Build/Version:** e.g. 4227, v1.3.0
   - **Bug Summary:** One clear sentence
   - **Steps to Reproduce:** Numbered steps
   - **Expected Result** and **Actual Result**
   - **Test Environment:** Device, OS, browser, etc.
5. Click **Submit new issue**.

**What happens:** The issue receives the `bug` and `qa` labels and a governance acknowledgment comment is posted.

---

## How to Create a Sprint

1. Go to **Issues** → **New issue**.
2. Select **Sprint Planning**.
3. Fill in:
   - **Sprint Name:** e.g., Sprint 12 - March 1–14
   - **Sprint Dates:** YYYY-MM-DD to YYYY-MM-DD
   - **Sprint Goal:** What this sprint aims to achieve
   - **Sprint Features (One Per Line):** One feature per line, no bullets or numbers:
     ```
     Implement burn-down chart
     Add sprint health indicator
     Prevent duplicate child creation
     ```
   - **Sprint Approved:** Pending, Approved, or Rejected
4. Click **Submit new issue**.

**What happens:**

- The issue gets `sprint`, `planning`, and `sprint-planning` labels.
- If **child task creation** is enabled in your trigger workflow, the Delivery OS will:
  - Parse each feature line from the Sprint Features section
  - Create a child issue for each (with "Parent Sprint: #N" link)
  - Post a Sprint Health Summary comment with links to child issues.
- If **auto close sprint** is enabled, closing child issues updates burn-down and auto-closes the sprint when 100% complete.

---

## How to Request Production Release

1. Ensure you have a sprint planning issue (e.g., #12).
2. Go to **Issues** → **New issue**.
3. Select **Production Release & QA Sign-Off**.
4. Fill in:
   - **Sprint Reference:** e.g., `#45`
   - **Version / Build Number:** e.g., v2.4.1
   - **Release Summary:** What's in this release
   - **QA Summary + Evidence Links:** Link QA issues, screenshots, logs
   - **Overall QA Recommendation:** Approve for Production, Reject Release, or Conditional Approval
   - **Deployment Authorized:** Yes or No
5. Click **Submit new issue**.

**What happens:** The issue receives `release`, `production`, and `approval` labels. The Delivery OS posts an approval comment and (if configured) notifies the release approver. For **dual approval**, both the release approver and QA lead must comment approval before deployment is authorized.

---

## How to Approve a Release

**Single approval:** If you are the Release Approver, comment `Approved for production` or `Release approved` on the production release issue.

**Dual approval (Min Allan + QA Lead):** When using `trigger-authorize-deployment.yml`, both approvers must comment:
- Release approver: `approved`, `approve`, `ok`, or `go ahead`
- QA lead: `qa approved`, `approved`, `qa ok`, or `looks good`

Once both approve, the issue receives the `ready-for-deploy` label. To decline, the release approver comments `declined`, `reject`, or `not approved`.

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
   - **Related Sprint Task Issue (#):** e.g., `#101`
   - **What to Test:** Test scope and steps
   - **Environment + Build Link:** Staging build, TestFlight/APK/Web URL
   - **Acceptance Criteria:** Expected behavior, edge cases
   - **Artifacts:** Screenshots, Logs, Video Recording, Crash Report
   - **QA Outcome:** Pending, Pass, or Fail
4. Click **Submit new issue**.

**What happens:** The issue receives the `qa-request` label. If auto-assign is configured, QA team members are assigned.

---

## How to Uninstall the Delivery OS

1. **Delete these workflow files** from `.github/workflows/`:
   - `delivery-os-release-control.yml`
   - `delivery-os-sprint-orchestration.yml`
   - `delivery-os-intake-governance.yml`
   - `delivery-os-auto-close-sprint.yml`
   - `delivery-os-notify-release-approver.yml`
   - `delivery-os-authorize-deployment.yml`
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
| Submit task | New issue → Task |
| Report bug | New issue → Bug Report |
| Create sprint | New issue → Sprint Planning |
| Request release | New issue → Production Release & QA Sign-Off |
| Approve release | Comment `Approved for production` or use dual approval workflow |
| Enable alerts | Add secrets + set `enable_telegram` / `enable_whatsapp` in triggers |
| Enable child tasks | Set `enable_child_task_creation: true` in sprint trigger |
| Enable auto-close sprint | Install `trigger-auto-close-sprint.yml` |
| Enable dual approval | Install `trigger-authorize-deployment.yml` and set approver usernames |
| Uninstall | Delete `delivery-os-*.yml` workflows |

---

For integration and configuration details, see [Consumer Setup](consumer-setup.md).
