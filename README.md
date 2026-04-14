# multi-agent-dev

**[English](README.en.md) | 中文**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

**多 Agent 协作开发体系** — 同时支持 Claude Code 和 Codex

将复杂开发任务拆解为专业角色并协调协作。每个平台有独立完整的实现，共享相同的方法论。

## 快速开始

### 安装

```bash
git clone <repo-url>
cd multi-agent-dev
chmod +x install.sh

./install.sh --all        # 安装到所有检测到的平台
./install.sh --claude     # 仅 Claude Code
./install.sh --codex      # 仅 Codex
./install.sh --uninstall  # 卸载
```

**前置要求：**
- **Claude Code**: 需启用 Agent Teams — `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- **Codex**: Codex CLI 已安装

### 第一条命令

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
├── 00_project_lead_plan.md       # 执行计划
├── 01_architect_design.md        # 架构设计
├── 02_developer_changelog.md     # 开发日志
├── 03_reviewer_report.md         # 审查报告
└── 04_tester_report.md           # 测试报告
```

---

## 7 个通用角色

| 角色 | 核心能力 | 产出物 |
|------|---------|--------|
| **architect** | 需求分析、模块划分、接口定义、技术选型 | `01_architect_design.md` |
| **developer** | 代码实现、Bug 修复 | 代码 + `02_developer_changelog.md` |
| **reviewer** | 架构一致性、安全、性能、代码质量审查 | `03_reviewer_report.md` |
| **tester** | 测试设计、边界验证 | 测试代码 + `04_tester_report.md` |
| **researcher** | 多源调研、方案比较 | `00_researcher_{topic}_findings.md` |
| **tech-writer** | API 文档、使用指南 | `05_techwriter_docs.md` |
| **project-lead** | 任务拆解、团队协调 | `00_project_lead_plan.md` |

## 6 种架构模式

```
你的任务是什么类型？
│
├─ 新功能开发        → 流水线 + 生成-验证
│                      architect → developer → reviewer → developer(修改) → tester
├─ 技术调研/方案对比  → 扇出/扇入
│                      researcher × N → 汇总
├─ 代码审查          → 扇出/扇入
│                      reviewer × N（安全/性能/架构）→ 汇总报告
├─ Bug 修复          → 生成-验证（或直接完成）
│                      developer → reviewer → developer(修改)（最多 2 轮）
├─ 大规模重构/迁移    → 监督者
│                      project-lead → developer × N → 逐批验证
├─ 全栈/多层级项目    → 层级委派
│                      architect → developer-frontend | developer-backend → tester
├─ 混合类型任务       → 专家池
│                      按子任务类型路由到对应专家
└─ 文档完善          → 扇出/扇入
                       researcher → tech-writer
```

<details>
<summary>一句话判定各模式</summary>

| 模式 | 何时使用 |
|------|--------|
| 流水线 | 各步骤有先后依赖，前一步的输出是后一步的输入 |
| 扇出/扇入 | 多人独立并行做类似的事，最后汇总 |
| 专家池 | 不同子任务需要不同专家，按类型路由 |
| 生成-验证 | 一个人做，另一个人查，不行就改 |
| 监督者 | 一个人统筹分配，多人执行，动态调度 |
| 层级委派 | 自上而下分解，前后端/多模块并行开发 |

</details>

---

## 提示词工程 — 如何写好任务描述

### 好的 vs 差的任务描述

| 差 | 好 | 为什么好 |
|----|------|---------|
| 帮我写个 API | 组建团队为 FastAPI 项目添加用户 CRUD 接口，使用 SQLAlchemy + PostgreSQL，需要分页和过滤 | 明确了技术栈、范围、具体需求 |
| 审查一下代码 | 组队从安全性、性能、可维护性三个维度审查 src/auth/ 目录的代码 | 指定了审查维度和范围 |
| 调研一下数据库 | 组队调研 PostgreSQL vs MySQL vs SQLite，从性能、运维复杂度、生态成熟度对比，项目约 10 万日活 | 指定了候选、维度、场景约束 |

### 任务描述四要素

1. **目标** — 要做什么（动词开头）
2. **约束** — 技术栈、兼容性、性能要求
3. **范围** — 涉及哪些模块/文件
4. **期望产出** — 需要代码？文档？还是两者都要？

---

## 模型选择策略

### 核心原则：规划用强模型，执行可用快模型

复杂任务的 Phase 0-1（上下文确认 + 任务分析）是整个协作的基石。**用最强的模型做任务定义和规划**，能显著提升后续所有 agent 的工作质量。

```
Phase 0-1（分析规划）  → 顶级模型（Opus / o3）
Phase 2（团队组建）     → 顶级模型
Phase 3（执行）         → 按角色选择：
  - architect / reviewer → 强模型（需要深度推理）
  - developer / tester   → 快模型即可（代码实现）
  - researcher           → 强模型（需要综合判断）
Phase 4-5（整合报告）   → 顶级模型
```

| 任务类型 | 推荐模型 | 原因 |
|---------|---------|------|
| 架构设计 / 技术调研 | 最强模型 | 决策影响全局 |
| 代码审查 | 强模型 | 需发现隐藏问题 |
| 代码实现 / 测试 / 文档 | 标准模型 | 有明确指导，执行即可 |

**Claude Code** 中所有 agent 建议统一 `model: "opus"`。**Codex** 在 `~/.codex/config.toml` 中设置 `model_reasoning_effort = "xhigh"` 以使用最强推理能力。

---

## 实战案例

### 案例 A：新功能开发（Claude Code）

```
用户：组建团队，为 FastAPI 项目添加用户认证模块：JWT + bcrypt + SQLAlchemy
```

```
Phase 1 → 中等规模，流水线 + 生成-验证，architect + developer + reviewer
Phase 2 → TeamCreate: auth-feature
Phase 3 → architect 设计 → developer 实现 → reviewer 审查（发现 2 个安全问题）→ developer 修复
Phase 4 → 一致性检查通过
Phase 5 → 产出：设计文档 + 代码 + 审查报告
```

### 案例 B：技术调研（Codex）

```bash
codex "参照 AGENTS.md，组队调研 Click vs Typer vs Fire，从功能、类型安全、学习曲线评估"
```

```
Phase 1 → 技术调研，扇出/扇入，3 个 researcher
Phase 2 → 执行计划写入 _workspace/00_project_lead_plan.md
Phase 3 → 串行扮演各角色：
  [researcher-click] → _workspace/00_researcher_click_findings.md
  [researcher-typer] → _workspace/00_researcher_typer_findings.md
  [researcher-fire]  → _workspace/00_researcher_fire_findings.md
Phase 4 → 汇总三份报告，处理矛盾结论
Phase 5 → 最终推荐报告
```

---

## 进阶技巧

### 部分重新执行

`_workspace/` 已存在时，只重跑某个角色：

```
_workspace/ 已有上次的产出物，只需要重新执行 reviewer 审查，关注安全性维度
```

### 自定义角色

```bash
# 复制基础角色 → 修改定义
cp ~/.claude/agents/developer.md .claude/agents/dba.md
# 编辑 name、description、核心角色等
```

### 混合模式

不同阶段使用不同执行模式：
```
扇出/扇入（researcher 并行调研）→ 流水线（architect 设计）→ 层级委派（前后端并行）→ 生成-验证（审查修改）
```

### 产出物复用

```
上次的架构设计还在 _workspace/01_architect_design.md，基于这个设计继续实现支付模块
```

---

## 常见问题

<details>
<summary><strong>"编排器没有组队，直接执行了"</strong></summary>

任务被判定为小规模。解决：使用触发词"组建团队""组队"，或直接指定角色。

</details>

<details>
<summary><strong>"agent 产出物互相矛盾"</strong></summary>

这是设计行为。冲突处理协议：标注来源并列，不删除任何一方。汇总阶段会对比矛盾点并综合判断。

</details>

<details>
<summary><strong>"审查报告太笼统"</strong></summary>

在任务描述中指定审查维度：安全性（SQL 注入、XSS）、性能（N+1 查询、缓存）、可维护性（命名、错误处理）。

</details>

<details>
<summary><strong>"Codex 环境下无法并行"</strong></summary>

编排器自动降级为串行扮演模式 — 依次切换角色视角，通过 `_workspace/` 维护边界，效果等价。

</details>

<details>
<summary><strong>"想修改已完成的某个阶段"</strong></summary>

描述修改内容，编排器进入部分重新执行模式，仅重跑指定 agent。

</details>

---

## 平台差异

| 维度 | Claude Code (`claude/`) | Codex (`codex/`) |
|------|:-----------------------:|:----------------:|
| Agent 间通信 | SendMessage 实时消息 | `_workspace/` 文件传递 |
| 团队组建 | TeamCreate API | 顺序/并行子任务调用 |
| 进度管理 | TaskCreate/TaskUpdate | 文件产出物检查 |
| 安装位置 | `~/.claude/agents/` + `~/.claude/skills/` | `~/.agents/` + `~/.codex/AGENTS.md` |

## 项目结构

```
multi-agent-dev/
├── claude/                         # Claude Code 完整实现
│   ├── agents/                     # 7 个 Agent 角色定义
│   └── skills/cc-orchestrator/     # 编排器 + references/
├── codex/                          # Codex 完整实现
│   ├── agents/                     # 7 个 Agent 角色定义（文件驱动）
│   └── skills/codex-orchestrator/  # 编排器 + references/
├── tests/                          # 测试场景与验收标准
├── CLAUDE.md                       # Claude Code 项目指令
├── AGENTS.md                       # Codex 全局指令
├── install.sh                      # 双平台安装脚本
├── LICENSE                         # MIT
└── CHANGELOG.md                    # 变更历史
```

## License

MIT
