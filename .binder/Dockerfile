# BinderHub-compatible Dockerfile for LDaCA Project
FROM milysun/ldaca-app:latest

# BinderHub expects these specific configurations
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER=${NB_USER}
ENV NB_UID=${NB_UID}
ENV HOME=/home/${NB_USER}

# Switch to root to make system changes
USER root

# Install minimal BinderHub requirements
RUN apt-get update && apt-get install -y \
    tini \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Use the existing app user (UID 1000) and rename to jovyan for BinderHub compatibility
RUN usermod -l ${NB_USER} app && \
    usermod -d ${HOME} ${NB_USER} && \
    groupmod -n ${NB_USER} app && \
    mkdir -p ${HOME} && \
    chown -R ${NB_USER}:${NB_USER} ${HOME}

# Give jovyan user sudo access for BinderHub
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure nginx to listen on port 8080 for BinderHub
RUN sed -i 's/listen 443/listen 8080/g' /etc/nginx/sites-available/default && \
    sed -i 's/listen \[::\]:443/listen [::]:8080/g' /etc/nginx/sites-available/default

# Copy BinderHub configuration files
COPY .binder/supervisord-binder.conf /etc/supervisor/conf.d/supervisord.conf
COPY .binder/start /usr/local/bin/start-ldaca.sh
COPY .binder/start-notebook.sh /usr/local/bin/start-notebook.sh
COPY .binder/jupyterhub-singleuser /usr/local/bin/jupyterhub-singleuser
COPY .binder/postBuild /usr/local/bin/postBuild

# Make scripts executable
RUN chmod +x /usr/local/bin/start-ldaca.sh && \
    chmod +x /usr/local/bin/start-notebook.sh && \
    chmod +x /usr/local/bin/jupyterhub-singleuser && \
    chmod +x /usr/local/bin/postBuild

# Set up proper permissions and directories for BinderHub
RUN chown -R ${NB_USER}:${NB_USER} /app && \
    mkdir -p /tmp/supervisor && \
    chown -R ${NB_USER}:${NB_USER} /tmp/supervisor && \
    chmod -R 755 /app && \
    mkdir -p ${HOME}/.jupyter && \
    chown -R ${NB_USER}:${NB_USER} ${HOME}

# Run postBuild setup
RUN /usr/local/bin/postBuild

# Switch to the jovyan user
USER ${NB_USER}
WORKDIR ${HOME}

# Expose port 8080 for BinderHub proxy  
EXPOSE 8080

# Set the entrypoint that BinderHub expects
ENTRYPOINT ["tini", "-g", "--"]
CMD ["/usr/local/bin/start-notebook.sh"]
