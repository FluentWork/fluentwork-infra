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
4. Do not perform destructive git operations without explicit approval.
5. Surface permission, deploy, and rollback implications clearly.

## High-Risk Paths

1. Production deploy workflows
2. Secrets and environment templates
3. Rollback scripts and release automation
4. Shared reusable workflow definitions

## CI Boundary

CI validates workflow syntax, config, and deploy checks. CI does not run a full interactive skills runtime.
