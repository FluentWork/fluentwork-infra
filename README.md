# FluentWork Infra

`fluentwork-infra` is the infrastructure and automation repository for FluentWork.

## Scope

This repository will contain:

- reusable GitHub Actions workflows
- deployment scripts and environment definitions
- Docker and runtime packaging assets
- observability and alerting configuration
- shared schema documents and contract artifacts
- environment bootstrap and release automation

## Planned Structure

```text
.github/
deploy/
environments/
docker/
monitoring/
docs/
schemas/
scripts/
```

## Responsibilities

- define CI/CD baselines for all FluentWork repositories
- manage environment-specific deployment configuration
- keep release automation and rollback scripts centralized
- provide shared pipeline building blocks for iOS and backend repos
- own cross-repo observability and event schema source-of-truth documents
- shared agent policy comes from `fluentwork-meta`
- external helpers such as gstack and Matt Pocock style skills are allowed, but repo rules win on conflicts

## CI/CD Goals

- reusable workflow templates
- deployment validation
- environment protection rules
- release traceability
- agent entry file validation
- pre-commit gstack `/review` attestation (`GSTACK_REVIEWED=1`); CI does not run code review

## Related Repositories

- `fluentwork-meta`
- `fluentwork-ios`
- `fluentwork-backend`

## Current Initialization Status

This repository currently includes:

- `CLAUDE.md`
- `AGENTS.md`
- `CODEOWNERS`
- `.github/workflows/agent-config-check.yml`
- `.github/workflows/infra-ci.yml`
- `.githooks/pre-commit` + `scripts/setup-git-hooks.sh` + `scripts/gstack-review-gate.sh`
- `scripts/check-repo-structure.sh`
- executable workflow validation baseline
- initial infra directory skeleton
- canonical shared schema documents under `docs/observability/`
- canonical transport and event schemas under `schemas/`
- shared-schema implementation design doc under `docs/observability/01_共享Schema实现设计.md`

## Agent Tooling

- **gstack `/review`** before commit, then `GSTACK_REVIEWED=1 git commit ...`
- emergency bypass: `SKIP_GSTACK_REVIEW=1` (justify in commit/PR)
- `gstack` can be used locally for deeper `/review` and `/setup-deploy`
- OCR scripts optional/manual only; not part of default pre-commit
- Matt Pocock style skills may be used as helpers under FluentWork shared governance
- GitHub CI does not run code review
