# -*- coding: windows-1252-dos -*-
library(strafica)
library(readxl)

.ancfile = function(...) {
    return(enc2native(ancfile(...)))
}

# Zones

message("Reading data into zones...")

zones = read.csv2(.ancfile("area/zones.csv"), stringsAsFactors=FALSE)
zones$cbd = ifelse(zones$cbd, 1, 0)
zones$suburb = ifelse(zones$suburb, 1, 0)

municipalities = read.delims(.ancfile("area/municipalities.txt"), fileEncoding="utf-8")
municipalities = pick(municipalities,
                      municipality, municipality_name,
                      capital_region, surrounding_municipality, peripheral_municipality)
zones = leftjoin(zones, municipalities, by="municipality")

built_land_area = read_xlsx(.ancfile("input/Maankäyttö/rakennettu_maapinta_ala_2018.xlsx"), sheet="Kaikki")
built_land_area = as.data.frame(built_land_area)
m = match(zones$zone_orig, built_land_area$SIJ2019)
zones$area = built_land_area$`Rakennetun alan pinta-ala (km2)`

landuse = read_xlsx(.ancfile("input/Maankäyttö/maankayttotiedot_sijoittelualueittain_kaikki_yhdessa.xlsx"))
landuse = as.data.frame(landuse)
m = match(zones$zone_orig, landuse$SIJ2019)
zones$populated_land_area = landuse$As_ruutujen_maa_ala[m]
zones$population_density = landuse$Asukkaita_per_as_ruutujen_maa_ala[m]
zones$housing = landuse$Aspien_pro[m]
zones$jobs = landuse$tp_yht[m]
zones$job_density = zones$jobs / zones$area
zones$population = landuse$Asukkaat_yht[m]
zones$jobs_service = landuse$varsinais_palvelutpt[m]
zones$jobs_shopping = landuse$myymälätpt[m]

m = which(zones$area < 0.000001)
zones$job_density[m] = 0

parking = read.csv2(.ancfile("input/Estimoinnin_lähtötiedot/md21_pysakointikustannus_tyo_2018.csv"),
                    fileEncoding="utf-8",
                    stringsAsFactors=FALSE)
zones$parking_fee_work = parking$parking_fee[match(zones$zone_orig, parking$zone)]
parking = read.csv2(.ancfile("input/Estimoinnin_lähtötiedot/md22_pysakointikustannus_muu_2018.csv"),
                    fileEncoding="utf-8",
                    stringsAsFactors=FALSE)
zones$parking_fee_other = parking$parking_fee[match(zones$zone_orig, parking$zone)]
zones = na.to.zero(zones, c("parking_fee_work", "parking_fee_other"))

students = read_xlsx(.ancfile("input/Maankäyttö/opla_luettelo_2017_2.xlsx"), sheet="sij19")
students = as.data.frame(students)
m = match(zones$zone_orig, students$SIJ2019)
zones$students_primary_school = round(students$peruskoulu[m])
zones$students_high_school = round(students$`aste2 yhteensä`[m])
zones$students_university = round(students$`aste3 yhteensä`[m])

cars = read_xlsx(.ancfile("input/Maankäyttö/Auto2018_pisteet_sum.xlsx"))
m = match(zones$zone_orig, cars$SIJ2019)
zones$cars_per_people = as.numeric(cars$Autonomistusaste[m]) * 1000
quantile(zones$cars_per_people, c(0, 0.01, 0.02, 0.98, 0.99, 1), na.rm=TRUE)

zones = downclass(zones)
check.na(zones)
save(zones, file="zones.RData")
