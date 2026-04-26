#!/bin/bash
# Smoke tests for install.sh using isolated HOME directories.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALLER="$REPO_DIR/install.sh"
MINIMAL_PATH="/usr/bin:/bin:/usr/sbin:/sbin"

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

make_home() {
    mktemp -d "${TMPDIR:-/tmp}/multi-agent-dev-install.XXXXXX"
}

cleanup_home() {
    rm -rf "$1"
}

assert_file() {
    [ -f "$1" ] || fail "expected file: $1"
}

assert_symlink_target() {
    local link_path="$1"
    local expected_target="$2"

    [ -L "$link_path" ] || fail "expected symlink: $link_path"
    [ "$(readlink "$link_path")" = "$expected_target" ] || fail "unexpected target for $link_path"
}

test_codex_install_is_idempotent() {
    local home_dir
    home_dir=$(make_home)
    trap 'cleanup_home "$home_dir"' RETURN

    HOME="$home_dir" "$INSTALLER" --codex >/dev/null
    assert_file "$home_dir/.agents/agents/architect.md"
    assert_file "$home_dir/.codex/AGENTS.md"
    assert_symlink_target "$home_dir/.agents/skills/codex-orchestrator" "$REPO_DIR/codex/skills/codex-orchestrator"

    HOME="$home_dir" "$INSTALLER" --codex >/dev/null
    assert_symlink_target "$home_dir/.agents/skills/codex-orchestrator" "$REPO_DIR/codex/skills/codex-orchestrator"
}

test_claude_install_and_uninstall() {
    local home_dir
    home_dir=$(make_home)
    trap 'cleanup_home "$home_dir"' RETURN

    HOME="$home_dir" "$INSTALLER" --claude >/dev/null
    assert_file "$home_dir/.claude/agents/architect.md"
    assert_symlink_target "$home_dir/.claude/skills/cc-orchestrator" "$REPO_DIR/claude/skills/cc-orchestrator"

    HOME="$home_dir" "$INSTALLER" --uninstall >/dev/null
    [ ! -e "$home_dir/.claude/agents/architect.md" ] || fail "claude agent was not removed"
    [ ! -e "$home_dir/.claude/skills/cc-orchestrator" ] || fail "claude skill was not removed"
}

test_all_requires_detected_platform() {
    local home_dir
    local output_file
    home_dir=$(make_home)
    output_file="$home_dir/no-platform.out"
    trap 'cleanup_home "$home_dir"' RETURN

    if HOME="$home_dir" PATH="$MINIMAL_PATH" "$INSTALLER" --all >"$output_file" 2>&1; then
        fail "--all succeeded without detected platforms"
    fi

    grep -q "未检测到 Claude Code 或 Codex 环境" "$output_file" || fail "missing no-platform message"
}

test_all_detects_existing_codex_dir() {
    local home_dir
    home_dir=$(make_home)
    trap 'cleanup_home "$home_dir"' RETURN

    mkdir -p "$home_dir/.codex"
    HOME="$home_dir" PATH="$MINIMAL_PATH" "$INSTALLER" --all >/dev/null
    assert_file "$home_dir/.agents/agents/architect.md"
    assert_symlink_target "$home_dir/.agents/skills/codex-orchestrator" "$REPO_DIR/codex/skills/codex-orchestrator"
}

test_codex_install_is_idempotent
test_claude_install_and_uninstall
test_all_requires_detected_platform
test_all_detects_existing_codex_dir

echo "install smoke tests passed"
