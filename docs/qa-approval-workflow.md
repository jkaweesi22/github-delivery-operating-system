# QA & Approval Workflow

Structured QA requests and release approvals with dynamic @username tagging. No hardcoded usernames.

---

## Issue Templates

### QA Request (`qa-request.yml`)

Use for QA review requests with structured test scope and recommendation.

| Field | Required | Description |
|-------|----------|-------------|
| Title | Yes | Brief summary |
| Feature / Issue Reference | Yes | Link (e.g., #42) |
| Environment | Yes | Development, Staging, Production, All |
| Test Scope | Yes | What to test and how |
| Risk Assessment | Yes | Low, Medium, High, Critical |
| QA Recommendation | Yes | Approve, Reject, Conditional |
| **QA Reviewer GitHub Username** | Yes | Username to tag (e.g., @qa-reviewer) |
| Artifact / Attachment Notes | No | Describe artifacts to attach |

### Release Approval (`release-approval.yml`)

Use for production release approval with governance fields.

| Field | Required | Description |
|-------|----------|-------------|
| Sprint Reference | Yes | Link (e.g., #12) |
| QA Recommendation | Yes | Approve, Reject, Conditional |
| Risk Summary | Yes | Risks and mitigations |
| **Release Approver GitHub Username** | Yes | Username to tag (e.g., @release-approver) |

---

## Dynamic Tagging in Workflows

When the `production` label is applied (e.g., from release-approval or risk-review), the release-control workflow:

1. Parses the issue body for "Release Approver GitHub Username"
2. Extracts the value (supports `@username` or `username`)
3. Mentions that username in the approval comment
4. Falls back to `default_release_approver` (workflow input) if not found
5. Falls back to `release_approver` (legacy input) if still not found
6. If none: posts a comment requesting approver assignment

### Comment Format (with approver)

```
## 🚨 Release Approval Required

@username

| Field | Value |
|-------|-------|
| Event | Issue |
| Sprint | #12 |
| QA Recommendation | Approve |
| Repository | owner/repo |

Please review the QA recommendation and comment `Approved for production` or `Release approved` to sign off.
```

---

## Configuring Default Approvers

In your trigger workflow:

```yaml
with:
  release_approver: "@release-approver"      # Legacy fallback
  default_release_approver: "@my-team/ops"   # When issue omits Release Approver
```

Use `default_release_approver` when your team has a designated approver but issues may not always include it.

---

## Template Adoption

- Templates live in the **central repository** only
- **Optional** — copy `.github/ISSUE_TEMPLATE/` into consumer repos manually
- **Non-destructive** — installer never overwrites existing consumer templates
- **Safe** — placeholders only; no personal usernames hardcoded
- Usable in any public or private repository
