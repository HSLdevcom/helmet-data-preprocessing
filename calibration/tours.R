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

tours$old_izone = tours$izone
tours$old_jzone = tours$jzone
tours$izone = ifelse(tours$inverted, tours$old_jzone, tours$old_izone)
tours$jzone = ifelse(tours$inverted, tours$old_izone, tours$old_jzone)

model_types = read.delims("models.txt")
tours = leftjoin(tours, model_types)

zones = read.csv2(ancfile("area/zones.csv"))
tours$idistrict = zones$district[match(tours$izone, zones$zone)]
tours$jdistrict = zones$district[match(tours$jzone, zones$zone)]

modes = read.delims("modes.txt")
tours = leftjoin(tours, modes)
tours = unpick(tours, mode)

save(tours, file="tours.RData")
