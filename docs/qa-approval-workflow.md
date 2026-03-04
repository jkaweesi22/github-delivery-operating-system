# QA & Approval Workflow

Structured QA requests and production release approvals with configurable approvers. Supports single approver or dual approval (release approver + QA lead).

---

## Issue Templates

### Bug Report (`bug-report.yml`)

Use for structured bug reports with platform, severity, and reproduction steps.

| Field | Required | Description |
|-------|----------|-------------|
| Platform(s) Affected | Yes | Android, iOS, Web, Backend/API (checkboxes) |
| Severity | Yes | P0–P3 (Blocker, Critical, Major, Minor) |
| Build / Version | Yes | e.g. 4227, v1.3.0 |
| Bug Summary | Yes | One clear sentence |
| Steps to Reproduce | Yes | Numbered steps |
| Expected Result | Yes | What should happen |
| Actual Result | Yes | What actually happens |
| Test Environment | Yes | Device, OS, browser, network |
| Logs / Screenshots / Videos | No | Supporting evidence |

### QA Request (`qa-request.yml`)

Use for QA testing requests for sprint tasks or bug fixes.

| Field | Required | Description |
|-------|----------|-------------|
| Related Sprint Task Issue (#) | Yes | Link (e.g., #101) |
| What to Test | Yes | Test scope and steps |
| Environment + Build Link | No | Staging build, TestFlight/APK/Web URL |
| Acceptance Criteria | No | Expected behavior, edge cases |
| Artifacts | No | Screenshots, Logs, Video Recording, Crash Report (checkboxes) |
| QA Outcome | No | Pending, Pass, Fail |

### Production Release & QA Sign-Off (`production-release-qa-signoff.yml`)

Use for formal production release governance and QA sign-off.

| Field | Required | Description |
|-------|----------|-------------|
| Sprint Reference | Yes | Link (e.g., #45) |
| Version / Build Number | Yes | e.g. v2.4.1 |
| Release Summary | Yes | What's in this release |
| QA Summary + Evidence Links | No | Link QA issues, screenshots, logs |
| Overall QA Recommendation | No | Approve for Production, Reject Release, Conditional Approval |
| Deployment Authorized | No | Yes or No |

---

## Release Approval Flow

When the `production` label is applied (e.g., from production-release-qa-signoff), the release-control workflow:

1. Parses the issue body for sprint reference and QA recommendation
2. Resolves approver from `default_release_approver` or `release_approver` workflow input
3. Posts approval comment with @mention
4. If none configured: posts comment requesting approver assignment

### Dual Approval (Optional)

Use `trigger-authorize-deployment.yml` for dual approval:

- **Release approver** (e.g., aMugabi): Must comment `approved`, `approve`, `ok`, or `go ahead`
- **QA lead** (e.g., jkaweesi22): Must comment `qa approved`, `approved`, `qa ok`, or `looks good`

Both must approve before `ready-for-deploy` label is applied. Release approver can decline with `declined`, `reject`, or `not approved`.

### Comment Format (with approver)

```
## 🚨 Release Approval Required

@username

| Field | Value |
|-------|-------|
| Event | Issue |
| Sprint | #45 |
| QA Recommendation | Approve for Production |
| Repository | owner/repo |

Please review the QA recommendation and comment `Approved for production` or `Release approved` to sign off.
```

---

## Configuring Approvers

In your trigger workflow:

```yaml
with:
  release_approver: "@release-approver"      # Legacy fallback
  default_release_approver: "@my-team/ops"   # When issue omits approver
```

For dual approval (`authorize-deployment`):

```yaml
with:
  release_approver_username: "aMugabi"
  qa_approver_username: "jkaweesi22"
```

---

## Template Adoption

- Templates live in the **central repository** only
- **Optional** — copy `.github/ISSUE_TEMPLATE/` into consumer repos via `--with-templates`
- **Non-destructive** — installer never overwrites existing consumer templates
- **Safe** — no personal usernames hardcoded; configurable per consumer
