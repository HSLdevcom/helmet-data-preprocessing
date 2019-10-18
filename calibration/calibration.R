# -*- coding: utf-8-unix -*-
library(strafica)

add_mode_share = function(df_with_modes, df_without_modes) {
    df_without_modes = rename(df_without_modes, xfactor=xfactor_all)
    df_with_modes = leftjoin(df_with_modes, df_without_modes)
    df_with_modes$modesh = df_with_modes$xfactor / df_with_modes$xfactor_all
    df_with_modes = unpick(df_with_modes, xfactor_all)
    return(df_with_modes)
}

m = which(data$mode %in% c(4, 5))
data$mode[m] = 45

###
### Trips
###

fold(data, .(survey, area1, area2, model_type, mode),
     n=length(pid),
     xfactor=sum(xfactor))

data_area = fold(data, .(survey, area1, area2), xfactor=sum(xfactor))

data_model_type = fold(data, .(survey, area1, area2, model_type),
                       xfactor=sum(xfactor))

data_model_type_mode = fold(data, .(survey, area1, area2, model_type, mode),
                            xfactor=sum(xfactor))
data_model_type_mode = add_mode_share(data_model_type_mode, data_model_type)

data_mode = fold(data, .(survey, area1, area2, mode),
                 xfactor=sum(xfactor))
data_mode = add_mode_share(data_mode, data_area)

# Plus sama sen tiedon kanssa, onko koti-työ vai työ-koti!


###
### Length
###

data$length_class = apply.breaks(data$length,
                                 class=c(0, 1, 3, 5, 10, 20),
                                 lower=c(0, 1, 3, 5, 10, 20),
                                 upper=c(1, 3, 5, 10, 20, Inf))
stopifnot(all(!is.na(data$length_class)))

# Onko kaikki pituuden HA-pituuksia?

length_model_type = fold(data, .(survey, length, model_type),
                         xfactor=sum(xfactor))
length_model_type_mode = fold(data, .(survey, length, model_type, mode),
                              xfactor=sum(xfactor))
length_model_type_mode = add_mode_share(length_model_type_mode, length_model_type)


###
### Internal and external trips
###

data$internal = (data$izone==data$jzone)

internal = fold(data, .(survey, internal),
                xfactor=sum(xfactor))
internal_area = fold(data, .(survey, internal, area1, area2),
                     xfactor=sum(xfactor))
internal_model_type = fold(data, .(survey, internal, model_type),
                           xfactor=sum(xfactor))

internal_mode = fold(data, .(survey, internal, mode),
                     xfactor=sum(xfactor))
internal_mode = add_mode_share(internal_mode, internal)
