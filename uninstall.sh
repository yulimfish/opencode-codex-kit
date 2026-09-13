#!/usr/bin/env bash
# opencode-codex-kit uninstaller
set -euo pipefail

CFG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
SKILLS_DIR="$CFG_DIR/skills"
AGENTS_DIR="$CFG_DIR/agents"
MANAGED_MANIFEST="$CFG_DIR/.opencode-codex-kit-managed"
SKILL_MANIFEST="$CFG_DIR/.opencode-codex-kit-skills"

echo "==> removing skills"
if [[ -f "$SKILL_MANIFEST" ]]; then
  while IFS= read -r dest; do
    [[ -n "$dest" && -d "$dest" ]] || continue
    if [[ -n "$(git -C "$dest" status --porcelain 2>/dev/null)" ]]; then
      echo "  preserved modified skill: $dest"
    else
      rm -rf "$dest"
      echo "  removed $dest"
    fi
  done < "$SKILL_MANIFEST"
  rm -f "$SKILL_MANIFEST"
else
  echo "  no ownership manifest — preserving existing skill checkouts"
fi

echo "==> removing memory evolution helper files (keeping reports and data)"
if [[ -f "$MANAGED_MANIFEST" ]]; then
  while IFS=$'\t' read -r path checksum; do
    [[ -n "$path" && -n "$checksum" && -f "$path" && ! -L "$path" ]] || continue
    current=$(shasum -a 256 "$path" | cut -d ' ' -f 1)
    if [[ "$current" == "$checksum" ]]; then
      rm -f "$path"
      echo "  removed $path"
    else
      echo "  preserved modified file: $path"
    fi
  done < "$MANAGED_MANIFEST"
  rm -f "$MANAGED_MANIFEST"
else
  echo "  no ownership manifest — preserving existing agent/helper files"
fi

echo "==> removing plugins"
cd "$CFG_DIR"
npm uninstall --silent opencode-codex-guardrails @yulimfish/opencode-tool-search 2>/dev/null || true

echo "Done. Remember to edit opencode.jsonc to remove plugin entries and restart opencode."
