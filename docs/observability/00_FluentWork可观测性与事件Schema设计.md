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
