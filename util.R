# -*- coding: windows-1252-dos -*-
library(strafica)

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
    patterns = c("^(1 - [27])",
                 "^(1 - 3)",
                 "^(1 - 4)",
                 "^(1 - 5)",
                 "^1$|^(1 - [16])",
                 "^2$|^(2 - [1234567])")
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

# from alternatives.R
check_class = function(x, exclude=NA) {
    cnames = colnames(x)
    classes = sapply(x, class)
    scnames = pad(cnames, n=max(nchar(cnames)))
    sclasses = pad(classes, n=max(nchar(classes)))
    message("Checking data frame for classes...")
    for (i in seq_along(cnames)) {
        if (classes[i] %in% exclude) next
        messagef(" %s: %s",
                 scnames[i], sclasses[i])
    }
}
