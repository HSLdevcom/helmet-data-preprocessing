# -*- coding: utf-8-unix -*-
library(strafica)

trips = load1("trips.RData")
mode_names = unique(read.delims("modes.txt")$mode_name)

morning = expand.grid(mode=mode_names, hh=6:8, mm=0:59, ss=0, stringsAsFactors=FALSE)
morning$lower = sprintf("%s:%s:%s",
                        pad(morning$hh, pad="0", n=2),
                        pad(morning$mm, pad="0", n=2),
                        pad(morning$ss, pad="0", n=2))
morning$upper = sprintf("%s:%s:%s",
                        pad(morning$hh+1, pad="0", n=2),
                        pad(morning$mm, pad="0", n=2),
                        pad(morning$ss, pad="0", n=2))
morning = subset(morning, upper <= "09:00:00")
morning = arrange(morning, lower)
morning$xfactor = 0

for (i in rows.along(morning)) {
    chosen = which(trips$mode_name %in% morning$mode[i] &
                       trips$itime >= morning$lower[i] &
                       trips$itime < morning$upper[i])
    morning$xfactor[i] = sum(trips$xfactor[chosen])
}

morning = arrange(morning, -xfactor)
m_car = min(which(morning$mode %in% "car"))
m_transit = min(which(morning$mode %in% "transit"))
m_walk = min(which(morning$mode %in% "walk"))
m_bike = min(which(morning$mode %in% "bike"))

peak = dfsas(mode_name=c("car", "transit", "bike", "walk"),
             lower=c(morning$lower[m_car],
                     morning$lower[m_transit],
                     morning$lower[m_bike],
                     morning$lower[m_walk]),
             upper=c(morning$upper[m_car],
                     morning$upper[m_transit],
                     morning$upper[m_bike],
                     morning$upper[m_walk]),
             percentage=c(1, 1, 1, 1))

print(peak)
save(peak, file="peak_morning.RData")
