#!/bin/bash
# -*- coding: utf-8-unix -*-
(cd alternatives/ && rm -fv *.txt)
rm -fv *.RData *.csv

Rscript --quiet --no-save --encoding=UTF-8 background.R
Rscript --quiet --no-save --encoding=UTF-8 tours.R
Rscript --quiet --no-save --encoding=UTF-8 observations.R
Rscript --quiet --no-save --encoding=UTF-8 average.R
Rscript --quiet --no-save --encoding=UTF-8 alternatives.R
