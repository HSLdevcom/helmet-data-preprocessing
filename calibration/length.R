# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

tours = load1("tours.RData")
zones = read.csv2(ancfile("area/zones.csv"))

###
### Length
###

mat = read.csv(ancfile("input/Estimoinnin_lähtötiedot/Vastukset2018/mf377.csv"), stringsAsFactors=FALSE)
colnames(mat)[1] = "izone"
mat = tidyr::gather(mat, key="jzone", value="length", -izone)
mat$jzone = gsub("X", "", mat$jzone)
mat$izone = as.integer(mat$izone)
mat$jzone = as.integer(mat$jzone)
mat$izone = zones$zone[match(mat$izone, zones$zone_orig)]
mat$jzone = zones$zone[match(mat$jzone, zones$zone_orig)]
mat$length = as.numeric(mat$length)

tours = leftjoin(tours, mat)

tours$length_class = apply.breaks(tours$length,
                                  class=c(0, 1, 3, 5, 10, 20),
                                  lower=c(0, 1, 3, 5, 10, 20),
                                  upper=c(1, 3, 5, 10, 20, Inf))
stopifnot(all(!is.na(tours$length_class)))

# Onko kaikki pituuden HA-pituuksia?

length_model_type = fold(tours, .(length_class, model_type),
                         weight=sum(weight))
length_model_type_mode = fold(tours, .(length_class, model_type, mode_name),
                              weight=sum(weight))
length_model_type_mode = add_mode_share(length_model_type_mode, length_model_type)
