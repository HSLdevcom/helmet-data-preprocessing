# -*- coding: utf-8-unix -*-
library(strafica)
library(readxl)
columns = read.delims("survey/coltypes-heha-uusi.csv")
raw = read_xlsx("input/HEHA-aineistot/MATKAT18_V3.xlsx", col_types=columns$col_type)
raw = as.data.frame(raw)
save(raw, file="survey/temp/raw-heha.RData")
