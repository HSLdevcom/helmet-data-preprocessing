#!/bin/bash
# -*- coding: utf-8-unix -*-
rm *.csv
Rscript --quiet --no-save --encoding=CP1252 zones.R
