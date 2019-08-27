[![Build Status](https://travis-ci.org/HSLdevcom/helmet-data-preprocessing.svg?branch=master)](https://travis-ci.org/HSLdevcom/helmet-data-preprocessing)  

# helmet-data-preprocessing

This repository includes data preprocessing scripts. Preprocessed data is fed
into `helmet-estimation`, and estimation results are programmed into
`helmet-model-system`.

## Setup

We're using `pipenv` to isolate our environment from the other Python modules.
Python version is 2.7 because our final deployment target (EMME) supports only
2.7.

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

To use R, install the newest version of R. The scripts were written in R 3.4.4.
Please note, that scripts use encoding `windows-1252`.

### External dependencies

R-scripts use proprietary library called `strafica` which needs to be installed
separately. `strafica` package can be found from the office for selected people
to use. You can check dependencies from the DESCRIPTION file or from the
[Dockerfile](Dockerfile) and then install it:

```
Rscript --quiet --no-save --encoding=CP1252 install-dependencies.R
(cd strafica && Rscript --quiet --no-save --encoding=CP1252 install.R)
```

### Input data

All input data is located in private EXT-HELMET_KEHI_40 Sharepoint group. Just
download the folder `5 Data`, and either rename it as `input` to run scripts on
your local environment, or mount it to Docker.

### Docker

R and Python environment is also virtualized using Docker. See
[Dockerfile](Dockerfile) for details. Build and run using commands below.
Run-script will open up a bash session where user can start the preprocessing.
External dependencies and the data need to be however mapped as external volume,
see `docker run` commands below.

#### Build and run on Windows PowerShell

```
docker build -t helmet-data-preprocessing .

docker run -it --rm `
    -v //c/Users/xxx/input/:/input/ `
    -v //c/Users/xxx/output/:/output/ `
    -v //c/Users/xxx/strafica/:/strafica `
    helmet-data-preprocessing
```

#### Build and run on Linux command line

```
docker build -t helmet-data-preprocessing .

docker run -it --rm \
  -v ~/xxx/input/:/input/ \
  -v ~/xxx/output/:/output/ \
  -v ~/xxx/strafica/:/strafica \
  helmet-data-preprocessing
```

## Tests

We're using PyTest framework. Tests are in [tests-folder](tests) and can be
invoked with:

```   
pipenv run pytest
```

## Running

Run every script by running `sh batch.sh`. Output files in CSV or RData format
will be created to `output` folder.

## Troubleshooting

Q: My application is using Python 3 instead of Python 2.  
A: Remember to use `pipenv run` command instead of `python`. You can check the
version with `pipenv run python --version`.

Q: Some library is not found (f.ex Pandas).  
A: Run `pipenv install`.
