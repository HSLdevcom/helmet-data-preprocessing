# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

add_mode_share = function(df_with_modes, df_without_modes) {
    df_without_modes = rename(df_without_modes, xfactor=xfactor_all)
    df_with_modes = leftjoin(df_with_modes, df_without_modes)
    df_with_modes$modesh = df_with_modes$xfactor / df_with_modes$xfactor_all
    df_with_modes = unpick(df_with_modes, xfactor_all)
    return(df_with_modes)
}

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

observations1 = load1(ancfile("metropolitan/primary/observations.RData"))
observations2 = load1(ancfile("peripheral/primary/observations.RData"))
data = rbind_list(observations1, observations2)
data = pick(data,
            pid,
            mode,
            ttype,
            survey,
            xfactor,
            izone,
            jzone,
            closed,
            order)
data$inverted = is_inverted(data$order)

data$old_izone = data$izone
data$old_jzone = data$jzone
data$izone = ifelse(data$inverted, data$old_jzone, data$old_izone)
data$jzone = ifelse(data$inverted, data$old_izone, data$old_jzone)

model_types = read.delims("models.txt")
data = leftjoin(data, model_types)

zones = read.csv2(ancfile("area/zones.csv"))
data$idistrict = zones$district[match(data$izone, zones$zone)]
data$jdistrict = zones$district[match(data$jzone, zones$zone)]

modes = read.delims("modes.txt")
data = leftjoin(data, modes)
data = unpick(data, mode)


###
### Trips
###

fold(data, .(survey, idistrict, jdistrict, model_type, mode_name),
     n=length(pid),
     xfactor=sum(xfactor))

data_district = fold(data, .(survey, idistrict, jdistrict), xfactor=sum(xfactor))

data_model_type = fold(data, .(survey, idistrict, jdistrict, model_type),
                       xfactor=sum(xfactor))

data_model_type_mode = fold(data, .(survey, idistrict, jdistrict, model_type, mode_name),
                            xfactor=sum(xfactor))
data_model_type_mode = add_mode_share(data_model_type_mode, data_model_type)

models = unique(model_types$model_type)
modes = unique(modes$mode_name)
for (i in seq_along(models)) {
    for (j in seq_along(modes)) {
        output = subset(data_model_type_mode,
                        model_type %in% models[i] & mode_name %in% modes[j])
        print(as_square_matrix(output,
                               from="idistrict",
                               to="jdistrict",
                               value="xfactor",
                               snames=unique(zones$district),
                               stitle=sprintf("demand-%s-%s",
                                              models[i],
                                              modes[j])))
        print(as_square_matrix(output,
                               from="idistrict",
                               to="jdistrict",
                               value="modesh",
                               snames=unique(zones$district),
                               stitle=sprintf("modesh-%s-%s",
                                              models[i],
                                              modes[j])))
    }
}

data_mode = fold(data, .(survey, idistrict, jdistrict, mode_name),
                 xfactor=sum(xfactor))
data_mode = add_mode_share(data_mode, data_district)


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
length_model_type_mode = fold(data, .(survey, length, model_type, mode_name),
                              xfactor=sum(xfactor))
length_model_type_mode = add_mode_share(length_model_type_mode, length_model_type)


###
### Internal and external trips
###

data$internal = (data$izone==data$jzone)

internal = fold(data, .(survey, internal),
                xfactor=sum(xfactor))
internal_district = fold(data, .(survey, internal, idistrict, jdistrict),
                     xfactor=sum(xfactor))
internal_model_type = fold(data, .(survey, internal, model_type),
                           xfactor=sum(xfactor))

internal_mode = fold(data, .(survey, internal, mode_name),
                     xfactor=sum(xfactor))
internal_mode = add_mode_share(internal_mode, internal)
