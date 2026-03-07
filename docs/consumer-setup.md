# Consumer Setup Guide

This guide explains how to install the Delivery Operating System into your repository. Workflows and templates are **copied directly** into your repo. No `workflow_call` or external references.

---

## ⚠️ Which Command to Use?

| Situation | Command | What happens |
|-----------|---------|--------------|
| **New repo** (no Delivery OS yet) | `./scripts/install.sh --with-templates /path/to/repo` | Installs all workflows and templates |
| **Repo with existing workflows/templates** (yours + others) | `./scripts/install.sh --with-templates /path/to/repo` | Adds only *missing* Delivery OS files. **Your existing files are NOT touched.** |
| **Update Delivery OS** (get latest fixes) | `./scripts/install.sh --with-templates --overwrite /path/to/repo` | **Replaces** Delivery OS workflows/templates. Your *other* workflows (different names) stay intact. |
| **Preview before installing** | `./scripts/install.sh --with-templates --dry-run /path/to/repo` | Shows what would be copied. No files changed. |

**Warning:** `--overwrite` replaces only Delivery OS files (same names). It does **not** delete your other workflows or templates. Use `--dry-run` first if unsure.

---

## Installation

From the `github-delivery-operating-system` repo root:

```bash
# Copy workflows only
./scripts/install.sh /path/to/your-repo

# Copy workflows + issue templates (required for sprint child creation)
./scripts/install.sh --with-templates /path/to/your-repo

# Copy workflows + templates + create labels via gh CLI
./scripts/install.sh --with-templates --with-labels /path/to/your-repo

# Update existing install (overwrite workflows and templates)
./scripts/install.sh --with-templates --overwrite /path/to/your-repo

# Preview what would happen (no files changed)
./scripts/install.sh --with-templates --dry-run /path/to/your-repo

# Explicitly skip existing (same as default)
./scripts/install.sh --no-overwrite /path/to/your-repo
```

**Options:**

| Flag | Description |
|------|-------------|
| `--with-templates` | Copy issue templates (sprint, task, bug, QA, production release) |
| `--with-labels` | Create labels via `gh` CLI (requires `gh auth` and GitHub remote) |
| `--overwrite` | Replace existing workflow/template files |
| `--no-overwrite` | Explicitly skip existing files (default behavior) |
| `--dry-run` | Show what would happen without changing any files |

By default, existing files are **skipped** (never overwritten). Use `--overwrite` to replace. Use `--dry-run` to preview changes safely.

---

## What Gets Installed

| Workflow | Purpose |
|----------|---------|
| `sprint-child-creator.yml` | Creates child issues when a sprint planning issue (title contains `SPRINT -`) is opened |
| `auto-close-sprint.yml` | Updates burn-down, sprint health; auto-closes sprint when 100% complete |
| `notify-release-approver.yml` | Pings release approver when a production release issue is opened |
| `authorize-deployment.yml` | Dual approval (release approver + QA) before deployment |
| `auto-assign-qa.yml` | Assigns QA team to issues with `qa` or `qa-request` label |
| `telegram-issues.yml` | Sends Telegram alerts for bugs, QA, sprints, releases, PR merges |
| `setup-labels.yml` | One-time workflow to create all required labels |

---

## Sprint Child Creation

Child issues are created **automatically** when:

1. An issue is opened with a title containing `SPRINT -` (e.g. `SPRINT - Sprint 12`)
2. The issue body contains a section `### Sprint Features (One Per Line)` with one feature per line

**Required:** Use the `sprint_planning.yml` template (install with `--with-templates`). The template provides the correct form structure.

Each line under "Sprint Features" becomes a child issue with `Parent Sprint: #N` in the body.

---

## Configuration

### Repo Variables (Settings → Secrets and variables → Actions → Variables)

| Variable | Description |
|----------|-------------|
| `RELEASE_APPROVER` | GitHub username of release approver (for notify + authorize) |
| `QA_APPROVER` | GitHub username of QA approver (for dual approval) |
| `QA_ASSIGNEES` | Comma-separated usernames for QA auto-assignment (e.g. `user1,user2`) |
| `PROJECT_NAME` | Optional; shown in release approval notifications |

### Secrets (optional)

| Secret | Used By |
|--------|---------|
| `TELEGRAM_BOT_TOKEN` | telegram-issues, auto-close-sprint |
| `TELEGRAM_CHAT_ID` | telegram-issues, auto-close-sprint |

### Telegram Alerts

1. Create a bot via [@BotFather](https://t.me/BotFather); copy the token.
2. Start a chat with your bot or add it to a group/channel.
3. Get the chat ID: send a message, then visit `https://api.telegram.org/bot<TOKEN>/getUpdates` and read `chat.id`.
4. Add both secrets in **Settings → Secrets and variables → Actions**.

Alerts are sent for: bugs, QA requests, sprints, production releases, PR merges to main. If secrets are not set, the workflow skips sending (no error).

---

## Required Labels

Run **Actions → Setup Labels → Run workflow** once, or use `--with-labels` when installing (requires `gh` CLI).

| Label | Color |
|-------|-------|
| intake | 0E8A16 |
| bug | D93F0B |
| sprint | 1D76DB |
| sprint-active | 1D76DB |
| planning | 5319E7 |
| sprint-planning | 5319E7 |
| task | 7057FF |
| qa | FBCA04 |
| qa-request | FBCA04 |
| production | D93F0B |
| release | B60205 |
| approval | 0E8A16 |
| ready-for-deploy | 0E8A16 |
| declined | B60205 |
| risk | B60205 |

---

## Issue Templates (with `--with-templates`)

| Template | Purpose |
|----------|---------|
| `sprint_planning.yml` | Sprint planning; each feature line → child issue |
| `task.yml` | Structured task with priority, status, acceptance criteria |
| `qa_request.yml` | QA testing request |
| `production_release_qa_signoff.yml` | Production release + QA sign-off |
| `bug_report.yml` | Bug report with platform, severity, steps |

---

## Troubleshooting

### "Resource not accessible by integration" when creating issues

The consumer repo must allow workflows to write. In your consumer repo:

1. Go to **Settings** → **Actions** → **General**
2. Under **Workflow permissions**, select **Read and write permissions**
3. Save

---

## Uninstalling

1. Delete these files from `.github/workflows/`:
   - `sprint-child-creator.yml`
   - `auto-close-sprint.yml`
   - `notify-release-approver.yml`
   - `authorize-deployment.yml`
   - `auto-assign-qa.yml`
   - `telegram-issues.yml`
   - `setup-labels.yml`

2. Optionally remove templates from `.github/ISSUE_TEMPLATE/` and repo variables/secrets.
