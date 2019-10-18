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


tours = load1("tours.RData")
model_types = read.delims("models.txt")
modes = read.delims("modes.txt")
zones = read.csv2(ancfile("area/zones.csv"))


###
### Trips
###

fold(tours, .(survey, idistrict, jdistrict, model_type, mode_name),
     n=length(pid),
     xfactor=sum(xfactor))

tours_district = fold(tours, .(survey, idistrict, jdistrict), xfactor=sum(xfactor))

tours_model_type = fold(tours, .(survey, idistrict, jdistrict, model_type),
                       xfactor=sum(xfactor))

tours_model_type_mode = fold(tours, .(survey, idistrict, jdistrict, model_type, mode_name),
                            xfactor=sum(xfactor))
tours_model_type_mode = add_mode_share(tours_model_type_mode, tours_model_type)

models = unique(model_types$model_type)
modes = unique(modes$mode_name)
for (i in seq_along(models)) {
    for (j in seq_along(modes)) {
        output = subset(tours_model_type_mode,
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

tours_mode = fold(tours, .(survey, idistrict, jdistrict, mode_name),
                 xfactor=sum(xfactor))
tours_mode = add_mode_share(tours_mode, tours_district)
