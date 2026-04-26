#!/bin/bash
# multi-agent-dev installer
# 将 agent 角色库和编排器 skill 安装到 Claude Code 和/或 Codex

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== multi-agent-dev 安装器 ==="
echo ""

# 检测可用平台
HAS_CLAUDE=false
HAS_CODEX=false

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

has_detected_platforms() {
    [ "$HAS_CLAUDE" = true ] || [ "$HAS_CODEX" = true ]
}

print_no_platforms() {
    echo "未检测到 Claude Code 或 Codex 环境。"
    echo "请先安装 Claude Code 或 Codex CLI，或使用 --claude / --codex 强制安装到指定平台。"
}

if [ -d "$HOME/.claude" ] || command_exists claude; then
    HAS_CLAUDE=true
fi

if [ -d "$HOME/.codex" ] || [ -d "$HOME/.agents" ] || command_exists codex; then
    HAS_CODEX=true
fi

# 验证符号链接是否指向正确目标
check_symlink() {
    local link_path="$1"
    local expected_target="$2"
    local name="$3"

    if [ -L "$link_path" ]; then
        local current_target
        current_target=$(readlink "$link_path")
        if [ "$current_target" = "$expected_target" ]; then
            echo "  跳过 $name（符号链接已正确）"
            return 0
        else
            echo "  更新 $name（旧链接指向 $current_target）"
            rm "$link_path"
            return 1
        fi
    elif [ -e "$link_path" ]; then
        echo "  警告：$name 存在但非符号链接，跳过"
        return 0
    fi
    return 1
}

# ─── Claude Code 安装 ───
install_claude() {
    local CLAUDE_DIR="$HOME/.claude"
    local SRC_DIR="$SCRIPT_DIR/claude"
    echo "── 安装到 Claude Code ──"

    if [ ! -d "$SRC_DIR/agents" ]; then
        echo "  错误：源目录 $SRC_DIR/agents 不存在"; exit 1
    fi

    mkdir -p "$CLAUDE_DIR/agents"
    mkdir -p "$CLAUDE_DIR/skills"

    # 复制 agent 定义
    for agent_file in "$SRC_DIR/agents/"*.md; do
        filename=$(basename "$agent_file")
        if [ -f "$CLAUDE_DIR/agents/$filename" ]; then
            echo "  跳过 agents/$filename（已存在）"
        else
            cp "$agent_file" "$CLAUDE_DIR/agents/$filename" || { echo "  错误：无法复制 agents/$filename"; exit 1; }
            echo "  安装 agents/$filename"
        fi
    done

    # 符号链接编排器 skill
    if ! check_symlink "$CLAUDE_DIR/skills/cc-orchestrator" "$SRC_DIR/skills/cc-orchestrator" "skills/cc-orchestrator"; then
        ln -s "$SRC_DIR/skills/cc-orchestrator" "$CLAUDE_DIR/skills/cc-orchestrator" || { echo "  错误：无法创建符号链接"; exit 1; }
        echo "  安装 skills/cc-orchestrator（符号链接）"
    fi

    echo ""
}

# ─── Codex 安装 ───
install_codex() {
    local AGENTS_DIR="$HOME/.agents"
    local SRC_DIR="$SCRIPT_DIR/codex"
    echo "── 安装到 Codex ──"

    if [ ! -d "$SRC_DIR/agents" ]; then
        echo "  错误：源目录 $SRC_DIR/agents 不存在"; exit 1
    fi

    mkdir -p "$AGENTS_DIR/skills"
    mkdir -p "$AGENTS_DIR/agents"

    # 复制 agent 定义
    for agent_file in "$SRC_DIR/agents/"*.md; do
        filename=$(basename "$agent_file")
        if [ -f "$AGENTS_DIR/agents/$filename" ]; then
            echo "  跳过 agents/$filename（已存在）"
        else
            cp "$agent_file" "$AGENTS_DIR/agents/$filename" || { echo "  错误：无法复制 agents/$filename"; exit 1; }
            echo "  安装 agents/$filename"
        fi
    done

    # 符号链接编排器 skill
    if ! check_symlink "$AGENTS_DIR/skills/codex-orchestrator" "$SRC_DIR/skills/codex-orchestrator" "skills/codex-orchestrator"; then
        ln -s "$SRC_DIR/skills/codex-orchestrator" "$AGENTS_DIR/skills/codex-orchestrator" || { echo "  错误：无法创建符号链接"; exit 1; }
        echo "  安装 skills/codex-orchestrator（符号链接）"
    fi

    # 复制 AGENTS.md 模板（如果不存在或为空）
    if [ ! -f "$HOME/.codex/AGENTS.md" ] || [ ! -s "$HOME/.codex/AGENTS.md" ]; then
        mkdir -p "$HOME/.codex"
        cp "$SCRIPT_DIR/AGENTS.md" "$HOME/.codex/AGENTS.md" || { echo "  错误：无法复制 AGENTS.md"; exit 1; }
        echo "  安装 AGENTS.md"
    else
        echo "  跳过 AGENTS.md（已存在且非空）"
    fi

    echo ""
}

# ─── 卸载 ───
uninstall_claude() {
    local CLAUDE_DIR="$HOME/.claude"
    echo "── 卸载 Claude Code ──"

    for agent in architect developer reviewer tester researcher tech-writer project-lead; do
        if [ -f "$CLAUDE_DIR/agents/$agent.md" ]; then
            rm "$CLAUDE_DIR/agents/$agent.md"
            echo "  移除 agents/$agent.md"
        fi
    done

    if [ -L "$CLAUDE_DIR/skills/cc-orchestrator" ]; then
        rm "$CLAUDE_DIR/skills/cc-orchestrator"
        echo "  移除 skills/cc-orchestrator"
    fi

    echo ""
}

uninstall_codex() {
    local AGENTS_DIR="$HOME/.agents"
    echo "── 卸载 Codex ──"

    for agent in architect developer reviewer tester researcher tech-writer project-lead; do
        if [ -f "$AGENTS_DIR/agents/$agent.md" ]; then
            rm "$AGENTS_DIR/agents/$agent.md"
            echo "  移除 agents/$agent.md"
        fi
    done

    if [ -L "$AGENTS_DIR/skills/codex-orchestrator" ]; then
        rm "$AGENTS_DIR/skills/codex-orchestrator"
        echo "  移除 skills/codex-orchestrator"
    fi

    echo "  注意：~/.codex/AGENTS.md 未自动移除（可能含用户自定义内容）"
    echo ""
}

# ─── 帮助信息 ───
show_help() {
    echo "用法：./install.sh [选项]"
    echo ""
    echo "选项："
    echo "  --claude      仅安装到 Claude Code"
    echo "  --codex       仅安装到 Codex"
    echo "  --all         安装到所有检测到的平台"
    echo "  --uninstall   卸载所有已安装内容"
    echo "  --help, -h    显示此帮助信息"
}

# ─── 参数解析 ───
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
    exit 0
elif [ "$1" = "--claude" ]; then
    install_claude
elif [ "$1" = "--codex" ]; then
    install_codex
elif [ "$1" = "--all" ]; then
    if ! has_detected_platforms; then
        print_no_platforms
        exit 1
    fi
    [ "$HAS_CLAUDE" = true ] && install_claude
    [ "$HAS_CODEX" = true ] && install_codex
elif [ "$1" = "--uninstall" ]; then
    [ "$HAS_CLAUDE" = true ] && uninstall_claude
    [ "$HAS_CODEX" = true ] && uninstall_codex
    echo "=== 卸载完成 ==="
    exit 0
else
    if ! has_detected_platforms; then
        print_no_platforms
        exit 1
    fi

    echo "检测到以下平台："
    [ "$HAS_CLAUDE" = true ] && echo "  - Claude Code"
    [ "$HAS_CODEX" = true ] && echo "  - Codex"
    echo ""
    echo "用法："
    echo "  ./install.sh --claude      仅安装到 Claude Code"
    echo "  ./install.sh --codex       仅安装到 Codex"
    echo "  ./install.sh --all         安装到所有检测到的平台"
    echo "  ./install.sh --uninstall   卸载所有已安装内容"
    echo ""

    # 默认安装到所有检测到的平台
    read -p "安装到所有检测到的平台？[Y/n] " answer
    answer=${answer:-Y}
    if [[ "$answer" =~ ^[Yy] ]]; then
        [ "$HAS_CLAUDE" = true ] && install_claude
        [ "$HAS_CODEX" = true ] && install_codex
    else
        echo "已取消。请使用 --claude 或 --codex 指定平台。"
        exit 0
    fi
fi

echo "=== 安装完成 ==="
echo ""
echo "使用方式："
echo '  Claude Code: "组建团队帮我实现 XXX"'
echo '  Codex:       在 AGENTS.md 中引用 agent 角色定义'
