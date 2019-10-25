# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

tours = load1("tours.RData")
model_types = read.delims("models.txt")
modes = read.delims("modes.txt")
zones = read.csv2(ancfile("area/zones.csv"))


###
### Tours
###

models = unique(model_types$model_type)
modes = unique(modes$mode_name)
districts = unique(zones$district)

tours_district = fold(tours, .(idistrict, jdistrict), weight=sum(weight))
stitle = sprintf("demand")
square = as_square_matrix(tours_district,
                          from="idistrict",
                          to="jdistrict",
                          value="weight",
                          from_names=districts,
                          to_names=districts,
                          matrix_title=stitle)
write.delim(square, fname=sprintf("output/%s.txt", stitle))

tours_model_type = fold(tours, .(idistrict, jdistrict, model_type),
                        weight=sum(weight))

for (i in seq_along(models)) {
    output = subset(tours_model_type,
                    model_type %in% models[i])
    stitle = sprintf("demand-%s-all", models[i])
    square = as_square_matrix(output,
                              from="idistrict",
                              to="jdistrict",
                              value="weight",
                              from_names=districts,
                              to_names=districts,
                              matrix_title=stitle)
    write.delim(square, fname=sprintf("output/%s.txt", stitle))
}

tours_mode = fold(tours, .(idistrict, jdistrict, mode_name),
                  weight=sum(weight))
tours_mode = add_mode_share(tours_mode, tours_district)

for (j in seq_along(modes)) {
    output = subset(tours_mode,
                    mode_name %in% modes[j])
    stitle = sprintf("demand-all-%s", modes[j])
    square = as_square_matrix(output,
                              from="idistrict",
                              to="jdistrict",
                              value="weight",
                              from_names=districts,
                              to_names=districts,
                              matrix_title=stitle)
    write.delim(square, fname=sprintf("output/%s.txt", stitle))
    stitle = sprintf("modesh-all-%s", modes[j])
    square = as_square_matrix(output,
                              from="idistrict",
                              to="jdistrict",
                              value="modesh",
                              from_names=districts,
                              to_names=districts,
                              matrix_title=stitle)
    write.delim(square, fname=sprintf("output/%s.txt", stitle))
}

tours_model_type_mode = fold(tours, .(idistrict, jdistrict, model_type, mode_name),
                            weight=sum(weight))
tours_model_type_mode = add_mode_share(tours_model_type_mode, tours_model_type)

for (i in seq_along(models)) {
    for (j in seq_along(modes)) {
        output = subset(tours_model_type_mode,
                        model_type %in% models[i] & mode_name %in% modes[j])
        stitle = sprintf("demand-%s-%s", models[i], modes[j])
        square = as_square_matrix(output,
                               from="idistrict",
                               to="jdistrict",
                               value="weight",
                               from_names=districts,
                               to_names=districts,
                               matrix_title=stitle)
        write.delim(square, fname=sprintf("output/%s.txt", stitle))
        stitle = sprintf("modesh-%s-%s", models[i], modes[j])
        square = as_square_matrix(output,
                               from="idistrict",
                               to="jdistrict",
                               value="modesh",
                               from_names=districts,
                               to_names=districts,
                               matrix_title=stitle)
        write.delim(square, fname=sprintf("output/%s.txt", stitle))
    }
}

save(tours_model_type_mode, file="demand.RData")
