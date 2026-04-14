# multi-agent-dev

**多 Agent 协作开发体系** | **Multi-Agent Collaborative Development Framework**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

同时支持 Claude Code 和 Codex。将复杂开发任务拆解为专业角色并协调协作。每个平台有独立完整的实现，共享相同的方法论。

Supports both Claude Code and Codex. Decomposes complex development tasks into specialized agent roles and orchestrates their collaboration. Each platform has its own complete implementation sharing the same methodology.

## 项目结构 / Project Structure

```
multi-agent-dev/
├── claude/                              # Claude Code implementation
│   ├── agents/                          # Agent role definitions (7)
│   │   ├── architect.md
│   │   ├── developer.md
│   │   ├── reviewer.md
│   │   ├── tester.md
│   │   ├── researcher.md
│   │   ├── tech-writer.md
│   │   └── project-lead.md
│   └── skills/cc-orchestrator/          # Orchestrator (Agent Teams)
│       ├── SKILL.md
│       └── references/
│           ├── pattern-selector.md
│           ├── agent-catalog.md
│           └── task-decomposition.md
├── codex/                               # Codex implementation
│   ├── agents/                          # Agent role definitions (file-driven)
│   │   └── (same 7 roles, adapted for Codex)
│   └── skills/codex-orchestrator/       # Orchestrator (file-driven)
│       ├── SKILL.md
│       └── references/
│           ├── pattern-selector.md
│           ├── agent-catalog.md
│           └── task-decomposition.md
├── CLAUDE.md                            # Claude Code project instructions
├── AGENTS.md                            # Codex global instructions
├── install.sh                           # Dual-platform installer
├── LICENSE                              # MIT License
├── CHANGELOG.md                         # Changelog
└── README.md
```

## 平台差异 / Platform Differences

| 维度 / Dimension | Claude Code (`claude/`) | Codex (`codex/`) |
|------|:-----------------------:|:----------------:|
| Agent 间通信 / Inter-agent Communication | SendMessage 实时消息 / Real-time messages | `_workspace/` 文件传递 / File-based |
| 团队组建 / Team Formation | TeamCreate API | 顺序/并行子任务调用 / Sequential/parallel subtasks |
| 进度管理 / Progress Tracking | TaskCreate/TaskUpdate | 文件产出物检查 / File artifact checking |
| 接口配置 / Interface Config | YAML frontmatter | Markdown 角色定义 / Markdown role definitions |
| 安装位置 / Install Location | `~/.claude/agents/` + `~/.claude/skills/` | `~/.agents/` + `~/.codex/AGENTS.md` |

## 安装 / Installation

```bash
git clone <repo-url>
cd multi-agent-dev
chmod +x install.sh

./install.sh --all      # Install to all detected platforms / 安装到所有检测到的平台
./install.sh --claude   # Claude Code only / 仅 Claude Code
./install.sh --codex    # Codex only / 仅 Codex
./install.sh --uninstall # Uninstall / 卸载
```

### 前置要求 / Prerequisites

- **Claude Code**: 需启用 Agent Teams / Requires Agent Teams — `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- **Codex**: Codex CLI 已安装 / Codex CLI installed

## 7 个通用角色 / 7 Universal Roles

| 角色 / Role | 核心能力 / Core Capability | 产出物 / Artifact |
|------|---------|--------|
| **architect** | 需求分析、模块划分、接口定义、技术选型 / Requirements analysis, module design, API contracts, tech selection | `01_architect_design.md` |
| **developer** | 代码实现、Bug 修复 / Code implementation, bug fixes | code + `02_developer_changelog.md` |
| **reviewer** | 架构一致性、安全、性能、代码质量审查 / Architecture consistency, security, performance, code quality review | `03_reviewer_report.md` |
| **tester** | 测试设计、边界验证 / Test design, boundary verification | tests + `04_tester_report.md` |
| **researcher** | 多源调研、方案比较 / Multi-source research, solution comparison | `00_researcher_{topic}_findings.md` |
| **tech-writer** | API 文档、使用指南 / API docs, user guides | `05_techwriter_docs.md` |
| **project-lead** | 任务拆解、团队协调 / Task decomposition, team coordination | `00_project_lead_plan.md` |

## 6 种架构模式 / 6 Architecture Patterns

| 场景 / Scenario | 模式 / Pattern | 默认团队 / Default Team |
|------|------|---------|
| 新功能开发 / New Feature | 流水线 + 生成-验证 / Pipeline + Producer-Reviewer | architect → developer → reviewer + tester |
| 技术调研 / Tech Research | 扇出/扇入 / Fan-out/Fan-in | researcher × 2-4 |
| 代码审查 / Code Review | 扇出/扇入 / Fan-out/Fan-in | reviewer × 2-3 |
| 大规模重构 / Major Refactor | 监督者 / Supervisor | project-lead + developer × 2-3 |
| 全栈开发 / Full-stack Dev | 层级委派 / Hierarchical Delegation | architect + developer × 2 + tester |
| 混合类型任务 / Mixed Tasks | 专家池 / Expert Pool | 按子任务类型路由 / Routed by subtask type |
| 文档完善 / Documentation | 扇出/扇入 / Fan-out/Fan-in | tech-writer + researcher |

## 使用方式 / Usage

**Claude Code:**
```
组建团队帮我实现用户认证功能
Assemble a team to implement user authentication
```

**Codex:**

将 `AGENTS.md` 放到项目根目录或 `~/.codex/`，引用 `agents/` 下的角色定义。

Place `AGENTS.md` in the project root or `~/.codex/`, referencing role definitions under `agents/`.

## 自定义扩展 / Customization

在项目级别创建角色定义覆盖全局 / Override global roles at the project level:

```bash
# Claude Code
mkdir -p .claude/agents && cp claude/agents/developer.md .claude/agents/

# Codex — add role definitions in project-level AGENTS.md
```

## License

MIT
