#!/usr/bin/env bash
# opencode-codex-kit uninstaller
set -euo pipefail

CFG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
SKILLS_DIR="$CFG_DIR/skills"
AGENTS_DIR="$CFG_DIR/agents"

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
# swarm-worker-{kimi,deepseek,glm,minimax} are legacy names, kept here so
# older installs get cleaned up too.
AGENT_FILES=(
  swarm-worker.md
  swarm-synth.md
  goal-verify.md
  swarm-worker-kimi.md
  swarm-worker-deepseek.md
  swarm-worker-glm.md
  swarm-worker-minimax.md
  memory-dream.md
)

echo "==> removing skills"
for s in "${SKILLS[@]}"; do
  if [[ -d "$SKILLS_DIR/$s" ]]; then
    rm -rf "$SKILLS_DIR/$s"
    echo "  removed $s"
  fi
done

echo "==> removing memory evolution helper files (keeping reports and data)"
rm -f "$CFG_DIR/memory/bin/dreamctl" "$CFG_DIR/memory/dream/TEMPLATE.md"

echo "==> removing swarm agent md files"
for f in "${AGENT_FILES[@]}"; do
  if [[ -f "$AGENTS_DIR/$f" ]]; then
    rm -f "$AGENTS_DIR/$f"
    echo "  removed agents/$f"
  fi
done

echo "==> removing plugins"
cd "$CFG_DIR"
npm uninstall --silent opencode-codex-guardrails @yulimfish/opencode-tool-search 2>/dev/null || true

echo "Done. Remember to edit opencode.jsonc to remove plugin entries and restart opencode."
