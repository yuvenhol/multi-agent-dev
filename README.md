# multi-agent-dev

**[English](README.en.md) | 中文**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

**多 Agent 协作开发体系** — 同时支持 Claude Code 和 Codex

将复杂开发任务拆解为专业角色并协调协作。每个平台有独立完整的实现，共享相同的方法论。

## 项目结构

```
multi-agent-dev/
├── claude/                              # Claude Code 完整实现
│   ├── agents/                          # Agent 角色定义（7 个）
│   │   ├── architect.md
│   │   ├── developer.md
│   │   ├── reviewer.md
│   │   ├── tester.md
│   │   ├── researcher.md
│   │   ├── tech-writer.md
│   │   └── project-lead.md
│   └── skills/cc-orchestrator/          # 编排器（Agent Teams 模式）
│       ├── SKILL.md
│       └── references/
│           ├── pattern-selector.md
│           ├── agent-catalog.md
│           └── task-decomposition.md
├── codex/                               # Codex 完整实现
│   ├── agents/                          # Agent 角色定义（文件驱动协调）
│   │   └── (同上 7 个角色，适配 Codex)
│   └── skills/codex-orchestrator/       # 编排器（文件驱动模式）
│       ├── SKILL.md
│       └── references/
│           ├── pattern-selector.md
│           ├── agent-catalog.md
│           └── task-decomposition.md
├── CLAUDE.md                            # Claude Code 项目指令
├── AGENTS.md                            # Codex 全局指令
├── install.sh                           # 双平台安装脚本
├── LICENSE                              # MIT 许可证
├── CHANGELOG.md                         # 变更历史
└── README.md
```

## 平台差异

| 维度 | Claude Code (`claude/`) | Codex (`codex/`) |
|------|:-----------------------:|:----------------:|
| Agent 间通信 | SendMessage 实时消息 | `_workspace/` 文件传递 |
| 团队组建 | TeamCreate API | 顺序/并行子任务调用 |
| 进度管理 | TaskCreate/TaskUpdate | 文件产出物检查 |
| 接口配置 | YAML frontmatter | Markdown 角色定义 |
| 安装位置 | `~/.claude/agents/` + `~/.claude/skills/` | `~/.agents/` + `~/.codex/AGENTS.md` |

## 安装

```bash
git clone <repo-url>
cd multi-agent-dev
chmod +x install.sh

./install.sh --all      # 安装到所有检测到的平台
./install.sh --claude   # 仅 Claude Code
./install.sh --codex    # 仅 Codex
./install.sh --uninstall # 卸载
```

### 前置要求

- **Claude Code**: 需启用 Agent Teams — `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- **Codex**: Codex CLI 已安装

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

| 场景 | 模式 | 默认团队 |
|------|------|---------|
| 新功能开发 | 流水线 + 生成-验证 | architect → developer → reviewer + tester |
| 技术调研 | 扇出/扇入 | researcher × 2-4 |
| 代码审查 | 扇出/扇入 | reviewer × 2-3 |
| 大规模重构 | 监督者 | project-lead + developer × 2-3 |
| 全栈开发 | 层级委派 | architect + developer × 2 + tester |
| 混合类型任务 | 专家池 | 按子任务类型路由到对应专家 |
| 文档完善 | 扇出/扇入 | tech-writer + researcher |

## 使用方式

**Claude Code:**
```
组建团队帮我实现用户认证功能
组队调研 Python CLI 框架哪个最好
```

**Codex:**
将 `AGENTS.md` 放到项目根目录或 `~/.codex/`，引用 `agents/` 下的角色定义。

## 自定义扩展

在项目级别创建角色定义覆盖全局：
```bash
# Claude Code
mkdir -p .claude/agents && cp claude/agents/developer.md .claude/agents/

# Codex
# 在项目 AGENTS.md 中添加角色说明
```

## License

MIT
