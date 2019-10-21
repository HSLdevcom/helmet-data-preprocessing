# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

tours = load1("tours.RData")
model_types = read.delims("models.txt")
modes = read.delims("modes.txt")
zones = read.csv2(ancfile("area/zones.csv"))
tours$internal = (tours$izone==tours$jzone)

###
### Internal and external tours
###

internal = fold(tours, .(internal),
                weight=sum(weight))

internal_mode = fold(tours, .(internal, mode_name),
                     weight=sum(weight))
internal_mode = add_mode_share(internal_mode, internal)

internal_model_type = fold(tours, .(internal, model_type),
                           weight=sum(weight))

internal_model_type_mode = fold(tours, .(internal, model_type, mode_name),
                     weight=sum(weight))
internal_model_type_mode = add_mode_share(internal_model_type_mode, internal_model_type)

###
### Districts
###


internal_district = fold(tours, .(internal, idistrict, jdistrict),
                         weight=sum(weight))

internal_district_mode = fold(tours, .(internal, idistrict, jdistrict, mode_name),
                     weight=sum(weight))
internal_district_mode = add_mode_share(internal_district_mode, internal_district)

internal_district_model_type = fold(tours, .(internal, idistrict, jdistrict, model_type),
                           weight=sum(weight))

internal_district_model_type_mode = fold(tours, .(internal, idistrict, jdistrict, model_type, mode_name),
                                weight=sum(weight))
internal_district_model_type_mode = add_mode_share(internal_district_model_type_mode, internal_district_model_type)

