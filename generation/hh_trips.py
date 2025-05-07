import pandas as pd
import matplotlib.pyplot as plt

# #Process HEHA
heha = pd.read_excel("C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\HEHA-aineistot\\HEHA23_MATKAT_KERTOIMET.xlsx")
print(len(heha))
heha.query("kerroin_arki>0.001", inplace=True)
print(len(heha))
lenkit = heha.query("LENKKI==1")
print(len(lenkit))
#print(lenkit.head())
print(lenkit["kerroin_arki"].sum()/heha["kerroin_arki"].sum())

taustat = pd.read_excel("C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\HEHA-aineistot\\HEHA23_TAUSTAT_KERTOIMET.xlsx")
taustat.query("kerroin_arki>0.001", inplace=True)
print("Per capita: ",lenkit["kerroin_arki"].sum()/taustat["kerroin_arki"].sum())
#taustat = taustat[["username"]]
taustat['username']=taustat['username'].astype(str)
lenkit['username']=lenkit['username'].astype(str)
print(taustat.head())
print(taustat.dtypes)
print(lenkit.dtypes)
print(lenkit["username"].dtype,taustat["username"].dtype)

lenkit = lenkit.set_index("username").join(taustat.set_index("username"),on="username",how="left",lsuffix="_lenkit",rsuffix="_taustat")
print(lenkit.head())

modes = {1: "car",2: "pt", 3: "bike", 4: "walk", 5: "other"}
ages = []
shares = []
pop = []
age_groups = [(7,17),(18,29),(30,49),(50,64),(65,99)]
ag_bins = [6.5,17.5,29.5,49.5,64.5,99.5]
for age in range(100):
    pop_share = taustat.query("ika==@age")["kerroin_arki"].sum()
    share = float(lenkit.query("ika==@age")["kerroin_arki_lenkit"].sum()/pop_share)
    print(f'{age}:',share)
    ages.append(age)
    pop.append(pop_share)
    shares.append(share)
# df_ages = pd.DataFrame({"age":ages,"pop":pop})
# df_grouped = df_ages["pop"].groupby(pd.cut(df_ages['ika'], bins=ag_bins, labels=age_groups)).agg("sum")
# print(df_grouped)
for ag in age_groups:
    age_start,age_end = ag
    pop_share = taustat.query("ika>@age_start & ika<=@age_end")["kerroin_arki"].sum()
    share = float(lenkit.query("ika>@age_start & ika<=@age_end")["kerroin_arki_lenkit"].sum())
    print(ag,share/pop_share)
plt.plot(ages,shares)
for mode in modes:
    print(f'{modes[mode]}: {lenkit.query("pktapa2_luok==@mode")["kerroin_arki_lenkit"].sum()/lenkit["kerroin_arki_lenkit"].sum()}')
# heha.to_excel("C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\HEHA-aineistot\\HEHA23_MATKAT_KERTOIMET_sij23.xlsx",
#              sheet_name='Data',index=False)
plt.show()