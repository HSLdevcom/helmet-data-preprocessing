# -*- coding: utf-8-unix -*-
#note: R commands work straight in the file, python and linux commands need to be copy-pasted to a suitable command line
library(strafica)

verbose_source <- function(file, encoding="UTF-8", ...) {
  message(sprintf("*** Running %s... ***", basename(file)))
  source(file, encoding=encoding, ...)
  #invisible(source(file, encoding=encoding, ...))
}

ROOT_DIRECTORY <- getwd()

setwd("area")
verbose_source("zones.R")
#verbose_source("matrices.R")
setwd(ROOT_DIRECTORY)

for f in *.csv ; do cat $f | fold -w 180 -s > folded_$f ; done #works if in right folder (Aineisto/uudet 2023/flatfiles)

# python ./survey/add_sij2023.py
# python ./survey/add_sij2023_lt23.py

setwd(ROOT_DIRECTORY)
verbose_source("survey/raw-heha.R")
verbose_source("survey/survey-heha.R")
verbose_source("survey/survey-hlt.R")
verbose_source("survey/survey-lt23.R")
setwd(ROOT_DIRECTORY)

#Select HEHA18 or HEHA23 via heha_year_config.txt

# pipenv run python -m tours.main input-config-heha.json
# pipenv run python -m tours.main input-config-hlt.json
# pipenv run python -m tours.main input-config-heha23.json #if this fails due unicode, check the source data for weird unicode characters

setwd("metropolitan/primary/")
verbose_source("background.R")
verbose_source("tours.R")
verbose_source("observations.R")
# verbose_source("average.R")
setwd(ROOT_DIRECTORY)

setwd("metropolitan/secondary/")
verbose_source("tours.R")
verbose_source("observations.R")
setwd(ROOT_DIRECTORY)

setwd("peripheral/primary/")
verbose_source("background.R")
verbose_source("tours.R")
verbose_source("observations.R")
# verbose_source("average.R")
setwd(ROOT_DIRECTORY)

setwd("peripheral/constructed/")
verbose_source("tours.R")
verbose_source("observations.R")
setwd(ROOT_DIRECTORY)


setwd("metropolitan/primary/")
verbose_source("alternatives.R")
setwd(ROOT_DIRECTORY)

setwd("metropolitan/secondary/")
verbose_source("alternatives.R")
setwd(ROOT_DIRECTORY)

setwd("metropolitan/generation/")
verbose_source("ttypes.R")
verbose_source("alternatives.R")
setwd(ROOT_DIRECTORY)

setwd("peripheral/primary/")
verbose_source("alternatives.R")
setwd(ROOT_DIRECTORY)

setwd("peripheral/constructed/")
verbose_source("alternatives.R")
setwd(ROOT_DIRECTORY)

setwd("generation")
verbose_source("generation-peripheral.R")
verbose_source("generation-metropolitan.R")
verbose_source("generation-metropolitan-secondary.R")
setwd(ROOT_DIRECTORY)

setwd("calibration")
verbose_source("tours.R")
verbose_source("demand.R")
verbose_source("length.R")
verbose_source("own_zone_demand.R")
verbose_source("car_user.R")
verbose_source("driver_share.R")
verbose_source("demand_from_zones.R")
verbose_source("output.R")
setwd(ROOT_DIRECTORY)

setwd("shares") 
verbose_source("tours.R")
verbose_source("trips.R")
verbose_source("peak_morning.R")
verbose_source("peak_afternoon.R")
verbose_source("peak_other.R")
verbose_source("shares.R")
verbose_source("shares_3h-to-1h.R")
setwd(ROOT_DIRECTORY)

#remove old alternatives.txt from alternatives folders
cat metropolitan/primary/alternatives/alternatives-wss-*.txt | fold -w 180 -s > ../H4_estimointi/Helmet4/helmet_estimation/Aineisto/uudet2023/havainnot23/WSS.txt
cat metropolitan/primary/alternatives/alternatives-wbo-*.txt | fold -w 180 -s > ../H4_estimointi/Helmet4/helmet_estimation/Aineisto/uudet2023/havainnot23/WBO.txt
cat metropolitan/primary/alternatives/alternatives-spb-*.txt | fold -w 180 -s > ../H4_estimointi/Helmet4/helmet_estimation/Aineisto/uudet2023/havainnot23/SPB.txt
cat metropolitan/primary/alternatives/alternatives-other-*.txt | fold -w 180 -s > ../H4_estimointi/Helmet4/helmet_estimation/Aineisto/uudet2023/havainnot23/OTH.txt
cat metropolitan/secondary/alternatives/alternatives--*.txt | fold -w 180 -s > ../H4_estimointi/Helmet4/helmet_estimation/Aineisto/uudet2023/havainnot23/SEC.txt
# cat peripheral/primary/alternatives/alternatives--*.txt | fold -w 180 -s > ../H4_estimointi/Helmet4/helmet_estimation/Aineisto/uudet2023/havainnot/YMP.txt
# cat peripheral/constructed/alternatives/alternatives--*.txt | fold -w 180 -s > ../H4_estimointi/Helmet4/helmet_estimation/Aineisto/uudet2023/havainnot/YCO.txt

cat metropolitan/generation/alternatives/alternatives*.txt | fold -w 180 -s > ../H4_estimointi/Helmet4/helmet_estimation/Aineisto/uudet2023/havainnot23/ACCM.txt

#vastukset
python -m impedances.main
#Create SEC_vastukset from SEC and zones
python ./impedances/sec_dest_impedances.py
cat output/impedances/SEC_vastukset.txt |  fold -w 180 -s > ../H4_estimointi/Helmet4/helmet_estimation/Aineisto/uudet2023/havainnot23/SEC_vastukset.txt
#move impedance files from output to estimate folder of Alogit
for f in *.csv ; do cat $f | fold -w 180 -s > new_$f ; done #works if in right folder (Aineisto/uudet 2023/vastukset)
python ./impedances/park_and_ride_observations.py
cat HBW_park_and_ride_choice.txt | fold -w 180 -s > HBW_park_and_ride.txt #liipy-aineisto

#flatfiles (zonet)
python -m area.main
cat ../H4_estimointi/Helmet4/helmet_estimation/Aineisto/uudet2023/zonedata_base.csv | fold -w 180 -s > ../H4_estimointi/Helmet4/helmet_estimation/Aineisto/uudet2023/zonedata_base_folded.csv 
#vanha: remove header from zonedata_base manually, replace ; with space, fill missing data for peripheral municipalities (age distribution)
#vanha: cat input/estimation_Sami/zonedata_forecast_muokattu.csv | fold -w 180 -s > ../H4_estimointi/Helmet4/helmet_estimation/Aineisto/uudet2023/zonedata_base_folded.csv

cat ../H4_estimointi/Helmet4/helmet_estimation/Aineisto/uudet2023/zonedata_accessibility.csv | fold -w 180 -s > ../H4_estimointi/Helmet4/helmet_estimation/Aineisto/uudet2023/zonedata_accessibility_folded.csv 


