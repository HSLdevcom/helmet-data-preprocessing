# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

observations1 = load1(ancfile("metropolitan/primary/observations.RData"))
observations2 = load1(ancfile("peripheral/primary/observations.RData"))
tours = rbind_list(observations1, observations2)
tours = pick(tours,
            pid,
            mode,
            ttype,
            survey,
            xfactor,
            izone,
            jzone,
            closed,
            order)
tours$inverted = is_inverted(tours$order)

tours$inverted_izone = ifelse(tours$inverted, tours$jzone, tours$izone)
tours$inverted_jzone = ifelse(tours$inverted, tours$izone, tours$jzone)

model_types = read.delims("models.txt")
tours = leftjoin(tours, model_types)

zones = read.csv2(ancfile("area/zones.csv"))
tours$idistrict = zones$district[match(tours$izone, zones$zone)]
tours$jdistrict = zones$district[match(tours$jzone, zones$zone)]

modes = read.delims("modes.txt")
tours = leftjoin(tours, modes)
tours = unpick(tours, mode)

tours$weight = ifelse(tours$closed, 1, 0.5) * tours$xfactor
save(tours, file="tours.RData")
