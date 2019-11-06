#!/bin/bash
# -*- coding: utf-8-unix -*-
rm -fv *.RData *.csv

Rscript --quiet --no-save --encoding=UTF-8 generation-peripheral.R
Rscript --quiet --no-save --encoding=UTF-8 generation-metropolitan.R
Rscript --quiet --no-save --encoding=UTF-8 generation-metropolitan-secondary.R
