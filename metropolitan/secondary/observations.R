# -*- coding: utf-8-unix -*-
library(strafica)
library(readxl)
source(ancfile("util.R"))

zones = read.csv2(ancfile("area/zones.csv"), stringsAsFactors=FALSE)
background = load1(ancfile("primary/background.RData"))

message("Formatting tour data...")

tours = load1("tours.RData")

observations = data.frame(pid=tours$pid)
observations$mode = tours$mode
observations$ttype = get_ttype(tours$tour_type,
                               tours$constructed)
observations$other_destinations = ifelse(rowSums(tours[, grepl("^visits_t", colnames(tours), perl=TRUE)]) > 3, 1, 0)
observations$closed = ifelse(tours$closed, 1, 2)

# Origin
m = match(tours$zone_origin, zones$zone_orig)
observations$izone = zones$zone[m]
observations$izone_cbd = ifelse(zones$cbd[m]==1, 1, 0)
observations$izone_cars_per_people = zones$cars_per_people[m]
observations$izone_population_density = zones$population_density[m]
observations$izone_job_density = zones$job_density[m]
observations$izone_housing = zones$housing[m]
observations$izone_parking_fee_other = zones$parking_fee_other[m]

# Destination
m = match(tours$zone_destination, zones$zone_orig)
observations$jzone = zones$zone[m]
observations$jzone_cbd = ifelse(zones$cbd[m]==1, 1, 0)
observations$jzone_cars_per_people = zones$cars_per_people[m]

# Secondary destination
m = match(tours$zone_secondary_destination, zones$zone_orig)
observations$kzone = zones$zone[m]

mtypes = read.delims(ancfile("primary/mtypes.txt"))
observations = leftjoin(observations, mtypes)

# Add background information
observations = leftjoin(observations, background)

# Output
observations = downclass(observations)
check.na(observations)
save(observations, file="observations.RData")
