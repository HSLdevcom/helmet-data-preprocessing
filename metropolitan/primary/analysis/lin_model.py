import pandas as pd
from sklearn import linear_model
from sklearn.metrics import mean_squared_error, r2_score
import matplotlib.pyplot as plt
import math


data = pd.read_csv("OTH_by_zone.csv",sep=";")
inputs = [
data["pop"].apply(lambda x: math.pow(x,1)).values,
data["jobs"].values,
data["service"].apply(lambda x: math.pow(x,1)).values,
data["shops"].apply(lambda x: math.pow(x,1)).values,
data["zone_area"].values,
data["cbd"].values,
]
y = data.OBS_COUNT.values

x=[]
for i in range(len(inputs[0])):
    x.append([var[i] for var in inputs])
#x=[[var] for var in inputs for vars in inputs]
length = len(x)
#x = x.reshape(length, 1)
y = y.reshape(length, 1)

regr = linear_model.LinearRegression(positive=True)
regr.fit(x, y)

y_pred = regr.predict(x)

# The coefficients
print("Coefficients: \n", regr.coef_)
# The mean squared error
print("Mean squared error: %.2f" % mean_squared_error(y, y_pred))
# The coefficient of determination: 1 is perfect prediction
print("Coefficient of determination: %.2f" % r2_score(y, y_pred))

# Plot outputs
plt.scatter(y,y_pred, color="black")
#plt.scatter(y,[math.exp(v/200) for v in y_pred], color="blue")
plt.plot([0,8e3], [0,8e3], color="blue", linewidth=1)
#plt.plot(x, y_pred, color="blue", linewidth=3)

plt.xticks(())
plt.yticks(())

plt.show()

