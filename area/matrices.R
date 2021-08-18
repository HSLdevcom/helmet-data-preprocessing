# -*- coding: utf-8-unix -*-
library(strafica)

read_emme_csv = function(file, value="value", ...) {
    mat = data.table::fread(file, ...)
    colnames(mat)[1] = "izone"
    mat = tidyr::gather(mat, key="jzone", value="value", -izone)
    mat$jzone = gsub("X", "", mat$jzone)
    mat$izone = as.integer(mat$izone)
    mat$jzone = as.integer(mat$jzone)
    mat$value = as.numeric(mat$value)
    colnames(mat)[3] = value
    return(mat)
}

# Read zones
zones = read.csv2("zones.csv", stringsAsFactors=FALSE)
zones = pick(zones, zone_orig, municipality, capital_region, area)

matrices = expand.grid(izone=zones$zone_orig, jzone=zones$zone_orig)


# Read matrices

files = dfsas(fname=c("Vastukset2016/mf380.csv",
                      "Vastukset2016/mf381.csv",
                      "Vastukset2016/mf382.csv",
                      "Vastukset2016/mf383.csv",
                      "Vastukset2016/mf384.csv",
                      "Vastukset2016/mf385.csv",
                      "Vastukset2016/mf110.csv",
                      "Vastukset2016/mf114.csv",
                      "Vastukset2016/mf118.csv",
                      "Vastukset2016/mf386.csv",
                      "Vastukset2016/mf387.csv",
                      "Vastukset2016/mf100.csv",
                      "Vastukset2016/mf101.csv",
                      "Vastukset2016/mf102.csv",
                      "Joukkoliikenteen kustannukset/jkl_kust_yht.csv",
                      "Vastukset2018/mf380.csv",
                      "Vastukset2018/mf381.csv",
                      "Vastukset2018/mf382.csv",
                      "Vastukset2018/mf383.csv",
                      "Vastukset2018/mf384.csv",
                      "Vastukset2018/mf385.csv",
                      "Vastukset2018/mf110.csv",
                      "Vastukset2018/mf114.csv",
                      "Vastukset2018/mf118.csv",
                      "Vastukset2018/mf377.csv",
                      "Vastukset2018/mf386.csv",
                      "Vastukset2018/mf387.csv",
                      "Vastukset2018/mf100.csv",
                      "Vastukset2018/mf101.csv",
                      "Vastukset2018/mf102.csv"),
              name=c("ttime_car_aht_2016",
                     "length_car_aht_2016",
                     "ttime_car_pt_2016",
                     "length_car_pt_2016",
                     "ttime_car_iht_2016",
                     "length_car_iht_2016",
                     "ttime_transit_aht_2016",
                     "ttime_transit_pt_2016",
                     "ttime_transit_iht_2016",
                     "ttime_bicycle_2016",
                     "length_bicycle_2016",
                     "length_bicycle_separate_cycleway_2016",
                     "length_bicycle_adjacent_cycleway_2016",
                     "length_bicycle_mixed_traffic_2016",
                     "cost_transit_monthly_2018",
                     "ttime_car_aht_2018",
                     "length_car_aht_2018",
                     "ttime_car_pt_2018",
                     "length_car_pt_2018",
                     "ttime_car_iht_2018",
                     "length_car_iht_2018",
                     "ttime_transit_aht_2018",
                     "ttime_transit_pt_2018",
                     "ttime_transit_iht_2018",
                     "length_pedestrian_2018",
                     "ttime_bicycle_2018",
                     "length_bicycle_2018",
                     "length_bicycle_separate_cycleway_2018",
                     "length_bicycle_adjacent_cycleway_2018",
                     "length_bicycle_mixed_traffic_2018"))

message("Reading matrices...")
time.start = Sys.time()
for (i in rows.along(files)) {
    fname = sprintf("input/Estimoinnin_lähtötiedot/%s", files$fname[i])
    messagef("  %2d/%2d: %s", i, nrow(files), fname)
    mat = read_emme_csv(ancfile(fname),
                        value=files$name[i],
                        stringsAsFactors=FALSE)
    matrices = leftjoin(matrices, mat)
}
progress.final(time.start)

matrices = leftjoin(matrices, read.csv(ancfile("input/Estimoinnin_lähtötiedot/Vastukset2012/cost_aht.csv"), stringsAsFactors = FALSE))
matrices = leftjoin(matrices, read.csv(ancfile("input/Estimoinnin_lähtötiedot/Vastukset2012/dist_aht.csv"), stringsAsFactors = FALSE))
matrices = leftjoin(matrices, read.csv(ancfile("input/Estimoinnin_lähtötiedot/Vastukset2012/dist_pt.csv"), stringsAsFactors = FALSE))
matrices = leftjoin(matrices, read.csv(ancfile("input/Estimoinnin_lähtötiedot/Vastukset2012/dist_iht.csv"), stringsAsFactors = FALSE))
matrices = leftjoin(matrices, read.csv(ancfile("input/Estimoinnin_lähtötiedot/Vastukset2012/time_aht.csv"), stringsAsFactors = FALSE))
matrices = leftjoin(matrices, read.csv(ancfile("input/Estimoinnin_lähtötiedot/Vastukset2012/time_pt.csv"), stringsAsFactors = FALSE))
matrices = leftjoin(matrices, read.csv(ancfile("input/Estimoinnin_lähtötiedot/Vastukset2012/time_iht.csv"), stringsAsFactors = FALSE))

# Car costs from lengths
lengths = grep("^length_car_(.+)_2016", colnames(matrices), perl=TRUE, value=TRUE)
costs = matrices[, lengths]
costs = costs * 0.133
colnames(costs) = gsub("length", "cost", colnames(costs))
matrices = cbind(matrices, costs)

lengths = grep("^length_car_(.+)_2018", colnames(matrices), perl=TRUE, value=TRUE)
costs = matrices[, lengths]
costs = costs * 0.144
colnames(costs) = gsub("length", "cost", colnames(costs))
matrices = cbind(matrices, costs)

lengths = grep("^length_car_(.+)_2012", colnames(matrices), perl=TRUE, value=TRUE)
costs = matrices[, lengths]
costs = costs * 0.157
colnames(costs) = gsub("length", "cost", colnames(costs))
matrices = cbind(matrices, costs)


# Transit costs from monthly tickets
izone_in_capital_region = zones$capital_region[match(matrices$izone, zones$zone_orig)]
jzone_in_capital_region = zones$capital_region[match(matrices$jzone, zones$zone_orig)]
matrices$cost_transit_work_2018 = ifelse(izone_in_capital_region & jzone_in_capital_region,
                                         matrices$cost_transit_monthly_2018 / 60,
                                         matrices$cost_transit_monthly_2018 / 44)
matrices$cost_transit_other_2018 = matrices$cost_transit_monthly_2018 / 30
matrices$cost_transit_work_2016 = matrices$cost_transit_work_2018
matrices$cost_transit_other_2016 = matrices$cost_transit_other_2018
matrices$cost_transit_work_2012 = ifelse(izone_in_capital_region & jzone_in_capital_region,
                                         matrices$cost_transit_monthly_2012 / 60,
                                         matrices$cost_transit_monthly_2012 / 44)
matrices$cost_transit_other_2012 = matrices$cost_transit_monthly_2012 / 30
matrices = unpick(matrices, cost_transit_monthly_2018)
matrices = unpick(matrices, cost_transit_monthly_2012)

# Bicycling
matrices$ttime_bicycle_2016 = pclip(matrices$ttime_bicycle_2016, -Inf, 9999)
matrices$ttime_bicycle_2018 = pclip(matrices$ttime_bicycle_2018, -Inf, 9999)
matrices$ttime_bicycle_2012 = pclip(matrices$ttime_bicycle_pt_2012, -Inf, 9999)

# Walking
walk_speed = 5.0 / 60  # km/min
matrices$ttime_pedestrian_2018 = matrices$length_pedestrian_2018 / walk_speed  # min
matrices$length_pedestrian_2016 = matrices$length_pedestrian_2018
matrices$ttime_pedestrian_2016 = matrices$ttime_pedestrian_2018
matrices$ttime_pedestrian_2012 = matrices$length_pedestrian_pt_2012 / walk_speed  # min

# Municipalities
matrices$imunicipality = zones$municipality[match(matrices$izone, zones$zone_orig)]
matrices$jmunicipality = zones$municipality[match(matrices$jzone, zones$zone_orig)]
stopif(any(is.na(matrices$imunicipality) | is.na(matrices$jmunicipality)))
matrices$same_municipality = (matrices$imunicipality == matrices$jmunicipality)
matrices$same_municipality = as.integer(ifelse(matrices$same_municipality, 1, 0))
matrices = unpick(matrices, imunicipality, jmunicipality)

# Same zone
matrices$same_zone = (matrices$izone == matrices$jzone)
matrices$same_zone = as.integer(ifelse(matrices$same_zone, 1, 0))

# Area for same zones
zones = pick(zones, zone_orig, area)
zones = rename(zones, zone_orig=jzone)
matrices = leftjoin(matrices, zones)
m = which(matrices$izone != matrices$jzone)
matrices$area[m] = 0


# Output
check.na(matrices)
message("Writing matrices...")
time.start = Sys.time()
data.table::fwrite(matrices, file="matrices.csv")
progress.final(time.start)
