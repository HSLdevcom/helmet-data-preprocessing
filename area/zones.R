# -*- coding: utf-8-unix -*-
library(strafica)
library(readxl)

.ancfile = function(...) {
    return(enc2native(ancfile(...)))
}

zones = read.shape(ancfile("input/aluejaot/aluejaot_2019_SHP/sijoittelualueet2019.shp"),
                   encoding="utf-8")
zones = sp.to.polys(zones, data.only=TRUE)
zones = pick(zones, sij2019, kela)
zones = rename(zones, sij2019=zone_orig, kela=municipality)
zones$municipality = as.integer(zones$municipality)
zones = arrange(zones, zone_orig)
zones$zone = rows.along(zones)

zones$cbd = ifelse(zones$zone_orig %in% c(101:999), TRUE, FALSE)
zones$suburb = ifelse(zones$municipality %in% 91 & !(zones$cbd), TRUE, FALSE)

message("Reading data into zones...")

zones$cbd = ifelse(zones$cbd, 1, 0)
zones$suburb = ifelse(zones$suburb, 1, 0)

municipalities = read.delims("municipalities.txt", fileEncoding="utf-8")
municipalities = pick(municipalities,
                      municipality, municipality_name,
                      capital_region, surrounding_municipality, peripheral_municipality)
zones = leftjoin(zones, municipalities, by="municipality")

zones$district = zones$municipality_name
m = which(zones$municipality_name %in% c("Espoo","Kauniainen","Vantaa"))
zones$district[m] = "espoo_vant_kau"
m = which(zones$municipality_name %in% "Helsinki" & zones$cbd)
zones$district[m] = "helsinki_cbd"
m = which(zones$municipality_name %in% "Helsinki" & !zones$cbd)
zones$district[m] = "helsinki_other"
zones$district[zones$surrounding_municipality] = "surrounding"
zones$district[zones$peripheral_municipality] = "peripheral"

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

income = read_xlsx(.ancfile("input/Maankäyttö/tulotiedot_2016_korjattu.xlsx"), sheet="tulotaso_korjattu")
m = match(zones$zone_orig, income$SIJ2019)
zones$income_person = income$hr_mtu[m]
zones$income_household = income$tr_mtu[m]

zones = downclass(zones)
check.na(zones)
write.csv2(zones, file="zones.csv", row.names=FALSE)
