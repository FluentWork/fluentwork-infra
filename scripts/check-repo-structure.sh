#!/usr/bin/env bash
set -euo pipefail

test -f CLAUDE.md
test -f AGENTS.md
test -f CODEOWNERS
test -d .github/workflows
test -d deploy
test -d environments
test -d docker
test -d monitoring
test -d scripts

echo "Infra repository structure is present."
