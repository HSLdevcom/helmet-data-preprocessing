#!/bin/bash
# -*- coding: utf-8-unix -*-
(cd alternatives/ && rm -fv *.txt)
rm -fv *.RData *.csv

Rscript --quiet --no-save --encoding=CP1252 ttypes.R
Rscript --quiet --no-save --encoding=CP1252 alternatives.R
