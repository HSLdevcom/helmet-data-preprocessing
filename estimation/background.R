# -*- coding: windows-1252-dos -*-
library(strafica)

# This scripts writes all background data that is needed from respondents. This
# is done separately to avoid having survey-specific columns names in too many
# places... All people are handled whether or not they make any tours.

zones = load1("zones.RData")

background = list()

# HEHA 2018

message("Formatting HEHA 2018 personal data...")
people = read.csv2(ancfile("input/tausta-heha.csv"), stringsAsFactors=FALSE)

df = data.frame(pid=people$pid)
df$year = 2018
df$survey = 0
df$xfactor = people$paino6
df$cars_owned = NA
df$cars_owned = ifelse(people$montako_autoa == 0, 0, df$cars_owned)
df$cars_owned = ifelse(people$montako_autoa == 1, 1, df$cars_owned)
df$cars_owned = ifelse(people$montako_autoa >= 2, 2, df$cars_owned)
df$cars_owned = ifelse(is.na(people$montako_autoa), 9, df$cars_owned)
df$minor = ifelse(!is.na(people$ika) & people$ika <= 17, TRUE, FALSE)
df$licence = NA
df$licence = ifelse(people$onko_ajokortti == 1, 1, 0)
df$licence = ifelse(df$minor, 0, df$licence)
df$licence = ifelse(is.na(people$onko_ajokortti), 9, df$licence)
df$car_user = NA
df$car_user = ifelse(df$cars_owned %in% c(1,2) &
                         df$licence == 1 &
                         people$miten_usein_auto_kaytettavissa == "Aina tai melkein aina" &
                         !df$minor, 1, 0)
df$car_user = ifelse(is.na(df$car_user), 9, df$car_user)
df$employed = NA
df$employed = ifelse(people$toimi == "Työssäkäyvä", 1, 0)
df$employed = ifelse(df$minor & is.na(people$toimi), 0, df$employed)
df$employed = ifelse(is.na(people$toimi), 9, df$employed)
df = unpick(df, minor)
df$children = NA
df$children = ifelse(people$kotitalous_0_6v > 0, 1, 0)
df$children = ifelse(is.na(people$kotitalous_0_6v), 9, df$children)
df$female = ifelse(people$sukup_laaj == "Nainen", 1, 0)
df$age_7_17 = ifelse(people$ika >= 7 & people$ika <= 17, 1, 0)
df$age_18_29 = ifelse(people$ika >= 18 & people$ika <= 29, 1, 0)
df$age_30_49 = ifelse(people$ika >= 30 & people$ika <= 49, 1, 0)
df$age_50_64 = ifelse(people$ika >= 50 & people$ika <= 64, 1, 0)
df$age_65 = ifelse(people$ika >= 65, 1, 0)
df$age_missing = ifelse(is.na(people$ika) | people$ika < 7, 9, 0)

m = match(people$ap_sij19, zones$zone_orig)
df$rzone = zones$zone[m]
df$rzone_capital_region = ifelse(zones$capital_region[m], 1, 0)
df$rzone_surrounding_municipality = ifelse(zones$surrounding_municipality[m], 1, 0)
df$rzone_peripheral_municipality = ifelse(zones$peripheral_municipality[m], 1, 0)

background = rbind_list(background, df)

# HEHA 2007-2008

message("Formatting HEHA 2007-2008 personal data...")

# HLT 2016

message("Formatting HLT 2016 personal data...")
people = read.csv2(ancfile("input/tausta-hlt.csv"), stringsAsFactors=FALSE)

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
df$licence = ifelse(is.na(people$T_AJOKORTTI), 9, df$licence)
df$car_user = NA
df$car_user = ifelse(df$cars_owned %in% c(1,2) &
                         df$licence == 1 &
                         people$T_HAKULJ == 1 &
                         !df$minor, 1, 0)
df$car_user = ifelse(is.na(df$car_user), 9, df$car_user)
df$employed = NA
df$employed = ifelse(people$T_ANSIOTYO %in% c(1,2), 1, 0)
df$employed = ifelse(df$minor & is.na(people$T_ANSIOTYO), 0, df$employed)
df$employed = ifelse(is.na(people$T_ANSIOTYO), 9, df$employed)
df = unpick(df, minor)
df$children = NA
df$children = ifelse(people$T_0_6V > 0, 1, 0)
df$children = ifelse(is.na(people$T_0_6V), 9, df$children)
df$female = ifelse(people$T_SUKUPUOLI == 2, 1, 0)
df$age_7_17 = ifelse(people$T_IKA >= 7 & people$T_IKA <= 17, 1, 0)
df$age_18_29 = ifelse(people$T_IKA >= 18 & people$T_IKA <= 29, 1, 0)
df$age_30_49 = ifelse(people$T_IKA >= 30 & people$T_IKA <= 49, 1, 0)
df$age_50_64 = ifelse(people$T_IKA >= 50 & people$T_IKA <= 64, 1, 0)
df$age_65 = ifelse(people$T_IKA >= 65, 1, 0)
df$age_missing = ifelse(is.na(people$T_IKA) | people$T_IKA < 7, 9, 0)

m = match(people$rsij2019, zones$zone_orig)
df$rzone = zones$zone[m]
df$rzone_capital_region = ifelse(zones$capital_region[m], 1, 0)
df$rzone_surrounding_municipality = ifelse(zones$surrounding_municipality[m], 1, 0)
df$rzone_peripheral_municipality = ifelse(zones$peripheral_municipality[m], 1, 0)

background = rbind_list(background, df)

# Add personal data to tours

stopifnot(length(unique(background$pid)) == nrow(background))
save(background, file="background.RData")
