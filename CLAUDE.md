# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

多 Agent 协作开发体系，提供一套平台无关的 agent 角色库和编排方法论。支持 Claude Code（通过 Agent Teams）和 Codex（通过 AGENTS.md）两个平台。

核心思路：将复杂开发任务拆解为专业 agent 角色（architect、developer、reviewer、tester、researcher、tech-writer、project-lead），通过编排器 skill 协调协作完成。

## 安装

```bash
./install.sh --all      # 安装到所有检测到的平台
./install.sh --claude    # 仅 Claude Code
./install.sh --codex     # 仅 Codex
```

Claude Code 安装需要环境变量：`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

## 架构

**角色定义层**：每个平台有独立的 7 个角色 Markdown 定义文件（YAML frontmatter + 角色描述 + 协议）
- `claude/agents/*.md` — Claude Code 专用（SendMessage 实时通信）
- `codex/agents/*.md` — Codex 专用（`_workspace/` 文件驱动协调）

**编排层**：每个平台有独立的编排器 skill
- `claude/skills/cc-orchestrator/` — Claude Code 编排器（Agent Teams 模式）
- `codex/skills/codex-orchestrator/` — Codex 编排器（文件驱动模式）
- 各编排器包含：`SKILL.md`（主逻辑，6 Phase 工作流）+ `references/`（pattern-selector、agent-catalog、task-decomposition）

**6 Phase 工作流**：上下文确认 → 任务分析 → 团队组建/执行计划 → 执行 → 整合与验证 → 清理与报告

**6 种架构模式**（详见 `references/pattern-selector.md`）：流水线、扇出/扇入、专家池、生成-验证、监督者、层级委派

**平台适配层**：
- Claude Code：角色文件安装到 `~/.claude/agents/`，skill 符号链接到 `~/.claude/skills/`
- Codex：角色文件安装到 `~/.agents/agents/`，skill 符号链接到 `~/.agents/skills/`，`AGENTS.md` 复制到 `~/.codex/`

**产出物目录** (`_workspace/`)：运行时生成，命名规范 `{阶段编号}_{agent名}_{产出物名}.{ext}`

## Harness: 通用开发协作

**触发：** 当收到需要多角色协作的复杂开发任务时，使用 `cc-orchestrator` skill。简单任务可直接完成。

**执行模式选择：**
- Agent 团队（默认，2+ agent）：TeamCreate + SendMessage + TaskCreate
- 子 Agent（单一任务）：Agent 工具 + run_in_background
- 混合模式：按阶段切换

**关键约束：**
- 所有 agent 显式设置 `model: "opus"`
- 数据冲突时不删除任何一方，标注来源并列
- 设计分歧由 architect 最终决定
- Phase 1 分析结果需向用户确认后才能执行

## 变更历史

| 日期 | 变更内容 | 对象 | 原因 |
|------|----------|------|------|
| 2026-04-14 | 初始构建 | 全部 | — |
