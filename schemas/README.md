# FluentWork Shared Schemas

This directory holds cross-repository schema artifacts owned by `fluentwork-infra`.

- `events/`: domain and analytics event schemas
- `transport/`: cross-runtime transport and contract schemas
- `transport/wss-control-frames-v1.json`: canonical WSS control-frame contract
- `events/speech-observability-events-v1.json`: canonical speech observability event contract

Runtime repositories keep mirror copies for test and packaging convenience, but
all shared schema changes must land here first and then be synced outward.
