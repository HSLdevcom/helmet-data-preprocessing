# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

# This scripts writes all background data that is needed from respondents. This
# is done separately to avoid having survey-specific columns names in too many
# places... All people are handled whether or not they make any tours.

zones = read.csv2(ancfile("area/zones.csv"), stringsAsFactors=FALSE)

background = list()

# HEHA 2018

message("Formatting HEHA 2018 personal data...")
people = read.csv2(ancfile("survey/tausta-heha.csv"), stringsAsFactors=FALSE)
people = subset(people, rzone %in% zones$zone_orig)

df = data.frame(pid=people$pid)
df$year = 2018
df$survey = 0
df$xfactor = people$xfactor
df$cars_owned = NA
df$cars_owned = ifelse(people$montako_autoa == 0, 0, df$cars_owned)
df$cars_owned = ifelse(people$montako_autoa == 1, 1, df$cars_owned)
df$cars_owned = ifelse(people$montako_autoa >= 2, 2, df$cars_owned)
df$cars_owned = ifelse(is.na(people$montako_autoa), 9, df$cars_owned)
df$minor = ifelse(!is.na(people$ika) & people$ika <= 17, TRUE, FALSE)
df$licence = NA
df$licence = ifelse(people$onko_ajokortti == 1, 1, 0)
df$licence = ifelse(df$minor, 0, df$licence)
df$licence = ifelse(is.na(df$licence), 9, df$licence)
df$car_user = NA
df$car_user = ifelse(df$cars_owned %in% c(1,2) &
                         df$licence == 1 &
                         people$miten_usein_auto_kaytettavissa == "Aina tai melkein aina" &
                         !df$minor, 1, 0)
df$car_user = ifelse(is.na(df$car_user), 9, df$car_user)
df$employed = NA
df$employed = ifelse(people$toimi == "Työssäkäyvä", 1, 0)
df$employed = ifelse(df$minor & is.na(people$toimi), 0, df$employed)
df$employed = ifelse(is.na(df$employed), 9, df$employed)
df = unpick(df, minor)
df$children = NA
df$children = ifelse(people$kotitalous_0_6v > 0, 1, 0)
df$children = ifelse(is.na(people$kotitalous_0_6v), 9, df$children)
df$female = ifelse(people$sukup_laaj == "Nainen", 1, 0)
df = leftjoin(df, get_age_groups(people$ika, df$pid), by="pid")

df$lippu_hsl_kausi = ifelse(people$lippu_hsl_kausi == "Kyllä", 1, 0)
df$lippu_hsl_arvo = ifelse(people$lippu_hsl_arvo == "Kyllä", 1, 0)
df$lippu_mobiililippu = ifelse(people$lippu_mobiililippu == "Kyllä", 1, 0)
df$lippu_muu_kausi = ifelse(people$lippu_muu_kausi == "Kyllä", 1, 0)
df$lippu_muu_arvo = ifelse(people$lippu_muu_arvo == "Kyllä", 1, 0)

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
