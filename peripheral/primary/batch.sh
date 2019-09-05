#!/bin/bash
# -*- coding: utf-8-unix -*-
(cd alternatives/ && rm -fv *.txt)
rm -fv *.RData *.csv

Rscript --quiet --no-save --encoding=CP1252 background.R
Rscript --quiet --no-save --encoding=CP1252 tours.R
Rscript --quiet --no-save --encoding=CP1252 observations.R
Rscript --quiet --no-save --encoding=CP1252 average.R
Rscript --quiet --no-save --encoding=CP1252 alternatives.R
