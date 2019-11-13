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


###
### One-trip tours
###

leg1 = subset(tours, order %in% "A")
leg1$forward = TRUE
leg1$itime = leg1$itime

trips1 = leg1


###
### Two-trip tours
###

leg1 = subset(tours, nchar(order)==2)
leg1$forward = TRUE
leg1$itime = leg1$itime
leg1 = vsubset(leg1, !(closed %in% 2 & order %in% "BA"))

leg2 = subset(tours, nchar(order)==2)
leg2$forward = FALSE
leg2$itime = leg2$jtime
leg2 = vsubset(leg2, !(closed %in% 2 & order %in% "AB"))

trips2 = rbind_list(leg1, leg2)


###
### Three-trip tours
###

leg1 = subset(tours, nchar(order)==3)
leg1$forward = (leg1$order %in% positive)
leg1$itime = ifelse(leg1$forward, leg1$itime, leg1$jtime)
leg1 = vsubset(leg1, !(closed %in% 2 & order %in% "ACB"))
leg1 = vsubset(leg1, !(closed %in% 2 & order %in% "BCA"))

leg2 = subset(tours, nchar(order)==3)
leg2$model_type = "hoo_leg2"
leg2$forward = (leg2$order %in% positive)
leg2$itime = ifelse(leg2$forward, leg2$jtime, leg2$ktime)
leg2 = vsubset(leg2, !(closed %in% 2 & order %in% "BAC"))
leg2 = vsubset(leg2, !(closed %in% 2 & order %in% "CAB"))

leg3 = subset(tours, nchar(order)==3)
leg3$model_type = "hoo_leg3"
leg3$forward = (leg3$order %in% positive)
leg3$itime = ifelse(leg3$forward, leg3$ktime, leg3$itime)
leg3 = vsubset(leg3, !(closed %in% 2 & order %in% "ABC"))
leg3 = vsubset(leg3, !(closed %in% 2 & order %in% "CBA"))

trips3 = rbind_list(leg1, leg2, leg3)


###
### Trips
###

trips = rbind_list(trips1, trips2, trips3)
trips = unpick(trips, jtime, ktime)


###
### Output
###

print(fold(trips, .(model_type), xfactor=sum(xfactor)))
check.na(trips)
trips = downclass(trips)
save(trips, file="trips.RData")
