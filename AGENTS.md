# AGENTS

## Repository

- Name: `fluentwork-infra`
- Role: reusable workflows, deployment, environments, and release automation

## Shared Rules

This repository inherits shared agent policy from `FluentWork/fluentwork-meta/agents/shared/`.

Shared topics:

1. AI collaboration and role split
2. Git and PR rules
3. Review gate
4. Skills policy
5. Matt Pocock skills usage boundary

## Local Rules

1. Protect deploy, secrets, rollback, and environment changes.
2. Keep workflow permissions minimal.
3. Treat reusable workflows as cross-repo interfaces.
4. Prefer validation and dry-run steps before rollout.

## Required Behaviors

1. Read current infra and governance docs before editing.
2. Keep changes scoped to the active workflow or environment concern.
3. Do not bypass review, CI, or owner approval requirements.
4. Before each commit, local OpenCodeReview must pass: fix any `high` / `critical` findings (see `scripts/ocr-local-review.sh`); `medium` / `low` may remain as follow-ups.
5. Do not perform destructive git operations without explicit approval.
6. Surface permission, deploy, and rollback implications clearly.

## High-Risk Paths

1. Production deploy workflows
2. Secrets and environment templates
3. Rollback scripts and release automation
4. Shared reusable workflow definitions

## Local Review Gate

1. One-time per clone: `./scripts/setup-git-hooks.sh` (sets `core.hooksPath=.githooks`).
2. Pre-commit runs `scripts/ocr-local-review.sh` (OCR CLI + `ocr-fail-on-high.sh`).
3. Emergency bypass only: `SKIP_OCR=1`, and justify in the commit/PR body.
4. Optional archive: `./scripts/ocr-export-review.sh` after a review.

## CI Boundary

CI validates workflow syntax, config, and deploy checks. CI does not run OpenCodeReview or a full interactive skills runtime.
