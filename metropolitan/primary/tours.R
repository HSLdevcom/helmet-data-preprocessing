# -*- coding: utf-8-unix -*-
library(strafica)

# This script is created to get rid of unviable tours before doing any further
# estimation data adjustments.

zones = read.csv2(ancfile("area/zones.csv"), stringsAsFactors=FALSE)

# HEHA 2018
tours = read.csv2(ancfile("tours/tours-heha.csv"),
                  stringsAsFactors=FALSE)
tours$closed = ifelse(tours$closed == "True", TRUE, FALSE)
tours$model = 1
tours$year = 2018
tours$constructed = FALSE
m = match(tours$rzone, zones$zone_orig)
tours = subset(tours, ((zones$capital_region[m] | zones$surrounding_municipality[m]) &
                           tours$zone_origin %in% zones$zone_orig &
                           tours$zone_destination %in% zones$zone_orig))
tours = subset(tours, rzone %in% zones$zone_orig)
tours = subset(tours, mode %in% 1:5)
tours = downclass(tours)
check.na(tours)
save(tours, file="tours.RData")
