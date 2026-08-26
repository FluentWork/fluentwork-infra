# FluentWork Infra

`fluentwork-infra` is the infrastructure and automation repository for FluentWork.

## Scope

This repository will contain:

- reusable GitHub Actions workflows
- deployment scripts and environment definitions
- Docker and runtime packaging assets
- observability and alerting configuration
- environment bootstrap and release automation

## Planned Structure

```text
.github/
deploy/
environments/
docker/
monitoring/
scripts/
```

## Responsibilities

- define CI/CD baselines for all FluentWork repositories
- manage environment-specific deployment configuration
- keep release automation and rollback scripts centralized
- provide shared pipeline building blocks for iOS and backend repos
- shared agent policy comes from `fluentwork-meta`
- external helpers such as gstack and Matt Pocock style skills are allowed, but repo rules win on conflicts

## CI/CD Goals

- reusable workflow templates
- deployment validation
- environment protection rules
- release traceability
- agent entry file validation
- pre-merge review via **gstack `/review`** (OpenCodeReview pre-commit gate paused)

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
- `.githooks/pre-commit` + `scripts/setup-git-hooks.sh` (local OCR gate)
- `scripts/check-repo-structure.sh`
- executable workflow validation baseline
- initial infra directory skeleton

## Agent Tooling

- `gstack` can be used locally for deeper `/review` and `/setup-deploy`
- **gstack `/review`** is the primary pre-merge review path
- OpenCodeReview pre-commit gate is **paused**; optional `FORCE_OCR=1 ./scripts/ocr-local-review.sh`
- after a review, optionally run `./scripts/ocr-export-review.sh` to save findings under `.opencodereview/reviews/` (see `latest.md`)
- Matt Pocock style skills may be used as helpers under FluentWork shared governance
- GitHub CI does not run OpenCodeReview; use gstack `/review` before merge; `scripts/ocr-fail-on-high.sh` remains the cross-repo canonical severity gate
