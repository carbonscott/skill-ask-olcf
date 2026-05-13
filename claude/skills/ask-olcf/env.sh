#!/bin/bash
# Environment for ask-olcf skill.
# Site-specific config goes in env.local (not tracked in git).
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
if [[ -f "$SKILL_DIR/env.local" ]]; then
    source "$SKILL_DIR/env.local"
fi
export OLCF_DOCS_ROOT="${OLCF_DOCS_ROOT:-}"
