# -*- coding: utf-8-unix -*-
library(strafica)

trips = load1("trips.RData")
mode_names = unique(read.delims("modes.txt")$mode_name)

afternoon = expand.grid(mode=mode_names, hh=15:17, mm=0:59, ss=0, stringsAsFactors=FALSE)
afternoon$lower = sprintf("%s:%s:%s",
                          pad(afternoon$hh, pad="0", n=2),
                          pad(afternoon$mm, pad="0", n=2),
                          pad(afternoon$ss, pad="0", n=2))
afternoon$upper = sprintf("%s:%s:%s",
                          pad(afternoon$hh+1, pad="0", n=2),
                          pad(afternoon$mm, pad="0", n=2),
                          pad(afternoon$ss, pad="0", n=2))
afternoon = subset(afternoon, upper <= "18:00:00")
afternoon = arrange(afternoon, lower)
afternoon$xfactor = 0

for (i in rows.along(afternoon)) {
    chosen = which(trips$mode_name %in% afternoon$mode[i] &
                       trips$itime >= afternoon$lower[i] &
                       trips$itime < afternoon$upper[i])
    afternoon$xfactor[i] = sum(trips$xfactor[chosen])
}

afternoon = arrange(afternoon, -xfactor)
m_car = min(which(afternoon$mode %in% "car"))
m_transit = min(which(afternoon$mode %in% "transit"))
m_walk = min(which(afternoon$mode %in% "walk"))
m_bike = min(which(afternoon$mode %in% "bike"))

peak = dfsas(mode_name=c("car", "transit", "bike", "walk"),
             lower=c(afternoon$lower[m_car],
                     afternoon$lower[m_transit],
                     afternoon$lower[m_bike],
                     afternoon$lower[m_walk]),
             upper=c(afternoon$upper[m_car],
                     afternoon$upper[m_transit],
                     afternoon$upper[m_bike],
                     afternoon$upper[m_walk]),
             percentage=c(1, 1, 1, 1))

print(peak)
save(peak, file="peak_afternoon.RData")
