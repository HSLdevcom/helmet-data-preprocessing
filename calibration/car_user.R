# -*- coding: utf-8-unix -*-
library(strafica)

zones = read.csv2(ancfile("area/zones.csv"), stringsAsFactors=FALSE)

people0 = load1(ancfile("metropolitan/primary/background.RData"))
people0 = subset(people0, rzone_capital_region %in% 1 | rzone_surrounding_municipality %in% 1)

people2 = load1(ancfile("peripheral/primary/background.RData"))
people2 = subset(people2, rzone_peripheral_municipality  %in% 1)

people = rbind_list(people0, people2)
m = match(people$rzone, zones$zone)
people$municipality = zones$municipality[m]
people$municipality_name = zones$municipality_name[m]
people$cbd = zones$cbd[m]
people$suburb = zones$suburb[m]

m1 = which(people$cbd & people$municipality_name %in% "Helsinki")
m2 = which(people$suburb & people$municipality_name %in% "Helsinki")
people$municipality_name[m1] = "Helsingin kantakaupunki"
people$municipality_name[m2] = "Helsingin esikaupunkialue"

stat = fold(people, .(municipality, municipality_name),
     car_user_0=sum(xfactor[car_user %in% 0]),
     car_user_1=sum(xfactor[car_user %in% 1]),
     car_user_9=sum(xfactor[car_user %in% 9]))
stat$car_user_share = stat$car_user_1 / (stat$car_user_0 + stat$car_user_1)

save(stat, file="car_user.RData")
