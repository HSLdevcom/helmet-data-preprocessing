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

To use R, install the newest version of R. The scripts were written in R 3.4.4. Please note, that scripts use encoding `windows-1252`.

R-environment is also virtualized using Docker. See [Dockerfile](Dockerfile) for details.
Build and run using attached scripts. Run-script will open up a bash session where user
can start the preprocessing. External dependencies and the data need to be however mapped
as external volume, see [the run script](run-docker.sh).

```   
./build-docker.sh
./run-docker.sh
```   


### External dependencies

R-scripts use proprietary library called `strafica` which needs to be installed separately.
`strafica` package can be found from the office for selected people to use.
You can check dependencies from the DESCRIPTION file or from the [Dockerfile](Dockerfile)
and then install it:

```   
cd strafica && Rscript ./install.R
```


### Input data

All input data is located in private EXT-HELMET_KEHI_40 Sharepoint group. Input data is organized like this:

```
├── data
│   └── raw
│       ├── heha
│       │   └── MATKAT18_V3.xlsx
│       ├── hlt
│       │   ├── M_MATKAT.CSV
│       │   ├── PA_PAIKAT_sijoittelualueet.csv
│       │   └── T_TAUSTA.CSV
│       ├── jkl_kust_yht.csv
│       ├── Maankäyttö
│       │   ├── Autonomistus mallialueittain YKR 2015_v1.xlsx
│       │   ├── HS15_vaesto2017.xlsx
│       │   ├── koko_mallialue_asuinrakennukset_2016_2017.xlsx
│       │   ├── koko_mallialue_myymala_ja_palvelutpt_2016.xlsx
│       │   ├── koko_mallialue_työpaikat_yht_2016.xlsx
│       │   ├── maankayttotiedot_sijoittelualueittain_kaikki_yhdessa.xlsx
│       │   ├── maapinta_ala_ja_asutut_ruudut.xlsx
│       │   ├── opla_luettelo_2017_2.xlsx
│       │   ├── opla_luettelo_2017.xlsx
│       │   ├── rakennettu_maapinta_ala_2018.xlsx
│       │   ├── teollisuus_ja_kuljetustpt_2016.xlsx
│       │   ├── tulotiedot_2016.xlsx
│       │   └── ymparyskunnat_vaesto2016.xlsx
│       ├── md21_pysakointikustannus_tyo_2018.csv
│       ├── md22_pysakointikustannus_muu_2018.csv
│       ├── pysäköintikustannukset_2018.xlsx
│       ├── sijoittelualueet2019
│       │   ├── sijoittelualueet2019.dbf
│       │   ├── sijoittelualueet2019.prj
│       │   ├── sijoittelualueet2019.qpj
│       │   ├── sijoittelualueet2019.shp
│       │   └── sijoittelualueet2019.shx
│       ├── Vastukset2016
│       │   ├── mf100.csv
│       │   ├── mf101.csv
│       │   ├── ...
│       └── Vastukset2018
│           ├── mf100.csv
│           ├── mf101.csv
│           ├── ...
├── helmet-data-preprocessing
│   ├── ...
│   │   ├── ...
│   │   │   ├── ...
│   │   │   ├── ...
...
```

Folders in Sharepoint:

- `heha`: 5 Data > HEHA-aineistot
- `hlt`: 5 Data > HLT-aineisto
- `jkl_kust_yht.csv`: 5 Data > Estimoinnin_lähtotiedot > Joukkoliikenteen kustannukset
- `Maankäyttö`: 5 Data > Maankäyttö
- `pysäköintikustannukset_2018.xlsx`: 5 Data > Estimoinnin_lähtötiedot
- `sijoittelualueet2019`: 5 Data > aluejaot > aluejaot_2019_SHP
- `Vastukset2016`: 5 Data > Estimoinnin_lähtötiedot > Vastukset2016
- `Vastukset2018`: 5 Data > Estimoinnin_lähtötiedot > Vastukset2018

## Tests

We're using PyTest framework. Test are in [tests-folder](tests) and can be invoked with

```   
pipenv run pytest
```

## Running

```
cd input/
Rscript zones.R
Rscript survey-heha.R
Rscript survey-hlt.R
cd ..
pipenv run python ./tours/main.py
# ALTERNATIVELY:
# pipenv run python ./tours/main.py input-config-heha.json
# pipenv run python ./tours/main.py input-config-hlt.json
cd estimation/
sh batch.sh
```

Output files in CSV or RData format will be created to `input`, `tours/output`, `estimation`, and `estimation/alternatives` folders.

## Troubleshooting

Q: My application is using Python 3 instead of Python 2  
A:
  - Remember to use pipenv run command instead of python
   - you can check the version with pipenv run python --version

Q: Some library is not found (f.ex Pandas)  
A: Run: pipenv install
