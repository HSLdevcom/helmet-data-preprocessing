# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

# This scripts writes all background data that is needed from respondents. This
# is done separately to avoid having survey-specific columns names in too many
# places... All people are handled whether or not they make any tours.

zones = read.csv2(ancfile("area/zones.csv"), stringsAsFactors=FALSE)

background = list()

# HLT 2016

message("Formatting HLT 2016 personal data...")
people = read.csv2(ancfile("survey/tausta-hlt.csv"), stringsAsFactors=FALSE)
people = subset(people, rzone %in% zones$zone_orig)

df = data.frame(pid=people$pid)
df$year = 2016
df$survey = 2
df$xfactor = people$xfactor
df$cars_owned = NA
df$cars_owned = ifelse(people$T_AUTOT == 0, 0, df$cars_owned)
df$cars_owned = ifelse(people$T_AUTOT == 1, 1, df$cars_owned)
df$cars_owned = ifelse(people$T_AUTOT >= 2, 2, df$cars_owned)
df$cars_owned = ifelse(is.na(people$T_AUTOT), 9, df$cars_owned)
df$minor = ifelse(!is.na(people$T_IKA) & people$T_IKA <= 17, TRUE, FALSE)
df$licence = NA
df$licence = ifelse(people$T_AJOKORTTI == 1, 1, 0)
df$licence = ifelse(df$minor, 0, df$licence)
df$licence = ifelse(is.na(df$licence), 9, df$licence)
df$car_user = NA
df$car_user = ifelse(df$cars_owned %in% c(1,2) &
                         df$licence == 1 &
                         people$T_HAKULJ == 1 &
                         !df$minor, 1, 0)
df$car_user = ifelse(is.na(df$car_user), 9, df$car_user)
df$employed = NA
df$employed = ifelse(people$T_ANSIOTYO %in% c(1,2), 1, 0)
df$employed = ifelse(df$minor & is.na(people$T_ANSIOTYO), 0, df$employed)
df$employed = ifelse(is.na(df$employed), 9, df$employed)
df = unpick(df, minor)
df$children = NA
df$children = ifelse(people$T_0_6V > 0, 1, 0)
df$children = ifelse(is.na(people$T_0_6V), 9, df$children)
df$female = ifelse(people$T_SUKUPUOLI == 2, 1, 0)
df = leftjoin(df, get_age_groups(people$T_IKA, df$pid), by="pid")

m = match(people$rzone, zones$zone_orig)
df$rzone = zones$zone[m]
df$rzone_capital_region = ifelse(zones$capital_region[m], 1, 0)
df$rzone_surrounding_municipality = ifelse(zones$surrounding_municipality[m], 1, 0)
df$rzone_peripheral_municipality = ifelse(zones$peripheral_municipality[m], 1, 0)
df$rzone_income_person = zones$income_person[m]
df$rzone_income_household = zones$income_household[m]

# Add personal data to tours
background = rbind_list(background, df)

stopifnot(length(unique(background$pid)) == nrow(background))
background = downclass(background)
check.na(background)
save(background, file="background.RData")
