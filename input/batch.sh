#!/bin/bash
# -*- coding: utf-8-unix -*-
rm *.csv
Rscript --quiet --no-save --encoding=CP1252 zones.R
Rscript --quiet --no-save --encoding=CP1252 survey-heha.R
Rscript --quiet --no-save --encoding=CP1252 survey-hlt.R

