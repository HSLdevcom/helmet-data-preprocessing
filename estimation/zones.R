# -*- coding: windows-1252-dos -*-
library(strafica)
library(readxl)

# Zones

message("Reading data into zones...")

zones = read.csv2(ancfile("input/zones.csv"), stringsAsFactors=FALSE)
zones$cbd = ifelse(zones$cbd, 1, 0)
zones$suburb = ifelse(zones$suburb, 1, 0)

municipalities = read.delims(ancfile("input/municipalities.txt"), fileEncoding="utf-8")
municipalities = pick(municipalities,
                      municipality, municipality_name,
                      capital_region, surrounding_municipality, peripheral_municipality)
zones = leftjoin(zones, municipalities, by="municipality")

built_land_area = read_xlsx(ancfile("data/raw/Maankäyttö/rakennettu_maapinta_ala_2018.xlsx"), sheet="Kaikki")
built_land_area = as.data.frame(built_land_area)
m = match(zones$zone_orig, built_land_area$SIJ2019)
zones$area = built_land_area$`Rakennetun alan pinta-ala (km2)`

landuse = read_xlsx(ancfile("data/raw/Maankäyttö/maankayttotiedot_sijoittelualueittain_kaikki_yhdessa.xlsx"))
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

parking = read.csv2(ancfile("data/raw/md21_pysakointikustannus_tyo_2018.csv"),
                    fileEncoding="utf-8",
                    stringsAsFactors=FALSE)
zones$parking_fee_work = parking$parking_fee[match(zones$zone_orig, parking$zone)]
parking = read.csv2(ancfile("data/raw/md22_pysakointikustannus_muu_2018.csv"),
                    fileEncoding="utf-8",
                    stringsAsFactors=FALSE)
zones$parking_fee_other = parking$parking_fee[match(zones$zone_orig, parking$zone)]
zones = na.to.zero(zones, c("parking_fee_work", "parking_fee_other"))

students = read_xlsx(ancfile("data/raw/Maankäyttö/opla_luettelo_2017_2.xlsx"), sheet="sij19")
students = as.data.frame(students)
m = match(zones$zone_orig, students$SIJ2019)
zones$students_primary_school = round(students$peruskoulu[m])
zones$students_high_school = round(students$`aste2 yhteensä`[m])
zones$students_university = round(students$`aste3 yhteensä`[m])

cars = read_xlsx(ancfile("data/raw/Maankäyttö/Autonomistus mallialueittain YKR 2015_v1.xlsx"))
cars = as.data.frame(cars)
# Average household size from those cells we have information about. We will
# assume that cells without any information behave similarly.
cars$household_size = cars$`Henkilöitä yhteensä (ne ykr-ruudut, joista tiedot on saatavilla, kotitalouksia > 1)` / cars$`Kotitalouksien lukumäärä yhteensä niissä ruuduissa, joista tiedot saatavilla (H-sarake)`
# For zones without any (known) households, we will assume a weighted average
# size of all household sizes.
m = which(is.nan(cars$household_size))
cars$household_size[m] = weighted.mean(cars$household_size, cars$`Kotitalouksien lukumäärä yhteensä niissä ruuduissa, joista tiedot saatavilla (H-sarake)`, na.rm=TRUE)
m = which(is.na(cars$`0 auton kotitalouksia (%)`) | is.na(cars$`1 auton kotitalouksia (%)`) | is.na(cars$`Useamman auton kotitaloudet (%)`))
percentages = c(sum(cars$`kotitalouksia, joissa 0 autoa (=J-O-P)`),
                sum(cars$`kotitalouksia, joissa 1 auto`),
                sum(cars$`kotitalouksia, joissa 2+ autoa`))
percentages = percentages / sum(percentages)
cars$`0 auton kotitalouksia (%)`[m] = percentages[1]
cars$`1 auton kotitalouksia (%)`[m] = percentages[2]
cars$`Useamman auton kotitaloudet (%)`[m] = percentages[3]
m = match(zones$zone_orig, cars$`SIJ2019 (mallin aluejako)`)
zones$household_size = cars$household_size[m]
zones$households = zones$population / zones$household_size
zones$households_cars_0 = cars$`0 auton kotitalouksia (%)`[m] * zones$households
zones$households_cars_1 = cars$`1 auton kotitalouksia (%)`[m] * zones$households
zones$households_cars_2 = cars$`Useamman auton kotitaloudet (%)`[m] * zones$households
zones$cars_per_people = (zones$households_cars_1 + 2.2 * zones$households_cars_2) / (zones$population / 1000)
m = which(is.na(zones$cars_per_people) | zones$cars_per_people < 1)
zones$cars_per_people[m] = weighted.mean(zones$cars_per_people, zones$population)
quantile(zones$cars_per_people, c(0, 0.01, 0.02, 0.98, 0.99, 1), na.rm=TRUE)

zones = downclass(zones)
check.na(zones)
save(zones, file="zones.RData")
