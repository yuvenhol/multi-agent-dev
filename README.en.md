# multi-agent-dev

**English | [中文](README.md)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

**Multi-Agent Collaborative Development Framework** — supporting both Claude Code and Codex

Decomposes complex development tasks into specialized agent roles and orchestrates their collaboration. Each platform has its own complete implementation sharing the same methodology.

## Quick Start

### Let AI Help You Install

If you're using Claude Code or another AI coding assistant, just send it this prompt:

> Help me install multi-agent-dev, the multi-agent collaboration framework. Steps:
> 1. Clone `https://github.com/yuwenhao/multi-agent-dev` locally
> 2. Check my environment (whether `~/.claude` or `~/.codex` directories exist)
> 3. If Claude Code, ensure env var `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is set to `1`
> 4. Run `./install.sh --all` to install
> 5. Verify: check that `~/.claude/agents/` has 7 role files and `~/.claude/skills/cc-orchestrator` symlink is correct

### Manual Installation

```bash
git clone https://github.com/yuwenhao/multi-agent-dev.git && cd multi-agent-dev
chmod +x install.sh
./install.sh --all        # Install to all detected platforms
```

> **Prerequisites:**
> - **Claude Code**: Requires Agent Teams — `export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
> - **Codex**: Codex CLI installed

### Verify Installation

```bash
# Claude Code: check role files
ls ~/.claude/agents/*.md
# Should see 7 files: architect developer project-lead researcher reviewer tech-writer tester

# Claude Code: check orchestrator
ls -la ~/.claude/skills/cc-orchestrator
# Should be a symlink to the repo
```

### First Command

**Claude Code:**
```
Assemble a team to implement user login with JWT auth and password encryption
```

**Codex:**
```bash
codex "Following AGENTS.md collaboration spec, assemble a team to add REST API docs for this project"
```

### What to Expect

1. **Phase 1 Analysis** — Orchestrator identifies task type, scale, selects pattern and team
2. **Confirmation** — "Analysis above, proceed?" (for complex/ambiguous tasks)
3. **Team Execution** — Agents work sequentially or in parallel
4. **Artifacts** — All intermediate outputs saved in `_workspace/`

```
_workspace/
├── 00_project_lead_plan.md       # Execution plan
├── 01_architect_design.md        # Architecture design
├── 02_developer_changelog.md     # Development log
├── 03_reviewer_report.md         # Review report
└── 04_tester_report.md           # Test report
```

---

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

```
What type is your task?
│
├─ New Feature Dev       → Pipeline + Producer-Reviewer
│                          architect → developer → reviewer → developer(fix) → tester
├─ Tech Research         → Fan-out/Fan-in
│                          researcher × N → aggregate
├─ Code Review           → Fan-out/Fan-in
│                          reviewer × N (security/performance/architecture) → summary
├─ Bug Fix               → Producer-Reviewer (or direct)
│                          developer → reviewer → developer(fix) (max 2 rounds)
├─ Major Refactor        → Supervisor
│                          project-lead → developer × N → batch verify
├─ Full-stack Project    → Hierarchical Delegation
│                          architect → developer-frontend | developer-backend → tester
├─ Mixed Tasks           → Expert Pool
│                          Route subtasks to matching experts
└─ Documentation         → Fan-out/Fan-in
                           researcher → tech-writer
```

<details>
<summary>One-line pattern guide</summary>

| Pattern | When to Use |
|---------|-------------|
| Pipeline | Steps have sequential dependencies — each output feeds the next |
| Fan-out/Fan-in | Multiple agents work independently in parallel, then aggregate |
| Expert Pool | Different subtasks need different specialists, route by type |
| Producer-Reviewer | One creates, another validates, iterate if needed |
| Supervisor | One coordinator, multiple workers, dynamic dispatch |
| Hierarchical Delegation | Top-down decomposition, parallel frontend/backend/modules |

</details>

---

## Prompt Engineering — Writing Effective Tasks

### Good vs Bad Task Descriptions

| Bad | Good | Why It's Better |
|-----|------|-----------------|
| Build me an API | Assemble a team to add user CRUD endpoints to FastAPI using SQLAlchemy + PostgreSQL, with pagination and filtering | Clear tech stack, scope, specific requirements |
| Review the code | Assemble a review team to audit src/auth/ from security, performance, and maintainability perspectives | Specifies review dimensions and scope |
| Research databases | Research team: compare PostgreSQL vs MySQL vs SQLite on performance, ops complexity, ecosystem maturity for ~100K DAU | Specifies candidates, dimensions, constraints |

### Four Elements of a Good Task

1. **Goal** — What to accomplish (start with a verb)
2. **Constraints** — Tech stack, compatibility, performance requirements
3. **Scope** — Which modules/files are involved
4. **Expected Output** — Code? Docs? Both?

---

## Model Selection Strategy

### Core Principle: Use Top Models for Planning, Standard for Execution

Phase 0-1 (context + analysis) is the foundation. **Using the strongest model for task definition and planning** significantly improves all downstream agent work.

```
Phase 0-1 (Analysis & Planning)  → Top model (Opus / o3)
Phase 2 (Team Formation)         → Top model
Phase 3 (Execution)              → Per role:
  - architect / reviewer → Strong model (deep reasoning)
  - developer / tester   → Standard model (code implementation)
  - researcher           → Strong model (synthesis & judgment)
Phase 4-5 (Integration & Report) → Top model
```

| Task Type | Recommended Model | Reason |
|-----------|------------------|--------|
| Architecture / Research | Strongest | Decisions affect everything downstream |
| Code Review | Strong | Must catch hidden issues |
| Implementation / Testing / Docs | Standard | Has clear guidance to follow |

**Claude Code**: all agents should use `model: "opus"`. **Codex**: set `model_reasoning_effort = "xhigh"` in `~/.codex/config.toml` for strongest reasoning.

---

## Walkthrough Examples

### Example A: New Feature (Claude Code)

```
User: Assemble a team to add user auth to FastAPI: JWT + bcrypt + SQLAlchemy
```

```
Phase 1 → Medium scale, Pipeline + Producer-Reviewer, architect + developer + reviewer
Phase 2 → TeamCreate: auth-feature
Phase 3 → architect designs → developer implements → reviewer finds 2 security issues → developer fixes
Phase 4 → Consistency check passed
Phase 5 → Artifacts: design doc + code + review report
```

### Example B: Tech Research (Codex)

```bash
codex "Following AGENTS.md, research team: compare Click vs Typer vs Fire on features, type safety, learning curve"
```

```
Phase 1 → Tech research, Fan-out/Fan-in, 3 researchers
Phase 2 → Plan written to _workspace/00_project_lead_plan.md
Phase 3 → Serial role switching:
  [researcher-click] → _workspace/00_researcher_click_findings.md
  [researcher-typer] → _workspace/00_researcher_typer_findings.md
  [researcher-fire]  → _workspace/00_researcher_fire_findings.md
Phase 4 → Aggregate reports, resolve contradictions
Phase 5 → Final recommendation
```

---

## Advanced Tips

### Partial Re-execution

When `_workspace/` exists, re-run only specific roles:
```
_workspace/ has previous artifacts. Re-run only the reviewer, focusing on security this time
```

### Custom Roles

```bash
cp ~/.claude/agents/developer.md .claude/agents/dba.md
# Edit name, description, core role definitions
```

### Mixed Modes

Different phases can use different patterns:
```
Fan-out/Fan-in (parallel research) → Pipeline (architect designs) → Hierarchical (parallel dev) → Producer-Reviewer (review & fix)
```

### Artifact Reuse

```
Architecture design is still in _workspace/01_architect_design.md, continue implementing the payment module based on it
```

---

## FAQ

<details>
<summary><strong>"The orchestrator didn't form a team, just executed directly"</strong></summary>

Task was judged as small-scale. Fix: use trigger words like "assemble a team", or directly specify roles.

</details>

<details>
<summary><strong>"Agent artifacts contradict each other"</strong></summary>

By design. Conflict protocol: annotate sources side-by-side, never delete either side. Aggregation phase synthesizes.

</details>

<details>
<summary><strong>"Review report is too vague"</strong></summary>

Specify review dimensions: security (SQL injection, XSS), performance (N+1, caching), maintainability (naming, error handling).

</details>

<details>
<summary><strong>"Codex can't execute in parallel"</strong></summary>

Orchestrator auto-falls back to serial role-playing — switching perspectives sequentially via `_workspace/` files. Equivalent result.

</details>

<details>
<summary><strong>"I want to modify a completed phase"</strong></summary>

Describe the change, orchestrator enters partial re-execution mode, re-runs only the specified agent.

</details>

---

## Platform Differences

| Dimension | Claude Code (`claude/`) | Codex (`codex/`) |
|------|:-----------------------:|:----------------:|
| Inter-agent Communication | SendMessage real-time | `_workspace/` file-based |
| Team Formation | TeamCreate API | Sequential/parallel subtasks |
| Progress Tracking | TaskCreate/TaskUpdate | File artifact checking |
| Install Location | `~/.claude/agents/` + `~/.claude/skills/` | `~/.agents/` + `~/.codex/AGENTS.md` |

## Project Structure

```
multi-agent-dev/
├── claude/                         # Claude Code implementation
│   ├── agents/                     # 7 agent role definitions
│   └── skills/cc-orchestrator/     # Orchestrator + references/
├── codex/                          # Codex implementation
│   ├── agents/                     # 7 agent role definitions (file-driven)
│   └── skills/codex-orchestrator/  # Orchestrator + references/
├── tests/                          # Test scenarios & acceptance criteria
├── CLAUDE.md                       # Claude Code project instructions
├── AGENTS.md                       # Codex global instructions
├── install.sh                      # Dual-platform installer
├── LICENSE                         # MIT
└── CHANGELOG.md                    # Changelog
```

## License

MIT
