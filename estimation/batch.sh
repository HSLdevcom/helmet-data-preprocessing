#!/bin/bash
# -*- coding: utf-8-unix -*-
rscript zones.R
rscript matrices.R
rscript observations.R
rscript alternatives.R

cd alternatives/
cat alternatives-hs15-*.txt | fold -w 180 -s > alternatives-hs15.txt
cat alternatives-outer-*.txt | fold -w 180 -s > alternatives-outer.txt

