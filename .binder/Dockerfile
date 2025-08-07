FROM milysun/ldaca-binder:latest

# Switch to root to create BinderHub startup script
USER root

# Create a BinderHub-specific startup script
COPY binder-start.sh /usr/local/bin/binder-start.sh
RUN chmod +x /usr/local/bin/binder-start.sh

# Create Jupyter configuration for BinderHub
RUN mkdir -p /home/jovyan/.jupyter && \
    echo 'import os' > /home/jovyan/.jupyter/jupyter_lab_config.py && \
    echo 'c = get_config()' >> /home/jovyan/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.ip = '0.0.0.0'" >> /home/jovyan/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.port = 8888" >> /home/jovyan/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.open_browser = False" >> /home/jovyan/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.token = ''" >> /home/jovyan/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.password = ''" >> /home/jovyan/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_root = True" >> /home/jovyan/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_origin = '*'" >> /home/jovyan/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.disable_check_xsrf = True" >> /home/jovyan/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.root_dir = '/home/jovyan/work'" >> /home/jovyan/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.base_url = os.environ.get('JUPYTERHUB_SERVICE_PREFIX', '/')" >> /home/jovyan/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_remote_access = True" >> /home/jovyan/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.jpserver_extensions = {'jupyter_server_proxy': True}" >> /home/jovyan/.jupyter/jupyter_lab_config.py

# Create work directory with README and Welcome notebook
COPY Welcome_to_LDaCA.ipynb /home/jovyan/work/Welcome_to_LDaCA.ipynb
RUN mkdir -p /home/jovyan/work && \
    echo '# LDaCA Web Application' > /home/jovyan/work/README.md && \
    echo '' >> /home/jovyan/work/README.md && \
    echo 'This BinderHub instance is running the LDaCA Web Application.' >> /home/jovyan/work/README.md && \
    echo '' >> /home/jovyan/work/README.md && \
    echo '**To get started, open the Welcome_to_LDaCA.ipynb notebook!**' >> /home/jovyan/work/README.md && \
    echo '' >> /home/jovyan/work/README.md && \
    echo '## Quick Access' >> /home/jovyan/work/README.md && \
    echo '' >> /home/jovyan/work/README.md && \
    echo '- [LDaCA Web App](../proxy/8080/) - Main application interface' >> /home/jovyan/work/README.md && \
    echo '- [API Documentation](../proxy/8080/api/docs) - Backend API docs' >> /home/jovyan/work/README.md

# Ensure proper ownership
RUN chown -R jovyan:jovyan /home/jovyan/.jupyter /home/jovyan/work

# Switch to jovyan user
USER jovyan
WORKDIR /home/jovyan

# Use our BinderHub startup script
CMD ["/usr/local/bin/binder-start.sh"]
