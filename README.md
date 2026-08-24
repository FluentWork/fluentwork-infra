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

## CI/CD Goals

- reusable workflow templates
- deployment validation
- environment protection rules
- release traceability

## Related Repositories

- `fluentwork-meta`
- `fluentwork-ios`
- `fluentwork-backend`
