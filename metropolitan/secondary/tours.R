# -*- coding: windows-1252-dos -*-
library(strafica)

tours = load1(ancfile("primary/tours.RData"))
tour_columns = colnames(tours)
tours = subset(tours, secondary_destination != -1)
tours = subset(tours, zone_secondary_destination != 0)
stopifnot(all(tours$order %in% c("ABC", "ACB", "BAC", "BCA", "CAB", "CBA")))
tours$from = ifelse(tours$order %in% c("ACB", "BAC", "CBA"), "A", "B")
save(tours, file="tours.RData")
