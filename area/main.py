import pandas as pd

df1 = pd.read_csv("input/estimation_Sami/zonedata_base.csv")

col_dict = {    "Unnamed: 0":"zone",
                "population":"pop",
                "share_age_7-17":"age7to17",
                "share_age_18-29":"age18to29",
                "share_age_30-49":"age30to49",
                "share_age_50-64":"age50to64",
                "share_age_65-99":"age64to99",
                "share_age_7-99":"age7to99",
                "share_age_18-99":"age18to99",
                "share_female":"female",
                "share_male":"male",
                "population_density":"popDens",
                "workplaces":"workplaces",
                "service":"service",
                "shops":"shops",
                "logistics":"logistics",
                "industry":"industry",
                "parking_cost_work": "parkCostW",
                "parking_cost_errand": "parkCostE",
                "comprehesive_schools": "schoolL1",
                "secondary_schools":"schoolL2",
                "tertiary_education":"schoolL3",
                "zone_area":"area",
                "share_detached_houses":"detachS",
                "perc_detached_houses_sqrt":"detachSqrt",
                "helsinki":"helsinki",
                "cbd":"cbd",
                "lauttasaari":"lauttaS",
                "helsinki_other":"helsOther",
                "espoo_vant_kau":"espooVantK",
                "surrounding":"surround",
                "shops_cbd":"shopsCbd",
                "shops_elsewhere":"shopsElse",
                "car_density":"carDens",
                "cars_per_1000":"carsPer1K"}

df1 = df1.rename(columns=col_dict)
df1 = df1 * 1 #hacky way to turn true false into ints
df1 = df1.fillna(0)
df_cols = pd.DataFrame(data = {"columns": ["index"]+list(col_dict.values())})
df_cols.to_csv("../H4_estimointi/Helmet4/helmet_estimation/Aineisto/uudet2023/zonedata_base_cols.csv", index=False)

df1.to_csv("../H4_estimointi/Helmet4/helmet_estimation/Aineisto/uudet2023/zonedata_base.csv", sep=" ")
