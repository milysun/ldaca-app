FROM milysun/ldaca-app:latest

USER root

# Install Jupyter and BinderHub requirements
RUN apt-get update && apt-get install -y \
    python3-pip \
    curl \
    supervisor \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Jupyter and BinderHub requirements
RUN pip3 install \
    jupyterlab \
    jupyterhub \
    jupyter-server-proxy \
    requests \
    && jupyter lab --generate-config

# Create jovyan user for BinderHub compatibility
RUN useradd -m -s /bin/bash jovyan && \
    usermod -aG sudo jovyan && \
    echo "jovyan ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    # Ensure jovyan can access supervisor and required directories \
    mkdir -p /var/log/supervisor && \
    chown -R jovyan:jovyan /var/log/supervisor

# Create BinderHub startup script that starts LDaCA services
RUN printf '#!/bin/bash\nset -euo pipefail\n\necho "🚀 Starting LDaCA services in background..."\n\n# Function to start services safely in the background\nstart_ldaca_services() {\n    echo "📦 Preparing LDaCA services..."\n    \n    # Check if supervisor config exists\n    if [ -f /etc/supervisor/conf.d/supervisord.conf ]; then\n        # Start supervisor in background after a delay to avoid PostStartHook issues\n        (\n            sleep 10  # Wait for Jupyter to fully start\n            echo "🔄 Starting LDaCA backend and frontend..."\n            sudo /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf > /tmp/supervisor.log 2>&1\n            echo "✅ LDaCA services started - check /tmp/supervisor.log for details"\n        ) &\n        echo "⏳ LDaCA services will start in background after Jupyter is ready"\n    else\n        echo "⚠️ Supervisor config not found, LDaCA services not available"\n    fi\n}\n\n# Start services in background without blocking\nstart_ldaca_services\n\necho "🌐 Starting Jupyter environment..."\n\n# Execute whatever command was passed (BinderHub will pass jupyterhub-singleuser)\nexec "$@"\n' > /usr/local/bin/binder-start.sh && chmod +x /usr/local/bin/binder-start.sh

# Create Jupyter config for BinderHub with server proxy
RUN mkdir -p /home/jovyan/.jupyter && printf 'import os\nc = get_config()\nc.ServerApp.ip = "0.0.0.0"\nc.ServerApp.port = 8888\nc.ServerApp.open_browser = False\nc.ServerApp.token = ""\nc.ServerApp.password = ""\nc.ServerApp.allow_root = True\nc.ServerApp.allow_origin = "*"\nc.ServerApp.disable_check_xsrf = True\nc.ServerApp.root_dir = "/home/jovyan/work"\nc.ServerApp.base_url = os.environ.get("JUPYTERHUB_SERVICE_PREFIX", "/")\nc.ServerApp.allow_remote_access = True\nc.ServerApp.jpserver_extensions = {"jupyter_server_proxy": True}\n\n# Configure jupyter-server-proxy for LDaCA\nc.ServerProxy.servers = {\n    "ldaca": {\n        "command": ["echo", "LDaCA already running"],\n        "port": 443,\n        "timeout": 30,\n        "absolute_url": False,\n        "launcher_entry": {\n            "title": "LDaCA Web App",\n            "icon_path": "/home/jovyan/work/ldaca-icon.svg"\n        }\n    },\n    "ldaca-api": {\n        "command": ["echo", "LDaCA API already running"],\n        "port": 8001,\n        "timeout": 30,\n        "absolute_url": False,\n        "launcher_entry": {\n            "title": "LDaCA API",\n            "icon_path": "/home/jovyan/work/api-icon.svg"\n        }\n    }\n}\n' > /home/jovyan/.jupyter/jupyter_lab_config.py

# Create work directory and files
RUN mkdir -p /home/jovyan/work && printf '# LDaCA Web Application\n\nThis BinderHub instance provides access to the **Language Data Commons of Australia (LDaCA)** web application.\n\n**Open Welcome_to_LDaCA.ipynb to get started!**\n\n## Quick Access Links\n- [🌐 LDaCA Web App](../proxy/443/) - Main application interface\n- [📚 API Documentation](../proxy/8001/api/docs) - Backend API documentation\n- [🔍 API Health Check](../proxy/8001/api/health) - Check API status\n\n## Architecture\n- **Frontend**: React app served by Nginx on port 443\n- **Backend**: FastAPI on port 8001\n- **Database**: SQLite with initialization scripts\n- **Jupyter**: This environment on port 8888\n\nThe application uses supervisor to manage multiple services (nginx, fastapi, db-init).\n' > /home/jovyan/work/README.md

# Copy the comprehensive Welcome notebook
COPY .binder/Welcome_to_LDaCA.ipynb /home/jovyan/Welcome_to_LDaCA.ipynb

# Set ownership
RUN chown -R jovyan:jovyan /home/jovyan

USER jovyan
WORKDIR /home/jovyan

# Set our startup script as the entrypoint
ENTRYPOINT ["/usr/local/bin/binder-start.sh"]
CMD ["jupyterhub-singleuser"]
