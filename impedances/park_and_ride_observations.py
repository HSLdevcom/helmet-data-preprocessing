import csv
import numpy as np
import pandas as pd
import geopandas as gpd
from shapely.geometry import Point
import openmatrix as omx

PARK_FACILITIES = 97
PARK_FIRST = 2126

def coords2point(coords):
    if type(coords) == float:
        return coords
    k = coords.split(",")
    if k[1]=='' or k[0]=='': return np.nan
    return Point(float(k[1]), float(k[0]))

observations = pd.read_excel('C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\Liipy_aineisto\\Liipy 2022 laajennuskertoimella.xlsx') 
alogit_data = "C:\\Users\\HajduPe\\helmet-data-preprocessing\\output\\HBW_park_and_ride_choice.txt"

aluejako = gpd.read_file("C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\aluejaot\\SIJ2023_aluejako.shp")
print(aluejako.head())
aluejako = aluejako[["SIJ2023", "geometry"]]
aluejako = aluejako.to_crs(4326)
#impendances = omx.open_file('C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\estimation_Sami\\hw.omx') #Must have all 2098 zones
impendances = omx.open_file('C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\tuloskansion_vastukset\\dist_aht.omx') #Must have all 2098 zones
zonedata = pd.read_csv("C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\estimation_Sami\\zonedata_forecast.csv") #Must have all 2098 zones

#process observations
print(list(observations.columns))
selector_d = {'Mikä oli lähtöpaikkasi osoite?:latitude': 'aloitus_lat', 
              'Mikä oli lähtöpaikkasi osoite?:longitude': 'aloitus_lon',
              'Jatkettuasi matkaa liityntäpysäköinnistä, mikä oli määränpään osoite?:latitude':'maaranpaa_lat',
              'Jatkettuasi matkaa liityntäpysäköinnistä, mikä oli määränpään osoite?:longitude':'maaranpaa_lon',
              'Oliko matkasi määränpää':'tarkoitus',
              'Jos olisit kulkenut koko matkan henkilöautolla, millainen pysäköintipaikka sinulla olisi ollut matkan määränpäässä?':'maksullisuus',
              'Olisiko tekemälläsi matkalla lähtöpaikastasi liityntäpysäköintialueelle ollut käytettävissä bussiyhteys?':'bussiyhteys',
              'Liityntäpysäköinnin kesto':'kesto',
              'Tutkimus':'liitynta_mode',
              'Longitude':'laitos_lon',
              'Latitude':'laitos_lat',
              'Pysäköintitilan nimi':'laitos_name',
              'Laajennuskerroin':'xfactor',
              }
observations = observations.rename(columns=selector_d)[selector_d.values()]
observations = observations[observations["liitynta_mode"]=='Auto']

#Assign coordinates to start and end
for c in ["aloitus","maaranpaa"]:
    
    #observations["geometry"] = observations.apply(lambda row: coords2point(row["G_"+c+"koordinaatit"]), axis=1)
    observations["geometry"] = observations.apply(lambda row: Point(float(row[c+"_lon"]), float(row[c+"_lat"])), axis=1)
    #heha["geometry"] = heha.apply(lambda row: Point(row["lon_"+c], row["lat_"+c]), axis=1)

    # Convert to a GeoDataFrame
    observations = gpd.GeoDataFrame(observations, geometry="geometry")

    # Declare the coordinate system for the places GeoDataFrame
    # GeoPandas doesn't do any transformations automatically when performing
    # the spatial join. The layers are already in the same CRS (WGS84) so no
    # transformation is needed.
    observations.crs = {"init": "epsg:4326"}

    observations = gpd.tools.sjoin(observations, aluejako, how="left")
    observations[c+"_sij23"] = observations["SIJ2023"]
    observations = observations.drop(columns=['index_right', 'SIJ2023'])

observations = observations.dropna(subset=["aloitus_sij23","maaranpaa_sij23","laitos_name"])
print(observations[["aloitus_sij23","maaranpaa_sij23"]].head())

laitos_map = {
    "60.2065,24.66 - Espoonaukio":35029,
    "60.2046,24.6528 - Kirkkojärventie Kannusillankatu":35029,
    "60.1903,24.6021 - Hansatie":35094,
    "60.1915,24.6051 - Hansatie-Vantinportti":35094,
    "60.4057,25.1053 - Veturiaukio":35084,
    "60.4056,25.1076 - Tapulikatu pohjoinen":35084,
    "60.2166,24.7521 - Karapellontie eteläinen":35023,
    "60.1192,24.4403 - Munkinmäki":35001,
    "60.1906,24.6052 - Vantinportti-Hyttipojankuja":35094,
    "60.404,25.1071 - Tapulikatu eteläinen":35084,
    "60.3309,25.0679 - Laurintie P2":35092,
    "60.4063,25.1058 - Junailijankatu":35084,
    "60.3809,25.0966 - Saviontie":35074,
    "60.206,24.6601 - Kirkkojärventie Espoonportti":35029,
    "60.1192,24.4385 - Munkinmäentie":35001,
    "60.2171,24.7518 - Karapellontie pohjoinen":35023,
    "60.3524,25.0801 - Mäyräkuja P1":35053,
    "60.2065,24.6625 - Kirkkojärventie Kirkkokatu":35029,
    "60.3218,25.0591 - Karsikkokuja P1":35062,
    "60.325,25.0608 - Peijaksentie P2":35062,
    "60.1203,24.4411 - Aseman ostoskeskus":35001,
    "60.315,24.8432 - Kivistön asema P1":35069,
    "60.1614,24.7377 - Matinkylän asema":35051,
    "60.3228,25.04 - Koivukylänväylä P1":35032,
    "60.2967,25.0457 - Ratatie P1":35086,
    "60.1747,24.7816 - P-Urheilupuisto":35068,
    "60.2937,25.0457 - Väritehtaankatu P2":35086,
    "60.3239,25.0338 - Koivukylänväylä P2":35032,
    "60.1579,24.5381 - Masalan asema läntinen":35050,
    "60.304,25.0491 - Haarikkokuja P2":35009,
    "60.3122,24.839 - Radioasemantie P2":35050,
    "60.1702,24.7639 - Niittykumpu":35059,
    "60.1374,24.5122 - Jorvaksenkaari":35020,
    "60.2941,24.8455 - Härkälenkki P1":35017,
    "60.2963,25.0469 - Teatteripolku P3":35086,
    "60.1585,24.5396 - Masalan asema itäinen":35050,
    "60.648,25.3067 - Mäntsälän asema etelä":35057,
    "60.6486,25.3078 - Mäntsälän asema pohjoinen":35057,
    "60.2191,24.8112 - Leppävaaranaukio":35039,
    "60.1654,24.8444 - Hanasaarenranta":35010,
    "60.4746,25.0901 - Kirjastokatu":35043,
    "60.4759,25.0876 - Pajalantie":35043,
    "60.2184,24.8947 - Haagan pappilantie":35007,
    "60.2198,24.8098 - Turuntie":35039,
    "60.4553,25.1009 - Ainola":35076,
    "60.4965,25.1325 - Haarajoen Asemakatu":35008,
    "60.2309,24.884 - Kuparitie":35035,
    "60.3034,25.0487 - Haarikkokuja P1":35009,
    "60.4756,25.0865 - Järvenpään linja-autoasema":35043,
    "60.1602,24.8808 - Lauttasaarentie":35038,
    "60.2057,24.6582 - Kirkkojärventie By Pia's":35029,
    "60.1184,24.481 - Porkkalantie":35064,
    "60.1178,24.4727 - Tolsan asema läntinen":35087,
    "60.1464,24.5782 - Sarvvikinportti":35073,
    "60.2407,24.8737 - Soittajantie":35078,
    "60.2853,24.8473 - Ratastie P1":35072,
    "60.2785,24.8536 - Martinlaakso P1":35049,
    "60.2601,24.8549 - Punamultapolku P1":35066,
    "60.27,24.4405 - Eerikinkartanontie pohjoinen":35002,
    "60.2707,24.8542 - Louhelan asema P1":35041,
    "60.2479,24.8637 - Luutnantinaukio":35045,
    "60.3341,24.3271 - Majatuvankuja":35018,
    "60.2697,24.4407 - Eerikinkartanontie eteläinen":35001,
    "60.2403,24.8748 - Sitratie":35078,
    "60.2634,25.0305 - Jäkälätie eteläinen":35080,
    "60.2292,24.9665 - Oulunkylän Tori eteläinen":35088,
    "60.2182,24.9456 - Osmontie":35061,
    "60.2436,24.9952 - Eskolantie P1":35004,
    "60.2295,24.9672 - Torivoudintie":35088,
    "60.2295,24.966 - Oulunkylän Tori pohjoinen":35088,
    "60.2519,25.0115 - Malmin asema":35048,
    "60.2413,24.993 - Ratavallintie P2":35004,
    "60.263,25.0285 - Seunalankuja":35080,
    "60.2186,24.8113 - Sello":35039,
    "60.3021,25.048 - Kiskokuja P3":35009,
    "60.2082,25.143 - Vuosaaren Mosaiikkiparkki":35096,
    "60.2144,25.0928 - Puotilan metrotori P2":35067,
    "60.2373,25.0819 - Kontulan ostoskeskus":35028,
    "60.2153,25.0921 - Vanhanlinnantori P3":35067,
    "60.2152,25.0949 - Puotilan metrokatu P1":35067,
    "60.2052,25.1215 - Rastilan metroasema":35071,
    "60.176,24.8047 - Tapiola Park":35083,
    "60.238,25.1088 - Mellunmäenraitio eteläinen":35052,
    "60.276,25.0356 - Tapulinkaupungintie pohjoinen":35085,
    "60.2738,25.0363 - Raidekuja":35085,
    "60.2386,25.1081 - Mellunmäenraitio pohjoinen":35052,
    "60.2381,25.1105 - Pallaksentie":35052,
    "60.1942,25.028 - Hiihtäjäntie":35013,
    "60.1886,25.0035 - Kulosaaren puistotie läntinen P2":35034,
    "60.5537,24.9685 - Jokelantie pohjoinen":35019,
    "60.1889,25.0059 - Ukko-Pekan porras P1":35034,
    "60.21,25.0774 - Kauppakeskus Itis":35025,
    "60.6317,24.8552 - Solbonkatu eteläinen":35011,
    "60.5532,24.9691 - Jokelantie asema":35019,
    "60.5513,24.9729 - Jokelantie eteläinen":35019,
    "60.5536,24.971 - Puhelinkuja":35019,
    "60.374,25.2656 - Erottaja":35003,
    "60.2985,25.3281 - Keskustatie":35077,
    "60.3908,25.6371 - Katajamäen liityntäpysäköinti - auto":35024,
    "60.2985,25.3375 - Miilin terminaali - auto":35077,
    "60.3738,25.2502 - Susiympyrä - auto":35003,
    "60.2058,25.0479 - Muuntajankatu P4":35055,
    "60.2065,25.0456 - Siilitie itäinen P2":35055,
    "60.2061,25.0444 - Siilitie läntinen P1":35055,
    "60.4876,25.0668 - Jäppilänkatu":35042,
    "60.4867,25.0653 - Loutinkatu":35042,
}

observations["laitos_str"] = observations.apply(lambda row: f'{row["laitos_lat"]},{row["laitos_lon"]} - {row["laitos_name"]}', axis=1)
# print("laitos_map = {")
# for laitos in observations["laitos_str"].unique():
#     print(f'    "{laitos}":')
# print("}")
observations["laitos_emme"] = observations["laitos_str"].map(laitos_map)
observations["laitos_emme"] = observations["laitos_emme"].astype(int)
print(observations)

#impendance matrices
#matrix_list = ["walk_dist","walk_time"]+list(impendances.list_matrices())
matrix_list = list(impendances.list_matrices())
print(matrix_list)
imp_arrays = {}
scaler = 1.0 #0.5
for matrix_key in matrix_list:
    if matrix_key == "walk_dist":
        imp_arrays["walk_dist"] = np.array(impendances["bike_dist"]) * scaler
    elif matrix_key == "walk_time":
        imp_arrays["walk_time"] = np.array(impendances["bike_time"]) * 3 * scaler
    else:
        imp_arrays[matrix_key] = np.array(impendances[matrix_key]) * scaler
print(imp_arrays["car_work"].shape)
print('mappings:', impendances.list_mappings()) # ['taz']
tazs = impendances.mapping('zone_number')
#Alogit file
selector_d = {'aloitus_sij23':'izone',
              'maaranpaa_sij23':'jzone',
              'laitos_emme':'kzone',
              'xfactor':'xfactor',
              }
alogit_observations = observations.rename(columns=selector_d)[selector_d.values()]
id_counter = 1

#zone data
print(zonedata["service"],zonedata["shops"])
var_list = []
#impedances
zonedata_nearbys = {}
for i in range(0,PARK_FACILITIES):
                zonedata_nearbys[i] = zonedata[zonedata.apply(lambda x: imp_arrays["car_work"][tazs[int(x["id"])],i]<1,axis=1)] #filter nearby areas

# kzone2id = {tazs[taz]:taz for taz in tazs if taz>34999} #inverted dictionary lookup for lp facilities
# print(kzone2id)
with open(alogit_data, "w", newline='') as out_file:
    writer = csv.writer(out_file, delimiter=' ',
                            quotechar='|', quoting=csv.QUOTE_MINIMAL)
    
    for e,obs in alogit_observations.iterrows():
            #print("Observation: ",e)
            obs_data = obs

            #Python indexes from zero, zones and Alogit are from 1
            pfrom = tazs[int(obs_data["izone"])]
            pto = tazs[int(obs_data["jzone"])]
            new_row = [id_counter]
            if e==0: var_list.append("Pid")
            #print(pfrom, pto)

            choice = tazs[int(obs_data["kzone"])]-PARK_FIRST+1
            new_row.append(choice)
            if e==0: var_list.append("choice")

            weight = float(obs_data["xfactor"])
            new_row.append(weight)
            if e==0: var_list.append("weight")

            for i in range(0,PARK_FACILITIES):
                # delta = (a+b) - c
                li = PARK_FIRST+i
                kval = imp_arrays["car_work"][pfrom,li] + imp_arrays["transit_work"][li,pto]
                no_kval = imp_arrays["car_work"][pfrom,pto]
                delta_val = kval - no_kval
                new_row.append(delta_val)
                if e==0: var_list.append(f"deltaV({i+1})")
            for i in range(0,PARK_FACILITIES):
                zonedata_nearby = zonedata_nearbys[i] #filter nearby areas
                attraction = zonedata_nearby["shops"].astype(float).sum()
                new_row.append(attraction)
                if e==0: var_list.append(f"shops({i+1})")
            for i in range(0,PARK_FACILITIES):
                zonedata_nearby = zonedata_nearbys[i] #filter nearby areas
                attraction = zonedata_nearby["service"].astype(float).sum()
                new_row.append(attraction)
                if e==0: var_list.append(f"service({i+1})")
            writer.writerow(new_row)
            id_counter += 1
            # if counter > 5: break
    
print(var_list)

impendances.close()

