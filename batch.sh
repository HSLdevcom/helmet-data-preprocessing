#!/bin/bash
# -*- coding: utf-8-unix -*-
(cd input/ && sh batch.sh)
pipenv run python ./tours/main.py input-config-heha.json
pipenv run python ./tours/main.py input-config-hlt.json
(cd estimation/ && sh batch.sh)

