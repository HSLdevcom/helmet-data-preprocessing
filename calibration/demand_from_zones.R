# -*- coding: utf-8-unix -*-
library(strafica)

tours = load1("tours.RData")
tours$model_type = factor(tours$model_type,
                          levels=c("hw","hc","hu","hs","ho",
                                   "hoo","so","wo","oo",
                                   "hwp","hop",
                                   "sop","oop"))
stat = fold(tours, .(izone_orig, model_type),
            n=length(pid),
            weight=sum(weight))
stat = rename(stat, izone_orig=izone)
write.csv2(stat, file="demand_from_zones.csv", row.names=FALSE)
print(stat)
