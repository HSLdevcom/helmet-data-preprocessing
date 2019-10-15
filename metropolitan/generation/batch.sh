#!/bin/bash
# -*- coding: utf-8-unix -*-
(cd alternatives/ && rm -fv *.txt)
rm -fv *.RData *.csv

Rscript --quiet --no-save --encoding=UTF-8 ttypes.R
Rscript --quiet --no-save --encoding=UTF-8 alternatives.R
Rscript --quiet --no-save --encoding=UTF-8 generation-nhb.R
