FROM r-base:3.6.0

WORKDIR /helmet-data-preprocessing

# Use .dockerignore to define copied files more accurately.
COPY . ./

# Install Python & our dependencies
RUN apt-get update && apt-get install -y python2.7 python-pip
RUN pip install pipenv
RUN pipenv install

# Install R and our dependencies
RUN apt-get update && apt-get install -y libgdal-dev gdal-bin libproj-dev proj-data proj-bin libgeos-dev apt-utils libgit2-dev libssl-dev libssh2-1-dev
RUN Rscript ./install-dependencies.R

CMD ["/bin/bash"]
