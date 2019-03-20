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

```   
pipenv install

```


install new libraries:

```   
pipenv install <your-new-library>
```
