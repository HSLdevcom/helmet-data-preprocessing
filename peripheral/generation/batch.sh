#!/bin/bash
# -*- coding: utf-8-unix -*-
rm -fv *.RData *.csv

Rscript --quiet --no-save --encoding=UTF-8 tours.R
Rscript --quiet --no-save --encoding=UTF-8 generation.R
Rscript --quiet --no-save --encoding=UTF-8 trips.R
Rscript --quiet --no-save --encoding=UTF-8 shares.R
