# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2026-03-31

### Changed

- Package metadata (`repository`, `homepage`, `bugs`) and docs now point at the **Phaneroo** GitHub org after the repo transfer (npm registry page updates on publish).

## [1.0.2] - 2026-03-17

### Added

- `delivery-os status` — show which workflows and templates are installed
- `delivery-os uninstall` — remove workflows (optionally templates with `--with-templates`)
- `CHANGELOG.md` for version history
- GitHub release workflow (triggered on tag push)
- Refined npm keywords for discoverability

## [1.0.1] - 2026-03-17

### Security

- Replace `execSync` with `execFileSync` for gh CLI calls to avoid shell access (resolves Socket security analysis warning)

## [1.0.0] - 2026-03-17

### Added

- Initial release
- `delivery-os install` with `--with-templates`, `--with-labels`, `--overwrite`, `--dry-run`
- 7 GitHub Actions workflows: sprint-child-creator, auto-close-sprint, notify-release-approver, authorize-deployment, auto-assign-qa, telegram-issues, setup-labels
- 6 issue templates: sprint planning, task, bug report, QA request, production release, config
- npm package publish
