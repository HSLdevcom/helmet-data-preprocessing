# -*- coding: utf-8-unix -*-
library(strafica)

trips = load1("trips.RData")
mode_names = unique(read.delims("modes.txt")$mode_name)

afternoon = expand.grid(mode=mode_names, hh=15:17, mm=0:59, ss=0, stringsAsFactors=FALSE)
afternoon$itime_trip = sprintf("%s:%s:%s",
                             pad(afternoon$hh, pad="0", n=2),
                             pad(afternoon$mm, pad="0", n=2),
                             pad(afternoon$ss, pad="0", n=2))
afternoon$jtime_trip = sprintf("%s:%s:%s",
                             pad(afternoon$hh+1, pad="0", n=2),
                             pad(afternoon$mm, pad="0", n=2),
                             pad(afternoon$ss, pad="0", n=2))
afternoon = subset(afternoon, jtime_trip <= "18:00:00")
afternoon = arrange(afternoon, itime_trip)
afternoon$xfactor = 0

for (i in rows.along(afternoon)) {
    chosen = which(trips$mode_name %in% afternoon$mode[i] &
                       trips$itime_trip >= afternoon$itime_trip[i] &
                       trips$itime_trip < afternoon$jtime_trip[i])
    afternoon$xfactor[i] = sum(trips$xfactor[chosen])
}

afternoon = arrange(afternoon, -xfactor)
m_car = min(which(afternoon$mode %in% "car"))
m_transit = min(which(afternoon$mode %in% "transit"))
m_walk = min(which(afternoon$mode %in% "walk"))
m_bike = min(which(afternoon$mode %in% "bike"))

peak = dfsas(mode_name=c("car", "transit", "bike", "walk"),
             lower=c(afternoon$itime_trip[m_car],
                     afternoon$itime_trip[m_transit],
                     afternoon$itime_trip[m_bike],
                     afternoon$itime_trip[m_walk]),
             upper=c(afternoon$jtime_trip[m_car],
                     afternoon$jtime_trip[m_transit],
                     afternoon$jtime_trip[m_bike],
                     afternoon$jtime_trip[m_walk]),
             percentage=c(1, 1, 1, 1))

print(peak)
save(peak, file="peak_afternoon.RData")
