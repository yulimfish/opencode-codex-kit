#!/usr/bin/env bash
# opencode-codex-kit installer — safe, idempotent, one-shot.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Yulimfish/opencode-codex-kit/main/install.sh | bash

set -euo pipefail

BLUE=$'\033[0;34m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'; RED=$'\033[0;31m'; NC=$'\033[0m'
say() { printf "%s\n" "${BLUE}==>${NC} $*"; }
ok()  { printf "%s\n" "${GREEN}✓${NC} $*"; }
warn(){ printf "%s\n" "${YELLOW}!${NC} $*"; }
die() { printf "%s\n" "${RED}✗${NC} $*" >&2; exit 1; }

CFG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
SKILLS_DIR="$CFG_DIR/skills"
GH_USER="Yulimfish"

SKILLS=(
  clarify-before-act
  ui-preview-first
  long-term-memory
  memory-graph-ui
  tool-call-discipline
  memory-dream
)

PLUGINS=(
  opencode-codex-guardrails
  opencode-codex-doubao-shim
)

# --- prereq --------------------------------------------------------------
say "checking prerequisites"
command -v git  >/dev/null || die "git not found. Install git first."
command -v npm  >/dev/null || die "npm not found. Install Node.js (>=18) first."
command -v curl >/dev/null || die "curl not found."
command -v bun  >/dev/null || warn "bun not found — the doubao-shim plugin needs bun to run. Install via https://bun.sh"

# --- dirs ----------------------------------------------------------------
say "preparing $CFG_DIR"
mkdir -p "$SKILLS_DIR"
ok "config dir ready"

# --- skills --------------------------------------------------------------
for s in "${SKILLS[@]}"; do
  dest="$SKILLS_DIR/$s"
  repo="https://github.com/$GH_USER/opencode-skill-$s.git"
  if [[ -d "$dest/.git" ]]; then
    say "updating skill: $s"
    git -C "$dest" pull --ff-only --quiet || warn "pull failed for $s (keeping local copy)"
  else
    say "installing skill: $s"
    if [[ -e "$dest" ]]; then
      warn "$dest exists but is not a git checkout — moving to $dest.bak.$(date +%s)"
      mv "$dest" "$dest.bak.$(date +%s)"
    fi
    git clone --depth=1 --quiet "$repo" "$dest"
  fi
  ok "$s"
done

# --- plugins -------------------------------------------------------------
say "installing plugins via npm (cwd=$CFG_DIR)"
cd "$CFG_DIR"
if [[ ! -f package.json ]]; then
  npm init -y >/dev/null
  # opencode plugins are loaded by string ID; type=module makes ESM plugins work.
  node -e 'const f="package.json";const p=require("./"+f);p.type="module";require("fs").writeFileSync(f,JSON.stringify(p,null,2))'
fi
npm install --silent "${PLUGINS[@]}"
ok "plugins installed"

# --- next steps ----------------------------------------------------------
cat <<EOF

${GREEN}All done!${NC}

Next steps:

1. Add plugins to ${YELLOW}$CFG_DIR/opencode.jsonc${NC}:

   {
     "plugin": [
       "opencode-codex-guardrails",
       "opencode-codex-doubao-shim",
       "opencode-mem"
     ]
   }

2. Export your Volcengine Ark key (needed by doubao-shim):

   ${YELLOW}export ARK_KEY="ark-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx-xxxxx"${NC}

   Get one at https://console.volcengine.com/ark

3. Add memory config to ${YELLOW}$CFG_DIR/opencode-mem.jsonc${NC}:

   {
     "embeddingApiUrl": "http://127.0.0.1:4748/v1",
     "embeddingApiKey": "not-used-shim-ignores",
     "embeddingModel": "doubao-embedding-vision-250615",
     "embeddingDimensions": 2048
   }

4. Restart opencode. Look for:
     [codex-doubao-shim] health OK at :4748
     [codex-guardrails] armed
     [opencode-mem] loaded …

Full docs: https://github.com/$GH_USER/opencode-codex-kit
EOF
