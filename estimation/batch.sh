#!/bin/bash
# -*- coding: utf-8-unix -*-
(cd alternatives/ && rm *.txt)
rm *.RData *.csv

rscript zones.R
rscript matrices.R
rscript observations.R
rscript average.R
rscript alternatives.R

cd alternatives/

cat alternatives-metropolitan-*.txt | fold -w 180 -s > alternatives-metropolitan.txt
cat alternatives-peripheral-*.txt | fold -w 180 -s > alternatives-peripheral.txt
cat alternatives-metropolitan-1_100.txt | fold -w 180 -s > alternatives-metropolitan-test.txt
cat alternatives-peripheral-1_100.txt | fold -w 180 -s > alternatives-peripheral-test.txt

