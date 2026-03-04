#!/usr/bin/env bash
set -euo pipefail

# Hypergraph Coding Agent Framework — Installer
# Usage: curl -sSL https://raw.githubusercontent.com/tjmustard/Hypergraph-Coding-Agent-Framework/main/install.sh | bash

REPO_URL="https://github.com/tjmustard/Hypergraph-Coding-Agent-Framework.git"
BRANCH="main"
TMP_DIR="$(mktemp -d)"
INSTALL_DIRS=(".agents" ".claude" "spec" "tests" "docs")
INSTALL_FILES=(".agentignore" "CLAUDE.md" "GEMINI.md")

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║        Hypergraph Coding Agent Framework Installer       ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# --- Preflight checks ---
for cmd in git pip; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌  Error: '$cmd' is required but not installed." >&2
    exit 1
  fi
done

if [ ! -d ".git" ]; then
  echo "⚠️  Warning: No git repository detected in the current directory."
  read -r -p "   Install anyway? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
fi

# --- Clone framework ---
echo "📦  Cloning framework (branch: $BRANCH)..."
git clone --depth=1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR" --quiet

# --- Copy directories ---
echo "📁  Copying framework directories..."
for dir in "${INSTALL_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo "    ⚠️  '$dir' already exists — merging (existing files will not be overwritten)."
    cp -rn "$TMP_DIR/$dir/." "$dir/"
  else
    cp -r "$TMP_DIR/$dir" "$dir"
    echo "    ✅  $dir/"
  fi
done

# --- Copy root config files ---
echo "📄  Copying root config files..."
for file in "${INSTALL_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "    ⚠️  '$file' already exists — skipping."
  else
    cp "$TMP_DIR/$file" "$file"
    echo "    ✅  $file"
  fi
done

# --- Set permissions ---
echo "🔧  Setting script permissions..."
chmod +x .agents/scripts/*.py
echo "    ✅  .agents/scripts/*.py"

# --- Install Python dependencies ---
echo "🐍  Installing Python dependencies..."
pip install pyyaml --quiet
echo "    ✅  pyyaml"

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  ✅  Installation complete!                              ║"
echo "║                                                          ║"
echo "║  Next steps:                                             ║"
echo "║    1. Run /discover to scan your codebase               ║"
echo "║    2. Run /baseline to generate your first SuperPRD     ║"
echo "║    3. See CLAUDE.md for full usage instructions         ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
