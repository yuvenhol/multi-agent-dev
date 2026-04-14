# Multi-Agent Development

面对复杂开发任务时，将任务拆解为专业 agent 角色并协调协作。

## Agent 角色

本项目提供 7 个通用开发角色，详细定义见 `agents/` 目录：

| 角色 | 职责 |
|------|------|
| **architect** | 架构设计、模块划分、接口定义、技术选型 |
| **developer** | 代码实现、Bug 修复、遵循项目约定 |
| **reviewer** | 代码审查、安全/性能/质量检查 |
| **tester** | 测试设计、边界验证、缺陷报告 |
| **researcher** | 技术调研、方案比较、最佳实践 |
| **tech-writer** | API 文档、使用指南、README |
| **project-lead** | 任务拆解、团队组建、进度协调 |

## 协作规范

### 任务拆解
1. 识别任务性质（新功能/调研/重构/修复/文档）
2. 估算规模（小: 不组队 / 中: 2-3人 / 大: 3-5人）
3. 选择架构模式（流水线/扇出扇入/生成-验证/监督者/层级委派）
4. 从角色库选择组合

### 数据传递
- 结构化产出物存放 `_workspace/` 目录
- 命名规范：`{阶段}_{agent}_{产出物}.{ext}`

### 冲突处理
- 数据冲突：标注来源并列，不删除任何一方
- 设计分歧：architect 有最终决定权

## 参考资料

> 以下路径相对于 `~/.agents/` 目录（安装后）或 `codex/` 目录（项目内）。

- 架构模式选择指南：`skills/codex-orchestrator/references/pattern-selector.md`
- 角色速查表：`skills/codex-orchestrator/references/agent-catalog.md`
- 任务拆解方法论：`skills/codex-orchestrator/references/task-decomposition.md`
