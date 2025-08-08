FROM milysun/ldaca-app:latest

USER root

# Install Jupyter and BinderHub requirements
RUN apt-get update && apt-get install -y \
    python3-pip \
    curl \
    supervisor \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Jupyter and BinderHub requirements with compatible versions
RUN pip3 install --no-cache-dir \
    jupyterlab==4.0.12 \
    jupyterhub==4.1.6 \
    jupyter-server-proxy==4.1.2 \
    jupyter-server==2.12.1 \
    notebook==7.0.8 \
    requests \
    && jupyter lab --generate-config

# Create jovyan user for BinderHub compatibility
RUN useradd -m -s /bin/bash jovyan && \
    usermod -aG sudo jovyan && \
    echo "jovyan ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    # Ensure jovyan can access supervisor and required directories \
    mkdir -p /var/log/supervisor && \
    chown -R jovyan:jovyan /var/log/supervisor

# Create a simple background service launcher script
RUN printf '#!/bin/bash\nset -e\n\necho "🚀 LDaCA Background Service Launcher"\n\n# Wait for Jupyter to be fully ready\nsleep 15\n\n# Check if supervisor config exists and start services\nif [ -f /etc/supervisor/conf.d/supervisord.conf ]; then\n    echo "🔄 Starting LDaCA services..." > /tmp/ldaca-startup.log 2>&1\n    sudo /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf >> /tmp/ldaca-startup.log 2>&1 || true\n    echo "✅ LDaCA services startup complete" >> /tmp/ldaca-startup.log 2>&1\nelse\n    echo "⚠️ Supervisor config not found" > /tmp/ldaca-startup.log 2>&1\nfi\n' > /usr/local/bin/start-ldaca-services.sh && chmod +x /usr/local/bin/start-ldaca-services.sh

# Create Jupyter config for BinderHub with server proxy
RUN mkdir -p /home/jovyan/.jupyter && printf 'import os\nc = get_config()\n\n# Server configuration for BinderHub\nc.ServerApp.ip = "0.0.0.0"\nc.ServerApp.port = 8888\nc.ServerApp.open_browser = False\nc.ServerApp.token = ""\nc.ServerApp.password = ""\nc.ServerApp.allow_origin = "*"\nc.ServerApp.disable_check_xsrf = True\nc.ServerApp.allow_remote_access = True\nc.ServerApp.base_url = os.environ.get("JUPYTERHUB_SERVICE_PREFIX", "/")\n\n# Enable jupyter-server-proxy\nc.ServerApp.jpserver_extensions = {"jupyter_server_proxy": True}\n\n# Configure server proxy for LDaCA services\nc.ServerProxy.servers = {\n    "ldaca": {\n        "command": ["echo", "LDaCA Web App"],\n        "port": 443,\n        "timeout": 30,\n        "absolute_url": False,\n        "launcher_entry": {\n            "title": "LDaCA Web App",\n            "icon_path": "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTEyIDJMMTMuMDkgOC4yNkwyMCA5TDEzLjA5IDE1Ljc0TDEyIDIyTDEwLjkxIDE1Ljc0TDQgOUwxMC45MSA4LjI2TDEyIDJaIiBmaWxsPSIjRkY2QzM3Ii8+Cjwvc3ZnPgo="\n        }\n    },\n    "ldaca-api": {\n        "command": ["echo", "LDaCA API"],\n        "port": 8001,\n        "timeout": 30,\n        "absolute_url": False,\n        "launcher_entry": {\n            "title": "LDaCA API",\n            "icon_path": "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTEyIDJMMTMuMDkgOC4yNkwyMCA5TDEzLjA5IDE1Ljc0TDEyIDIyTDEwLjkxIDE1Ljc0TDQgOUwxMC45MSA4LjI2TDEyIDJaIiBmaWxsPSIjMzc5OUZGIi8+Cjwvc3ZnPgo="\n        }\n    }\n}\n' > /home/jovyan/.jupyter/jupyter_lab_config.py

# Create work directory and files
RUN mkdir -p /home/jovyan/work && printf '# LDaCA Web Application\n\nThis BinderHub instance provides access to the **Language Data Commons of Australia (LDaCA)** web application.\n\n**Open Welcome_to_LDaCA.ipynb to get started!**\n\n## Quick Access Links\n- [🌐 LDaCA Web App](../proxy/443/) - Main application interface\n- [📚 API Documentation](../proxy/8001/api/docs) - Backend API documentation\n- [🔍 API Health Check](../proxy/8001/api/health) - Check API status\n\n## Architecture\n- **Frontend**: React app served by Nginx on port 443\n- **Backend**: FastAPI on port 8001\n- **Database**: SQLite with initialization scripts\n- **Jupyter**: This environment on port 8888\n\nThe application uses supervisor to manage multiple services (nginx, fastapi, db-init).\n' > /home/jovyan/work/README.md

# Copy the comprehensive Welcome notebook
COPY .binder/Welcome_to_LDaCA.ipynb /home/jovyan/Welcome_to_LDaCA.ipynb

# Set ownership
RUN chown -R jovyan:jovyan /home/jovyan

USER jovyan
WORKDIR /home/jovyan

# Let BinderHub handle the entrypoint - we'll use postBuild for service startup
