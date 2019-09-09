# -*- coding: windows-1252-dos -*-
library(strafica)
library(readxl)
source(ancfile("util.R"))

zones = read.csv2(ancfile("area/zones.csv"), stringsAsFactors=FALSE)
background = load1("background.RData")

message("Formatting tour data...")

tours = load1("tours.RData")

observations = data.frame(pid=tours$pid)
observations$mode = tours$mode
observations$ttype = get_ttype(tours$tour_type,
                               tours$constructed)
observations$other_destinations = ifelse(rowSums(tours[, grepl("^visits_t", colnames(tours), perl=TRUE)]) > 2, 1, 0)
observations$closed = ifelse(tours$closed, 1, 2)
observations$order = tours$order

m = match(tours$zone_origin, zones$zone_orig)
observations$izone = zones$zone[m]
observations$izone_cbd = ifelse(zones$cbd[m]==1, 1, 0)
observations$izone_population_density = zones$population_density[m]
observations$izone_job_density = zones$job_density[m]
observations$izone_housing = zones$housing[m]
observations$izone_parking_fee_other = zones$parking_fee_other[m]
observations$izone_cars_per_people = zones$cars_per_people[m]

m = match(tours$zone_destination, zones$zone_orig)
observations$jzone = zones$zone[m]

observations$ipeak = get_peak(tours$itime_origin)
observations$jpeak = get_peak(tours$itime_destination)

# If tour visits only one place and returns to it, do not interpret a return
# time slot.
m = which(rowSums(tours[,grep("^visits_t[0-9]+", colnames(tours))]) == 1)
observations$jpeak[m] = NA

mtypes = read.delims("mtypes.txt")
observations = leftjoin(observations, mtypes)

m = match(tours$zone_secondary_destination, zones$zone_orig)
observations$kzone = zones$zone[m]

# Add background information
observations = leftjoin(observations, background)

# Output
observations = downclass(observations)
check.na(observations)
save(observations, file="observations.RData")
