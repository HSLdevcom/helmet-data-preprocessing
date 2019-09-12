# -*- coding: utf-8-unix -*-
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

generation = load1(ancfile("primary/background.RData"))
generation = leftjoin(generation, zones, by="rzone")
generation = subset(generation, generation$rzone_capital_region | generation$rzone_surrounding_municipality)

# ttypes_key.txt defines the class of each ttypes group. Groups not mentioned in
# the file go into "muu / other" class.
ttypes = load1("ttypes.RData")
ttypes_key = read.delims("ttypes_key.txt")
ttypes = leftjoin(ttypes, ttypes_key, by="ttypes_model", missing=39)

# People with zero tours go into "0" class.
generation = leftjoin(generation, ttypes, by="pid")
m = which(is.na(generation$homebased_tours))
generation$homebased_tours[m] = 0
m = which(is.na(generation$ttypes))
generation$ttypes[m] = 1

# Class variable from homebased_tours
generation$homebased_tours_class = generation$homebased_tours
m = which(generation$homebased_tours >= 4)
generation$homebased_tours_class[m] = 4

# Create dummy variables for accessibility measures
generation$accessibility_work = 1.00
generation$accessibility_study = 1.00
generation$accessibility_school = 1.00
generation$accessibility_shopping = 1.00
generation$accessibility_other = 1.00

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
write_alogit(generation, fname="alternatives/alternatives.txt")
writeLines(colnames(generation), "alternatives/columns.txt")
