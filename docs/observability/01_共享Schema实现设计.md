# FluentWork 共享 Schema 实现设计

## 目标

本设计文档解释当前共享 schema 实现的工程设计、职责边界与后续扩展方式。

目标有四个：

1. 为跨仓 transport / event schema 提供单一 source of truth
2. 避免 backend / iOS 各自维护同名协议，产生静默漂移
3. 保持运行时仓可独立测试、独立打包、独立在 CI 中工作
4. 为后续新增埋点事件、购买事件、review 事件提供统一扩展路径

## 问题背景

在本轮迁移前，voice transport schema 实际保存在 backend 仓内，iOS 通过实现对齐而不是通过共享产物对齐。这种方式有三个问题：

1. canonical 定义混在单个运行时仓中，天然偏向某一端
2. 另一端只能靠文档或测试约定跟随，容易出现字段静默漂移
3. 如果直接跨仓相对路径读取 canonical 文件，会让测试、打包、CI 强耦合于本地目录结构

因此当前实现采用：

- `infra` 持有 canonical schema
- backend / iOS 消费 repo-local mirror 副本
- mirror 由同步脚本更新

## 设计决策

### 1. 为什么 canonical 放在 `fluentwork-infra`

原因：

1. schema 的职责是跨仓 contract，而不是单仓实现细节
2. 后续不仅语音 transport 会复用，事件埋点、worker、review、订阅购买都会继续扩展
3. `infra` 天然适合承接 shared contract、校验、生成与治理规则

结论：

- `meta` 保留业务设计和技术说明，不保存 machine-readable canonical
- `backend` / `ios` 只保存 mirror，不再自定义同名 canonical

### 2. 为什么不用运行时仓直接读 `../fluentwork-infra/...`

原因：

1. sibling repo 路径依赖会让单仓 CI 失效
2. 本地工作区结构一变，测试与打包立刻断裂
3. iOS 资源打包与 Go embed 都更适合消费仓内文件

结论：

mirror 不是临时妥协，而是当前阶段最稳定的工程落点。

### 3. 为什么同时保留 transport schema 和 event schema

两者语义不同：

1. transport schema 描述协议边界，驱动状态机与跨端协作
2. event schema 描述业务事实与埋点记录，驱动 logger / tracker / analytics adapter

如果混成一套 schema，会导致：

1. 协议升级与埋点升级相互耦合
2. 一个字段既承担网络契约，又承担业务统计含义，边界变脏

因此当前将其分层：

1. `schemas/transport/*.json`
2. `schemas/events/*.json`

## 当前仓库布局

### `fluentwork-infra`

canonical source:

1. `docs/observability/00_FluentWork可观测性与事件Schema设计.md`
2. `docs/observability/01_共享Schema实现设计.md`
3. `schemas/transport/wss-control-frames-v1.json`
4. `schemas/events/speech-observability-events-v1.json`

### `fluentwork-backend`

mirror consumer:

1. `schemas/transport/wss-control-frames-v1.json`
2. `schemas/events/speech-observability-events-v1.json`
3. `schemas/embed.go`
4. `scripts/sync-shared-schemas.sh`

### `fluentwork-ios`

mirror consumer:

1. `Shared/FluentWorkCore/Resources/Schemas/*.json`
2. `Shared/FluentWorkCore/SharedSchemaMirror.swift`
3. `Scripts/sync-shared-schemas.sh`

## 变更流程

后续新增埋点事件、review 事件、购买事件或 transport 字段时，统一按下面流程执行。

### A. 新增 event schema

适用场景：

1. 新增 logger / tracker / analytics 事件
2. 已有事件需要冻结字段名、枚举值、必填项
3. 同一事件需要跨 backend / iOS 共用字段定义

处理步骤：

1. 先改 `fluentwork-infra/schemas/events/*.json`
2. 必要时同步更新 `infra/docs/observability/*.md`
3. 在 backend 执行 `./scripts/sync-shared-schemas.sh`
4. 在 iOS 执行 `./Scripts/sync-shared-schemas.sh`
5. 补 backend / iOS 对 mirror 的基线测试
6. 再进入 logger、tracker、analytics adapter 的实现

规则：

1. 先冻结字段，再写埋点代码
2. 新字段必须解释其业务语义，而不是只写名字
3. `reason` / `source` / `phase` / `error_code` 优先枚举化

### B. 新增 transport schema

适用场景：

1. 新增控制帧
2. 变更现有 frame 的字段
3. 需要端到端消除本地推断，改为显式协议

处理步骤：

1. 先改 `fluentwork-infra/schemas/transport/*.json`
2. 更新 backend mirror 与 iOS mirror
3. 更新 backend 编解码和 handler 测试
4. 更新 iOS `WSControlFrame` 编解码与状态机接线测试
5. 确认不存在仅靠一端本地推断的残留逻辑

### C. 新增 schema 文档

适用场景：

1. 引入新事件域，例如 `review`、`corpus`、`billing`
2. 某一事件域已经复杂到需要单独说明设计边界

处理步骤：

1. 在 `infra/docs/observability/` 新增文档
2. 在主文档中登记入口
3. 仅在 `meta` 留跳转或引用，不复制正文

## 版本策略

### 1. 何时升版本

以下情况视为 breaking change：

1. 删除字段
2. 重命名字段
3. 修改字段语义
4. 将可选改为必填
5. 缩小枚举取值范围

处理方式：

1. 新建 `*-v2.json`
2. mirror 同步后，再逐仓迁移消费者
3. 旧版本保留到所有运行时完成切换

### 2. 何时不必升版本

以下场景可视为 non-breaking：

1. 新增可选字段
2. 新增向后兼容枚举值
3. 仅补文档、不改 machine-readable contract

## 验收与门禁

每次 schema 变更至少满足：

1. `infra` canonical 已更新
2. backend / iOS mirror 已同步
3. backend / iOS 基线测试通过
4. 文档解释了字段语义与变更原因
5. PR 描述明确说明是否 breaking

后续可继续增强：

1. 增加 CI 检查 mirror 漂移
2. 增加 schema diff gate
3. 自动生成 typed model 或 validator

## 为什么这个设计适合当前阶段

当前 FluentWork 还处在高频演进期，协议与事件都在快速变化。

如果过早引入独立 schema 发布中心、包管理分发或代码生成流水线，会带来额外维护成本；如果继续各仓自行维护 schema，则很快会失控。

因此当前设计选择了一个中间态：

1. canonical 集中到 `infra`
2. 运行时通过 mirror 保持独立
3. 用同步脚本和基线测试控制漂移

这套方案的优点是：

1. 成本低，今天就能执行
2. 不破坏单仓开发体验
3. 已经具备后续升级到 CI gate 或代码生成的基础

## 后续建议

下一批优先按同一模式推进：

1. `review` 事件 schema
2. `corpus` 同步事件 schema
3. `billing / subscription` 事件 schema
4. schema mirror 漂移检测 CI
