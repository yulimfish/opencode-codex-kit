#!/usr/bin/env bash
# opencode-codex-kit uninstaller
set -euo pipefail

CFG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
SKILLS_DIR="$CFG_DIR/skills"

SKILLS=(
  clarify-before-act
  ui-preview-first
  long-term-memory
  memory-graph-ui
  tool-call-discipline
  memory-dream
)

echo "==> removing skills"
for s in "${SKILLS[@]}"; do
  if [[ -d "$SKILLS_DIR/$s" ]]; then
    rm -rf "$SKILLS_DIR/$s"
    echo "  removed $s"
  fi
done

echo "==> removing plugins"
cd "$CFG_DIR"
npm uninstall --silent opencode-codex-guardrails opencode-codex-doubao-shim 2>/dev/null || true

echo "Done. Remember to edit opencode.jsonc to remove plugin entries."
