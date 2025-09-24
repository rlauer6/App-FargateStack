#!/bin/sh
# Exit immediately if a command exits with a non-zero status.
set -e

# --- Your Startup Logic ---
echo "Updating application repository..."
cd /root/git/App-FargateStack
git fetch
git pull
echo "Update complete."

exec "$@"
