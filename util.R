# -*- coding: utf-8-unix -*-
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


write_alogit = function(x, fname, sep=" ", accuracy=0.01) {
    x = round(as.matrix(x), digits=2)
    x = t(apply(x, 1, formatC, format="fg"))
    write.table(x,
                file=fname,
                quote=FALSE,
                sep=sep,
                row.names=FALSE,
                col.names=FALSE)
    return(invisible())
}


#' Get age groups from age vector.
#' 
#' @param x Age vector.
#' @param pid Person ID vector.
#' @return A data frame with first column being \code{pid} and other columns
#'   being age group columns.
get_age_groups = function(x, pid) {
    stopifnot(is.integer(x))
    df = data.frame(pid=pid)
    df$age_7_17 = ifelse(x >= 7 & x <= 17, 1, 0)
    df$age_18_29 = ifelse(x >= 18 & x <= 29, 1, 0)
    df$age_30_49 = ifelse(x >= 30 & x <= 49, 1, 0)
    df$age_50_64 = ifelse(x >= 50 & x <= 64, 1, 0)
    df$age_65 = ifelse(x >= 65, 1, 0)
    df$age_missing = ifelse(is.na(x) | x < 7, 9, 0)
    return(df)
}
