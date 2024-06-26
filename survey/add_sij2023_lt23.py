import pandas as pd
import geopandas as gpd
from shapely.geometry import Point

print("Importing surveys")

#Load shapefile
aluejako = gpd.read_file("C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\aluejaot\\SIJ2023_aluejako.shp")
print(aluejako.head())
aluejako = aluejako[["SIJ2023", "geometry"]]
aluejako = aluejako.to_crs(4326)

# #Process HEHA
heha = pd.read_excel("C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\HEHA-aineistot\\HEHA23_MATKAT_KERTOIMET.xlsx")
for c in ["aloitus","maaranpaa"]:

    heha["geometry"] = heha.apply(lambda row: Point(row["lon_"+c], row["lat_"+c]), axis=1)

    # Convert to a GeoDataFrame
    heha = gpd.GeoDataFrame(heha, geometry="geometry")

    # Declare the coordinate system for the places GeoDataFrame
    # GeoPandas doesn't do any transformations automatically when performing
    # the spatial join. The layers are already in the same CRS (WGS84) so no
    # transformation is needed.
    heha.crs = {"init": "epsg:4326"}

    heha = gpd.tools.sjoin(heha, aluejako, how="left")
    heha[c+"_sij23"] = heha["SIJ2023"]
    heha = heha.drop(columns=['index_right', 'SIJ2023'])

heha = heha.dropna(subset=["aloitus_sij23","maaranpaa_sij23"])
print(heha[["aloitus_sij23","maaranpaa_sij23"]].head())

heha.to_excel("C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\HEHA-aineistot\\HEHA23_MATKAT_KERTOIMET_sij23.xlsx",
             sheet_name='Data',index=False)

# #Process HEHA taustat
heha = pd.read_excel("C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\HEHA-aineistot\\HEHA23_TAUSTAT_KERTOIMET.xlsx")
for c in ["asuinpaikka"]:

    heha["geometry"] = heha.apply(lambda row: Point(row["lon"], row["lat"]), axis=1)

    # Convert to a GeoDataFrame
    heha = gpd.GeoDataFrame(heha, geometry="geometry")

    # Declare the coordinate system for the places GeoDataFrame
    # GeoPandas doesn't do any transformations automatically when performing
    # the spatial join. The layers are already in the same CRS (WGS84) so no
    # transformation is needed.
    heha.crs = {"init": "epsg:4326"}

    heha = gpd.tools.sjoin(heha, aluejako, how="left")
    heha[c+"_sij23"] = heha["SIJ2023"]
    heha = heha.drop(columns=['index_right', 'SIJ2023'])

heha = heha.dropna(subset=["asuinpaikka_sij23"])
print(heha[["asuinpaikka_sij23"]].head())

heha.to_excel("C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\HEHA-aineistot\\HEHA23_TAUSTAT_KERTOIMET_sij23.xlsx",
             sheet_name='Data',index=False)




