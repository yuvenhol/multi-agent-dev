# Changelog

## [Unreleased]

### Added
- 安装器 smoke test，覆盖 Claude Code / Codex 安装、重复安装、卸载和 `--all` 检测行为。

### Changed
- README 补齐 Codex 安装验证步骤，并说明 `--all` 的平台检测规则。
- `.gitignore` 忽略本地 `.claude/` 配置目录，避免误提交机器级设置。

### Fixed
- 修复 Codex 编排器符号链接校验目标写错导致重复安装时总是重建的问题。
- `./install.sh --all` 在未检测到任何平台时改为明确失败，不再输出误导性的安装完成。

## [1.0.0] - 2026-04-14

### Added
- 7 个通用 agent 角色：architect、developer、reviewer、tester、researcher、tech-writer、project-lead
- 6 种架构模式：流水线、扇出/扇入、专家池、生成-验证、监督者、层级委派
- Claude Code 编排器 skill（cc-orchestrator）— Agent Teams 模式
- Codex 编排器 skill（codex-orchestrator）— 文件驱动模式
- 双平台安装脚本 install.sh（支持 --claude / --codex / --all / --uninstall）
- 参考文档：pattern-selector、agent-catalog、task-decomposition
