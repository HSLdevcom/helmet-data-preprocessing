# -*- coding: utf-8-unix -*-
library(strafica)
library(writexl)

output = list(demand=load1("demand.RData"),
              length=load1("length.RData"),
              own_zone_demand=load1("own_zone_demand.RData"))
write_xlsx(output, path="output/calibration.xlsx", format_headers=FALSE)
