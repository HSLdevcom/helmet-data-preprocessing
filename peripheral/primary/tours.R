# -*- coding: utf-8-unix -*-
library(strafica)

# This script is created to get rid of unviable tours before doing any further
# estimation data adjustments.

zones = read.csv2(ancfile("area/zones.csv"), stringsAsFactors=FALSE)

# HLT 2016
tours = read.csv2(ancfile("tours/tours-hlt.csv"),
                  stringsAsFactors=FALSE)
tours$closed = ifelse(tours$closed == "True", TRUE, FALSE)
tours$model = 2
tours$year = 2016
tours$constructed = FALSE
m = match(tours$rzone, zones$zone_orig)
tours = subset(tours, (zones$peripheral_municipality[m] &
                           tours$zone_origin %in% zones$zone_orig &
                           tours$zone_destination %in% zones$zone_orig))
tours = subset(tours, rzone %in% zones$zone_orig)
tours = subset(tours, mode %in% 3:5)
tours = downclass(tours)
check.na(tours)
save(tours, file="tours.RData")
