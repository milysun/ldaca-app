FROM milysun/ldaca-app:latest

USER root

# Install Jupyter and BinderHub requirements
RUN apt-get update && apt-get install -y \
    python3-pip \
    curl \
    supervisor \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Jupyter Lab and server proxy
RUN pip3 install \
    jupyterlab \
    jupyter-server-proxy \
    requests \
    && jupyter lab --generate-config

# Create jovyan user for BinderHub compatibility
RUN useradd -m -s /bin/bash jovyan && \
    usermod -aG sudo jovyan && \
    echo "jovyan ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create BinderHub startup script
RUN printf '#!/bin/bash\nset -euo pipefail\necho "🚀 Starting LDaCA services..."\n\n# Start LDaCA application as root (supervisor needs root privileges)\necho "📦 Starting LDaCA backend and frontend..."\nsudo /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf &\n\n# Wait for services to start\nsleep 20\n\n# Check LDaCA status (it runs on port 443 in your setup)\necho "🔍 Checking LDaCA status..."\nif curl -s --max-time 10 http://localhost:443/health > /dev/null 2>&1; then\n    echo "✅ LDaCA frontend is running on port 443"\nelse\n    echo "⚠️ LDaCA frontend startup in progress..."\nfi\n\n# Check backend API\nif curl -s --max-time 10 http://localhost:8001/api/health > /dev/null 2>&1; then\n    echo "✅ LDaCA backend API is running on port 8001"\nelse\n    echo "⚠️ LDaCA backend API startup in progress..."\nfi\n\necho "🌐 Starting Jupyter Lab..."\n# Start Jupyter Lab for BinderHub\nexec jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --ServerApp.token="" --ServerApp.password="" --ServerApp.allow_origin="*" --ServerApp.disable_check_xsrf=True --ServerApp.allow_remote_access=True --ServerApp.root_dir="/home/jovyan/work" --ServerApp.base_url="${JUPYTERHUB_SERVICE_PREFIX:-/}"\n' > /usr/local/bin/binder-start.sh && chmod +x /usr/local/bin/binder-start.sh

# Create Jupyter config for BinderHub with server proxy
RUN mkdir -p /home/jovyan/.jupyter && printf 'import os\nc = get_config()\nc.ServerApp.ip = "0.0.0.0"\nc.ServerApp.port = 8888\nc.ServerApp.open_browser = False\nc.ServerApp.token = ""\nc.ServerApp.password = ""\nc.ServerApp.allow_root = True\nc.ServerApp.allow_origin = "*"\nc.ServerApp.disable_check_xsrf = True\nc.ServerApp.root_dir = "/home/jovyan/work"\nc.ServerApp.base_url = os.environ.get("JUPYTERHUB_SERVICE_PREFIX", "/")\nc.ServerApp.allow_remote_access = True\nc.ServerApp.jpserver_extensions = {"jupyter_server_proxy": True}\n\n# Configure jupyter-server-proxy for LDaCA\nc.ServerProxy.servers = {\n    "ldaca": {\n        "command": ["echo", "LDaCA already running"],\n        "port": 443,\n        "timeout": 30,\n        "absolute_url": False,\n        "launcher_entry": {\n            "title": "LDaCA Web App",\n            "icon_path": "/home/jovyan/work/ldaca-icon.svg"\n        }\n    },\n    "ldaca-api": {\n        "command": ["echo", "LDaCA API already running"],\n        "port": 8001,\n        "timeout": 30,\n        "absolute_url": False,\n        "launcher_entry": {\n            "title": "LDaCA API",\n            "icon_path": "/home/jovyan/work/api-icon.svg"\n        }\n    }\n}\n' > /home/jovyan/.jupyter/jupyter_lab_config.py

# Create work directory and files
RUN mkdir -p /home/jovyan/work && printf '# LDaCA Web Application\n\nThis BinderHub instance provides access to the **Language Data Commons of Australia (LDaCA)** web application.\n\n**Open Welcome_to_LDaCA.ipynb to get started!**\n\n## Quick Access Links\n- [🌐 LDaCA Web App](../proxy/443/) - Main application interface\n- [📚 API Documentation](../proxy/8001/api/docs) - Backend API documentation\n- [🔍 API Health Check](../proxy/8001/api/health) - Check API status\n\n## Architecture\n- **Frontend**: React app served by Nginx on port 443\n- **Backend**: FastAPI on port 8001\n- **Database**: SQLite with initialization scripts\n- **Jupyter**: This environment on port 8888\n\nThe application uses supervisor to manage multiple services (nginx, fastapi, db-init).\n' > /home/jovyan/work/README.md

# Create Welcome notebook with correct port references
RUN printf '{\n "cells": [\n  {\n   "cell_type": "markdown",\n   "metadata": {},\n   "source": [\n    "# 🚀 Welcome to LDaCA Web Application\\n",\n    "\\n",\n    "This BinderHub instance provides access to the **Language Data Commons of Australia (LDaCA)**.\\n",\n    "\\n",\n    "## 🌐 Quick Start\\n",\n    "\\n",\n    "### [Launch LDaCA Web App](/proxy/443/)\\n",\n    "\\n",\n    "### 📚 Additional Resources:\\n",\n    "- [API Documentation](/proxy/8001/api/docs)\\n",\n    "- [API Health Check](/proxy/8001/api/health)\\n",\n    "- [File Browser](/tree)\\n",\n    "\\n",\n    "## ℹ️ Architecture\\n",\n    "- **Frontend**: React served by Nginx (port 443)\\n",\n    "- **Backend**: FastAPI (port 8001)\\n",\n    "- **Jupyter**: This environment (port 8888)"\n   ]\n  },\n  {\n   "cell_type": "code",\n   "execution_count": null,\n   "metadata": {},\n   "outputs": [],\n   "source": [\n    "# Check LDaCA services status\\n",\n    "import requests\\n",\n    "import time\\n",\n    "\\n",\n    "def check_service(url, name):\\n",\n    "    try:\\n",\n    "        response = requests.get(url, timeout=5)\\n",\n    "        if response.status_code == 200:\\n",\n    "            print(f\\"✅ {name}: Running\\")\\n",\n    "        else:\\n",\n    "            print(f\\"⚠️  {name}: HTTP {response.status_code}\\")\\n",\n    "    except Exception as e:\\n",\n    "        print(f\\"❌ {name}: {str(e)}\\")\\n",\n    "\\n",\n    "print(\\"🔍 Checking LDaCA services...\\")\\n",\n    "check_service(\\"http://localhost:443/health\\", \\"Frontend (Nginx)\\")\\n",\n    "check_service(\\"http://localhost:8001/api/health\\", \\"Backend API\\")\\n",\n    "\\n",\n    "print(\\"\\\\n🌐 Access LDaCA at: /proxy/443/\\")\\n",\n    "print(\\"📚 API docs at: /proxy/8001/api/docs\\")"   ]\n  }\n ],\n "metadata": {\n  "kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"},\n  "language_info": {"name": "python", "version": "3.10.0"}\n },\n "nbformat": 4,\n "nbformat_minor": 4\n}\n' > /home/jovyan/work/Welcome_to_LDaCA.ipynb

# Set ownership
RUN chown -R jovyan:jovyan /home/jovyan

USER jovyan
WORKDIR /home/jovyan

CMD ["/usr/local/bin/binder-start.sh"]
