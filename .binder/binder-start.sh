#!/bin/bash
set -euo pipefail

echo "🚀 BinderHub: Starting LDaCA services..."

# Start LDaCA application in background
/usr/local/bin/start-ldaca.sh &

# Give LDaCA time to start
sleep 15

echo "🔍 Checking LDaCA status..."
if curl -s --max-time 5 http://localhost:8080/api/health > /dev/null 2>&1; then
    echo "✅ LDaCA is responding"
else
    echo "⚠️ LDaCA startup in progress..."
fi

echo "🌐 Starting Jupyter for BinderHub..."

# Start Jupyter Lab with BinderHub-compatible settings
exec jupyter lab \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root \
    --ServerApp.token='' \
    --ServerApp.password='' \
    --ServerApp.allow_origin='*' \
    --ServerApp.disable_check_xsrf=True \
    --ServerApp.allow_remote_access=True \
    --ServerApp.root_dir='/home/jovyan/work' \
    --ServerApp.base_url="${JUPYTERHUB_SERVICE_PREFIX:-/}"
