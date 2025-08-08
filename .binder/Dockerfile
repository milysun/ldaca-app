FROM milysun/ldaca-app:latest

USER root

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    curl \
    supervisor \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Jupyter components with specific versions for compatibility
RUN pip3 install --no-cache-dir \
    notebook==6.5.4 \
    jupyterhub==4.0.2 \
    jupyterlab==3.6.5 \
    jupyter-server-proxy==4.0.0 \
    requests \
    && jupyter lab --generate-config \
    && jupyter notebook --generate-config

# Create jovyan user for BinderHub compatibility
RUN useradd -m -s /bin/bash -u 1000 jovyan && \
    usermod -aG sudo jovyan && \
    echo "jovyan ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Fix permissions for jovyan
RUN mkdir -p /home/jovyan/.local /home/jovyan/.jupyter && \
    chown -R jovyan:jovyan /home/jovyan

# Create the startup script for LDaCA services
RUN printf '#!/bin/bash\nset -e\n\necho "🚀 LDaCA Background Service Launcher"\n\n# Wait for Jupyter to be fully ready\nsleep 15\n\n# Start services with proper permissions\nif [ -f /etc/supervisor/conf.d/supervisord.conf ]; then\n    echo "🔄 Starting LDaCA services..." > /tmp/ldaca-startup.log 2>&1\n    sudo /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf >> /tmp/ldaca-startup.log 2>&1 || true\n    echo "✅ LDaCA services startup complete" >> /tmp/ldaca-startup.log 2>&1\nelse\n    echo "⚠️ Supervisor config not found" > /tmp/ldaca-startup.log 2>&1\nfi\n' > /usr/local/bin/start-ldaca-services.sh && chmod +x /usr/local/bin/start-ldaca-services.sh

# Create Jupyter config that works with JupyterHub singleuser
RUN mkdir -p /etc/jupyter && \
    printf 'c = get_config()\n\n# JupyterHub singleuser compatibility\nc.NotebookApp.allow_origin = "*"\nc.NotebookApp.allow_root = False\nc.NotebookApp.trust_xheaders = True\n\n# ServerApp config for newer versions\nc.ServerApp.allow_origin = "*"\nc.ServerApp.allow_root = False\nc.ServerApp.trust_xheaders = True\nc.ServerApp.disable_check_xsrf = False\n\n# Enable extensions\nc.ServerApp.jpserver_extensions = {"jupyter_server_proxy": True}\n' > /etc/jupyter/jupyter_notebook_config.py

# Create user-specific Jupyter config
RUN mkdir -p /home/jovyan/.jupyter && \
    printf 'import os\nc = get_config()\n\n# Base URL from JupyterHub\nc.NotebookApp.base_url = os.environ.get("JUPYTERHUB_SERVICE_PREFIX", "/")\nc.ServerApp.base_url = os.environ.get("JUPYTERHUB_SERVICE_PREFIX", "/")\n\n# Server settings\nc.ServerApp.ip = "0.0.0.0"\nc.ServerApp.open_browser = False\n\n# Authentication handled by JupyterHub\nc.NotebookApp.token = ""\nc.ServerApp.token = ""\n\n# Enable server proxy\nc.ServerProxy.servers = {\n    "ldaca": {\n        "command": ["echo", "LDaCA already running"],\n        "port": 443,\n        "timeout": 30,\n        "absolute_url": False\n    },\n    "ldaca-api": {\n        "command": ["echo", "LDaCA API already running"],\n        "port": 8001,\n        "timeout": 30,\n        "absolute_url": False\n    }\n}\n' > /home/jovyan/.jupyter/jupyter_lab_config.py

# Create work directory and files
RUN mkdir -p /home/jovyan/work && \
    printf '# LDaCA Web Application\n\nOpen **Welcome_to_LDaCA.ipynb** to get started!\n\n## Quick Access\n- [🌐 LDaCA Web App](../proxy/443/)\n- [📚 API Documentation](../proxy/8001/api/docs)\n' > /home/jovyan/work/README.md

# Copy the Welcome notebook
COPY Welcome_to_LDaCA.ipynb /home/jovyan/work/Welcome_to_LDaCA.ipynb

# Create a startup script that works with jupyterhub-singleuser
RUN printf '#!/bin/bash\n# Start LDaCA services in background\n/usr/local/bin/start-ldaca-services.sh &\n\n# Start the notebook server using jupyterhub-singleuser if available\nif command -v jupyterhub-singleuser &> /dev/null; then\n    exec jupyterhub-singleuser "$@"\nelse\n    exec jupyter lab "$@"\nfi\n' > /usr/local/bin/start.sh && chmod +x /usr/local/bin/start.sh

# Fix all permissions
RUN chown -R jovyan:jovyan /home/jovyan && \
    chmod -R 755 /home/jovyan

# Switch to jovyan user
USER jovyan
WORKDIR /home/jovyan

# Set the default command to start.sh
CMD ["/usr/local/bin/start.sh"]