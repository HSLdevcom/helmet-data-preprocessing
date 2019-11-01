# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

model_types = read.delims("models.txt")
modes = read.delims("modes.txt")

observations1 = load1(ancfile("metropolitan/primary/observations.RData"))
observations2 = load1(ancfile("peripheral/primary/observations.RData"))
tours = rbind_list(observations1, observations2)
tours = pick(tours,
             pid,
             mode,
             ttype,
             survey,
             year,
             mtype,
             xfactor,
             itime,
             jtime,
             ktime,
             closed,
             order,
             no_of_trips)
tours = leftjoin(tours, model_types)
tours = leftjoin(tours, modes)
tours = unpick(tours, ttype, mode)

# HLT tours have never a secondary destination
m = which(tours$survey %in% 2 & tours$order %in% c("ABC", "ACB", "CAB"))
tours$order[m] = "AB"
m = which(tours$survey %in% 2 & tours$order %in% c("CBA", "BCA", "BAC"))
tours$order[m] = "BA"

positive = c("A", "AB", "ABC", "BCA", "CAB")

leg1 = tours
leg1$forward = ifelse(leg1$order %in% positive, TRUE, FALSE)
leg1$itime = ifelse(leg1$order %in% positive,
                    leg1$itime,
                    leg1$jtime)
leg1 = subset(leg1, !(closed %in% 2 & order %in% c("ACB", "BCA")))

leg2 = subset(tours, nchar(order) > 1)
leg2$forward = ifelse(leg2$order %in% positive, TRUE, FALSE)
leg2$itime = ifelse(leg2$order %in% positive,
                    leg2$jtime,
                    ifelse(leg2$order %in% "BA",
                           leg2$itime,
                           leg2$ktime))
leg2$model_type = ifelse(nchar(leg2$order)==2, leg2$model_type, "hoo_leg2")
leg2 = subset(leg2, !(closed %in% 2 & order %in% c("AB", "BA", "BAC", "CAB")))

leg3 = subset(tours, nchar(order) > 2)
leg3$forward = ifelse(leg3$order %in% positive, TRUE, FALSE)
leg3$itime = ifelse(leg3$order %in% positive,
                    leg3$ktime,
                    leg3$itime)
leg3$model_type = "hoo_leg3"
leg3 = subset(leg3, !(closed %in% 2 & order %in% c("ABC", "CBA")))

trips = rbind_list(leg1, leg2, leg3)
trips = unpick(trips, jtime, ktime)

# Output
check.na(trips)
trips = downclass(trips)
save(trips, file="trips.RData")
