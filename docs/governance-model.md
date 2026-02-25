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
| Bug | `bug` | Bug report; tagged for bug triage (use with `intake`) |
| Sprint | `sprint` | Assigned to a sprint; in progress |
| QA | `qa` | Under quality assurance review |
| Production | `production` | Release candidate; approval gate active |
| Risk | `risk` | Risk review required |
| Approved | `approved` | Release approved |
| Rejected | `rejected` | Release or item rejected |

## Approval Gates

### Production Release Gate

When an issue or PR receives the `production` label:

1. The **Release Control** workflow parses:
   - Sprint reference (`#number`)
   - QA recommendation (Approve / Reject / Conditional)

2. A governance summary comment is posted, including:
   - Event type and repository
   - Sprint reference and QA recommendation
   - Call to @release-approver for sign-off

3. Merge is blocked until a release approver comments with explicit approval (e.g., "Approved for production").

### Branch Protection

Recommended branch protection settings:

- Require status checks for workflows
- Require at least one approval from code owners
- Do not allow bypassing (or restrict bypass to admins)

## Structured Intake

### Feature / Bug Intake (delivery-intake)

Required fields:

- Intake type (Feature Request / Bug Report)
- Summary
- Description
- Priority
- Acceptance criteria

### Bug Report (bug-report)

Required fields:

- Summary
- Environment (Development, Staging, Production, All)
- Steps to reproduce
- Current behavior
- Expected behavior
- Priority
- Acceptance criteria (what "fixed" looks like)

### Sprint Planning

Required fields:

- Sprint name
- Deliverables (one per line)
- Target end date

### Risk Review

Required fields:

- Sprint reference
- QA recommendation
- Release notes
- Risk mitigation

### Release Approval

Required fields:

- Sprint reference
- QA recommendation
- Risk summary
- Release Approver GitHub Username

## Automation Rules

| Event | Automation |
|-------|------------|
| Issue/PR opened | Apply `intake` label; post acknowledgment |
| Sprint issue with `sprint-planning` label | Parse deliverables; optionally create child issues (if enabled); post health summary |
| `production` label added | Parse release details; post approval gate; mention approver |
| PR merged | Send Telegram + WhatsApp alert (if enabled) |
| `production` label added | Send Telegram + WhatsApp alert (if enabled) |
| `sprint-planning` label added | Send Telegram alert (if enabled) |
| `risk` label added | Send Telegram alert (if enabled) |
