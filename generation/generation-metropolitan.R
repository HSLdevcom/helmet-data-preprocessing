# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

observations = load1(ancfile("metropolitan/primary/observations.RData"))

# Tour types
observations = subset(observations, ttype %in% c(1:7))
observations$model_type = NA
m = which(observations$ttype %in% 1)
observations$model_type[m] = "hw"
m = which(observations$ttype %in% 2)
observations$model_type[m] = "hc"
m = which(observations$ttype %in% 3)
observations$model_type[m] = "hu"
m = which(observations$ttype %in% 4)
observations$model_type[m] = "hs"
m = which(observations$ttype %in% 5)
observations$model_type[m] = "ho"
m = which(observations$ttype %in% 6)
observations$model_type[m] = "wo"
m = which(observations$ttype %in% 7)
observations$model_type[m] = "oo"

tours = pick(observations,
             pid,
             mode,
             xfactor,
             model_type,
             closed)
tours$weight = ifelse(tours$closed %in% 1, 1, 0.5) * tours$xfactor
check.na(tours)

background = load1(ancfile("metropolitan/primary/background.RData"))
background = subset(background,
                    rzone_capital_region %in% 1 |
                        rzone_surrounding_municipality %in% 1)
background$age_group = NA
m = which(background$age_7_17 %in% 1)
background$age_group[m] = 1
m = which(background$age_18_29 %in% 1)
background$age_group[m] = 2
m = which(background$age_30_49 %in% 1)
background$age_group[m] = 3
m = which(background$age_50_64 %in% 1)
background$age_group[m] = 4
m = which(background$age_65 %in% 1)
background$age_group[m] = 5

tours = leftjoin(tours, background, by="pid")

stat = fold(tours, .(model_type, age_group, car_user),
            n=length(pid),
            weight=sum(weight))

background = fold(background, .(age_group, car_user), xfactor=sum(xfactor))

stat = leftjoin(stat, background)
stat$weight_per_person = stat$weight / stat$xfactor
write.csv2(stat, file="generation-metropolitan.csv", row.names=FALSE)
print(stat)

# Adding aggregate generation for printing
stat = fold(tours, .(model_type),
            n=length(pid),
            weight=sum(weight))
stat$weight_per_person = stat$weight / sum(background$xfactor)
print(stat)
