#!/usr/bin/env bash
# Install AI Skill Toolkit into a target project (macOS / Linux).
#
# POSIX equivalent of install-to-project.ps1. Uses symlinks instead of NTFS
# directory junctions for .claude/skills and .codex/skills.
#
# Usage:
#   ./scripts/install-to-project.sh --project /path/to/project
#   ./scripts/install-to-project.sh --project /path/to/project --dry-run
#   ./scripts/install-to-project.sh --project /path/to/project --force-links
#   ./scripts/install-to-project.sh --project /path/to/project --force-links --no-backup --yes
#
# Flags:
#   --project PATH    Required. Target project root.
#   --force-policy    Overwrite existing AGENTS.md / CLAUDE.md / .agents/AGENTS.md.
#   --force-links     Replace a non-empty .claude/skills or .codex/skills with a symlink.
#                     Existing content is backed up unless --no-backup is also set.
#   --dry-run         Print every action without making changes.
#   --no-backup       Suppress automatic backup of overwritten directories.
#                     Combined with --force-links this is destructive; requires --yes.
#   --yes             Skip interactive confirmation prompts (for CI).
#   -h, --help        Show this help.

set -euo pipefail

# --------------------------------------------------------------------
# Argument parsing
# --------------------------------------------------------------------
PROJECT_PATH=""
FORCE_POLICY=0
FORCE_LINKS=0
DRY_RUN=0
NO_BACKUP=0
ASSUME_YES=0

usage() {
  sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)       PROJECT_PATH="$2"; shift 2 ;;
    --project=*)     PROJECT_PATH="${1#*=}"; shift ;;
    --force-policy)  FORCE_POLICY=1; shift ;;
    --force-links)   FORCE_LINKS=1; shift ;;
    --dry-run)       DRY_RUN=1; shift ;;
    --no-backup)     NO_BACKUP=1; shift ;;
    --yes|-y)        ASSUME_YES=1; shift ;;
    -h|--help)       usage 0 ;;
    *) echo "Unknown argument: $1" >&2; usage 2 ;;
  esac
done

if [[ -z "$PROJECT_PATH" ]]; then
  echo "ERROR: --project is required." >&2
  usage 2
fi

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo "ERROR: ProjectPath does not exist: $PROJECT_PATH" >&2
  exit 2
fi

# Resolve absolute paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_PROJECT="$(cd "$PROJECT_PATH" && pwd)"

CURATED_SKILL_PATH="$SKILL_ROOT/skills"
MANIFEST_PATH="$CURATED_SKILL_PATH/manifest.json"
AGENTS_SOURCE_PATH="$SKILL_ROOT/.agents"

[[ -d "$CURATED_SKILL_PATH" ]] || { echo "ERROR: Curated skills folder not found: $CURATED_SKILL_PATH" >&2; exit 2; }
[[ -f "$MANIFEST_PATH"      ]] || { echo "ERROR: Skill manifest not found: $MANIFEST_PATH" >&2; exit 2; }
[[ -d "$AGENTS_SOURCE_PATH" ]] || { echo "ERROR: Toolkit .agents folder not found: $AGENTS_SOURCE_PATH" >&2; exit 2; }

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_ROOT="$TARGET_PROJECT/.agents/.backups/$TIMESTAMP"

PRIMARY_SKILL_DEST="$TARGET_PROJECT/.agents/skills"
JUNCTION_TARGETS=(
  "$TARGET_PROJECT/.claude/skills"
  "$TARGET_PROJECT/.codex/skills"
)

# --------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------
prefix() { if [[ $DRY_RUN -eq 1 ]]; then echo "[DRY-RUN]"; else echo "[      ]"; fi; }
action() { echo "$(prefix) $1: $2"; }

confirm() {
  local q="$1"
  if [[ $ASSUME_YES -eq 1 ]]; then return 0; fi
  read -r -p "$q [y/N] " resp || true
  [[ "$resp" =~ ^[yY]([eE][sS])?$ ]]
}

backup_path() {
  local src="$1"
  [[ -e "$src" ]] || return 0
  local rel="${src#"$TARGET_PROJECT"/}"
  local dest="$BACKUP_ROOT/$rel"
  local destParent
  destParent="$(dirname "$dest")"
  action "BACKUP" "$src -> $dest"
  if [[ $DRY_RUN -eq 0 ]]; then
    mkdir -p "$destParent"
    cp -R "$src" "$dest"
  fi
}

# Read manifest skill IDs (no jq dependency: minimal grep/sed parse)
mapfile -t EXPECTED_SKILLS < <(
  grep -o '"id"[[:space:]]*:[[:space:]]*"[^"]*"' "$MANIFEST_PATH" | sed -E 's/.*"id"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/'
)

if [[ ${#EXPECTED_SKILLS[@]} -eq 0 ]]; then
  echo "ERROR: Could not parse any skill IDs from $MANIFEST_PATH" >&2
  exit 2
fi

# --------------------------------------------------------------------
# Pre-flight: validate skills + plan symlink overwrites
# --------------------------------------------------------------------
declare -A REQUIRED_ASSETS
REQUIRED_ASSETS["ui-ux-pro-max"]="data scripts templates"

SKILL_DIRS=()
for SKILL_ID in "${EXPECTED_SKILLS[@]}"; do
  SKILL_PATH="$CURATED_SKILL_PATH/$SKILL_ID"
  SKILL_FILE="$SKILL_PATH/SKILL.md"
  if [[ ! -f "$SKILL_FILE" ]]; then
    echo "ERROR: Expected curated skill is missing SKILL.md: $SKILL_ID" >&2
    exit 2
  fi
  if [[ -n "${REQUIRED_ASSETS[$SKILL_ID]:-}" ]]; then
    for ASSET in ${REQUIRED_ASSETS[$SKILL_ID]}; do
      ASSET_PATH="$SKILL_PATH/$ASSET"
      if [[ ! -e "$ASSET_PATH" ]]; then
        echo "ERROR: Required asset missing for $SKILL_ID: '$ASSET' (expected directory at $ASSET_PATH)" >&2
        exit 2
      fi
      if [[ ! -d "$ASSET_PATH" ]]; then
        echo "ERROR: Required asset for $SKILL_ID is not a directory: $ASSET_PATH" >&2
        exit 2
      fi
      if [[ -z "$(find "$ASSET_PATH" -mindepth 1 -type f -print -quit)" ]]; then
        echo "ERROR: Required asset directory for $SKILL_ID is empty: $ASSET_PATH" >&2
        exit 2
      fi
    done
  fi
  SKILL_DIRS+=("$SKILL_PATH")
done

# Detect non-symlink directories at junction paths
JUNCTION_CONFLICTS=()
for J in "${JUNCTION_TARGETS[@]}"; do
  if [[ -e "$J" || -L "$J" ]]; then
    if [[ -L "$J" ]]; then
      :  # symlink: safe to replace
    elif [[ -d "$J" ]]; then
      if [[ -n "$(find "$J" -mindepth 1 -print -quit 2>/dev/null)" ]]; then
        JUNCTION_CONFLICTS+=("$J")
      fi
    fi
  fi
done

if [[ ${#JUNCTION_CONFLICTS[@]} -gt 0 ]]; then
  echo
  echo "WARNING: The following real directories contain content and will be replaced by a symlink:"
  for p in "${JUNCTION_CONFLICTS[@]}"; do echo "  - $p"; done

  if [[ $FORCE_LINKS -eq 0 ]]; then
    echo "Refusing to overwrite. Pass --force-links to proceed (content backed up to $BACKUP_ROOT unless --no-backup)." >&2
    exit 1
  fi

  if [[ $NO_BACKUP -eq 1 ]]; then
    echo "  --no-backup is set: existing content will be PERMANENTLY DELETED."
    if [[ $DRY_RUN -eq 0 ]] && ! confirm "Proceed with destructive overwrite?"; then
      echo "Aborted by user."
      exit 2
    fi
  else
    echo "  Existing content will be backed up to: $BACKUP_ROOT"
  fi
fi

echo
echo "Skill root:      $SKILL_ROOT"
echo "Target project:  $TARGET_PROJECT"
echo "Curated skills:  ${#SKILL_DIRS[@]}"
echo "Backup root:     $([[ $NO_BACKUP -eq 1 ]] && echo '(disabled)' || echo "$BACKUP_ROOT")"
echo "Mode:            $([[ $DRY_RUN -eq 1 ]] && echo 'DRY RUN (no changes)' || echo 'APPLY')"
echo

# --------------------------------------------------------------------
# Apply: copy skills (single source of truth)
# --------------------------------------------------------------------
copy_tree() {
  local src="$1" dest="$2"
  if [[ -e "$dest" ]]; then
    action "REMOVE" "$dest"
    [[ $DRY_RUN -eq 0 ]] && rm -rf "$dest"
  fi
  action "MKDIR" "$dest"
  if [[ $DRY_RUN -eq 0 ]]; then
    mkdir -p "$dest"
    # Exclude caches and OS junk
    rsync -a \
      --exclude='__pycache__' --exclude='.pytest_cache' --exclude='.mypy_cache' --exclude='.ruff_cache' \
      --exclude='node_modules' --exclude='.DS_Store' --exclude='Thumbs.db' \
      --exclude='*.pyc' --exclude='*.pyo' \
      "$src/" "$dest/"
  else
    action "COPY-TREE" "$src -> $dest (skipped in dry-run)"
  fi
}

# Backup primary skills directory if it exists with content
if [[ -d "$PRIMARY_SKILL_DEST" ]] && [[ $NO_BACKUP -eq 0 ]] && [[ $DRY_RUN -eq 0 ]]; then
  if [[ -n "$(find "$PRIMARY_SKILL_DEST" -mindepth 1 -print -quit 2>/dev/null)" ]]; then
    backup_path "$PRIMARY_SKILL_DEST"
  fi
fi

action "MKDIR" "$PRIMARY_SKILL_DEST"
[[ $DRY_RUN -eq 0 ]] && mkdir -p "$PRIMARY_SKILL_DEST"

for SKILL_PATH in "${SKILL_DIRS[@]}"; do
  copy_tree "$SKILL_PATH" "$PRIMARY_SKILL_DEST/$(basename "$SKILL_PATH")"
done

action "COPY" "$MANIFEST_PATH -> $PRIMARY_SKILL_DEST/"
[[ $DRY_RUN -eq 0 ]] && cp "$MANIFEST_PATH" "$PRIMARY_SKILL_DEST/"

# --------------------------------------------------------------------
# Apply: symlinks for .claude/skills and .codex/skills
# --------------------------------------------------------------------
for J in "${JUNCTION_TARGETS[@]}"; do
  parent="$(dirname "$J")"
  [[ $DRY_RUN -eq 0 ]] && mkdir -p "$parent"

  if [[ -L "$J" ]]; then
    action "UNLINK" "$J (existing symlink)"
    [[ $DRY_RUN -eq 0 ]] && rm "$J"
  elif [[ -e "$J" ]]; then
    if [[ $NO_BACKUP -eq 0 ]]; then
      backup_path "$J"
    fi
    action "REMOVE" "$J (real directory replaced)"
    [[ $DRY_RUN -eq 0 ]] && rm -rf "$J"
  fi

  action "SYMLINK" "$J -> $PRIMARY_SKILL_DEST"
  [[ $DRY_RUN -eq 0 ]] && ln -s "$PRIMARY_SKILL_DEST" "$J"
done

# --------------------------------------------------------------------
# Apply: .agents/{rules,roles,commands,plugins} and plugins/
# --------------------------------------------------------------------
install_subtree() {
  local src="$1" target="$2" label="$3"
  if [[ ! -d "$src" ]]; then
    echo "Skipped missing source: $src"
    return
  fi
  action "INSTALL-$label" "$src -> $target"
  if [[ $DRY_RUN -eq 0 ]]; then
    mkdir -p "$target"
    # Copy contents (not the directory itself) into target
    (cd "$src" && find . -mindepth 1 -maxdepth 1 -exec cp -R {} "$target"/ \;)
  fi
}

for t in \
  "$TARGET_PROJECT/.agents/rules" \
  "$TARGET_PROJECT/.agents/roles" \
  "$TARGET_PROJECT/.agents/commands" \
  "$TARGET_PROJECT/.agents/plugins"
do
  action "MKDIR" "$t"
  [[ $DRY_RUN -eq 0 ]] && mkdir -p "$t"
done

install_subtree "$AGENTS_SOURCE_PATH/rules"    "$TARGET_PROJECT/.agents/rules"    "RULES"
install_subtree "$AGENTS_SOURCE_PATH/roles"    "$TARGET_PROJECT/.agents/roles"    "ROLES"
install_subtree "$AGENTS_SOURCE_PATH/commands" "$TARGET_PROJECT/.agents/commands" "COMMANDS"
install_subtree "$AGENTS_SOURCE_PATH/plugins"  "$TARGET_PROJECT/.agents/plugins"  "PLUGINS-MARKETPLACE"

PLUGINS_SOURCE="$SKILL_ROOT/plugins"
PLUGINS_TARGET="$TARGET_PROJECT/plugins"
if [[ -d "$PLUGINS_SOURCE" ]]; then
  action "MKDIR" "$PLUGINS_TARGET"
  [[ $DRY_RUN -eq 0 ]] && mkdir -p "$PLUGINS_TARGET"
  for entry in "$PLUGINS_SOURCE"/*; do
    [[ -e "$entry" ]] || continue
    base="$(basename "$entry")"
    if [[ -d "$entry" ]]; then
      copy_tree "$entry" "$PLUGINS_TARGET/$base"
    else
      action "COPY" "$entry -> $PLUGINS_TARGET/"
      [[ $DRY_RUN -eq 0 ]] && cp "$entry" "$PLUGINS_TARGET/"
    fi
  done
else
  echo "Skipped missing source: $PLUGINS_SOURCE"
fi

# --------------------------------------------------------------------
# Apply: policy files (with backup-on-overwrite)
# --------------------------------------------------------------------
declare -a POLICY_PAIRS=(
  "$SKILL_ROOT/AGENTS.md|$TARGET_PROJECT/AGENTS.md"
  "$SKILL_ROOT/CLAUDE.md|$TARGET_PROJECT/CLAUDE.md"
  "$AGENTS_SOURCE_PATH/AGENTS.md|$TARGET_PROJECT/.agents/AGENTS.md"
)

for pair in "${POLICY_PAIRS[@]}"; do
  src="${pair%%|*}"
  tgt="${pair##*|}"
  if [[ ! -f "$src" ]]; then
    echo "Skipped missing source: $src"
    continue
  fi
  if [[ -e "$tgt" ]] && [[ $FORCE_POLICY -eq 0 ]]; then
    echo "Skipped existing policy: $tgt (pass --force-policy to overwrite)"
    continue
  fi
  if [[ -e "$tgt" ]] && [[ $FORCE_POLICY -eq 1 ]] && [[ $NO_BACKUP -eq 0 ]] && [[ $DRY_RUN -eq 0 ]]; then
    rel="${tgt#"$TARGET_PROJECT"/}"
    bk="$BACKUP_ROOT/$rel"
    bkParent="$(dirname "$bk")"
    action "BACKUP" "$tgt -> $bk"
    mkdir -p "$bkParent"
    cp "$tgt" "$bk"
  fi
  action "WRITE-POLICY" "$tgt"
  if [[ $DRY_RUN -eq 0 ]]; then
    mkdir -p "$(dirname "$tgt")"
    cp "$src" "$tgt"
  fi
done

echo
if [[ $DRY_RUN -eq 1 ]]; then
  echo "Dry run complete. No changes were made."
else
  echo "Done. Curated skills and multi-role system installed."
  if [[ $NO_BACKUP -eq 0 ]] && [[ -d "$BACKUP_ROOT" ]]; then
    echo "Backups (if any) saved under: $BACKUP_ROOT"
  fi
fi
