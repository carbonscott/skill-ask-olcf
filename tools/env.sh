#!/bin/bash
# Environment configuration for olcf-docs sync.
# Sources env.local for deployment-specific overrides.

# Add shared uv to PATH (needed for docs-index)
export PATH="/sdf/group/lcls/ds/dm/apps/dev/bin:$PATH"

# Use shared Python installs (not per-user ~/.local/share/uv/python)
export UV_PYTHON_INSTALL_DIR="/sdf/group/lcls/ds/dm/apps/dev/python"

export OLCF_DOCS_APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export OLCF_DOCS_DATA_DIR="${OLCF_DOCS_DATA_DIR:-/sdf/group/lcls/ds/dm/apps/dev/data/olcf-docs}"
export UV_CACHE_DIR="${UV_CACHE_DIR:-/tmp/uv-cache-$USER}"

# Source env.local for deployment-specific overrides
if [[ -f "$OLCF_DOCS_APP_DIR/env.local" ]]; then
    source "$OLCF_DOCS_APP_DIR/env.local"
fi
