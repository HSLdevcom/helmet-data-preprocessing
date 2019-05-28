#!/bin/bash
# -*- coding: utf-8-unix -*-
(cd alternatives/ && rm *.txt)
rm *.RData *.csv

rscript zones.R
rscript matrices.R
rscript background.R

rscript tours.R
rscript constructed.R
rscript secondary.R
rscript observations.R
rscript average.R
rscript average-secondary.R
rscript alternatives.R
rscript alternatives-secondary.R

cd alternatives/

cat alternatives-peripheral-1_100.txt | fold -w 180 -s > alternatives-peripheral-test.txt
cat alternatives-constructed-peripheral-1_100.txt | fold -w 180 -s > alternatives-constructed-peripheral-test.txt
cat alternatives-constructed-metropolitan-1_100.txt | fold -w 180 -s > alternatives-constructed-metropolitan-test.txt
cat alternatives-wss-metropolitan-1_100.txt | fold -w 180 -s > alternatives-wss-metropolitan-test.txt
cat alternatives-spbo-metropolitan-1_100.txt | fold -w 180 -s > alternatives-spbo-metropolitan-test.txt
cat alternatives-wbo-metropolitan-1_100.txt | fold -w 180 -s > alternatives-wbo-metropolitan-test.txt
cat alternatives-secondary-metropolitan-1_100.txt | fold -w 180 -s > alternatives-secondary-metropolitan-test.txt

cat alternatives-peripheral-*.txt | fold -w 180 -s > alternatives-peripheral.txt
cat alternatives-constructed-peripheral-*.txt | fold -w 180 -s > alternatives-constructed-peripheral.txt
cat alternatives-constructed-metropolitan-*.txt | fold -w 180 -s > alternatives-constructed-metropolitan.txt
cat alternatives-wss-metropolitan-*.txt | fold -w 180 -s > alternatives-wss-metropolitan.txt
cat alternatives-spbo-metropolitan-*.txt | fold -w 180 -s > alternatives-spbo-metropolitan.txt
cat alternatives-wbo-metropolitan-*.txt | fold -w 180 -s > alternatives-wbo-metropolitan.txt
cat alternatives-secondary-metropolitan-*.txt | fold -w 180 -s > alternatives-secondary-metropolitan.txt

