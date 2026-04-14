# Usage Guide

**English | [中文](GUIDE.md)**

## Table of Contents

- [Quick Start](#quick-start)
- [Prompt Engineering](#prompt-engineering--writing-effective-task-descriptions)
- [Model Selection Strategy](#model-selection-strategy)
- [Pattern Selection Decision Tree](#pattern-selection-decision-tree)
- [Walkthrough Examples](#walkthrough-examples)
- [Advanced Tips](#advanced-tips)
- [FAQ & Troubleshooting](#faq--troubleshooting)

---

## Quick Start

### After Installation

**Claude Code:**
```
Assemble a team to implement user login with JWT auth and password encryption
```

**Codex:**
```bash
codex "Following AGENTS.md collaboration spec, assemble a team to add REST API docs for this project"
```

### What to Expect

1. **Phase 1 Analysis** — The orchestrator identifies task type, scale, selects architecture pattern and team
2. **Confirmation** — "Analysis above, proceed?" (for complex/ambiguous tasks)
3. **Team Execution** — Agents work sequentially or in parallel
4. **Artifacts** — All intermediate outputs saved in `_workspace/`

```
_workspace/
├── 00_project_lead_plan.md        # Execution plan
├── 01_architect_design.md         # Architecture design
├── 02_developer_changelog.md      # Development log
├── 03_reviewer_report.md          # Review report
└── 04_tester_report.md            # Test report
```

---

## Prompt Engineering — Writing Effective Task Descriptions

### Good vs Bad Task Descriptions

| Bad | Good | Why It's Better |
|-----|------|-----------------|
| Build me an API | Assemble a team to add user CRUD endpoints to a FastAPI project using SQLAlchemy + PostgreSQL, with pagination and filtering | Clear tech stack, scope, specific requirements |
| Review the code | Assemble a review team to audit src/auth/ from security, performance, and maintainability perspectives | Specifies review dimensions and scope |
| Research databases | Assemble a research team to compare PostgreSQL vs MySQL vs SQLite on performance, ops complexity, and ecosystem maturity for a ~100K DAU project | Specifies candidates, dimensions, constraints |

### Four Elements of a Good Task Description

```
1. Goal — What to accomplish (start with a verb)
2. Constraints — Tech stack, compatibility, performance requirements
3. Scope — Which modules/files are involved
4. Expected Output — Code? Docs? Both?
```

### When to Specify Team vs Let the Orchestrator Decide

| Scenario | Recommendation |
|----------|---------------|
| You know exactly which roles you need | Specify directly: "Use architect + developer + reviewer" |
| Clear task type but uncertain scale | Describe the task, let the orchestrator decide: "Assemble a team to implement XXX" |
| Exploratory task | Just describe the goal: "Help me research the best approach" |

---

## Model Selection Strategy

### Core Principle: Use Top Models for Planning, Standard Models for Execution

Phase 0-1 (context check + task analysis) is the foundation of the entire collaboration. **Using the strongest model for task definition and planning** significantly improves all downstream agent work.

```
Recommended Strategy:

Phase 0-1 (Analysis & Planning)  → Top model (Opus / o3)
Phase 2 (Team Formation)         → Top model
Phase 3 (Execution)              → Per role:
  - architect / reviewer → Strong model (deep reasoning needed)
  - developer            → Standard model (code implementation)
  - researcher           → Strong model (synthesis & judgment)
  - tester               → Standard model (test writing)
Phase 4-5 (Integration & Report) → Top model
```

### Platform Configuration

**Claude Code:**
```yaml
# All agents default to opus in the orchestrator config
model: "opus"
```

In Claude Code Agent Teams, all members should use `model: "opus"` as teams currently can't mix models.

**Codex:**
```bash
# Use -m to specify model
codex -m o3 "Assemble a team to implement user auth"

# Or set default in config.toml
```

### Cost-Effectiveness Guide

| Task Type | Recommended Model | Reason |
|-----------|------------------|--------|
| Architecture design | Strongest | Design decisions affect everything downstream |
| Tech research | Strongest | Requires synthesis, trade-off analysis |
| Code review | Strong | Must catch hidden security and performance issues |
| Code implementation | Standard | Has clear design docs to follow |
| Test writing | Standard | Based on existing code and design |
| Documentation | Standard | Structured input, organize output |

---

## Pattern Selection Decision Tree

```
What type is your task?
│
├─ New Feature Development
│   └─ Pipeline + Producer-Reviewer
│      architect → developer → reviewer → developer(fix) → tester
│
├─ Tech Research / Comparison
│   └─ Fan-out/Fan-in
│      researcher × N (each covers a dimension or candidate) → aggregate
│
├─ Code Review
│   └─ Fan-out/Fan-in
│      reviewer × N (security / performance / architecture) → summary report
│
├─ Bug Fix
│   └─ Producer-Reviewer (or direct completion)
│      developer → reviewer → developer(fix) (max 2 rounds)
│
├─ Large-scale Refactor / Migration
│   └─ Supervisor
│      project-lead → developer × N (batch assign → dynamic rebalance → verify)
│
├─ Full-stack / Multi-tier Project
│   └─ Hierarchical Delegation
│      architect → developer-frontend | developer-backend (parallel) → tester
│
├─ Mixed Task Types
│   └─ Expert Pool
│      Route subtasks to matching expert roles
│
└─ Documentation
    └─ Fan-out/Fan-in
       researcher (gather info) → tech-writer (write docs)
```

### One-Line Pattern Guide

| Pattern | When to Use |
|---------|-------------|
| Pipeline | "Steps have sequential dependencies — each step's output feeds the next" |
| Fan-out/Fan-in | "Multiple agents work independently in parallel, then aggregate" |
| Expert Pool | "Different subtasks need different specialists, route by type" |
| Producer-Reviewer | "One creates, another validates, iterate if needed" |
| Supervisor | "One coordinator, multiple workers, dynamic task dispatch" |
| Hierarchical Delegation | "Top-down decomposition, parallel work on frontend/backend/modules" |

---

## Walkthrough Examples

### Example A: New Feature (Claude Code)

**User input:**
```
Assemble a team to add user authentication to a FastAPI project: JWT + bcrypt + SQLAlchemy
```

**Phase 1 — Orchestrator analysis:**
```
Task type: New feature development
Scale: Medium (4 concerns: auth logic, data model, API endpoints, security)
Pattern: Pipeline + Producer-Reviewer
Team: architect + developer + reviewer

Proceed? [Y/n]
```

**Phase 2 — Team formation:**
```
TeamCreate: auth-feature
Members: architect (opus), developer (opus), reviewer (opus)
Tasks:
  architect: #1 Analyze auth requirements → #2 Design API & data model
  developer: #3 Implement auth logic → #4 Implement endpoints (depends on #2)
  reviewer:  #5 Security review (depends on #3, #4)
  developer: #6 Fix review findings (depends on #5)
```

**Phase 3 — Execution:**
```
architect → _workspace/01_architect_design.md
developer → code + _workspace/02_developer_changelog.md
reviewer  → _workspace/03_reviewer_report.md (found 2 security issues)
developer → fixed security issues, updated code
```

---

### Example B: Tech Research (Codex)

**User input:**
```bash
codex "Following AGENTS.md, assemble a research team to compare Click vs Typer vs Fire
for Python CLI development, evaluate on features, type safety, and learning curve"
```

**Codex serial execution flow:**
```
Phase 1: Identified as tech research, fan-out/fan-in, 3 researchers

Phase 2: Plan written to _workspace/00_project_lead_plan.md

Phase 3: Serial role switching
  [Switch to researcher-click perspective]
  → _workspace/00_researcher_click_findings.md

  [Switch to researcher-typer perspective]
  → _workspace/00_researcher_typer_findings.md

  [Switch to researcher-fire perspective]
  → _workspace/00_researcher_fire_findings.md

Phase 4: Aggregate three reports, resolve contradictions
  → Final recommendation report

Phase 5: Report conclusions to user
```

---

## Advanced Tips

### Partial Re-execution

When `_workspace/` already exists, you can re-run specific roles:

```
_workspace/ already has previous artifacts. Re-run only the reviewer stage,
this time focusing on security dimension
```

The orchestrator detects `_workspace/` exists → enters partial re-execution mode → re-runs only the specified agent.

### Custom Roles

Create project-specific roles:

```bash
# 1. Copy a base role as template
cp ~/.claude/agents/developer.md .claude/agents/dba.md

# 2. Edit the role definition
# name: dba
# description: "Database management expert..."
# Core role: database design, query optimization, migration management...
```

New roles are automatically discovered by the orchestrator.

### Mixed Modes

Different phases can use different execution modes:

```
Phase 1: Fan-out/Fan-in — researcher × 2 parallel research
Phase 2: Pipeline — architect designs based on research
Phase 3: Hierarchical — developer-frontend | developer-backend parallel
Phase 4: Producer-Reviewer — reviewer checks, developer fixes
```

### Artifact Reuse

`_workspace/` artifacts can be reused in subsequent tasks:

```
The architecture design is still in _workspace/01_architect_design.md,
continue implementing the payment module based on that design
```

The orchestrator reads existing artifacts as input context for the new task.

---

## FAQ & Troubleshooting

### "The orchestrator didn't form a team, just executed directly"

**Cause:** Task was judged as small-scale (1-2 concerns), not needing a team.
**Fix:**
- Use explicit trigger words: "assemble a team", "multi-agent collaboration"
- Describe more concerns to trigger medium/large scale detection
- Directly specify: "Use architect + developer + reviewer roles"

### "Agent artifacts contradict each other"

**Cause:** In fan-out/fan-in mode, multiple agents work independently and may reach different conclusions.
**By design:** The conflict protocol states "annotate sources side-by-side, never delete either side." The aggregation phase compares contradictions and provides a synthesized judgment.

### "Review report is too vague"

**Fix:** Specify review dimensions in your task description:
```
Assemble a review team, each focusing on:
1. Security: SQL injection, XSS, auth bypass
2. Performance: N+1 queries, caching strategy, connection pooling
3. Maintainability: code duplication, naming conventions, error handling
```

### "Codex can't execute in parallel"

**Note:** If the current Codex environment doesn't support real parallelism, the orchestrator automatically falls back to **serial role-playing** — switching perspectives sequentially while maintaining boundaries through `_workspace/` files. The result is equivalent, just sequential.

### "I want to modify a completed phase"

**Fix:** Describe what needs to change, and the orchestrator enters partial re-execution mode:
```
The reviewer's report needs a performance dimension analysis added,
please re-run only the reviewer stage
```
