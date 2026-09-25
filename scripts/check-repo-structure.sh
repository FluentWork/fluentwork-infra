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
test -d docs
test -d docs/observability
test -d schemas
test -f schemas/transport/wss-control-frames-v2.json
test -f schemas/transport/wss-binary-audio-frames-v1.json
test -f schemas/events/speech-observability-events-v1.json
test -d scripts
test -f scripts/check-schema-freeze.sh

echo "Infra repository structure is present."
