import openmatrix as omx
import numpy as np
import csv

#Expected working folder: helmet-data-preprocessing/impedances

#Process matrices into csv files for Alogit
impendances = ["hc","ho","hoo","hs","hu","hw","oo","wh","wo",
               "hop","hwp","oop","sop","park_and_ride_utility"]
for imp in impendances:
    myfile = omx.open_file('C:\\Users\\HajduPe\\helmet-data-preprocessing\\input\\estimation_Sami\\'+imp+'.omx')
    print ("Impedance", imp)
    print ('Shape:', myfile.shape())                 # (100,100)
    print ('Number of tables:', len(myfile))         # 3
    print ('Table names:', myfile.list_matrices())   # ['m1','m2',',m3']
    matrix_list = list(myfile.list_matrices())
    zone_shift = 0 if imp not in ["hop","hwp","sop"] else 1771
    counter = 0
    for matrix_key in matrix_list:
        with open('output/impedances/'+imp+'_'+str(matrix_key)+'.csv', 'w', newline='\n') as csvfile:
            writer = csv.writer(csvfile, delimiter=' ',
                                    quotechar='|', quoting=csv.QUOTE_MINIMAL)
            if np.sum(myfile[matrix_key])>1e10: 
                print(f"{matrix_key} has sum {np.sum(myfile[matrix_key])}")
                for e,row in enumerate(myfile[matrix_key]):
                    if max(row)>10000: 
                        for ry, y in enumerate(row):
                            if y>10000:
                                counter += 1
                                if counter % 1000 == 0: print(f"Suspicious cell {e+1+zone_shift},{ry+1} with value {y}")
                        writer.writerow([e+1+zone_shift] + list([r if r<1e5 else 1e5 for r in row])) #capping max value to 100000
                    else:
                        writer.writerow([e+1+zone_shift] + list(row))
            else:
                for e,row in enumerate(myfile[matrix_key]):
                    writer.writerow([e+1+zone_shift] + list(row))
    myfile.close()


            

            

