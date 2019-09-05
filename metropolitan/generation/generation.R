# -*- coding: windows-1252-dos -*-
library(strafica)
source(ancfile("util.R"))

zones = read.csv2(ancfile("area/zones.csv"), stringsAsFactors=FALSE, fileEncoding="utf-8")
zones = pick(zones,
             zone,
             population_density,
             housing,
             parking_fee_other,
             cars_per_people,
             cbd,
             municipality)
# Rename according to convention
zones = rename(zones, zone=rzone)
columns = colnames(zones)[-1]
columns = sprintf("rzone_%s", columns)
colnames(zones)[-1] = columns

background = load1(ancfile("primary/background.RData"))
background = subset(background, survey %in% 0 & (rzone_capital_region | rzone_surrounding_municipality))
generation = background
generation = leftjoin(generation, zones, by="rzone")

# Add number and types of home-based tours
ttypes = load1("ttypes.RData")
ttypes_list = read.delims("ttypes_list.txt")
ttypes = leftjoin(ttypes, ttypes_list, by="ttypes_name")
generation = leftjoin(generation, ttypes, by="pid")

# Check that all needed columns exist and order columns.
columns = read.delims("order.txt")
columns$column = sprintf("^%s$", columns$column)
hits = sapply(rows.along(columns), function(i) {
    grep(columns$column[i], colnames(generation), value=TRUE)
})
columns$hits = sapply(hits, length)
stopifnot(all(columns$hits %in% c(1, nrow(zones))))
generation = generation[, unlist(hits)]

stopifnot(all(sapply(generation, class) %in% c("integer", "numeric")))
check.na(generation)
generation = downclass(generation)
write_alogit(generation, fname="generation.txt")
