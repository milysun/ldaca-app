#!/bin/bash
set -euo pipefail

echo "🚀 Starting LDaCA Web Application for BinderHub..."

# Always start our LDaCA application directly
# This bypasses Jupyter and serves the web frontend on port 8080
exec /usr/local/bin/start-ldaca.sh
