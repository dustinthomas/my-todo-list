#!/usr/bin/env bash
# Docker entrypoint that syncs Julia packages when Manifest.toml changes
# This solves the "package not installed" issue when switching machines

set -e

MANIFEST_CHECKSUM_FILE="/root/.julia/.manifest_checksum"
MANIFEST_FILE="/app/Manifest.toml"

sync_packages() {
    echo "Syncing Julia packages..."
    julia --project=/app -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'
    echo "Package sync complete."
}

# Check if Manifest.toml exists
if [ -f "$MANIFEST_FILE" ]; then
    CURRENT_CHECKSUM=$(md5sum "$MANIFEST_FILE" | cut -d' ' -f1)

    # Check if we have a previous checksum
    if [ -f "$MANIFEST_CHECKSUM_FILE" ]; then
        PREVIOUS_CHECKSUM=$(cat "$MANIFEST_CHECKSUM_FILE")

        if [ "$CURRENT_CHECKSUM" != "$PREVIOUS_CHECKSUM" ]; then
            echo "Manifest.toml changed, syncing packages..."
            sync_packages
            echo "$CURRENT_CHECKSUM" > "$MANIFEST_CHECKSUM_FILE"
        fi
    else
        # First run or depot was cleaned - sync packages
        echo "First run detected, syncing packages..."
        sync_packages
        # Ensure directory exists
        mkdir -p "$(dirname "$MANIFEST_CHECKSUM_FILE")"
        echo "$CURRENT_CHECKSUM" > "$MANIFEST_CHECKSUM_FILE"
    fi
else
    echo "Warning: Manifest.toml not found at $MANIFEST_FILE"
fi

# Execute the original command
exec "$@"
