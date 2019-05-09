# -*- coding: windows-1252-dos -*-
library(strafica)
library(readxl)

zones = load1("zones.RData")
background = load1("background.RData")

observations = list()

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


observations = leftjoin(observations, background)

observations = downclass(observations)
check.na(observations)
save(observations, file="observations.RData")
