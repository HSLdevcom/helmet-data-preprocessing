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

all = expand.grid(idistrict=unique(tours_model_type_mode$idistrict),
                  jdistrict=unique(tours_model_type_mode$jdistrict),
                  model_type=models,
                  mode_name=modes,
                  stringsAsFactors=FALSE)
all = arrange(all, idistrict, jdistrict, model_type, mode_name)
all = subset(all, !(model_type %in% c("hwp","hop","oop") & mode_name %in% c("walk","bike")))
all = fulljoin(all, tours_model_type_mode)
all$weight[is.na(all$weight)] = 0
all$modesh[is.na(all$modesh)] = 0
check.na(all)
save(all, file="demand.RData")
