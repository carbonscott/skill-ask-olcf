#!/bin/bash
# setup.sh — One-time local setup for ask-olcf
#
# Usage:
#   ./setup.sh [DATA_DIR]
#
# Clones the OLCF user docs repo, builds the FTS5 search index, and
# generates env.local so the skill is ready to use.
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${1:-$HOME/.local/share/docs-skills/olcf-docs}"

if [[ -d "$DATA_DIR" ]]; then
    echo "Data directory already exists: $DATA_DIR"
    echo "To re-index, run: $SKILL_DIR/bin/docs-index index \"$DATA_DIR\" --incremental --ext rst"
    exit 0
fi

echo "Cloning olcf/olcf-user-docs → $DATA_DIR ..."
mkdir -p "$(dirname "$DATA_DIR")"
git clone https://github.com/olcf/olcf-user-docs.git "$DATA_DIR"

echo "Building search index..."
"$SKILL_DIR/bin/docs-index" index "$DATA_DIR" --incremental --ext rst

# Keep the facility's shared uv reachable. Written FIRST, so the skill's own
# bin line below still prepends last and bin/docs-index keeps the precedence
# it had before this block existed; the shared bin sits behind it, supplying uv.
: > "$SKILL_DIR/env.local"
if [ -d /sdf ]; then
    echo 'export PATH="/sdf/group/lcls/ds/dm/apps/dev/bin:$PATH"' >> "$SKILL_DIR/env.local"
elif [ -d /lustre/orion ]; then
    echo 'export PATH="/ccs/home/cwang31/.local/bin:$PATH"' >> "$SKILL_DIR/env.local"
fi

cat >> "$SKILL_DIR/env.local" <<EOF
export OLCF_DOCS_ROOT="$DATA_DIR"
export PATH="$SKILL_DIR/bin:\$PATH"
EOF

echo ""
echo "Done. Skill is ready to use."
echo "env.local created at: $SKILL_DIR/env.local"
