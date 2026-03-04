# Governance Model

## Philosophy

The Delivery Operating System is built on four principles:

1. **Visibility drives accountability** — All intake, sprint progress, and release requests are tracked in GitHub.
2. **Accountability drives quality** — Structured forms and required fields ensure nothing slips through unqualified.
3. **Quality protects production** — Approval gates and QA recommendations guard production releases.
4. **Structured delivery reduces risk** — Standardized workflows and labels make delivery predictable and auditable.

## Lifecycle Stages

| Stage | Label | Description |
|-------|-------|-------------|
| Intake | `intake` | New item received; awaiting triage |
| Bug | `bug` | Bug report; tagged for bug triage (use with `qa`) |
| Task | `task` | Structured task with priority and status |
| Sprint | `sprint` | Assigned to a sprint; in progress |
| Planning | `planning` | Sprint planning issue (with `sprint-planning`) |
| QA | `qa` | Under quality assurance review |
| QA Request | `qa-request` | QA testing requested |
| Production | `production` | Release candidate; approval gate active |
| Release | `release` | Production release form |
| Approval | `approval` | Awaiting or received approval |
| Ready for Deploy | `ready-for-deploy` | Dual approval received; cleared for deployment |
| Declined | `declined` | Release declined by approver |
| Approved | `approved` | Release approved |
| Rejected | `rejected` | Release or item rejected |

## Approval Gates

### Production Release Gate

When an issue or PR receives the `production` label:

1. The **Release Control** workflow parses:
   - Sprint reference (`#number`)
   - QA recommendation (Approve for Production / Reject Release / Conditional Approval)

2. A governance summary comment is posted, including:
   - Event type and repository
   - Sprint reference and QA recommendation
   - Call to @release-approver for sign-off

3. Merge is blocked until a release approver comments with explicit approval (e.g., "Approved for production").

### Dual Approval (Optional)

When using `authorize-deployment`:

- **Release approver** and **QA lead** must both comment approval.
- Release approver can decline with `declined`, `reject`, or `not approved`.
- Once both approve, `ready-for-deploy` label is applied.

### Branch Protection

Recommended branch protection settings:

- Require status checks for workflows
- Require at least one approval from code owners
- Do not allow bypassing (or restrict bypass to admins)

## Structured Intake

### Sprint Planning (`sprint-planning`)

Required fields:

- Sprint name
- Sprint dates (YYYY-MM-DD to YYYY-MM-DD)
- Sprint goal
- Sprint features (one per line, no bullets)
- Sprint approved (Pending / Approved / Rejected)

### Task (`task`)

Required fields:

- Task summary
- Description
- Priority (P0–P3)
- Status (Backlog, In Progress, Blocked, Ready for Review, Done)
- Acceptance criteria

### Bug Report (`bug-report`)

Required fields:

- Platform(s) affected (Android, iOS, Web, Backend/API)
- Severity (P0–P3)
- Build / version
- Bug summary
- Steps to reproduce
- Expected result
- Actual result
- Test environment

### QA Request (`qa-request`)

Required fields:

- Related sprint task issue (#)
- What to test

Optional: Environment + build link, acceptance criteria, artifacts, QA outcome.

### Production Release & QA Sign-Off (`production-release-qa-signoff`)

Required fields:

- Sprint reference
- Version / build number
- Release summary

Optional: QA summary, QA recommendation, deployment authorized.

## Automation Rules

| Event | Automation |
|-------|------------|
| Issue/PR opened | Apply `intake` label; post acknowledgment |
| Sprint issue opened (title "SPRINT -") | sprint-child-creator creates child issues |
| Sprint issue with `sprint-planning` or `planning` label | sprint-orchestration parses; optionally creates children; post health summary |
| Child issue closed | auto-close-sprint updates burn-down; auto-close sprint when 100% |
| Production release issue opened | notify-release-approver pings approver |
| `production` label added | release-control parses; post approval gate; mention approver |
| Comment on production issue | authorize-deployment checks dual approval |
| PR merged | Send Telegram + WhatsApp alert (if enabled) |
| `production` label added | Send Telegram + WhatsApp alert (if enabled) |
| `sprint-planning` label added | Send Telegram alert (if enabled) |
| `risk` label added | Send Telegram alert (if enabled) |
