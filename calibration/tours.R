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

m = match(tours$izone, zones$zone)
tours$izone_orig = zones$zone_orig[m]
m = match(tours$jzone, zones$zone)
tours$jzone_orig = zones$zone_orig[m]

# Lengths
mat1 = as.data.frame(data.table::fread(ancfile("metropolitan/primary/average.csv"), stringsAsFactors=FALSE))
mat2 = as.data.frame(data.table::fread(ancfile("peripheral/primary/average.csv"), stringsAsFactors=FALSE))
mat = fulljoin(mat1, mat2, by=c("izone","jzone"))
mat$izone = zones$zone[match(mat$izone, zones$zone_orig)]
mat$jzone = zones$zone[match(mat$jzone, zones$zone_orig)]
mat = mat[, c("izone","jzone",grep("^length_car", colnames(mat), value=TRUE))]

tours$length = NA
all = expand.grid(year=unique(tours$year),
                  mtype=unique(tours$mtype))
for (i in rows.along(all)) {
    m = which(tours$year %in% all$year[i] &
                  tours$mtype %in% all$mtype[i])
    if (length(m) == 0) next
    col_name1 = sprintf("length_car_%d_%s_%s",
                       all$year[i],
                       all$mtype[i],
                       "there")
    col_name2 = sprintf("length_car_%d_%s_%s",
                       all$year[i],
                       all$mtype[i],
                       "back")
    messagef("%s & %s", col_name1, col_name2)
    
    mat1 = mat[, c("izone", "jzone", col_name1)]
    mat2 = mat[, c("izone", "jzone", col_name2)]
    mat2 = rename(mat2, izone=new_jzone, jzone=new_izone)
    mat2 = rename(mat2, new_jzone=jzone, new_izone=izone)
    mat0 = leftjoin(mat1, mat2)
    
    tours = leftjoin(tours, mat0)
    tours$length[m] = tours[m, col_name1] + tours[m, col_name2]
    tours = tours[, colnames(tours) %nin% c(col_name1, col_name2)]

}

tours$idistrict = zones$district[match(tours$izone, zones$zone)]
tours$jdistrict = zones$district[match(tours$jzone, zones$zone)]

tours = leftjoin(tours, model_types)
tours = leftjoin(tours, modes)
tours = rename(tours, mode=mode_original)

tours$weight = ifelse(tours$closed %in% 1, 1, 0.5) * tours$xfactor
check.na(tours)
save(tours, file="tours.RData")
