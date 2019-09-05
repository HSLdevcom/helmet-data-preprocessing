#!/bin/bash
# -*- coding: utf-8-unix -*-
rm -fv *.csv
Rscript --quiet --no-save --encoding=CP1252 zones.R
Rscript --quiet --no-save --encoding=CP1252 matrices.R
