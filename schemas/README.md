# FluentWork Shared Schemas

This directory holds cross-repository schema artifacts owned by `fluentwork-infra`.

- `events/`: domain and analytics event schemas
- `transport/`: cross-runtime transport and contract schemas
- `transport/wss-control-frames-v1.json`: canonical WSS control-frame contract (V1)
- `transport/wss-control-frames-v2.json`: WSS V2 control-frame contract (`ai.tts.start` / `ai.tts.end`; `ai.tts.audio` is binary, not JSON)
- `events/speech-observability-events-v1.json`: canonical speech observability event contract

Runtime repositories keep mirror copies for test and packaging convenience, but
all shared schema changes must land here first and then be synced outward.
