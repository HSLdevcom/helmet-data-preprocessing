FROM r-base:3.6.0

WORKDIR /helmet-data-preprocessing

# Use .dockerignore to define copied files more accurately.
COPY . ./

# Install Python & our dependencies
RUN apt-get update && apt-get install -y \
  python2.7 \
  python-pip
RUN pip install pipenv
RUN pipenv install --deploy --ignore-pipfile

# Install R and our dependencies
RUN apt-get update && apt-get install -y \
  apt-utils \
  gdal-bin \
  git \
  libgdal-dev \
  libgeos-dev \
  libgit2-dev \
  libproj-dev \
  libssh2-1-dev \
  libssl-dev \
  proj-bin \
  proj-data
RUN R --no-save --encoding=CP1252 -f install-dependencies.R

CMD ["/bin/bash"]
