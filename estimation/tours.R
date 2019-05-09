# -*- coding: windows-1252-dos -*-
library(strafica)

# This script is created to get rid of unviable tours before doing any further
# estimation data adjustments.

zones = load1("zones.RData")

# HLT 2016
tours = read.csv2(ancfile("tours/output/tours-hlt.csv"),
                  stringsAsFactors=FALSE)
tours$closed = ifelse(tours$closed == "True", TRUE, FALSE)
tours$model = 2
tours$year = 2016
m = match(tours$rzone, zones$zone_orig)
tours = subset(tours, (zones$peripheral_municipality[m] &
                           tours$zone_origin %in% zones$zone_orig &
                           tours$zone_destination %in% zones$zone_orig))
tours = subset(tours, mode %in% 1:5)
tours = downclass(tours)
check.na(tours)
save(tours, file="tours-peripheral.RData")

# HEHA 2018
tours = read.csv2(ancfile("tours/output/tours-heha.csv"),
                  stringsAsFactors=FALSE)
tours$closed = ifelse(tours$closed == "True", TRUE, FALSE)
tours$model = 1
tours$year = 2018
m = match(tours$rzone, zones$zone_orig)
tours = subset(tours, ((zones$capital_region[m] | zones$surrounding_municipality[m]) &
                           tours$zone_origin %in% zones$zone_orig &
                           tours$zone_destination %in% zones$zone_orig))
tours = subset(tours, mode %in% 1:5)
tours = downclass(tours)
check.na(tours)
save(tours, file="tours-metropolitan.RData")

