# -*- coding: windows-1252-dos -*-
library(strafica)

aluejako = read.shape(ancfile("data/raw/sijoittelualueet2019/sijoittelualueet2019.shp"),
                      encoding="utf-8")
aluejako = sp.to.polys(aluejako, data.only=TRUE)
aluejako = pick(aluejako, sij2019, kela)
aluejako = rename(aluejako, sij2019=zone_orig, kela=municipality)
aluejako$municipality = as.integer(aluejako$municipality)
aluejako = arrange(aluejako, zone_orig)
aluejako$zone = rows.along(aluejako)

aluejako$cbd = ifelse(aluejako$zone_orig %in% c(101:999, 1531, 1532), TRUE, FALSE)
aluejako$suburb = ifelse(aluejako$zone_orig %in% c(1000:1999, 244, 367, 368, 1570), TRUE, FALSE)

write.csv2(aluejako, file="zones.csv", row.names=FALSE)
