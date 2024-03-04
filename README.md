[![Build Status](https://travis-ci.org/HSLdevcom/helmet-data-preprocessing.svg?branch=master)](https://travis-ci.org/HSLdevcom/helmet-data-preprocessing)  

# helmet-data-preprocessing

This repository includes data preprocessing scripts. Preprocessed data is fed
into `helmet-estimation`, and estimation results are programmed into
`helmet-model-system`.

To use R, install the newest version of R. The scripts were written in R 3.6.0.
Please note, that scripts use encoding `UTF-8`.

## R environment setup

Aftr installing R v3.6.0, you can restore correct R environment (dependencies
etc.) via (`renv`)[https://rstudio.github.io/renv/articles/renv.html] command
`renv::restore()`. Previously, this package used a Docker image but it was
abanboned in favour of `renv`.

### Input data

All input data is located in private EXT-HELMET_KEHI_40 Sharepoint group. Just
download the folder `5 Data`, and either rename it as `input` to run scripts on
your local environment, or mount it to Docker.

Travel survey data is not included in `5 Data` because of privacy reasons.

### Running

Run every script by running `batch.R`. Output files in CSV or RData format
will be created to different folders. Please note, that Python scripts are
not run automatically - at least not yet. Moreover, Alogit will need
estimation data wrapped in 180 characters. Please use fast UNIX tools for that.

## Information about Python

### Setup

We're using `pipenv` to isolate our environment from the other Python modules.
Python version is 2.7 because our final deployment target (EMME) supported only
2.7 at the time of the development.

Intro to pipenv can be found from these links:
- https://docs.python-guide.org/dev/virtualenvs/
- https://jcutrer.com/python/pipenv-pipfile

Install `pipenv` (unless you already have it).   

```   
pip install --user pipenv
# TODO: add pipenv to your system PATH. In Linux the installation folder is ~/.local/bin
```

Then install the requirements from `Pipfile` using `pipenv` by running the
following scripts in repository:  

```   
# First setup:
pipenv install
# Once setup is done you can just run
pipenv sync
```

Install new libraries when needed (will update `Pipfile`, please commit that to
repository):

```   
pipenv install <your-new-library>
```

### Tests

We're using PyTest framework. Tests are in [tests-folder](tests) and can be
invoked with:

```   
pipenv run pytest
```
