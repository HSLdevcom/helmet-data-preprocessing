# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

zones = read.csv2(ancfile("area/zones.csv"))
model_types = read.delims("models.txt")
modes = read.delims("modes.txt")


observations1 = load1(ancfile("metropolitan/primary/observations.RData"))
observations2 = load1(ancfile("peripheral/primary/observations.RData"))
tours = rbind_list(observations1, observations2)
tours = pick(tours,
             pid,
             mode,
             ttype,
             survey,
             year,
             mtype,
             xfactor,
             izone,
             jzone,
             closed,
             order)
tours$inverted = is_inverted(tours$order)

tours$inverted_izone = ifelse(tours$inverted, tours$jzone, tours$izone)
tours$inverted_jzone = ifelse(tours$inverted, tours$izone, tours$jzone)

# Lengths
mat1 = as.data.frame(data.table::fread(ancfile("metropolitan/primary/average.csv"), stringsAsFactors=FALSE))
mat2 = as.data.frame(data.table::fread(ancfile("peripheral/primary/average.csv"), stringsAsFactors=FALSE))
mat = fulljoin(mat1, mat2, by=c("izone","jzone"))
mat$izone = zones$zone[match(mat$izone, zones$zone_orig)]
mat$jzone = zones$zone[match(mat$jzone, zones$zone_orig)]
mat = mat[, c("izone","jzone",grep("^length_car", colnames(mat), value=TRUE))]
tours = mcddply(tours, .(year, mtype, inverted), function(df) {
    direction = ifelse(df$inverted[1], "back", "there")
    col_name = sprintf("length_car_%d_%s_%s", df$year[1], df$mtype[1], direction)
    mat = mat[, c("izone","jzone",col_name)]
    colnames(mat) = c("izone","jzone","length")
    df = leftjoin(df, mat)
    return(df)
})

tours$idistrict = zones$district[match(tours$izone, zones$zone)]
tours$jdistrict = zones$district[match(tours$jzone, zones$zone)]

tours = leftjoin(tours, model_types)
tours = leftjoin(tours, modes)
tours = unpick(tours, mode)

tours$weight = ifelse(tours$closed, 1, 0.5) * tours$xfactor
check.na(tours)
save(tours, file="tours.RData")
