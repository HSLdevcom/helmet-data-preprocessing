#!/bin/bash
# -*- coding: utf-8-unix -*-
(cd input/ && rscript survey-heha.R)
(cd input/ && rscript survey-hlt.R)
python main.py heha
python main.py hlt
