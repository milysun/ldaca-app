#!/bin/bash
set -euo pipefail

echo "🚀 Starting LDaCA with BinderHub/JupyterHub compatibility..."

# Install jupyter and proxy packages first
echo "📦 Installing Jupyter and proxy..."
pip install --no-cache-dir jupyter jupyterlab notebook jupyter-server-proxy

# Start LDaCA in background
/usr/local/bin/start-ldaca.sh &

# Give LDaCA more time to start
sleep 15

# Create Jupyter config directory
mkdir -p /home/jovyan/.jupyter

# Create Jupyter config to proxy our application
cat > /home/jovyan/.jupyter/jupyter_lab_config.py << 'EOF'
c = get_config()

# Basic configuration for JupyterLab
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.token = ''
c.ServerApp.password = ''
c.ServerApp.allow_root = True
c.ServerApp.allow_origin = '*'
c.ServerApp.disable_check_xsrf = True
c.ServerApp.root_dir = '/home/jovyan/work'

# BinderHub specific configurations
# The base_url will be set by BinderHub environment variables
import os
c.ServerApp.base_url = os.environ.get('JUPYTERHUB_SERVICE_PREFIX', '/')
c.ServerApp.allow_remote_access = True

# Enable jupyter-server-proxy
c.ServerApp.jpserver_extensions = {
    'jupyter_server_proxy': True
}

# Handle BinderHub's URL structure - don't set default_url, let it use the natural flow
# c.ServerApp.default_url = '/lab'

# Don't redirect to LDaCA by default - let users navigate there
# c.ServerApp.default_url = '/proxy/8080/'
EOF

# Install jupyter-server-proxy for proxying
pip install --no-cache-dir jupyter-server-proxy

# Create a simple landing page
mkdir -p /home/jovyan/work
cat > /home/jovyan/work/README.md << 'EOF'
# LDaCA Web Application

This BinderHub instance is running the LDaCA Web Application.

**To access the LDaCA application, click here: [Open LDaCA](../proxy/8080/)**

Or manually navigate to: `/proxy/8080/` in your browser.

## About LDaCA

The Language Data Commons of Australia (LDaCA) Web Application provides tools for working with Australian language data and corpora.

## Quick Access

- [LDaCA Web App](../proxy/8080/) - Main application interface  
- [API Documentation](../proxy/8080/api/docs) - Backend API docs
EOF

# Copy the welcome notebook to the work directory
cp /usr/local/bin/LDaCA_Access.ipynb /home/jovyan/work/ 2>/dev/null || true

echo "🌐 Starting Jupyter Lab with LDaCA proxy..."

# Wait a bit more for LDaCA to be fully ready
sleep 5

# Debug: Check if we can reach localhost:8080
echo "🔍 Checking LDaCA status..."
if curl -s --max-time 5 http://localhost:8080/api/health > /dev/null 2>&1; then
    echo "✅ LDaCA is responding on port 8080"
else
    echo "⚠️ LDaCA not yet responding on port 8080 (this is normal during startup)"
fi

# Start Jupyter Lab with proper syntax
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
    --ServerApp.root_dir='/home/jovyan/work'
