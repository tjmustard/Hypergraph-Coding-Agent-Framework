#!/usr/bin/env bash
set -euo pipefail

# Hypergraph Coding Agent Framework — Installer / Upgrader
#
# Fresh install:
#   curl -sSL https://raw.githubusercontent.com/tjmustard/Hypergraph-Coding-Agent-Framework/main/install.sh | bash
#
# Upgrade (interactive prompts):
#   bash install.sh
#
# Upgrade (accept all):
#   bash install.sh -y

REPO_URL="https://github.com/tjmustard/Hypergraph-Coding-Agent-Framework.git"
BRANCH="main"
TMP_DIR="$(mktemp -d)"
INSTALL_DIRS=(".agents" ".claude" "spec" "tests" "docs")
INSTALL_FILES=(".agentignore" "CLAUDE.md" "GEMINI.md")

# --- Flags ---
AUTO_YES=false
for arg in "$@"; do
  [[ "$arg" == "-y" || "$arg" == "--yes" ]] && AUTO_YES=true
done

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

# --- Helpers ---
is_tty() { [ -t 0 ]; }

prompt_yn() {
  local msg="$1"
  local default="${2:-n}"  # default answer if non-interactive
  if $AUTO_YES; then
    echo "    $msg [y/N] y (auto)"
    return 0
  fi
  if ! is_tty; then
    echo "    $msg [y/N] $default (non-interactive)"
    [[ "$default" == "y" ]] && return 0 || return 1
  fi
  read -r -p "    $msg [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

# --- Banner ---
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║       Hypergraph Coding Agent Framework Installer        ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# --- Detect mode ---
UPGRADE_MODE=false
if [ -d ".agents" ]; then
  UPGRADE_MODE=true
  echo "🔄  Existing installation detected — running in UPGRADE mode."
  echo "    Use -y to accept all updates automatically."
else
  echo "🆕  No existing installation found — running fresh install."
fi
echo ""

# --- Preflight checks ---
for cmd in git pip; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌  Error: '$cmd' is required but not installed." >&2
    exit 1
  fi
done

if [ ! -d ".git" ] && ! $UPGRADE_MODE; then
  echo "⚠️  Warning: No git repository detected in the current directory."
  if ! prompt_yn "Install anyway?"; then
    echo "Aborted."
    exit 0
  fi
fi

# --- Clone framework ---
echo "📦  Fetching framework (branch: $BRANCH)..."
git clone --depth=1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR" --quiet
echo "    ✅  Done."
echo ""

# --- Process directories ---
echo "📁  Framework directories:"
for dir in "${INSTALL_DIRS[@]}"; do
  if [ -d "$dir" ] && $UPGRADE_MODE; then
    if prompt_yn "Update '$dir/'?"; then
      cp -r "$TMP_DIR/$dir/." "$dir/"
      echo "    ✅  $dir/ updated."
    else
      echo "    ⏭️   $dir/ skipped."
    fi
  else
    cp -r "$TMP_DIR/$dir" "$dir"
    echo "    ✅  $dir/ installed."
  fi
done
echo ""

# --- Process root config files ---
echo "📄  Root config files:"
for file in "${INSTALL_FILES[@]}"; do
  if [ -f "$file" ] && $UPGRADE_MODE; then
    if prompt_yn "Update '$file'?"; then
      cp "$TMP_DIR/$file" "$file"
      echo "    ✅  $file updated."
    else
      echo "    ⏭️   $file skipped."
    fi
  else
    cp "$TMP_DIR/$file" "$file"
    echo "    ✅  $file installed."
  fi
done
echo ""

# --- Set permissions ---
echo "🔧  Setting script permissions..."
chmod +x .agents/scripts/*.py
echo "    ✅  .agents/scripts/*.py"
echo ""

# --- Install Python dependencies ---
echo "🐍  Installing Python dependencies..."
pip install pyyaml --quiet
echo "    ✅  pyyaml"
echo ""

# --- Done ---
if $UPGRADE_MODE; then
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║  ✅  Upgrade complete!                                   ║"
  echo "║                                                          ║"
  echo "║  Tip: Run /refresh-memory to rebuild project context    ║"
  echo "╚══════════════════════════════════════════════════════════╝"
else
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║  ✅  Installation complete!                              ║"
  echo "║                                                          ║"
  echo "║  Next steps:                                             ║"
  echo "║    1. Run /discover to scan your codebase               ║"
  echo "║    2. Run /baseline to generate your first SuperPRD     ║"
  echo "║    3. See CLAUDE.md for full usage instructions         ║"
  echo "╚══════════════════════════════════════════════════════════╝"
fi
echo ""
