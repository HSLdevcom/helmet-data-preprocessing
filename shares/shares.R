# -*- coding: utf-8-unix -*-
library(strafica)

trips = load1("trips.RData")

peaks = list(morning=load1("peak_morning.RData"),
             other=load1("peak_other.RData"),
             afternoon=load1("peak_afternoon.RData"))

shares = ddply(trips, .(model_type, mode_name), function(df) {
    
    stat = dfsas(model_type=df$model_type[1],
                 mode_name=df$mode_name[1],
                 scenario=c("aht","pt","iht"),
                 share_from_origin=0,
                 share_to_origin=0)
    
    df = subset(df, !is.na(itime))
    
    temp = leftjoin(df, peaks[["morning"]])
    m = which(with(temp, itime >= lower & itime < upper))
    stat$share_from_origin[1] = sum(temp$xfactor[m] * temp$percentage[m] * temp$from_origin[m]) / sum(df$xfactor)
    stat$share_to_origin[1] = sum(temp$xfactor[m] * temp$percentage[m] * !temp$from_origin[m]) / sum(df$xfactor)
    
    temp = leftjoin(df, peaks[["other"]])
    m = which(with(temp, itime >= lower & itime < upper))
    stat$share_from_origin[2] = sum(temp$xfactor[m] * temp$percentage[m] * temp$from_origin[m]) / sum(df$xfactor)
    stat$share_to_origin[2] = sum(temp$xfactor[m] * temp$percentage[m] * !temp$from_origin[m]) / sum(df$xfactor)
    
    temp = leftjoin(df, peaks[["afternoon"]])
    m = which(with(temp, itime >= lower & itime < upper))
    stat$share_from_origin[3] = sum(temp$xfactor[m] * temp$percentage[m] * temp$from_origin[m]) / sum(df$xfactor)
    stat$share_to_origin[3] = sum(temp$xfactor[m] * temp$percentage[m] * !temp$from_origin[m]) / sum(df$xfactor)
    
    return(stat)
})

model_types = unique(read.delims("models.txt")$model_type)
mode_names = unique(read.delims("modes.txt")$mode_name)

all = expand.grid(model_type=model_types,
                  mode_name=mode_names,
                  scenario=c("aht","pt","iht"),
                  stringsAsFactors=TRUE)
shares = leftjoin(all, shares, missing=0)
shares = arrange(shares, model_type, mode_name, scenario)

save(shares, file="shares.RData")
write.csv2(shares, file="shares.csv", row.names=FALSE)
