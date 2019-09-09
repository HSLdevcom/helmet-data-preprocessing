# -*- coding: utf-8-unix -*-
library(strafica)

observations = load1(ancfile("primary/observations.RData"))

# Tour types in peripheral model
observations$ttype_peripheral = NA
m = which(observations$ttype %in% 1)
observations$ttype_peripheral[m] = 1
m = which(observations$ttype %in% 2:5)
observations$ttype_peripheral[m] = 2
m = which(observations$ttype %in% 6:7)
observations$ttype_peripheral[m] = 3

# If destination is visited before origin, the tour is inverted
observations$inverted = ifelse(observations$order %in% c("BA","BAC","BCA","CBA"),
                               TRUE,
                               FALSE)

# If the tour is inverted, the first trip is a return trip (from destination
# back to origin)
observations$return_trip = ifelse(observations$inverted,
                                  TRUE,
                                  FALSE)
observations$trip_time = ifelse(observations$return_trip,
                                observations$jpeak,
                                observations$ipeak)

# Closed trips are doubled: the return_trip status is negated to account for a trip
# to other direction
trips_return_trip = subset(observations, closed %in% 1)
trips_return_trip$return_trip = !(trips_return_trip$return_trip)
trips_return_trip$trip_time = ifelse(trips_return_trip$return_trip,
                                     trips_return_trip$jpeak,
                                     trips_return_trip$ipeak)
trips = rbind_list(observations,
                   trips_return_trip)

check.na(trips)
trips = downclass(trips)
save(trips, file="trips.RData")
