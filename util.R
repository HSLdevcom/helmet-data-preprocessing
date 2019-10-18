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


#' Check whether origin and primary destination have been inverted
#'
#' @param x Order of visits to origin (A), primary destination (B), and
#'   secondary destination (C)
#' @return A logical vector indicating whether the original tour was made from
#'   origin to primary destination or if the order was inverted.
is_inverted = function(x) {
    # Check that the format of x is correct
    stopifnot(all(x %in% c("A","AB","BA","ABC","ACB","BAC","BCA","CAB","CBA")))
    # Check inversion (B is visited before A)
    result = x %in% c("BA","BAC","BCA","CBA")
    return(result)
}


#' Get value from a matrix
#'
#' @param x A square matrix.
#' @param from Zone ID of the starting zone. Default is all zones.
#' @param to Zone ID of the ending zone. Default is all zones.
#' @return A matrix. Returns a 1x1 matrix when both `from` and `to` are scalars.
#'   Returns a 1xN row matrix when `from` is a vector and `to` is a scalar.
#'   Returns a Mx1 column matrix when `from` is a scalar and `to` is a vector.
#'   Returns a MxN matrix when both `from` and `to` are vectors.
get_matrix_value = function(x, from=seq(nrow(x)), to=seq(ncol(x))) {
    stopifnot(is.matrix(x))
    stopifnot(nrow(x)==ncol(x))
    return(x[from, to, drop=FALSE])
}


#' Get value from an impedance matrix
get_impedance = function(x, from=seq(nrow(x)), to=seq(ncol(x))) {
    return(get_matrix_value(x, from=from, to=to))
}


#' Spread data frame as square matrix
#' 
#' @param df Data frame.
#' @param from Name of the column which specifies unique rows.
#' @param to Name of the column which specifies unique columns.
#' @param value Name of the columns from which values are read from.
#' @param snames Names of the classes in from and to columns in correct order.
#' @param stitle Title of the square matrix.
#' @return A square data frame.
as_square_matrix = function(df, from, to, value, snames, stitle="square") {
    cols = c(from, to, value)
    df = df[, cols]
    df0 = expand.grid(x=snames, y=snames)
    colnames(df0) = c(from, to)
    df = leftjoin(df0, df, missing=0)
    df = tidyr::spread(df, key=to, value=value, fill=0)
    # Sort rows
    df = df[match(snames, df[, 1]), ]
    # Sort columns
    sorder = match(snames, colnames(df)[-1]) + 1
    df = df[, c(1, sorder)]
    # Rename first column
    colnames(df) = c(stitle, colnames(df)[-1])
    return(df)
}
