# -*- coding: utf-8-unix -*-
library(here)
library(tidyverse)
library(sf)
library(haven)

matk <- haven::read_sas(ancfile("aineistot/HEHA12 Laurille/matk12_4.sas7bdat"),
                        catalog_file = ancfile("aineistot/HEHA12 Laurille/formats.sas7bcat"))
taus <- haven::read_sas(ancfile("aineistot/HEHA12 Laurille/taus12_3.sas7bdat"),
                        catalog_file = ancfile("aineistot/HEHA12 Laurille/formats.sas7bcat"))

lpcoords <- matk %>% 
  dplyr::select(tunnus2, lpkrd_p, lpkrd_i, lpkrd3_p, lpkrd3_i, lpGK25_p, lpGK25_i) %>% 
  dplyr::filter(!(is.na(lpGK25_p) | is.na(lpGK25_i))) %>% 
  dplyr::filter(!(lpGK25_p == 6500000 & lpGK25_i == 25000000)) %>% 
  sf::st_as_sf(coords = c("lpGK25_i", "lpGK25_p"), crs = 3879) %>% 
  sf::st_transform(crs = sf::st_crs(4326)) %>% 
  dplyr::mutate(
    lp_x = as.numeric(sf::st_coordinates(.)[,1]),
    lp_y = as.numeric(sf::st_coordinates(.)[,2])
  ) %>% 
  sf::st_drop_geometry() %>% 
  dplyr::select(tunnus2, lp_x, lp_y)

mpcoords <- matk %>% 
  dplyr::select(tunnus2, mpkrd_p, mpkrd_i, mpkrd3_p, mpkrd3_i, mpGK25_p, mpGK25_i) %>% 
  dplyr::filter(!(is.na(mpGK25_p) | is.na(mpGK25_i))) %>% 
  dplyr::filter(!(mpGK25_p == 6500000 & mpGK25_i == 25000000)) %>% 
  sf::st_as_sf(coords = c("mpGK25_i", "mpGK25_p"), crs = 3879) %>% 
  sf::st_transform(crs = sf::st_crs(4326)) %>% 
  dplyr::mutate(
    mp_x = as.numeric(sf::st_coordinates(.)[,1]),
    mp_y = as.numeric(sf::st_coordinates(.)[,2])
  ) %>% 
  sf::st_drop_geometry() %>% 
  dplyr::select(tunnus2, mp_x, mp_y)

apcoords <- matk %>% 
  dplyr::select(tunnus2, apkrd_p, apkrd_i, apkrd3_p, apkrd3_i, apGK25_p, apGK25_i) %>% 
  dplyr::filter(!(is.na(apGK25_p) | is.na(apGK25_i))) %>% 
  dplyr::filter(!(apGK25_p == 6500000 & apGK25_i == 25000000)) %>% 
  sf::st_as_sf(coords = c("apGK25_i", "apGK25_p"), crs = 3879) %>% 
  sf::st_transform(crs = sf::st_crs(4326)) %>% 
  dplyr::mutate(
    ap_x = as.numeric(sf::st_coordinates(.)[,1]),
    ap_y = as.numeric(sf::st_coordinates(.)[,2])
  ) %>% 
  sf::st_drop_geometry() %>% 
  dplyr::select(tunnus2, ap_x, ap_y)

matk <- matk %>% 
  dplyr::left_join(lpcoords, by = "tunnus2") %>% 
  dplyr::left_join(mpcoords, by = "tunnus2") %>% 
  dplyr::left_join(apcoords, by = "tunnus2")

matk_formatted <- matk %>%
  dplyr::mutate(
    juokseva = KOHDE,
    montako_matkaa = MATLKM2,
    kerroin = laaker6,
    ika = ika2,
    sukup_laaj = SEX,
    ap_kela = APKUNC,
    montako_autoa = HALKM2,
    onko_ajokortti = ajokor,
    miten_usein_auto_kaytettavissa = HKAUTO,
    kotitalous_0_6v = ALLE7V,
    kotitalous_kaikki = PEKOKO2,
    ap_sij19 = apsij16,
  ) %>%
  dplyr::mutate(
    toimi = dplyr::if_else(tyoaik2 %in% c(1, 2), "Työssäkäyvä", "Ei työssäkäyvä")
  ) %>% 
  dplyr::mutate(
    lippu_hsl_kausi = as.integer((YTV_SEU + YTV_HKI + YTV_ESP + YTV_VAN + YTV_KER +
                                    YTV_KIR + YTV_3V + YTV_2V + YTV_KOUL + YTV_VAPA +
                                    YTV_MUU) >= 1),
    lippu_hsl_arvo = as.integer(YTV_ARVO >= 1),
    lippu_mobiililippu = 0L,
    lippu_muu_kausi = as.integer((VR_VYO + VR_VYOLI + VR_KAU + VR_KOUL + VR_VAPA +
                                    VR_MUU + LA_KA + LA_KAVA + LA_KOUL + LA_VAPA +
                                    LA_MUU) >= 1),
    lippu_muu_arvo = as.integer((VR_VYOSA + VR_KAUSA + LA_ARVO + LA_SA + LA_SAVA) >= 1)
  ) %>%
  dplyr::mutate(
    matkaid = tunnus2,
    PITUUS = MATPIT,
    LP = as.vector(LPLAA5, mode = "integer"),
    MP = as.vector(MPLAA5, mode = "integer"),
    lp_sij19 = lpsij16,
    mp_sij19 = mpsij16,
    Paakulkutapa = pktapa2,
    PKTAPA2 = pktapa2
  )  %>% 
  # Starting and ending times
  dplyr::mutate(
    hours = as.integer(floor(lpaika / 100)),
    hours = dplyr::if_else(hours >= 24L, hours - 24L, hours),
    minutes = as.integer(lpaika %% 100),
    seconds = 0L,
    LPdttm = sprintf("%s %02d:%02d:%02d", TUTKPVM, hours, minutes, seconds),
    LPdttm = dplyr::if_else(is.na(TUTKPVM) | is.na(hours) | is.na(minutes) | is.na(seconds), NA_character_, LPdttm)
  ) %>% 
  dplyr::mutate(
    MPdttm = as.character(lubridate::ymd_hms(LPdttm, tz = "Europe/Helsinki") + minutes(MATAIK))
  ) %>% 
  dplyr::select(-hours, -minutes, -seconds) %>% 
  # Coordinate system
  dplyr::select(juokseva:MPdttm, lp_x:ap_y)

matk_formatted <- as.data.frame(matk_formatted)
save(matk_formatted, file="raw-heha12.RData")
