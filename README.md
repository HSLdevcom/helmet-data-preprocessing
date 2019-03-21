[![Build Status](https://travis-ci.org/HSLdevcom/helmet-data-preprocessing.svg?branch=master)](https://travis-ci.org/HSLdevcom/helmet-data-preprocessing)  

# helmet-data-preprocessing

This repository includes data preprocessing scripts. Preprocessed data is fed
into `helmet-estimation`, and estimation results are programmed into
`helmet-model-system`.

## Setup

We're using *pipenv* to isolate our environment from the other python modules.

Python version is 2.7 because our final deployment target (EMME) supports only 2.7

intro to pipenv can be found from these links:
- https://docs.python-guide.org/dev/virtualenvs/
- https://jcutrer.com/python/pipenv-pipfile

Install pipenv (unless you already have it).   

```   
pip install --user pipenv
# TODO: add pipenv to your system PATH. In Linux the installation folder is ~/.local/bin

```

Then install the requirements from Pipfile using pipenv.  

```   
# First setup:
pipenv install
# Once setup is done you can just run
pipenv sync
```

Install new libraries when needed (will update Pipfile, please commit that to repository):

```   
pipenv install <your-new-library>
```

## Tests

We're using PyTest framework. Test are in [tests-folder](tests) and can be invoked with

```   
pipenv run pytest
```

## Running

```   
pipenv run python ./tours/main.py
```


## Troubleshooting

Q: My application is using Python 3 instead of Python 2  
A: 
  - Remember to use pipenv run command instead of python 
   - you can check the version with pipenv run python --version

Q: Some library is not found (f.ex Pandas)  
A: Run: pipenv install

   
