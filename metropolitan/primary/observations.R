# -*- coding: utf-8-unix -*-
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
observations$no_of_trips = tours$no_of_trips

observations$base_ttype = NA
m = which(observations$ttype %in% 1:5)
observations$base_ttype[m] = observations$ttype[m]
m = which(observations$ttype %in% 6)
observations$base_ttype[m] = 1
m = which(observations$ttype %in% 7)
# Works only if the numbers are single-digit!
previous_tour_type = sprintf("%d - %d", 1, as.integer(substr(tours$tour_type[m], 1, 1)))
observations$base_ttype[m] = get_ttype(previous_tour_type,
                                       rep(FALSE, times=length(previous_tour_type)))
# Actually, if a non-home-based tour starts from business location, it should be
# a work-based tour (ttype=6) with a base_ttype of 1. However, get_ttype does
# not consider nhb tours starting from business locations to be wb tours. To
# keep tour types the same and not to affect the estimation datas,
# non-home-based tours (ttype=7) with a starting point in a business location
# (base_ttype=1) are transformed into non-home-based trips (ttype=7) with a
# starting point in other location (base_ttype=5).
m = which(observations$ttype %in% 7 & observations$base_ttype %in% 1)
observations$base_ttype[m] = 5

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

observations$itime = ifelse(tours$itime_origin %in% c("", "nan"), NA, tours$itime_origin)
observations$jtime = ifelse(tours$itime_destination %in% c("", "nan"), NA, tours$itime_destination)
observations$ktime = ifelse(tours$itime_secondary_destination %in% c("", "nan"), NA, tours$itime_secondary_destination)
observations$ipeak = get_peak(tours$itime_origin)
observations$jpeak = get_peak(tours$itime_destination)

# If tour visits only one place and returns to it, do not interpret a return
# time slot.
m = which(rowSums(tours[,grep("^visits_t[0-9]+", colnames(tours))]) == 1)
observations$jpeak[m] = NA

mtypes = read.delims("mtypes.txt")
observations = leftjoin(observations, mtypes)
observations$inverted = is_inverted(tours$order)

m = match(tours$zone_secondary_destination, zones$zone_orig)
observations$kzone = zones$zone[m]

# Add background information
observations = leftjoin(observations, background)

# Output
observations = downclass(observations)
check.na(observations)
save(observations, file="observations.RData")
