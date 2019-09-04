#!/bin/bash
# -*- coding: utf-8-unix -*-
rm *.RData *.csv

Rscript --quiet --no-save --encoding=CP1252 tours.R
Rscript --quiet --no-save --encoding=CP1252 observations.R
Rscript --quiet --no-save --encoding=CP1252 alternatives.R
