FROM r-base:3.6.0

WORKDIR /helmet-data-preprocessing

# Use .dockerignore to define copied files more accurately.
COPY . ./

RUN apt-get update && apt-get install -y libgdal-dev gdal-bin libproj-dev proj-data proj-bin libgeos-dev

RUN Rscript ./install-dependencies.R

CMD ["/bin/bash"]
