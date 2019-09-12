#!/bin/bash
# -*- coding: utf-8-unix -*-
rm -fv *.csv
Rscript --quiet --no-save --encoding=UTF-8 zones.R
Rscript --quiet --no-save --encoding=UTF-8 matrices.R
