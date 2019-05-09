# -*- coding: windows-1252-dos -*-
library(strafica)
library(readxl)

zones = load1("zones.RData")

observations = list()
background_information = list()

# Tour

message("Formatting tour data...")

tours1 = read.csv2(ancfile("tours/output/tours-heha.csv"),
                   stringsAsFactors=FALSE)
tours2 = read.csv2(ancfile("tours/output/tours-hlt.csv"),
                   stringsAsFactors=FALSE)
tours = rbind_list(tours1, tours2)

df = data.frame(pid=tours$pid)
df$mode = tours$mode
df$ttype = NA
m = grepl("^(1 - 2)", tours$tour_type, perl=TRUE)
df$ttype[m] = 1
m = grepl("^(1 - 3)", tours$tour_type, perl=TRUE)
df$ttype[m] = 2
m = grepl("^(1 - 4)", tours$tour_type, perl=TRUE)
df$ttype[m] = 3
m = grepl("^(1 - 5)", tours$tour_type, perl=TRUE)
df$ttype[m] = 4
m = grepl("^1$|^(1 - [16])", tours$tour_type, perl=TRUE)
df$ttype[m] = 5
m = grepl("^2$|^(2 - [123456])", tours$tour_type, perl=TRUE)
df$ttype[m] = 6
m = is.na(df$ttype)
df$ttype[m] = 7
df$other_destinations = ifelse(rowSums(tours[, grepl("^visits_t", colnames(tours), perl=TRUE)]) > 2, 1, 0)
df$closed = ifelse(tours$closed, 1, 2)

m = match(tours$zone_origin, zones$zone_orig)
df$izone = zones$zone[m]
df$izone_cbd = ifelse(zones$cbd[m]==1, 1, 0)
df$izone_population_density = zones$population_density[m]
df$izone_housing = zones$housing[m]
df$izone_parking_fee_other = zones$parking_fee_other[m]
df$izone_cars_per_people = zones$cars_per_people[m]

m = match(tours$zone_destination, zones$zone_orig)
df$jzone = zones$zone[m]

df$ipeak = apply.breaks(tours$itime_origin,
                           class=c("morning","afternoon"),
                           c("06:00:00","15:00:00"),
                           c("08:59:59","17:59:59"))
m = which(is.na(df$ipeak))
df$ipeak[m] = "other"
m = which(tours$itime_origin == "")
df$ipeak[m] = NA

df$jpeak = apply.breaks(tours$itime_destination,
                           class=c("morning","afternoon"),
                           c("06:00:00","15:00:00"),
                           c("08:59:59","17:59:59"))
m = which(is.na(df$jpeak))
df$jpeak[m] = "other"
m = which(tours$itime_destination == "")
df$jpeak[m] = NA

# If tour visits only one place and returns to it, do not interpret a return
# time slot.
m = which(rowSums(tours[,grep("^visits_t[0-9]+", colnames(tours))]) == 1)
df$jpeak[m] = NA

df$mtype = ifelse(df$ttype==1,
                  "hbwork",
                  ifelse(df$ttype %in% c(2,3,4,5),
                         "hbother",
                         "nhb"))

observations = rbind_list(observations, df)

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

background_information = rbind_list(background_information, df)

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

background_information = rbind_list(background_information, df)

# Add personal data to tours

stopifnot(length(unique(background_information$pid)) == nrow(background_information))
observations = leftjoin(observations, background_information)

observations = downclass(observations)
check.na(observations)
save(observations, file="observations.RData")
