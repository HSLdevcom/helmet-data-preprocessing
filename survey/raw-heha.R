# -*- coding: utf-8-unix -*-
library(strafica)
library(readxl)
columns = read.delims("coltypes-heha.txt")
raw = read_xlsx(ancfile("input/HEHA-aineistot/MATKAT18_V3.xlsx"), col_types=columns$col_type)
raw = as.data.frame(raw)
save(raw, file="raw-heha.RData")
