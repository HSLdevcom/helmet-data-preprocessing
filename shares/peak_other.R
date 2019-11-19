# -*- coding: utf-8-unix -*-
library(strafica)

peak = dfsas(mode_name=c("car", "transit", "bike", "walk"),
             lower=c("09:00:00",
                     "09:00:00",
                     "09:00:00",
                     "09:00:00"),
             upper=c("15:00:00",
                     "15:00:00",
                     "15:00:00",
                     "15:00:00"),
             percentage=c(1/6, 1/6, 1/6, 1/6))

save(peak, file="peak_other.RData")
