# Github Action Built Image
FROM milysun/ldaca-app:7980190025cb

# Copy notebooks into the image so they appear in Binder
USER root
COPY LDaCa_Analysis.ipynb /home/jovyan/LDaCa_Analysis.ipynb
RUN chown 1000:1000 /home/jovyan/LDaCa_Analysis.ipynb /home/jovyan/start_services.ipynb || true
USER jovyan