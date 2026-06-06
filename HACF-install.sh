#!/usr/bin/env bash
set -euo pipefail

# Hypergraph Coding Agent Framework — Installer / Upgrader
#
# Fresh install (interactive):
#   curl -sSL https://raw.githubusercontent.com/tjmustard/Hypergraph-Coding-Agent-Framework/main/HACF-install.sh -o HACF-install.sh && bash HACF-install.sh
#
# Fresh install (non-interactive, all IDEs):
#   curl -sSL https://raw.githubusercontent.com/tjmustard/Hypergraph-Coding-Agent-Framework/main/HACF-install.sh | bash -s -- -y
#
# Install specific IDEs only:
#   bash HACF-install.sh --ides="claude,windsurf"
#
# Upgrade (interactive prompts):
#   bash HACF-install.sh
#
# Upgrade (accept all):
#   bash HACF-install.sh -y
#
# Upgrade, preserving CLAUDE.md / GEMINI.md / AGENTS.md customizations:
#   bash HACF-install.sh --preserve-custom
#   bash HACF-install.sh -y --preserve-custom

REPO_URL="https://github.com/tjmustard/Hypergraph-Coding-Agent-Framework.git"
BRANCH="main"
TMP_DIR="$(mktemp -d)"

# ---------------------------------------------------------------------------
# IDE Definitions
# Format: "id|Display Name|directories (space-sep)|files (space-sep)"
#
# .agents/ and core dirs (spec/, tests/, docs/) are ALWAYS installed.
# These entries define only the IDE-specific additions.
# ---------------------------------------------------------------------------
IDE_DEFS=(
  "claude|Claude Code|.claude|CLAUDE.md"
  "antigravity|Antigravity / Gemini CLI||GEMINI.md"
  "windsurf|Windsurf|.windsurf|"
  "cursor|Cursor|.cursor|"
  "cline|Cline|.clinerules|"
  "roo|Roo Code|.roo|"
  "universal|Universal — AGENTS.md  (GitHub Copilot, Zed, and others)||AGENTS.md"
)

# Source path overrides: these files are installed from .agents/install-templates/ rather
# than the repo root, so that the installed versions are framed for user projects rather
# than for HACF framework development. The repo root versions remain unchanged and continue
# to govern agents working on the HACF repo itself.
declare -A FILE_SOURCE_OVERRIDE=(
  ["CLAUDE.md"]=".agents/install-templates/CLAUDE.md"
  ["AGENTS.md"]=".agents/install-templates/AGENTS.md"
  ["GEMINI.md"]=".agents/install-templates/GEMINI.md"
)

# Always installed regardless of IDE selection
CORE_DIRS=(".agents" "tests")
CORE_FILES=(".agentignore")

# ---------------------------------------------------------------------------
# Flags
# ---------------------------------------------------------------------------
AUTO_YES=false
PRESELECTED_IDES=""   # empty = show menu; comma-separated IDs or "all"
PRESERVE_CUSTOM=false

# Agent instruction files users customize — protected by --preserve-custom
CUSTOM_PROTECTED_FILES=("CLAUDE.md" "GEMINI.md" "AGENTS.md")

for arg in "$@"; do
  case "$arg" in
    -y|--yes)            AUTO_YES=true ;;
    --ides=*)            PRESELECTED_IDES="${arg#--ides=}" ;;
    --preserve-custom)   PRESERVE_CUSTOM=true ;;
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

ide_id()          { echo "${1%%|*}"; }
ide_display()     { echo "${1}" | cut -d'|' -f2; }
ide_dirs()        { echo "${1}" | cut -d'|' -f3; }
ide_files()       { echo "${1}" | cut -d'|' -f4; }

# Parse a comma-separated IDE string into an array of IDs
parse_ide_list() {
  local input="$1"
  echo "${input//,/ }"
}

# Check if an ID is in a space-separated list
contains_id() {
  local id="$1"; shift
  local list="$*"
  [[ " $list " == *" $id "* ]]
}

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║       Hypergraph Coding Agent Framework Installer        ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# ---------------------------------------------------------------------------
# Detect upgrade vs. fresh install
# ---------------------------------------------------------------------------
UPGRADE_MODE=false
if [ -d ".agents" ]; then
  UPGRADE_MODE=true
  echo "🔄  Existing installation detected — running in UPGRADE mode."
  echo "    Use -y to accept all updates automatically."
else
  echo "🆕  No existing installation found — running fresh install."
fi
echo ""

# ---------------------------------------------------------------------------
# Preflight checks
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# IDE Selection
# ---------------------------------------------------------------------------
SELECTED_IDE_IDS=""

if $AUTO_YES || ! is_tty; then
  # Non-interactive / auto: install all IDEs
  for def in "${IDE_DEFS[@]}"; do
    id=$(ide_id "$def")
    SELECTED_IDE_IDS="$SELECTED_IDE_IDS $id"
  done
  echo "🤖  IDE selection: all (auto/non-interactive)"
  echo ""
elif [[ -n "$PRESELECTED_IDES" ]]; then
  # --ides flag provided
  if [[ "$PRESELECTED_IDES" == "all" ]]; then
    for def in "${IDE_DEFS[@]}"; do
      SELECTED_IDE_IDS="$SELECTED_IDE_IDS $(ide_id "$def")"
    done
    echo "🤖  IDE selection: all (--ides=all)"
  else
    SELECTED_IDE_IDS=$(parse_ide_list "$PRESELECTED_IDES")
    echo "🤖  IDE selection: $SELECTED_IDE_IDS (from --ides flag)"
  fi
  echo ""
else
  # Interactive: show menu
  echo "🖥️   Select the Agentic Coding IDE(s) to install support for."
  echo "    Enter the numbers separated by spaces, or type 'a' for all."
  echo ""
  i=1
  for def in "${IDE_DEFS[@]}"; do
    display=$(ide_display "$def")
    dirs=$(ide_dirs "$def")
    files=$(ide_files "$def")
    artifacts=""
    [[ -n "$dirs" ]]  && artifacts="$dirs/"
    [[ -n "$files" ]] && artifacts="$artifacts  $files"
    printf "    %d) %-38s  %s\n" "$i" "$display" "$artifacts"
    ((i++))
  done
  echo ""
  read -r -p "    Selection [a = all]: " raw_selection
  echo ""

  if [[ "$raw_selection" == "a" || "$raw_selection" == "A" || "$raw_selection" == "all" ]]; then
    for def in "${IDE_DEFS[@]}"; do
      SELECTED_IDE_IDS="$SELECTED_IDE_IDS $(ide_id "$def")"
    done
  else
    for num in $raw_selection; do
      if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#IDE_DEFS[@]}" ]; then
        idx=$(( num - 1 ))
        id=$(ide_id "${IDE_DEFS[$idx]}")
        SELECTED_IDE_IDS="$SELECTED_IDE_IDS $id"
      else
        echo "    ⚠️  Ignoring invalid selection: $num"
      fi
    done
  fi

  if [[ -z "${SELECTED_IDE_IDS// /}" ]]; then
    echo "❌  No valid IDEs selected. Aborting."
    exit 1
  fi

  echo "    ✅  Selected: $SELECTED_IDE_IDS"
  echo ""
fi

# Collect all IDE-specific dirs and files to install
IDE_DIRS_TO_INSTALL=()
IDE_FILES_TO_INSTALL=()

for def in "${IDE_DEFS[@]}"; do
  id=$(ide_id "$def")
  if contains_id "$id" $SELECTED_IDE_IDS; then
    dirs=$(ide_dirs "$def")
    files=$(ide_files "$def")
    [[ -n "$dirs" ]]  && IDE_DIRS_TO_INSTALL+=("$dirs")
    [[ -n "$files" ]] && IDE_FILES_TO_INSTALL+=("$files")
  fi
done

# ---------------------------------------------------------------------------
# Clone framework
# ---------------------------------------------------------------------------
echo "📦  Fetching framework (branch: $BRANCH)..."
git clone --depth=1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR" --quiet
echo "    ✅  Done."
echo ""

# ---------------------------------------------------------------------------
# Migration: remove deprecated .agents/workflows/
# ---------------------------------------------------------------------------
if [ -d ".agents/workflows" ] && $UPGRADE_MODE; then
  echo "🗑️   Removing deprecated .agents/workflows/ (content moved to .agents/skills/)..."
  rm -rf ".agents/workflows"
  echo "    ✅  .agents/workflows/ removed."
  echo ""
fi

# ---------------------------------------------------------------------------
# Install core directories (always)
# ---------------------------------------------------------------------------
echo "📁  Core framework directories:"
for dir in "${CORE_DIRS[@]}"; do
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

# ---------------------------------------------------------------------------
# Scaffold spec/ directory structure (never copy framework content)
# ---------------------------------------------------------------------------
echo "📁  Spec directory scaffold:"
for spec_dir in spec/active spec/archive spec/compiled; do
  if [ -d "$spec_dir" ]; then
    echo "    ✓  $spec_dir/ already exists."
  else
    mkdir -p "$spec_dir"
    echo "    ✅  $spec_dir/ created."
  fi
done
echo ""

# ---------------------------------------------------------------------------
# Install core files (always)
# ---------------------------------------------------------------------------
echo "📄  Core config files:"
for file in "${CORE_FILES[@]}"; do
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

# ---------------------------------------------------------------------------
# Install IDE-specific directories
# ---------------------------------------------------------------------------
if [ ${#IDE_DIRS_TO_INSTALL[@]} -gt 0 ]; then
  echo "🖥️   IDE directories:"
  for dir in "${IDE_DIRS_TO_INSTALL[@]}"; do
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
fi

# ---------------------------------------------------------------------------
# Install IDE-specific files
# ---------------------------------------------------------------------------
if [ ${#IDE_FILES_TO_INSTALL[@]} -gt 0 ]; then
  echo "📄  IDE config files:"
  for file in "${IDE_FILES_TO_INSTALL[@]}"; do
    src="${FILE_SOURCE_OVERRIDE[$file]:-$file}"
    if $PRESERVE_CUSTOM && [[ " ${CUSTOM_PROTECTED_FILES[*]} " == *" $file "* ]]; then
      echo "    ⏭️   $file skipped (--preserve-custom)."
      continue
    fi
    if [ -f "$file" ] && $UPGRADE_MODE; then
      if prompt_yn "Update '$file'?"; then
        cp "$TMP_DIR/$src" "$file"
        echo "    ✅  $file updated."
      else
        echo "    ⏭️   $file skipped."
      fi
    else
      cp "$TMP_DIR/$src" "$file"
      echo "    ✅  $file installed."
    fi
  done
  echo ""
fi

# ---------------------------------------------------------------------------
# Set permissions
# ---------------------------------------------------------------------------
echo "🔧  Setting script permissions..."
chmod +x .agents/scripts/*.py
echo "    ✅  .agents/scripts/*.py"
echo ""

# ---------------------------------------------------------------------------
# Install Python dependencies
# ---------------------------------------------------------------------------
echo "🐍  Installing Python dependencies..."
pip install pyyaml --quiet
echo "    ✅  pyyaml"
echo ""

# ---------------------------------------------------------------------------
# .gitignore option
# ---------------------------------------------------------------------------
# Build the list of installed paths that the user might want to gitignore
GITIGNORE_CANDIDATES=()
for def in "${IDE_DEFS[@]}"; do
  id=$(ide_id "$def")
  if contains_id "$id" $SELECTED_IDE_IDS; then
    dirs=$(ide_dirs "$def")
    files=$(ide_files "$def")
    [[ -n "$dirs" ]]  && GITIGNORE_CANDIDATES+=("$dirs/")
    [[ -n "$files" ]] && GITIGNORE_CANDIDATES+=("$files")
  fi
done

if [ ${#GITIGNORE_CANDIDATES[@]} -gt 0 ]; then
  echo "📝  .gitignore"
  echo "    The following IDE-specific paths were installed:"
  for entry in "${GITIGNORE_CANDIDATES[@]}"; do
    echo "      - $entry"
  done
  echo ""

  add_to_gitignore=false
  if $AUTO_YES; then
    echo "    Skipping .gitignore update (use interactive mode to choose)."
  elif ! is_tty; then
    echo "    Skipping .gitignore update (non-interactive mode)."
  else
    if prompt_yn "Add these paths to .gitignore?"; then
      add_to_gitignore=true
    fi
  fi

  if $add_to_gitignore; then
    GITIGNORE_FILE=".gitignore"
    touch "$GITIGNORE_FILE"

    added=0
    # Add a section header if any entries are new
    needs_header=true
    for entry in "${GITIGNORE_CANDIDATES[@]}"; do
      if ! grep -qxF "$entry" "$GITIGNORE_FILE" 2>/dev/null; then
        if $needs_header; then
          echo "" >> "$GITIGNORE_FILE"
          echo "# Hypergraph Coding Agent Framework — IDE config" >> "$GITIGNORE_FILE"
          needs_header=false
        fi
        echo "$entry" >> "$GITIGNORE_FILE"
        echo "    ✅  Added: $entry"
        ((added++)) || true
      else
        echo "    ⏭️   Already in .gitignore: $entry"
      fi
    done

    if [ "$added" -gt 0 ]; then
      echo "    ✅  .gitignore updated ($added entries added)."
    else
      echo "    ℹ️   All entries were already present in .gitignore."
    fi
  fi
  echo ""
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
if $UPGRADE_MODE; then
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║  ✅  Upgrade complete!                                   ║"
  echo "║                                                          ║"
  echo "║  Tips:                                                   ║"
  echo "║    • Run /hyper-refresh-memory to rebuild project context║"
  echo "║    • Run /hyper-contextualize to verify agent framing   ║"
  echo "╚══════════════════════════════════════════════════════════╝"
else
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║  ✅  Installation complete!                              ║"
  echo "║                                                          ║"
  echo "║  Next steps:                                             ║"
  echo "║    1. Run /hyper-discover to scan your codebase         ║"
  echo "║    2. Run /hyper-baseline to generate your first PRD    ║"
  echo "║    3. See AGENTS.md for full usage instructions         ║"
  echo "║    4. Run /hyper-contextualize to verify agent framing  ║"
  echo "╚══════════════════════════════════════════════════════════╝"
fi
echo ""
