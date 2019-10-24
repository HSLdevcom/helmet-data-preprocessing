# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

tours = load1("tours.RData")
zones = read.csv2(ancfile("area/zones.csv"))
model_types = read.delims("models.txt")
modes = read.delims("modes.txt")

###
### Length
###

length_class_names = c("0-1", "1-3", "3-5", "5-10", "10-20", "20--")
tours$length_class = apply.breaks(tours$length,
                                  class=length_class_names,
                                  lower=c(0, 1, 3, 5, 10, 20),
                                  upper=c(1, 3, 5, 10, 20, Inf))
stopifnot(all(!is.na(tours$length_class)))

# Onko kaikki pituuden HA-pituuksia?

length_all = fold(tours, .(length_class, model_type),
                  weight=sum(weight))

length_model_type = fold(tours, .(length_class, model_type),
                         weight=sum(weight))
length_model_type_mode = fold(tours, .(length_class, model_type, mode_name),
                              weight=sum(weight))
length_model_type_mode = add_mode_share(length_model_type_mode, length_model_type)

models = unique(model_types$model_type)
mode_names = unique(modes$mode_name)
for (i in seq_along(models)) {
    output = subset(length_model_type_mode,
                    model_type %in% models[i])
    stitle = sprintf("length-%s", models[i])
    square = as_square_matrix(output,
                              from="length_class",
                              to="mode_name",
                              value="weight",
                              from_names=length_class_names,
                              to_names=mode_names,
                              matrix_title=stitle)
    write.delim(square, fname=sprintf("output/%s.txt", stitle))
}
