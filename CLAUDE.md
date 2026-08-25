# FluentWork Infra

## Repo Role

`fluentwork-infra` is the infrastructure and automation repository for FluentWork.

It owns reusable workflows, deploy scripts, environment templates, and release automation boundaries.

## Shared Source Of Truth

Shared agent policy is maintained in `FluentWork/fluentwork-meta` under:

- `agents/shared/ai-collaboration.md`
- `agents/shared/git-and-pr-rules.md`
- `agents/shared/review-gate.md`
- `agents/shared/skills-policy.md`
- `agents/shared/matt-pocock-skills.md`

This file only adds infra-specific constraints.

## Repo-Specific Constraints

1. Prefer least privilege in workflows and automation.
2. Treat deploy, secrets, rollback, and environment config as high-risk.
3. Do not broaden workflow permissions casually.
4. Update documentation when pipeline or environment behavior changes.
5. Matt Pocock style skills may assist, but FluentWork infra rules win on conflicts.

## High-Risk Areas

1. production deploy workflows
2. secrets and environment templates
3. rollback scripts and release automation
4. shared reusable workflows used by other repos

## Expected Workflow

1. Read current infra and governance docs first.
2. Keep workflow, deploy, and environment changes scoped.
3. Prefer dry-run and validation steps before rollout.
4. Respect owner approval for production-affecting changes.
5. Call out blast radius and rollback expectations clearly.

## Tooling Integrations

1. `gstack` may be used locally for review and deploy setup assistance.
2. Matt Pocock style skills may be used as helpers under FluentWork shared policy.
3. Local OpenCodeReview runs on pre-commit (`scripts/ocr-local-review.sh`): any `high`/`critical` finding blocks the commit until fixed; no `high`/`critical` means the commit may proceed (see `fluentwork-meta/agents/shared/review-gate.md`). Canonical gate script: `scripts/ocr-fail-on-high.sh`.
