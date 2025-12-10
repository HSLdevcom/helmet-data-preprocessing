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
heha = pd.read_excel("C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\HEHA-aineistot\\Matkat18_V3.xlsx")
for c in ["ap","lp","mp"]:

    heha["geometry"] = heha.apply(lambda row: Point(row[c+"_x"], row[c+"_y"]), axis=1)

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

heha = heha.dropna(subset=["ap_sij23","lp_sij23","mp_sij23"])
print(heha[["ap_sij23","lp_sij23","mp_sij23"]].head())

heha.to_excel("C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\HEHA-aineistot\\Matkat18_sij23.xlsx",
             sheet_name='Data',index=False)

#Process HLT
hlt = pd.read_csv("C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\HLT-aineisto\\PA_PAIKAT_sijoittelualueet.csv")

hlt["geometry"] = hlt.apply(lambda row: Point(row["PA_ETRS89_LON"], row["PA_ETRS89_LAT"]), axis=1)

# Convert to a GeoDataFrame
hlt = gpd.GeoDataFrame(hlt, geometry="geometry")

# Declare the coordinate system for the places GeoDataFrame
# GeoPandas doesn't do any transformations automatically when performing
# the spatial join. The layers are already in the same CRS (WGS84) so no
# transformation is needed.
hlt.crs = {"init": "epsg:4326"}

hlt = gpd.tools.sjoin(hlt, aluejako, how="left")
hlt["sij2023"] = hlt["SIJ2023"].astype("Int64")
hlt = hlt.drop(columns=['index_right'])

hlt = hlt.dropna(subset=['sij2023'])
hlt.to_csv("C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\HLT-aineisto\\PA_PAIKAT_sijoittelualueet_sij2023.csv")

