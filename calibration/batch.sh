#!/bin/bash
# -*- coding: utf-8-unix -*-
rm -fv *.csv
Rscript --quiet --no-save --encoding=UTF-8 tours.R
Rscript --quiet --no-save --encoding=UTF-8 demand.R
Rscript --quiet --no-save --encoding=UTF-8 length.R
Rscript --quiet --no-save --encoding=UTF-8 internal.R
