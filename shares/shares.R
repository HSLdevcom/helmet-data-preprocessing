# -*- coding: utf-8-unix -*-
library(strafica)

trips = load1("trips.RData")

peaks = list(morning=load1("peak_morning.RData"),
             other=load1("peak_other.RData"),
             afternoon=load1("peak_afternoon.RData"))

temp = leftjoin(trips, peaks[["morning"]])
m = which(with(temp, itime_trip >= lower & itime_trip < upper))
share = sum(temp$xfactor[m] * temp$percentage[m]) / sum(temp$xfactor)
print(share)

temp = leftjoin(trips, peaks[["afternoon"]])
m = which(with(temp, itime_trip >= lower & itime_trip < upper))
share = sum(temp$xfactor[m] * temp$percentage[m]) / sum(temp$xfactor)
print(share)

temp = leftjoin(trips, peaks[["other"]])
m = which(with(temp, itime_trip >= lower & itime_trip < upper))
share = sum(temp$xfactor[m] * temp$percentage[m]) / sum(temp$xfactor)
print(share)
