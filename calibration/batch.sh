#!/bin/bash
# -*- coding: utf-8-unix -*-
rm -fv *.csv
Rscript --quiet --no-save --encoding=UTF-8 tours.R
Rscript --quiet --no-save --encoding=UTF-8 demand.R
Rscript --quiet --no-save --encoding=UTF-8 length.R
Rscript --quiet --no-save --encoding=UTF-8 own_zone_demand.R
Rscript --quiet --no-save --encoding=UTF-8 car_user.R
Rscript --quiet --no-save --encoding=UTF-8 driver_share.R
Rscript --quiet --no-save --encoding=UTF-8 demand_from_zones.R
Rscript --quiet --no-save --encoding=UTF-8 output.R
