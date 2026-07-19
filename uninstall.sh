#!/usr/bin/env bash
# opencode-codex-kit uninstaller
set -euo pipefail

CFG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
SKILLS_DIR="$CFG_DIR/skills"
AGENTS_DIR="$CFG_DIR/agent"

SKILLS=(
  clarify-before-act
  ui-preview-first
  long-term-memory
  memory-graph-ui
  tool-call-discipline
  memory-dream
  swarm-cluster
  post-task-audit
  screenshot-to-ui
)

# Agent md files installed by opencode-swarm-agents bundle.
AGENT_FILES=(
  swarm-worker.md
  swarm-worker-kimi.md
  swarm-worker-deepseek.md
  swarm-worker-glm.md
  swarm-worker-minimax.md
  swarm-synth.md
)

echo "==> removing skills"
for s in "${SKILLS[@]}"; do
  if [[ -d "$SKILLS_DIR/$s" ]]; then
    rm -rf "$SKILLS_DIR/$s"
    echo "  removed $s"
  fi
done

echo "==> removing swarm agent md files"
for f in "${AGENT_FILES[@]}"; do
  if [[ -f "$AGENTS_DIR/$f" ]]; then
    rm -f "$AGENTS_DIR/$f"
    echo "  removed agent/$f"
  fi
done

echo "==> removing plugins"
cd "$CFG_DIR"
npm uninstall --silent opencode-codex-guardrails opencode-codex-doubao-shim opencode-tool-search 2>/dev/null || true

echo "Done. Remember to edit opencode.jsonc to remove plugin entries and restart opencode."
