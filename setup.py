from distutils.core import setup

# To use a consistent encoding
from codecs import open
from os import path

here = path.abspath(path.dirname(__file__))

# Get the long description from the README file
with open(path.join(here, "README.md"), encoding="utf-8") as f:
    long_description = f.read()

setup(
    name='helmet-data-preprocessing',
    version='0.1',
    description='Data preprocessing scripts for Helmet 4.0',
    author='Johanna Piipponen',
    author_email='johanna.piipponen@strafica.fi',
    url='https://github.com/HSLdevcom/helmet-data-preprocessing',
    packages=['tours'],
    install_requires=['pandas',],
#    scripts=['tours',],
)
