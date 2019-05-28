#!/bin/bash
# -*- coding: utf-8-unix -*-
rm *.csv
rscript zones.R
rscript survey-heha.R
rscript survey-hlt.R

