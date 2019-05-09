# -*- coding: windows-1252-dos -*-
library(strafica)
library(readxl)

zones = load1("zones.RData")
background = load1("background.RData")

input = read.delims("input.txt")

message("Formatting tour data...")

for (i in rows.along(input)) {
    
    message(sprintf("%d/%d: %s", i, nrow(input), input$file[i]))
    tours = load1(input$file[i])
    
    observations = data.frame(pid=tours$pid)
    observations$mode = tours$mode
    observations$ttype = NA
    m = grepl("^(1 - 2)", tours$tour_type, perl=TRUE)
    observations$ttype[m] = 1
    m = grepl("^(1 - 3)", tours$tour_type, perl=TRUE)
    observations$ttype[m] = 2
    m = grepl("^(1 - 4)", tours$tour_type, perl=TRUE)
    observations$ttype[m] = 3
    m = grepl("^(1 - 5)", tours$tour_type, perl=TRUE)
    observations$ttype[m] = 4
    m = grepl("^1$|^(1 - [16])", tours$tour_type, perl=TRUE)
    observations$ttype[m] = 5
    m = grepl("^2$|^(2 - [123456])", tours$tour_type, perl=TRUE)
    observations$ttype[m] = 6
    m = is.na(observations$ttype)
    observations$ttype[m] = 7
    m = (observations$constructed & observations$ttype == 1)
    observations$ttype[m] = 8
    m = (observations$constructed & observations$ttype != 8)
    observations$ttype[m] = 9
    
    observations$other_destinations = ifelse(rowSums(tours[, grepl("^visits_t", colnames(tours), perl=TRUE)]) > 2, 1, 0)
    observations$closed = ifelse(tours$closed, 1, 2)
    
    m = match(tours$zone_origin, zones$zone_orig)
    observations$izone = zones$zone[m]
    observations$izone_cbd = ifelse(zones$cbd[m]==1, 1, 0)
    observations$izone_population_density = zones$population_density[m]
    observations$izone_housing = zones$housing[m]
    observations$izone_parking_fee_other = zones$parking_fee_other[m]
    observations$izone_cars_per_people = zones$cars_per_people[m]
    
    m = match(tours$zone_destination, zones$zone_orig)
    observations$jzone = zones$zone[m]
    
    observations$ipeak = apply.breaks(tours$itime_origin,
                            class=c("morning","afternoon"),
                            c("06:00:00","15:00:00"),
                            c("08:59:59","17:59:59"))
    m = which(is.na(observations$ipeak))
    observations$ipeak[m] = "other"
    m = which(tours$itime_origin == "")
    observations$ipeak[m] = NA
    
    observations$jpeak = apply.breaks(tours$itime_destination,
                            class=c("morning","afternoon"),
                            c("06:00:00","15:00:00"),
                            c("08:59:59","17:59:59"))
    m = which(is.na(observations$jpeak))
    observations$jpeak[m] = "other"
    m = which(tours$itime_destination == "")
    observations$jpeak[m] = NA
    
    # If tour visits only one place and returns to it, do not interpret a return
    # time slot.
    m = which(rowSums(tours[,grep("^visits_t[0-9]+", colnames(tours))]) == 1)
    observations$jpeak[m] = NA
    
    observations$mtype = ifelse(observations$ttype %in% c(1,8),
                      "hbwork",
                      ifelse(observations$ttype %in% c(2,3,4,5,9),
                             "hbother",
                             "nhb"))
    
    # Add background information
    observations = leftjoin(observations, background)
    
    # Output
    observations = downclass(observations)
    check.na(observations)
    fname = sprintf("observations-%s.RData", input$name[i])
    save(observations, file=fname)
}
