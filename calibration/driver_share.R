# -*- coding: utf-8-unix -*-
library(strafica)

tours = load1("tours.RData")

observations3 = load1(ancfile("metropolitan/secondary/observations.RData"))
observations3 = pick(observations3,
             pid,
             mode,
             ttype,
             survey,
             year,
             mtype,
             xfactor,
             izone,
             jzone,
             closed)
observations3 = leftjoin(observations3, read.delims("models.txt"))
observations3 = leftjoin(observations3, read.delims("modes.txt"))
observations3 = rename(observations3, mode=mode_original)
observations3$model_type = "hoo"

tours = rbind_list(tours, observations3)

tours = subset(tours, mode_name %in% "car")
tours$model_type = factor(tours$model_type,
                          levels=c("hw","hc","hu","hs","ho",
                                   "hoo","so","wo","oo",
                                   "hwp","hop",
                                   "sop","oop"))

tours$weight = ifelse(tours$closed %in% 1, 1, 0.5) * tours$xfactor

stat = fold(tours, .(model_type),
            weight_car_driver=sum(ifelse(mode_original %in% 4, weight, 0)),
            weight_car_passenger=sum(ifelse(mode_original %in% 5, weight, 0)))
stat$driver_share = stat$weight_car_driver / (stat$weight_car_driver + stat$weight_car_passenger)

write.csv2(stat, file="driver_share.csv", row.names=FALSE)
print(stat)
