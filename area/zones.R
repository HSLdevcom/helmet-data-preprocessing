# -*- coding: windows-1252-dos -*-
library(strafica)

zones = read.shape(ancfile("data/raw/sijoittelualueet2019/sijoittelualueet2019.shp"),
                      encoding="utf-8")
zones = sp.to.polys(zones, data.only=TRUE)
zones = pick(zones, sij2019, kela)
zones = rename(zones, sij2019=zone_orig, kela=municipality)
zones$municipality = as.integer(zones$municipality)
zones = arrange(zones, zone_orig)
zones$zone = rows.along(zones)

zones$cbd = ifelse(zones$zone_orig %in% c(101:999, 1531, 1532), TRUE, FALSE)
zones$suburb = ifelse(zones$zone_orig %in% c(1000:1999, 244, 367, 368, 1570), TRUE, FALSE)

write.csv2(zones, file="zones.csv", row.names=FALSE)
