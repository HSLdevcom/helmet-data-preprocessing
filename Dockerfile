FROM r-base:3.6.0

WORKDIR /helmet-data-preprocessing

# Use .dockerignore to define copied files more accurately.
COPY . ./
RUN Rscript ./install-dependencies.R

CMD ["/bin/bash"]
