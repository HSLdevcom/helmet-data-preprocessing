# -*- coding: utf-8-unix -*-
library(strafica)

###
### Length
###

tours$length_class = apply.breaks(tours$length,
                                  class=c(0, 1, 3, 5, 10, 20),
                                  lower=c(0, 1, 3, 5, 10, 20),
                                  upper=c(1, 3, 5, 10, 20, Inf))
stopifnot(all(!is.na(tours$length_class)))

# Onko kaikki pituuden HA-pituuksia?

length_model_type = fold(tours, .(survey, length, model_type),
                         xfactor=sum(xfactor))
length_model_type_mode = fold(tours, .(survey, length, model_type, mode_name),
                              xfactor=sum(xfactor))
length_model_type_mode = add_mode_share(length_model_type_mode, length_model_type)
