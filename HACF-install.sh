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
# Upgrade (interactive — shows mode selection menu):
#   bash HACF-install.sh
#
# Upgrade (accept all, full update):
#   bash HACF-install.sh -y
#
# Upgrade, preserving CLAUDE.md / GEMINI.md / AGENTS.md customizations:
#   bash HACF-install.sh --preserve-custom
#   bash HACF-install.sh -y --preserve-custom
#
# Targeted update modes (non-interactive):
#   bash HACF-install.sh --mode=full      # system + skills (default upgrade)
#   bash HACF-install.sh --mode=skills    # .agents/skills/ + IDE skill bridges only
#   bash HACF-install.sh --mode=system    # scripts, schemas, hooks, rules (not skills)
#   bash HACF-install.sh --mode=ide       # IDE dirs/files only
#   bash HACF-install.sh --mode=repair    # install only missing pieces
#   bash HACF-install.sh --mode=dry-run   # preview what would change, touch nothing
#
# Surgical file installs — skip existing files, never overwrite:
#   bash HACF-install.sh --files=pre-commit              # git pre-commit hook only
#   bash HACF-install.sh --files=pyproject-template      # ruff pyproject.toml template
#   bash HACF-install.sh --files=python-rules            # .agents/rules/python.md
#   bash HACF-install.sh --files=pre-commit,pyproject-template  # multiple targets

REPO_URL="https://github.com/tjmustard/Hypergraph-Coding-Agent-Framework.git"
BRANCH="main"
TMP_DIR="$(mktemp -d)"

# ---------------------------------------------------------------------------
# IDE Definitions
# Format: "id|Display Name|directories (space-sep)|files (space-sep)"
#
# .agents/ and core dirs (spec/, tests/) are handled separately.
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

# IDE subdirectories that contain per-skill bridge files.
# These are synced alongside .agents/skills/ in skills-only mode.
SKILL_BRIDGE_DIRS=(".claude/commands" ".windsurf/workflows")

# Source path overrides: these files are installed from .agents/install-templates/ rather
# than the repo root, so that the installed versions are framed for user projects rather
# than for HACF framework development.
declare -A FILE_SOURCE_OVERRIDE=(
  ["CLAUDE.md"]=".agents/install-templates/CLAUDE.md"
  ["AGENTS.md"]=".agents/install-templates/AGENTS.md"
  ["GEMINI.md"]=".agents/install-templates/GEMINI.md"
)

# Named file targets for --files= flag.
# Format: "src_in_clone|dst_in_project|chmod_x"
# All targets skip existing files (repair semantics — never overwrite).
declare -A FILE_TARGETS=(
  ["pre-commit"]=".agents/scripts/pre-commit|.git/hooks/pre-commit|yes"
  ["commit-msg"]=".agents/scripts/commit-msg|.git/hooks/commit-msg|yes"
  ["pre-push"]=".agents/scripts/pre-push|.git/hooks/pre-push|yes"
  ["pyproject-template"]=".agents/schemas/project-templates/pyproject.toml|.agents/schemas/project-templates/pyproject.toml|no"
  ["python-rules"]=".agents/rules/python.md|.agents/rules/python.md|no"
  ["testing-rules"]=".agents/rules/testing.md|.agents/rules/testing.md|no"
  ["security-rules"]=".agents/rules/security.md|.agents/rules/security.md|no"
  ["package-rules"]=".agents/rules/package-management.md|.agents/rules/package-management.md|no"
  ["git-workflow-rules"]=".agents/rules/git-workflow.md|.agents/rules/git-workflow.md|no"
)

# Core dirs/files installed in addition to .agents/ (always, regardless of IDE selection)
CORE_DIRS=("tests")
CORE_FILES=(".agentignore")

# System subdirectories within .agents/ (everything except skills/).
# .agents/memory/ is intentionally excluded — it contains user-generated content.
AGENT_SYSTEM_SUBDIRS=("scripts" "schemas" "config" "rules" "install-templates")

# Agent instruction files users customize — protected by --preserve-custom
CUSTOM_PROTECTED_FILES=("CLAUDE.md" "GEMINI.md" "AGENTS.md")

# ---------------------------------------------------------------------------
# Flags
# ---------------------------------------------------------------------------
AUTO_YES=false
PRESELECTED_IDES=""
PRESERVE_CUSTOM=false
DRY_RUN=false
REPAIR_MODE=false
MODE=""
FILES_TARGET=""

for arg in "$@"; do
  case "$arg" in
    -y|--yes)            AUTO_YES=true ;;
    --ides=*)            PRESELECTED_IDES="${arg#--ides=}" ;;
    --preserve-custom)   PRESERVE_CUSTOM=true ;;
    --mode=*)            MODE="${arg#--mode=}" ;;
    --files=*)           FILES_TARGET="${arg#--files=}" ;;
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

ide_id()      { echo "${1%%|*}"; }
ide_display() { echo "${1}" | cut -d'|' -f2; }
ide_dirs()    { echo "${1}" | cut -d'|' -f3; }
ide_files()   { echo "${1}" | cut -d'|' -f4; }

parse_ide_list() {
  local input="$1"
  echo "${input//,/ }"
}

contains_id() {
  local id="$1"; shift
  local list="$*"
  [[ " $list " == *" $id "* ]]
}

# Dry-run aware copy helpers
do_copy_dir() {
  local src="$1" dst="$2"
  if $DRY_RUN; then
    echo "    [DRY-RUN] would copy dir: $src → $dst"
  elif [ -d "$dst" ]; then
    cp -r "$src/." "$dst/"
  else
    cp -r "$src" "$dst"
  fi
}

do_copy_file() {
  local src="$1" dst="$2"
  if $DRY_RUN; then
    echo "    [DRY-RUN] would copy file: $src → $dst"
  else
    cp "$src" "$dst"
  fi
}

do_mkdir() {
  local dir="$1"
  if $DRY_RUN; then
    echo "    [DRY-RUN] would mkdir -p: $dir"
  else
    mkdir -p "$dir"
  fi
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

# Fresh install always runs the full install — skip mode selection entirely
if ! $UPGRADE_MODE && [[ -z "$FILES_TARGET" ]]; then
  MODE="install"
fi

# ---------------------------------------------------------------------------
# Mode Selection (upgrade only, skipped when --files= is given)
# ---------------------------------------------------------------------------
if $UPGRADE_MODE && [[ -z "$MODE" ]] && [[ -z "$FILES_TARGET" ]]; then
  if $AUTO_YES || ! is_tty; then
    MODE="full"
    echo "🤖  Update mode: full (auto/non-interactive)"
    echo ""
  else
    echo "📋  Select update mode:"
    echo ""
    echo "    1) Full update            — system + skills  (recommended)"
    echo "    2) Skills only            — .agents/skills/ + IDE skill bridges"
    echo "    3) System only            — scripts, schemas, hooks, rules (not skills)"
    echo "    4) IDE files only         — .claude/, .windsurf/, CLAUDE.md, etc."
    echo "    5) Repair / verify        — install only missing pieces"
    echo "    6) Dry-run preview        — show what would change, touch nothing"
    echo ""
    read -r -p "    Selection [1]: " raw_mode
    echo ""
    case "${raw_mode:-1}" in
      1) MODE="full" ;;
      2) MODE="skills" ;;
      3) MODE="system" ;;
      4) MODE="ide" ;;
      5) MODE="repair" ;;
      6) MODE="dry-run" ;;
      *) echo "    ⚠️  Invalid selection, defaulting to full."; MODE="full" ;;
    esac
    echo "    ✅  Mode: $MODE"
    echo ""
  fi
fi

if [[ "$MODE" == "dry-run" ]]; then
  DRY_RUN=true
  echo "🔍  DRY-RUN mode — no files will be modified."
  echo ""
fi

if [[ "$MODE" == "repair" ]]; then
  REPAIR_MODE=true
fi

# ---------------------------------------------------------------------------
# Preflight checks
# ---------------------------------------------------------------------------
for cmd in git pip; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌  Error: '$cmd' is required but not installed." >&2
    exit 1
  fi
done

if [ ! -d ".git" ]; then
  echo "⚠️  Warning: No git repository detected in the current directory."
  if is_tty && ! $AUTO_YES; then
    if prompt_yn "Initialize a git repository here (git init)?"; then
      git init
      echo "    ✅  git repository initialized."
    else
      if ! prompt_yn "Continue install without git?"; then
        echo "Aborted."
        exit 0
      fi
    fi
  fi
fi

# ---------------------------------------------------------------------------
# IDE Selection
# Skills-only and system-only modes don't need IDE selection — they either
# auto-detect installed bridge dirs or don't touch IDE files at all.
# ---------------------------------------------------------------------------
SELECTED_IDE_IDS=""
NEEDS_IDE_SELECTION=true
[[ "$MODE" == "skills" || "$MODE" == "system" || -n "$FILES_TARGET" ]] && NEEDS_IDE_SELECTION=false

if $NEEDS_IDE_SELECTION; then
  if $AUTO_YES || ! is_tty; then
    for def in "${IDE_DEFS[@]}"; do
      id=$(ide_id "$def")
      SELECTED_IDE_IDS="$SELECTED_IDE_IDS $id"
    done
    echo "🤖  IDE selection: all (auto/non-interactive)"
    echo ""
  elif [[ -n "$PRESELECTED_IDES" ]]; then
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
fi

# Collect IDE-specific dirs and files to install
IDE_DIRS_TO_INSTALL=()
IDE_FILES_TO_INSTALL=()

if $NEEDS_IDE_SELECTION; then
  for def in "${IDE_DEFS[@]}"; do
    id=$(ide_id "$def")
    if contains_id "$id" $SELECTED_IDE_IDS; then
      dirs=$(ide_dirs "$def")
      files=$(ide_files "$def")
      [[ -n "$dirs" ]]  && IDE_DIRS_TO_INSTALL+=("$dirs")
      [[ -n "$files" ]] && IDE_FILES_TO_INSTALL+=("$files")
    fi
  done
fi

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

# ===========================================================================
# Installation functions
# ===========================================================================

install_spec_scaffold() {
  echo "📁  Spec directory scaffold:"
  for spec_dir in spec/active spec/archive spec/compiled spec/process; do
    if [ -d "$spec_dir" ]; then
      echo "    ✓  $spec_dir/ already exists."
    else
      do_mkdir "$spec_dir"
      $DRY_RUN || echo "    ✅  $spec_dir/ created."
    fi
  done
  echo ""
}

install_core_dirs() {
  echo "📁  Core framework directories:"
  for dir in "${CORE_DIRS[@]}"; do
    if $REPAIR_MODE; then
      if [ -d "$dir" ]; then
        echo "    ✓  $dir/ already present."
        continue
      fi
      do_copy_dir "$TMP_DIR/$dir" "$dir"
      $DRY_RUN || echo "    ✅  $dir/ installed (was missing)."
    elif [ -d "$dir" ] && $UPGRADE_MODE; then
      if prompt_yn "Update '$dir/'?"; then
        do_copy_dir "$TMP_DIR/$dir" "$dir"
        $DRY_RUN || echo "    ✅  $dir/ updated."
      else
        echo "    ⏭️   $dir/ skipped."
      fi
    else
      do_copy_dir "$TMP_DIR/$dir" "$dir"
      $DRY_RUN || echo "    ✅  $dir/ installed."
    fi
  done
  echo ""
}

install_system_dirs() {
  echo "⚙️   System directories (.agents/ — excluding skills):"
  do_mkdir ".agents"
  for subdir in "${AGENT_SYSTEM_SUBDIRS[@]}"; do
    local src="$TMP_DIR/.agents/$subdir"
    local dst=".agents/$subdir"
    [ -d "$src" ] || continue
    if $REPAIR_MODE; then
      if [ -d "$dst" ]; then
        echo "    ✓  .agents/$subdir/ already present."
        continue
      fi
      do_copy_dir "$src" "$dst"
      $DRY_RUN || echo "    ✅  .agents/$subdir/ installed (was missing)."
    elif [ -d "$dst" ] && $UPGRADE_MODE; then
      if prompt_yn "Update '.agents/$subdir/'?"; then
        do_copy_dir "$src" "$dst"
        $DRY_RUN || echo "    ✅  .agents/$subdir/ updated."
      else
        echo "    ⏭️   .agents/$subdir/ skipped."
      fi
    else
      do_copy_dir "$src" "$dst"
      $DRY_RUN || echo "    ✅  .agents/$subdir/ installed."
    fi
  done
  echo ""
}

install_skills_dir() {
  echo "🧠  Skills (.agents/skills/):"
  do_mkdir ".agents"
  local src="$TMP_DIR/.agents/skills"
  local dst=".agents/skills"
  if $REPAIR_MODE; then
    if [ -d "$dst" ]; then
      echo "    ✓  .agents/skills/ already present."
    else
      do_copy_dir "$src" "$dst"
      $DRY_RUN || echo "    ✅  .agents/skills/ installed (was missing)."
    fi
  elif [ -d "$dst" ] && $UPGRADE_MODE; then
    if prompt_yn "Update '.agents/skills/'?"; then
      do_copy_dir "$src" "$dst"
      $DRY_RUN || echo "    ✅  .agents/skills/ updated."
    else
      echo "    ⏭️   .agents/skills/ skipped."
    fi
  else
    do_copy_dir "$src" "$dst"
    $DRY_RUN || echo "    ✅  .agents/skills/ installed."
  fi
  echo ""
}

install_skill_bridges() {
  echo "🔗  IDE skill bridges:"
  local found=false
  for bridge_dir in "${SKILL_BRIDGE_DIRS[@]}"; do
    local src="$TMP_DIR/$bridge_dir"
    [ -d "$src" ] || continue
    if [ -d "$bridge_dir" ]; then
      found=true
      if $REPAIR_MODE; then
        echo "    ✓  $bridge_dir/ already present."
      elif $UPGRADE_MODE; then
        if prompt_yn "Update '$bridge_dir/'?"; then
          do_copy_dir "$src" "$bridge_dir"
          $DRY_RUN || echo "    ✅  $bridge_dir/ updated."
        else
          echo "    ⏭️   $bridge_dir/ skipped."
        fi
      else
        do_copy_dir "$src" "$bridge_dir"
        $DRY_RUN || echo "    ✅  $bridge_dir/ installed."
      fi
    else
      echo "    ⏭️   $bridge_dir/ not installed in this project — skipping."
    fi
  done
  if ! $found; then
    echo "    ℹ️   No skill bridge directories found in this project."
  fi
  echo ""
}

install_core_files() {
  echo "📄  Core config files:"
  for file in "${CORE_FILES[@]}"; do
    if $REPAIR_MODE; then
      if [ -f "$file" ]; then
        echo "    ✓  $file already present."
        continue
      fi
      do_copy_file "$TMP_DIR/$file" "$file"
      $DRY_RUN || echo "    ✅  $file installed (was missing)."
    elif [ -f "$file" ] && $UPGRADE_MODE; then
      if prompt_yn "Update '$file'?"; then
        do_copy_file "$TMP_DIR/$file" "$file"
        $DRY_RUN || echo "    ✅  $file updated."
      else
        echo "    ⏭️   $file skipped."
      fi
    else
      do_copy_file "$TMP_DIR/$file" "$file"
      $DRY_RUN || echo "    ✅  $file installed."
    fi
  done
  echo ""
}

install_ide_dirs() {
  [ ${#IDE_DIRS_TO_INSTALL[@]} -gt 0 ] || return
  echo "🖥️   IDE directories:"
  for dir in "${IDE_DIRS_TO_INSTALL[@]}"; do
    if $REPAIR_MODE; then
      if [ -d "$dir" ]; then
        echo "    ✓  $dir/ already present."
        continue
      fi
      do_copy_dir "$TMP_DIR/$dir" "$dir"
      $DRY_RUN || echo "    ✅  $dir/ installed (was missing)."
    elif [ -d "$dir" ] && $UPGRADE_MODE; then
      if prompt_yn "Update '$dir/'?"; then
        do_copy_dir "$TMP_DIR/$dir" "$dir"
        $DRY_RUN || echo "    ✅  $dir/ updated."
      else
        echo "    ⏭️   $dir/ skipped."
      fi
    else
      do_copy_dir "$TMP_DIR/$dir" "$dir"
      $DRY_RUN || echo "    ✅  $dir/ installed."
    fi
  done
  echo ""
}

install_ide_files() {
  [ ${#IDE_FILES_TO_INSTALL[@]} -gt 0 ] || return
  echo "📄  IDE config files:"
  for file in "${IDE_FILES_TO_INSTALL[@]}"; do
    local src="${FILE_SOURCE_OVERRIDE[$file]:-$file}"
    if $PRESERVE_CUSTOM && [[ " ${CUSTOM_PROTECTED_FILES[*]} " == *" $file "* ]]; then
      echo "    ⏭️   $file skipped (--preserve-custom)."
      continue
    fi
    if $REPAIR_MODE; then
      if [ -f "$file" ]; then
        echo "    ✓  $file already present."
        continue
      fi
      do_copy_file "$TMP_DIR/$src" "$file"
      $DRY_RUN || echo "    ✅  $file installed (was missing)."
    elif [ -f "$file" ] && $UPGRADE_MODE; then
      if diff -q "$TMP_DIR/$src" "$file" > /dev/null 2>&1; then
        echo "    ✓  $file already up to date."
      else
        echo "    📋  Changes in $file:"
        diff --unified=3 "$file" "$TMP_DIR/$src" || true
        echo ""
        if prompt_yn "Update '$file'?"; then
          do_copy_file "$TMP_DIR/$src" "$file"
          $DRY_RUN || echo "    ✅  $file updated."
        else
          echo "    ⏭️   $file skipped."
        fi
      fi
    else
      do_copy_file "$TMP_DIR/$src" "$file"
      $DRY_RUN || echo "    ✅  $file installed."
    fi
  done
  echo ""
}

set_permissions() {
  echo "🔧  Setting script permissions..."
  if $DRY_RUN; then
    echo "    [DRY-RUN] would chmod +x .agents/scripts/*.py"
    echo "    [DRY-RUN] would chmod +x .agents/scripts/{pre-commit,commit-msg,pre-push}"
  else
    chmod +x .agents/scripts/*.py
    echo "    ✅  .agents/scripts/*.py"
    for hook in pre-commit commit-msg pre-push; do
      chmod +x ".agents/scripts/$hook" 2>/dev/null || true
      echo "    ✅  .agents/scripts/$hook"
    done
  fi
  echo ""
}

install_python_deps() {
  echo "🐍  Installing Python dependencies..."
  if $DRY_RUN; then
    echo "    [DRY-RUN] would pip install pyyaml"
  else
    pip install pyyaml --quiet
    echo "    ✅  pyyaml"
  fi
  echo ""
}

install_single_hook() {
  local hook="$1"
  local HOOK_SRC=".agents/scripts/$hook"
  local HOOK_DST=".git/hooks/$hook"

  if [ ! -f "$HOOK_SRC" ]; then
    echo "    ⚠️  $HOOK_SRC not found — skipping."
  elif $REPAIR_MODE; then
    if [ -f "$HOOK_DST" ]; then
      echo "    ✓  $hook hook already present."
    else
      do_copy_file "$HOOK_SRC" "$HOOK_DST"
      if ! $DRY_RUN; then
        chmod +x "$HOOK_DST"
        echo "    ✅  .git/hooks/$hook installed (was missing)."
      fi
    fi
  elif [ -f "$HOOK_DST" ] && $UPGRADE_MODE; then
    if diff -q "$HOOK_SRC" "$HOOK_DST" > /dev/null 2>&1; then
      echo "    ✓  $hook hook already up to date."
    else
      if prompt_yn "Update $hook hook?"; then
        do_copy_file "$HOOK_SRC" "$HOOK_DST"
        if ! $DRY_RUN; then
          chmod +x "$HOOK_DST"
          echo "    ✅  .git/hooks/$hook updated."
        fi
      else
        echo "    ⏭️   $hook hook skipped."
      fi
    fi
  else
    do_copy_file "$HOOK_SRC" "$HOOK_DST"
    if ! $DRY_RUN; then
      chmod +x "$HOOK_DST"
      echo "    ✅  .git/hooks/$hook installed."
    fi
  fi
}

install_hook() {
  [ -d ".git" ] || return
  echo "🔧  Git hooks:"
  for hook in pre-commit commit-msg pre-push; do
    install_single_hook "$hook"
  done
  echo ""
}

install_files() {
  local targets="${FILES_TARGET//,/ }"
  echo "📄  Targeted file install (skips existing files):"
  local available
  available="$(printf '%s ' "${!FILE_TARGETS[@]}")"
  for name in $targets; do
    local spec="${FILE_TARGETS[$name]:-}"
    if [[ -z "$spec" ]]; then
      echo "    ⚠️  Unknown target: '$name' — skipping."
      echo "       Available: $available"
      continue
    fi
    local src dst do_chmod
    IFS='|' read -r src dst do_chmod <<< "$spec"
    if [[ -f "$dst" ]]; then
      echo "    ✓  $dst already present — skipping."
      continue
    fi
    local parent
    parent="$(dirname "$dst")"
    do_mkdir "$parent"
    do_copy_file "$TMP_DIR/$src" "$dst"
    if ! $DRY_RUN; then
      [[ "$do_chmod" == "yes" ]] && chmod +x "$dst"
      echo "    ✅  $dst installed."
    fi
  done
  echo ""
}

# ---------------------------------------------------------------------------
# Spec scaffold always runs (idempotent mkdir -p calls)
# ---------------------------------------------------------------------------
install_spec_scaffold

# ---------------------------------------------------------------------------
# Mode routing
# ---------------------------------------------------------------------------
if [[ -n "$FILES_TARGET" ]]; then
  install_files
else
case "$MODE" in
  install|full|dry-run)
    install_system_dirs
    install_skills_dir
    install_skill_bridges
    install_core_dirs
    install_core_files
    install_ide_dirs
    install_ide_files
    set_permissions
    install_python_deps
    install_hook
    ;;
  skills)
    install_skills_dir
    install_skill_bridges
    set_permissions
    ;;
  system)
    install_system_dirs
    install_core_dirs
    install_core_files
    set_permissions
    install_python_deps
    install_hook
    ;;
  ide)
    install_ide_dirs
    install_ide_files
    ;;
  repair)
    install_system_dirs
    install_skills_dir
    install_skill_bridges
    install_core_dirs
    install_core_files
    install_ide_dirs
    install_ide_files
    set_permissions
    install_python_deps
    install_hook
    ;;
esac
fi  # end --files= branch

# ---------------------------------------------------------------------------
# .gitignore option (only for modes that touch IDE files)
# ---------------------------------------------------------------------------
if [[ -z "$FILES_TARGET" ]] && [[ "$MODE" == "install" || "$MODE" == "full" || "$MODE" == "ide" || "$MODE" == "repair" || "$MODE" == "dry-run" ]]; then
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
    elif $DRY_RUN; then
      echo "    [DRY-RUN] would prompt to add entries to .gitignore."
    else
      if prompt_yn "Add these paths to .gitignore?"; then
        add_to_gitignore=true
      fi
    fi

    if $add_to_gitignore; then
      GITIGNORE_FILE=".gitignore"
      touch "$GITIGNORE_FILE"

      added=0
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
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
MODE_LABEL=""
if [[ -n "$FILES_TARGET" ]]; then
  MODE_LABEL="File install (${FILES_TARGET})"
else
  case "$MODE" in
    install)  MODE_LABEL="Installation" ;;
    full)     MODE_LABEL="Upgrade" ;;
    skills)   MODE_LABEL="Skills update" ;;
    system)   MODE_LABEL="System update" ;;
    ide)      MODE_LABEL="IDE update" ;;
    repair)   MODE_LABEL="Repair" ;;
    dry-run)  MODE_LABEL="Dry-run preview" ;;
  esac
fi

if $DRY_RUN; then
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║  ✅  Dry-run complete — no files were modified.         ║"
  echo "║                                                          ║"
  echo "║  Re-run and select a different mode to apply changes.   ║"
  echo "╚══════════════════════════════════════════════════════════╝"
elif [[ "$MODE" == "install" ]]; then
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║  ✅  Installation complete!                              ║"
  echo "║                                                          ║"
  echo "║  Next steps:                                             ║"
  echo "║    1. Run /hyper-discover to scan your codebase         ║"
  echo "║    2. Run /hyper-baseline to generate your first PRD    ║"
  echo "║    3. See AGENTS.md for full usage instructions         ║"
  echo "║    4. Run /hyper-contextualize to verify agent framing  ║"
  echo "╚══════════════════════════════════════════════════════════╝"
else
  echo "╔══════════════════════════════════════════════════════════╗"
  printf "║  ✅  %-51s║\n" "$MODE_LABEL complete!"
  echo "║                                                          ║"
  echo "║  Tips:                                                   ║"
  echo "║    • Run /hyper-refresh-memory to rebuild project context║"
  echo "║    • Run /hyper-contextualize to verify agent framing   ║"
  echo "╚══════════════════════════════════════════════════════════╝"
fi
echo ""
