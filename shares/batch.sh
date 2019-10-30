#!/bin/bash
# -*- coding: utf-8-unix -*-
rm -fv *.csv *.RData
Rscript --quiet --no-save --encoding=UTF-8 trips.R
Rscript --quiet --no-save --encoding=UTF-8 peak_morning.R
Rscript --quiet --no-save --encoding=UTF-8 peak_afternoon.R
Rscript --quiet --no-save --encoding=UTF-8 peak_other.R
Rscript --quiet --no-save --encoding=UTF-8 shares.R
