# -*- coding: windows-1252-dos -*-
library(strafica)
library(readxl)


#' Get tour classes from tour types.
#' 
#' @param x A character vector of tour types (\code{tour_type}) as defined in \code{tours/output} files.
#' @param y A logical vector of whether tour is constructed or not.
#' @return An integer vector of which tour class does the tour belong to.
get_ttype = function(x, y) {
    stopifnot(is.character(x))
    stopifnot(is.logical(y))
    classes = rep(NA, times=length(x))
    # Seven classes for survey tours
    patterns = c("^(1 - 2)",
                 "^(1 - 3)",
                 "^(1 - 4)",
                 "^(1 - 5)",
                 "^1$|^(1 - [16])",
                 "^2$|^(2 - [123456])")
    for (i in seq(patterns)) {
        m = grepl(patterns[i], x, perl=TRUE)
        classes[m] = i
    }
    m = is.na(classes)
    classes[m] = 7
    # Two classes for constructed tours
    m = (y & classes == 1)
    classes[m] = 8
    m = (y & classes != 8)
    classes[m] = 9
    return(classes)
}


#' Get peak hour from timestamps.
#' 
#' @param x A character vector with timestamps of format \code{%H:%M:%S}.
#' @return An character vector of which peak hour does the timestamp belong to.
get_peak = function(x) {
    peak = apply.breaks(x,
                        class=c("morning","afternoon"),
                        c("06:00:00","15:00:00"),
                        c("08:59:59","17:59:59"))
    m = which(is.na(peak))
    peak[m] = "other"
    m = which(x == "")
    peak[m] = NA
    return(peak)
}

zones = load1("zones.RData")
background = load1("background.RData")

input = read.delims("input.txt")

message("Formatting tour data...")

for (i in rows.along(input)) {
    
    message(sprintf("%d/%d: %s", i, nrow(input), input$file[i]))
    tours = load1(input$file[i])
    
    observations = data.frame(pid=tours$pid)
    observations$mode = tours$mode
    observations$ttype = get_ttype(tours$tour_type,
                                   tours$constructed)
    observations$other_destinations = ifelse(rowSums(tours[, grepl("^visits_t", colnames(tours), perl=TRUE)]) > 2, 1, 0)
    observations$closed = ifelse(tours$closed, 1, 2)
    
    m = match(tours$zone_origin, zones$zone_orig)
    observations$izone = zones$zone[m]
    observations$izone_cbd = ifelse(zones$cbd[m]==1, 1, 0)
    observations$izone_population_density = zones$population_density[m]
    observations$izone_job_density = zones$job_density[m]
    observations$izone_housing = zones$housing[m]
    observations$izone_parking_fee_other = zones$parking_fee_other[m]
    observations$izone_cars_per_people = zones$cars_per_people[m]
    
    m = match(tours$zone_destination, zones$zone_orig)
    observations$jzone = zones$zone[m]
    
    observations$ipeak = get_peak(tours$itime_origin)
    observations$jpeak = get_peak(tours$itime_destination)
    
    # If tour visits only one place and returns to it, do not interpret a return
    # time slot.
    m = which(rowSums(tours[,grep("^visits_t[0-9]+", colnames(tours))]) == 1)
    observations$jpeak[m] = NA
    
    if (unique(tours$year) == 2016) {
        mtypes = read.delims("mtypes-peripheral.txt")
        observations = leftjoin(observations, mtypes)
    } else if (unique(tours$year) == 2018) {
        mtypes = read.delims("mtypes-metropolitan.txt")
        observations = leftjoin(observations, mtypes)
    }
    
    m = match(tours$zone_secondary_destination, zones$zone_orig)
    observations$kzone = zones$zone[m]
    
    # Add background information
    observations = leftjoin(observations, background)
    
    # Output
    observations = downclass(observations)
    check.na(observations)
    fname = sprintf("observations-%s.RData", input$name[i])
    save(observations, file=fname)
}
