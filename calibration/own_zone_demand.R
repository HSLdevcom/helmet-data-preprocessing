# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

tours = load1("tours.RData")
model_types = read.delims("models.txt")
modes = read.delims("modes.txt")
zones = read.csv2(ancfile("area/zones.csv"))
tours = subset(tours, izone==jzone)


###
### Internal and external tours
###

internal_model_type = fold(tours, .(model_type),
                           weight=sum(weight))

internal_model_type_mode = fold(tours, .(model_type, mode_name),
                     weight=sum(weight))
internal_model_type_mode = add_mode_share(internal_model_type_mode, internal_model_type)

###
### Districts
###

internal_district_model_type = fold(tours, .(idistrict, jdistrict, model_type),
                           weight=sum(weight))

internal_district_model_type_mode = fold(tours, .(idistrict, jdistrict, model_type, mode_name),
                                weight=sum(weight))
internal_district_model_type_mode = add_mode_share(internal_district_model_type_mode, internal_district_model_type)

stopifnot(all(internal_district_model_type_mode$idistrict==internal_district_model_type_mode$jdistrict))

models = unique(model_types$model_type)
mode_names = unique(modes$mode_name)
for (i in seq_along(models)) {
    output = subset(internal_district_model_type_mode,
                    model_type %in% models[i])
    stitle = sprintf("own_zone_demand-%s", models[i])
    square = as_square_matrix(output,
                              from="idistrict",
                              to="mode_name",
                              value="weight",
                              from_names=unique(zones$district),
                              to_names=mode_names,
                              matrix_title=stitle)
    write.delim(square, fname=sprintf("output/%s.txt", stitle))
}
