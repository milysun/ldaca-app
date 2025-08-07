FROM milysun/ldaca-binder:latest

# Ensure the startup script is executable
USER root
RUN chmod +x /usr/local/bin/start-notebook.sh

# Switch back to jovyan user
USER jovyan

# Set the working directory
WORKDIR /home/jovyan

# Explicitly set the command that BinderHub should run
CMD ["/usr/local/bin/start-notebook.sh"]
