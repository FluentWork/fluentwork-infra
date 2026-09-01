# FluentWork 可观测性与事件 Schema 设计

## 定位

本文件定义 FluentWork 跨仓事件与埋点 schema 的统一入口。

`fluentwork-infra` 现为 source of truth，承接：

1. 语音链路事件
2. 网络与重连事件
3. review 生成与消费事件
4. 语料库同步事件
5. 购买、转化、订阅等商业埋点
6. infra / worker / 网关可观测性事件

`fluentwork-meta` 保留产品与技术设计文档，但不再持有这套 schema 的主定义。

## 设计原则

1. schema 先行，再写 logger / tracker / analytics adapter
2. 字段命名统一 snake_case
3. 同名字段跨端、跨服务语义必须完全一致
4. error / reason / source 必须先枚举化，禁止自由文本扩散
5. 事件定义与 transport / API contract 解耦，但允许共享字段枚举
6. 进入运行时引用前，必须有版本号和 breaking-change 策略

## 事件分层

### 1. Domain Event

表达业务事实，不关心具体上报平台。

示例：

- `speech_session_started`
- `speech_interrupt_local`
- `speech_reconnect_started`
- `review_generation_completed`
- `corpus_delta_sync_applied`
- `subscription_checkout_started`

### 2. Transport / Contract Event

表达协议边界事件，驱动状态机或跨端协作。

示例：

- `session.start`
- `user.speech.start`
- `ai.audio.chunk`
- `ai.turn.end`
- `session.end`

### 3. Analytics Event

表达最终投递给具体平台的埋点记录。

示例：

- `ios.analytics.speech_session_started`
- `backend.analytics.review_generation_completed`

## 基础字段草案

所有 domain / analytics 事件优先复用以下基础字段：

- `event_name`
- `event_version`
- `event_time`
- `session_id`
- `user_id`
- `device_id`
- `trace_id`
- `platform`
- `app_version`
- `build_version`
- `source`
- `phase`
- `reason`
- `error_code`
- `error_message`
- `elapsed_ms`

## 语音链路首批字段

### 建议事件

1. `speech_session_started`
2. `speech_session_failed`
3. `speech_session_ended`
4. `speech_interrupt_local`
5. `speech_interrupt_forwarded`
6. `speech_reconnect_started`
7. `speech_reconnect_succeeded`
8. `speech_reconnect_timed_out`
9. `speech_audio_capture_started`
10. `speech_audio_capture_stopped`
11. `speech_audio_first_chunk_received`
12. `speech_turn_ended`
13. `speech_transport_disconnected`
14. `speech_transport_degraded`

### 建议字段

- `network_state`
- `audio_route`
- `is_reconnecting`
- `interrupt_watermark`
- `turn_id`
- `transport_type`

### `phrase_block_id`：badge dedupe 跨端关联键

`phrase_block_id` 是 `feedback.badge` 控制帧的语料库 ID（定义见 `schemas/transport/wss-control-frames-v1.json` 的 `$defs.feedbackBadge.properties.phrase_block_id`）。backend BadgeEmitter 用它做 `session|turn|phrase_block` 三段 dedupe key，iOS `BadgeFeedback` 层用它做 (badge, turn_id, phrase_block_id, time-window) 的本地 dedupe 镜像。

涉及 badge / hit-detection 的 domain / analytics 事件必须把 `phrase_block_id` 一并带上，否则无法跨 iOS ↔ backend ↔ worker 做命中归因。

`phrase_block_id` 在 event schema 中应作为 `eventBase` 的可选扩展字段使用，约束：

- 类型：`string`，非空
- 来源：`feedback.badge` 帧的 `phrase_block_id`
- 缺失语义：badge emit 端上游 phrase block 为空时 `NewFeedbackBadge` 直接跳过 emit，因此携带 `phrase_block_id` 的事件只能由真实命中产生；分析侧遇到缺失时按"非命中"处理，不补默认值

事件级示例（`feedback_badge_emitted`）：

```json
{
  "event_name": "feedback_badge_emitted",
  "event_version": 1,
  "event_time": "2026-09-01T15:57:29.346Z",
  "source": "voice_gateway",
  "session_id": "s-1234",
  "turn_id": "turn-1",
  "phrase_block_id": "block-节奏稳定-v1",
  "tier": "highlight",
  "elapsed_ms": 0
}
```

iOS 端镜像同一字段（同 turn、同 phrase_block，5s 窗口内只落 1 条 `state.badgeFeedback.entries`）：

```json
{
  "event_name": "ios.badge_feedback_dedupe_mirror",
  "event_version": 1,
  "event_time": "2026-09-01T15:57:29.347Z",
  "source": "ios",
  "session_id": "s-1234",
  "turn_id": "turn-1",
  "phrase_block_id": "block-节奏稳定-v1",
  "tier": "highlight",
  "phase": "asr"
}
```

跨端 join 路径：`session_id` + `turn_id` + `phrase_block_id` 三键等值 join，可还原一次完整命中生命周期（emit → dedupe → display）。

## 当前已冻结的一项 transport 修正

为消除 iOS 端对回合结束的本地时间推断，WSS transport schema 补充显式控制帧：

- `ai.turn.end`

语义：

1. 表示 AI 当前回合结束
2. 不要求该回合一定产生音频
3. 可同时覆盖纯文本回合与音频回合

## 仓库落位

当前目录约定：

1. 文档说明：`docs/observability/*.md`
2. 业务/分析 schema：`schemas/events/*.json`
3. transport schema：`schemas/transport/*.json`

实现设计文档：

- `docs/observability/01_共享Schema实现设计.md`

## 迁移策略

### 当前阶段

1. `infra` 持有 schema 文档与 canonical JSON schema 文件
2. 运行时仓库通过 mirror 副本消费，禁止再各自独立演进同名 schema
3. `meta` 仅保留跳转说明，不再作为 schema source of truth

### 下一阶段

下一步聚焦 mirror 自动同步与 gate：

1. backend / iOS 保留镜像副本，统一由 repo-local sync 脚本更新
2. schema 变更先落 `infra/schemas/`，再同步到运行时仓
3. 后续需要 CI 对 mirror 漂移和 breaking change 增加门禁

## 验收建议

1. canonical schema 进入 `infra/schemas/`
2. backend / iOS 仅消费 mirror 副本
3. sync 脚本与基线测试存在，能阻止静默漂移
4. 后续新增购买/订阅等商业埋点时，继续沿用同一入口扩展
