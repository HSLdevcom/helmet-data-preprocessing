# -*- coding: utf-8-unix -*-
library(strafica)

age_groups = dfsas(age_group=0:5,
                   age_group_name=c("missing",
                                    "7-17",
                                    "18-29",
                                    "30-49",
                                    "50-64",
                                    "65-"))
geographies = dfsas(geography=1:5,
                    geography_name=c("Helsingin kantakaupunki",
                                     "muu Helsinki",
                                     "Espoo-Kauniainen",
                                     "Vantaa",
                                     "kehyskunnat"))


observations = load1(ancfile("primary/observations.RData"))

background = load1(ancfile("primary/background.RData"))
background = subset(background, survey %in% 0 & (rzone_capital_region | rzone_surrounding_municipality))
background$age_group = NA
background$age_group = ifelse(background$age_7_17 %in% 1, 1, background$age_group)
background$age_group = ifelse(background$age_18_29 %in% 1, 2, background$age_group)
background$age_group = ifelse(background$age_30_49 %in% 1, 3, background$age_group)
background$age_group = ifelse(background$age_50_64 %in% 1, 4, background$age_group)
background$age_group = ifelse(background$age_65 %in% 1, 5, background$age_group)
background$age_group = ifelse(background$age_missing %in% 1, 0, background$age_group)

zones = read.csv2(ancfile("area/zones.csv"), stringsAsFactors=FALSE, fileEncoding="utf-8")
zones$geography = NA
zones$geography = ifelse(zones$cbd %in% 1, 1, zones$geography)
zones$geography = ifelse(zones$cbd %in% 0 & zones$municipality_name %in% "Helsinki", 2, zones$geography)
zones$geography = ifelse(zones$municipality_name %in% c("Espoo","Kauniainen"), 3, zones$geography)
zones$geography = ifelse(zones$municipality_name %in% c("Vantaa"), 4, zones$geography)
zones$geography = ifelse(zones$surrounding_municipality %in% 1, 5, zones$geography)
zones = pick(zones, zone, geography)
zones = rename(zones, zone=rzone)

background = leftjoin(background, zones, by="rzone")

observations = fold(observations, .(pid), no_of_homebased_tours=sum(ttype %in% 1:5))
observations$no_of_homebased_tours = pclip(observations$no_of_homebased_tours, xmax=4)
stopifnot(all(observations$pid %in% background$pid))

stat = leftjoin(background, observations, by="pid", missing=0)
stat = fold(stat, .(age_group, no_of_homebased_tours, geography), xfactor=sum(xfactor), n=length(pid))

all = expand.grid(age_group=1:5,
                  no_of_homebased_tours=0:4,
                  geography=1:5)
all = leftjoin(all, stat, missing=0)
all = arrange(all, age_group, no_of_homebased_tours)
all = leftjoin(all, age_groups)
all = leftjoin(all, geographies)

write.csv2(all, file="no_of_tours_by_age_and_area.csv", row.names=FALSE)
