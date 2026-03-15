#!/usr/bin/env bash
set -euo pipefail

# Hypergraph Coding Agent Framework — Uninstaller
#
# Removes all framework-provided files. Directories are only removed if they
# are empty after cleanup — user-created files are never deleted.
#
# The following directories are ALWAYS preserved regardless of options:
#   spec/   — your compiled specs, active drafts, archives
#   tests/  — your candidate outputs and fixtures
#
# Usage:
#   bash uninstall.sh           # interactive
#   bash uninstall.sh -y        # remove all without prompting

REPO_URL="https://github.com/tjmustard/Hypergraph-Coding-Agent-Framework.git"
BRANCH="main"
TMP_DIR="$(mktemp -d)"

# These directories are NEVER touched — not even read
PROTECTED_DIRS=("spec" "tests")

# These files at the repo root are never removed by uninstall
PROTECTED_FILES=("install.sh" "uninstall.sh" "README.md" "CHANGELOG.md")

# ---------------------------------------------------------------------------
# Flags
# ---------------------------------------------------------------------------
AUTO_YES=false

for arg in "$@"; do
  case "$arg" in
    -y|--yes) AUTO_YES=true ;;
  esac
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

is_tty() { [ -t 0 ]; }

prompt_yn() {
  local msg="$1"
  local default="${2:-n}"
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

is_protected() {
  local path="$1"
  for p in "${PROTECTED_DIRS[@]}"; do
    [[ "$path" == "$p" || "$path" == "$p/"* ]] && return 0
  done
  for f in "${PROTECTED_FILES[@]}"; do
    [[ "$path" == "$f" ]] && return 0
  done
  return 1
}

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║     Hypergraph Coding Agent Framework Uninstaller        ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# ---------------------------------------------------------------------------
# Preflight
# ---------------------------------------------------------------------------
if [ ! -d ".agents" ]; then
  echo "❌  No .agents/ directory found. Nothing to uninstall."
  exit 1
fi

echo "⚠️   This will remove all framework-provided files from this directory."
echo ""
echo "    Always preserved:"
for p in "${PROTECTED_DIRS[@]}"; do
  echo "      - $p/"
done
echo ""
echo "    Directories that still contain user-created files will NOT be removed."
echo ""

if ! prompt_yn "Proceed with uninstall?"; then
  echo "Aborted."
  exit 0
fi
echo ""

# ---------------------------------------------------------------------------
# Clone framework to obtain the authoritative file list
# ---------------------------------------------------------------------------
echo "📦  Fetching framework file list (branch: $BRANCH)..."
git clone --depth=1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR" --quiet
echo "    ✅  Done."
echo ""

# ---------------------------------------------------------------------------
# Remove framework-provided files
# ---------------------------------------------------------------------------
echo "🗑️   Removing framework files..."
removed=0

while IFS= read -r -d '' src_file; do
  rel="${src_file#"$TMP_DIR/"}"

  # Skip .git internals
  [[ "$rel" == .git/* ]] && continue

  # Skip protected paths
  is_protected "$rel" && continue

  if [ -f "$rel" ]; then
    rm "$rel"
    echo "    ✗  $rel"
    ((removed++)) || true
  fi
done < <(find "$TMP_DIR" -type f -not -path "*/.git/*" -print0)

echo ""
echo "    Removed $removed file(s)."
echo ""

# ---------------------------------------------------------------------------
# Remove empty directories (bottom-up), skipping protected
# ---------------------------------------------------------------------------
echo "📁  Removing empty directories..."
pruned=0

# Sort in reverse (deepest first) so parent dirs are evaluated after children
while IFS= read -r -d '' src_dir; do
  rel="${src_dir#"$TMP_DIR/"}"

  [[ "$rel" == .git* ]] && continue
  is_protected "$rel" && continue

  # Only remove if the directory exists and is now empty
  if [ -d "$rel" ] && [ -z "$(ls -A "$rel" 2>/dev/null)" ]; then
    rmdir "$rel"
    echo "    ✗  $rel/ (empty)"
    ((pruned++)) || true
  elif [ -d "$rel" ]; then
    echo "    ⏭️   $rel/ (kept — contains user files)"
  fi
done < <(find "$TMP_DIR" -mindepth 1 -type d -not -path "*/.git*" -print0 | sort -rz)

echo ""

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  ✅  Uninstall complete!                                 ║"
echo "║                                                          ║"
echo "║  spec/ and tests/ were not touched.                      ║"
echo "║  Re-run install.sh to restore the framework at any time. ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
