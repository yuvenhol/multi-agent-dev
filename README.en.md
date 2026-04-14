# multi-agent-dev

**English | [中文](README.md)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

**Multi-Agent Collaborative Development Framework** — supporting both Claude Code and Codex

Decomposes complex development tasks into specialized agent roles and orchestrates their collaboration. Each platform has its own complete implementation sharing the same methodology.

## Project Structure

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
│   └── skills/cc-orchestrator/          # Orchestrator (Agent Teams mode)
│       ├── SKILL.md
│       └── references/
│           ├── pattern-selector.md
│           ├── agent-catalog.md
│           └── task-decomposition.md
├── codex/                               # Codex implementation
│   ├── agents/                          # Agent role definitions (file-driven)
│   │   └── (same 7 roles, adapted for Codex)
│   └── skills/codex-orchestrator/       # Orchestrator (file-driven mode)
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

## Platform Differences

| Dimension | Claude Code (`claude/`) | Codex (`codex/`) |
|------|:-----------------------:|:----------------:|
| Inter-agent Communication | SendMessage real-time messaging | `_workspace/` file-based passing |
| Team Formation | TeamCreate API | Sequential/parallel subtask calls |
| Progress Tracking | TaskCreate/TaskUpdate | File artifact checking |
| Interface Config | YAML frontmatter | Markdown role definitions |
| Install Location | `~/.claude/agents/` + `~/.claude/skills/` | `~/.agents/` + `~/.codex/AGENTS.md` |

## Installation

```bash
git clone <repo-url>
cd multi-agent-dev
chmod +x install.sh

./install.sh --all      # Install to all detected platforms
./install.sh --claude   # Claude Code only
./install.sh --codex    # Codex only
./install.sh --uninstall # Uninstall
```

### Prerequisites

- **Claude Code**: Requires Agent Teams — `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- **Codex**: Codex CLI installed

## 7 Universal Roles

| Role | Core Capability | Artifact |
|------|---------|--------|
| **architect** | Requirements analysis, module design, API contracts, tech selection | `01_architect_design.md` |
| **developer** | Code implementation, bug fixes | code + `02_developer_changelog.md` |
| **reviewer** | Architecture consistency, security, performance, code quality review | `03_reviewer_report.md` |
| **tester** | Test design, boundary verification | tests + `04_tester_report.md` |
| **researcher** | Multi-source research, solution comparison | `00_researcher_{topic}_findings.md` |
| **tech-writer** | API docs, user guides | `05_techwriter_docs.md` |
| **project-lead** | Task decomposition, team coordination | `00_project_lead_plan.md` |

## 6 Architecture Patterns

| Scenario | Pattern | Default Team |
|------|------|---------|
| New Feature | Pipeline + Producer-Reviewer | architect → developer → reviewer + tester |
| Tech Research | Fan-out/Fan-in | researcher × 2-4 |
| Code Review | Fan-out/Fan-in | reviewer × 2-3 |
| Major Refactor | Supervisor | project-lead + developer × 2-3 |
| Full-stack Dev | Hierarchical Delegation | architect + developer × 2 + tester |
| Mixed Tasks | Expert Pool | Routed to experts by subtask type |
| Documentation | Fan-out/Fan-in | tech-writer + researcher |

## Usage

**Claude Code:**
```
Assemble a team to implement user authentication
Build a team to research which Python CLI framework is best
```

**Codex:**
Place `AGENTS.md` in the project root or `~/.codex/`, referencing role definitions under `agents/`.

## Customization

Override global roles at the project level:
```bash
# Claude Code
mkdir -p .claude/agents && cp claude/agents/developer.md .claude/agents/

# Codex — add role definitions in project-level AGENTS.md
```

## License

MIT
