# FluentWork Shared Schemas

This directory holds cross-repository schema artifacts owned by `fluentwork-infra`.

- `events/`: domain and analytics event schemas
- `transport/`: cross-runtime transport and contract schemas
- `transport/wss-control-frames-v2.json`: the WSS control-frame contract. `ai.tts.start` / `ai.tts.end`; `ai.tts.audio` is binary, not JSON; `client.turn.abort`; `ai.turn.end` optional `outcome` / `log_id`.
- `transport/wss-binary-audio-frames-v1.json`: byte layout of the WebSocket **binary** audio frames (downlink h4 / h8, uplink headerless). Not a JSON Schema — the frames are raw bytes. Frozen by sha256; verified by `scripts/check-schema-freeze.sh`.
- `events/speech-observability-events-v1.json`: canonical speech observability event contract

Runtime repositories keep mirror copies for test and packaging convenience, but
all shared schema changes must land here first and then be synced outward.

## Frozen artifacts

`scripts/check-schema-freeze.sh` pins selected artifacts by sha256. A change to a
pinned file fails CI until the digest is refreshed in the same commit. The point
is not to prevent change but to make it impossible to change silently — an
artifact whose whole purpose is to be the source of truth is worth nothing if
edits to it leave no trace.

Run it locally before committing a schema change:

```
bash scripts/check-schema-freeze.sh
```

A frozen artifact is one whose *bytes* are the contract, so there is no schema
to diff and no field to review. The digest is the only review surface it has.
