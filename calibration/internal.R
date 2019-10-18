# -*- coding: utf-8-unix -*-
library(strafica)

###
### Internal and external trips
###

tours$internal = (tours$izone==tours$jzone)

internal = fold(tours, .(survey, internal),
                xfactor=sum(xfactor))
internal_district = fold(tours, .(survey, internal, idistrict, jdistrict),
                         xfactor=sum(xfactor))
internal_model_type = fold(tours, .(survey, internal, model_type),
                           xfactor=sum(xfactor))

internal_mode = fold(tours, .(survey, internal, mode_name),
                     xfactor=sum(xfactor))
internal_mode = add_mode_share(internal_mode, internal)
