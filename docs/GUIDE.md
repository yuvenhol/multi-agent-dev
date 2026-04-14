# 使用教程

**[English](GUIDE.en.md) | 中文**

## 目录

- [快速开始](#快速开始)
- [提示词工程](#提示词工程--如何写好任务描述)
- [模型选择策略](#模型选择策略)
- [模式选择决策树](#模式选择决策树)
- [实战案例](#实战案例)
- [进阶技巧](#进阶技巧)
- [常见问题](#常见问题与排障)

---

## 快速开始

### 安装后第一步

**Claude Code:**
```
组建团队帮我实现一个用户登录功能，需要 JWT 认证和密码加密
```

**Codex:**
```bash
codex "参照 AGENTS.md 的协作规范，组队为当前项目添加 REST API 接口文档"
```

### 你会看到什么

1. **Phase 1 分析** — 编排器识别任务性质、规模、选择架构模式和团队方案
2. **确认提问** — "分析结果如上，确认执行？"（复杂/模糊任务时）
3. **团队执行** — agent 按分工依次或并行工作
4. **产出物** — 所有中间产出保存在 `_workspace/` 目录

```
_workspace/
├── 00_project_lead_plan.md        # 执行计划
├── 01_architect_design.md         # 架构设计
├── 02_developer_changelog.md      # 开发日志
├── 03_reviewer_report.md          # 审查报告
└── 04_tester_report.md            # 测试报告
```

---

## 提示词工程 — 如何写好任务描述

### 好的任务描述 vs 差的任务描述

| 差 | 好 | 为什么好 |
|----|------|---------|
| 帮我写个 API | 组建团队为 FastAPI 项目添加用户 CRUD 接口，使用 SQLAlchemy + PostgreSQL，需要分页和过滤 | 明确了技术栈、范围、具体需求 |
| 审查一下代码 | 组队从安全性、性能、可维护性三个维度审查 src/auth/ 目录的代码 | 指定了审查维度和范围 |
| 调研一下数据库 | 组队调研 PostgreSQL vs MySQL vs SQLite，从性能、运维复杂度、生态成熟度三个维度对比，项目规模约 10 万日活 | 指定了候选、维度、场景约束 |

### 任务描述四要素

```
1. 目标 — 要做什么（动词开头）
2. 约束 — 技术栈、兼容性、性能要求
3. 范围 — 涉及哪些模块/文件
4. 期望产出 — 需要代码？文档？还是两者都要？
```

### 何时指定团队 vs 让编排器自动决定

| 场景 | 建议 |
|------|------|
| 你清楚需要哪些角色 | 直接指定："用 architect + developer + reviewer 团队" |
| 任务性质明确但规模不确定 | 说明任务，让编排器判断："组队实现 XXX 功能" |
| 探索性任务 | 只描述目标："帮我调研最佳方案" |

---

## 模型选择策略

### 核心原则：规划用强模型，执行可用快模型

复杂任务的 Phase 0-1（上下文确认 + 任务分析）是整个协作的基石。**用最强的模型做任务定义和规划**，能显著提升后续所有 agent 的工作质量。

```
推荐策略：

Phase 0-1（分析规划）  → 顶级模型（Opus / o3）
Phase 2（团队组建）     → 顶级模型
Phase 3（执行）         → 按角色选择：
  - architect / reviewer → 强模型（需要深度推理）
  - developer            → 快模型即可（代码实现）
  - researcher           → 强模型（需要综合判断）
  - tester               → 快模型即可（测试编写）
Phase 4-5（整合报告）   → 顶级模型
```

### 平台配置

**Claude Code:**
```yaml
# 在 CLAUDE.md 或编排器配置中
# 所有 agent 默认使用 opus
model: "opus"
```

当前 Claude Code Agent Teams 中所有成员建议统一使用 `model: "opus"`，因为团队内无法混合模型。

**Codex:**
```bash
# 用 -m 指定模型
codex -m o3 "组队实现用户认证功能"

# 或在 config.toml 中设置默认模型
```

### 性价比建议

| 任务类型 | 推荐模型 | 原因 |
|---------|---------|------|
| 架构设计 | 最强模型 | 设计决策影响全局，一步错步步错 |
| 技术调研 | 最强模型 | 需要综合判断、权衡利弊 |
| 代码审查 | 强模型 | 需要发现隐藏的安全和性能问题 |
| 代码实现 | 标准模型 | 有明确的设计文档指导，执行即可 |
| 测试编写 | 标准模型 | 基于现有代码和设计生成测试 |
| 文档撰写 | 标准模型 | 有结构化输入，组织输出即可 |

---

## 模式选择决策树

```
你的任务是什么类型？
│
├─ 新功能开发
│   └─ 流水线 + 生成-验证
│      architect → developer → reviewer → developer(修改) → tester
│
├─ 技术调研 / 方案对比
│   └─ 扇出/扇入
│      researcher × N（各负责一个维度或候选方案）→ 汇总
│
├─ 代码审查
│   └─ 扇出/扇入
│      reviewer × N（安全/性能/架构 各一个视角）→ 汇总报告
│
├─ Bug 修复
│   └─ 生成-验证（或直接完成）
│      developer → reviewer → developer(修改)（最多 2 轮）
│
├─ 大规模重构 / 迁移
│   └─ 监督者
│      project-lead → developer × N（分批分配 → 动态再分配 → 逐批验证）
│
├─ 全栈开发 / 多层级项目
│   └─ 层级委派
│      architect → developer-frontend | developer-backend（并行）→ tester
│
├─ 混合类型任务
│   └─ 专家池
│      按子任务类型路由到对应专家角色
│
└─ 文档完善
    └─ 扇出/扇入
       researcher（收集信息）→ tech-writer（撰写文档）
```

### 一句话判定

| 模式 | 一句话 |
|------|--------|
| 流水线 | "各步骤有先后依赖，前一步的输出是后一步的输入" |
| 扇出/扇入 | "多人独立并行做类似的事，最后汇总" |
| 专家池 | "不同子任务需要不同专家，按类型路由" |
| 生成-验证 | "一个人做，另一个人查，不行就改" |
| 监督者 | "一个人统筹分配，多人执行，动态调度" |
| 层级委派 | "自上而下分解，前后端/多模块并行开发" |

---

## 实战案例

### 案例 A：新功能开发（Claude Code）

**用户输入：**
```
组建团队，为 FastAPI 项目添加用户认证模块：JWT + bcrypt + SQLAlchemy
```

**Phase 1 — 编排器分析：**
```
任务性质：新功能开发
规模：中等（4 个关注点：认证逻辑、数据模型、API 接口、安全）
架构模式：流水线 + 生成-验证
团队方案：architect + developer + reviewer

确认执行？[Y/n]
```

**Phase 2 — 团队组建：**
```
TeamCreate: auth-feature
成员：architect (opus), developer (opus), reviewer (opus)
任务分配：
  architect: #1 分析认证需求 → #2 设计接口和数据模型
  developer: #3 实现认证逻辑 → #4 实现 API 接口（依赖 #2）
  reviewer:  #5 安全审查（依赖 #3, #4）
  developer: #6 根据审查修改（依赖 #5）
```

**Phase 3 — 执行：**
```
architect → _workspace/01_architect_design.md
developer → 代码 + _workspace/02_developer_changelog.md
reviewer  → _workspace/03_reviewer_report.md（发现 2 个安全问题）
developer → 修复安全问题，更新代码
```

**Phase 4-5 — 整合报告：**
```
所有产出物一致性检查通过。
产出物：
  - _workspace/01_architect_design.md（架构设计）
  - _workspace/02_developer_changelog.md（开发日志）
  - _workspace/03_reviewer_report.md（审查报告）
  - src/auth/（认证模块代码）
```

---

### 案例 B：技术调研（Codex）

**用户输入：**
```bash
codex "参照 AGENTS.md 协作规范，组队调研 Python CLI 框架：Click vs Typer vs Fire，
从功能完整性、类型安全、学习曲线三个维度评估"
```

**Codex 串行执行流程：**
```
Phase 1: 识别为技术调研，扇出/扇入模式，3 个 researcher

Phase 2: 执行计划写入 _workspace/00_project_lead_plan.md
  - researcher-click: 调研 Click
  - researcher-typer: 调研 Typer
  - researcher-fire:  调研 Fire

Phase 3: 串行扮演各角色
  [切换为 researcher-click 视角]
  → _workspace/00_researcher_click_findings.md

  [切换为 researcher-typer 视角]
  → _workspace/00_researcher_typer_findings.md

  [切换为 researcher-fire 视角]
  → _workspace/00_researcher_fire_findings.md

Phase 4: 汇总三份报告，处理矛盾结论
  → 最终推荐报告

Phase 5: 向用户报告结论
```

---

## 进阶技巧

### 部分重新执行

当 `_workspace/` 已存在时，你可以只重跑某个角色：

```
# 只重新执行 reviewer 审查
_workspace/ 已经有上次的产出物了，只需要重新执行 reviewer 审查，
关注这次新增的安全性维度
```

编排器会识别到 `_workspace/` 存在 → 进入部分重新执行模式 → 仅重跑指定 agent。

### 自定义角色

在项目级别创建专属角色：

```bash
# 1. 复制基础角色作为模板
cp ~/.claude/agents/developer.md .claude/agents/dba.md

# 2. 修改角色定义
# name: dba
# description: "数据库管理专家。..."
# 核心角色：数据库设计、查询优化、迁移管理...
```

新角色会自动被编排器识别并纳入角色库。

### 混合模式

不同阶段可以使用不同的执行模式：

```
Phase 1: 扇出/扇入 — researcher × 2 并行调研
Phase 2: 流水线 — architect 基于调研结论设计
Phase 3: 层级委派 — developer-frontend | developer-backend 并行实现
Phase 4: 生成-验证 — reviewer 审查，developer 修改
```

### 产出物复用

`_workspace/` 的产出物可以在后续任务中复用：

```
上次的架构设计还在 _workspace/01_architect_design.md，
基于这个设计继续实现支付模块
```

编排器会读取已有产出物作为新任务的输入上下文。

---

## 常见问题与排障

### "编排器没有组队，直接执行了"

**原因：** 任务被判定为小规模（1-2 个关注点），不需要组队。
**解决：**
- 明确使用触发词："组建团队"、"组队"、"多 agent 协作"
- 描述更多关注点，让编排器判定为中/大规模
- 直接指定团队："用 architect + developer + reviewer 三个角色"

### "agent 产出物互相矛盾"

**原因：** 扇出/扇入模式中多个 agent 独立工作，可能得出不同结论。
**处理：** 这是框架的设计行为 — 冲突处理协议规定"标注来源并列，不删除任何一方"。汇总阶段会对比矛盾点并给出综合判断。

### "审查报告太笼统"

**解决：** 在任务描述中指定具体的审查维度：
```
组建审查团队，分别从以下维度审查：
1. 安全性：SQL 注入、XSS、认证绕过
2. 性能：N+1 查询、缓存策略、连接池
3. 可维护性：代码重复、命名规范、错误处理
```

### "Codex 环境下无法并行执行"

**说明：** Codex 当前环境如果不支持真实并行，编排器会自动降级为**串行扮演**模式 — 依次切换角色视角，通过 `_workspace/` 文件维护边界。效果等价，只是顺序执行。

### "想修改已完成的某个阶段"

**解决：** 描述你要修改的内容，编排器会进入部分重新执行模式：
```
reviewer 的审查报告需要补充性能维度的分析，
请重新执行 reviewer 阶段
```
