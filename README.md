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

## Agent Tooling

- **gstack `/review`** before commit, then `GSTACK_REVIEWED=1 git commit ...`
- emergency bypass: `SKIP_GSTACK_REVIEW=1` (justify in commit/PR)
- `gstack` can be used locally for deeper `/review` and `/setup-deploy`
- OCR scripts optional/manual only; not part of default pre-commit
- Matt Pocock style skills may be used as helpers under FluentWork shared governance
- GitHub CI does not run code review
