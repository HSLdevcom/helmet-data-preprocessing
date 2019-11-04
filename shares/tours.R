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
             xfactor,
             closed,
             order,
             no_of_trips)
tours = leftjoin(tours, model_types)
tours = leftjoin(tours, modes)
tours = unpick(tours, ttype, mode)
tours$weight = ifelse(tours$closed %in% 1, 1, 0.5) * tours$xfactor

# HLT tours have never a secondary destination
m = which(tours$survey %in% 2 & tours$order %in% c("ABC", "ACB", "CAB"))
tours$order[m] = "AB"
m = which(tours$survey %in% 2 & tours$order %in% c("CBA", "BCA", "BAC"))
tours$order[m] = "BA"

tours_hoo_leg2 = subset(tours, nchar(order)==3)
tours_hoo_leg2$model_type = "hoo_leg2"
tours_hoo_leg3 = subset(tours, nchar(order)==3)
tours_hoo_leg3$model_type = "hoo_leg3"

tours = rbind_list(tours, tours_hoo_leg2, tours_hoo_leg3)

tours = fold(tours, .(model_type, mode_name), weight=sum(weight))
check.na(tours)
tours = downclass(tours)
save(tours, file="tours.RData")
