import csv
import numpy as np
import openmatrix as omx

#Process impedances for secondary destinations
observations = "C:\\Users\\HajduPe\\H4_estimointi\\Helmet4\\helmet_estimation\\Aineisto\\uudet2023\\havainnot23\\SEC.txt"
obs_cols = "C:\\Users\\HajduPe\\helmet-data-preprocessing\\metropolitan\\secondary\\alternatives\\columns.txt"
impedances_per_obs = "C:\\Users\\HajduPe\\helmet-data-preprocessing\\output\\impedances\\SEC_vastukset.txt"
impendances = omx.open_file('C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\estimation_Sami\\oo.omx') #Must have all 2098 zones
zones_num = 2098

cols = {}
with open(obs_cols, "r") as cols_file:
    for e,attr in enumerate(csv.reader(cols_file)):
        cols[attr[0]] = e

matrix_list = ["walk_dist","walk_time"]+list(impendances.list_matrices())
imp_arrays = {}
scaler = 0.5
for matrix_key in matrix_list:
    if matrix_key == "walk_dist":
        imp_arrays["walk_dist"] = np.array(impendances["bike_dist"]) * scaler
    elif matrix_key == "walk_time":
        imp_arrays["walk_time"] = np.array(impendances["bike_time"]) * 3 * scaler
    else:
        imp_arrays[matrix_key] = np.array(impendances[matrix_key]) * scaler

# print(imp_arrays.keys())
# print(imp_arrays["walk_dist"][0,1])
counter = 1

weird_count = 0
good_count = 0

with open(impedances_per_obs, "w", newline='') as out_file:
    writer = csv.writer(out_file, delimiter=' ',
                            quotechar='|', quoting=csv.QUOTE_MINIMAL)

    with open(observations, "r") as obs_file:
        for obs in csv.reader(obs_file):
            obs_data = {col:data for col,data in zip(cols,obs[0].split(" "))}

            #Python indexes from zero, zones and Alogit are from 1
            pfrom = int(obs_data["izone"])-1
            pto = int(obs_data["jzone"])-1
            new_row = [obs_data["pid"]]
            #print(pfrom, pto)

            for matrix_name in imp_arrays:
                for i in range(0, zones_num):
                    # delta = (a+b) - c
                    kval = imp_arrays[matrix_name][pto,i] + imp_arrays[matrix_name][i,pfrom]
                    no_kval = imp_arrays[matrix_name][pto,pfrom]
                    delta_val = kval - no_kval
                    if delta_val>1000: 
                        if matrix_name == "car_time": weird_count+=1
                        delta_val = 1000
                    if delta_val<0:
                        #print(f"Between zone {pfrom} and {pto} delta {delta_val} if going via {i}, casting to zero")
                        delta_val = 0
                        weird_count+=1
                    else:
                        good_count+=1
                    new_row.append(delta_val)
            writer.writerow(new_row)
            counter += 1
            # if counter > 5: break

impendances.close()
print(f"Weird values less than zero: {weird_count}\nGood values: {good_count}")
# for matrix_name in imp_arrays:
#     print(matrix_name, np.max(imp_arrays[matrix_name]))
