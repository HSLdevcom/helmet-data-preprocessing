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
                 share_forward=0,
                 share_backward=0,
                 xfactor_forward=0,
                 xfactor_backward=0)
    
    df = subset(df, !is.na(itime))
    
    temp = leftjoin(df, peaks[["morning"]])
    m = which(with(temp, itime >= lower & itime < upper))
    stat$xfactor_forward[1] = sum(temp$xfactor[m] * temp$percentage[m] * temp$forward[m])
    stat$xfactor_backward[1] = sum(temp$xfactor[m] * temp$percentage[m] * !temp$forward[m])
    stat$share_forward[1] = stat$xfactor_forward[1] / sum(df$xfactor)
    stat$share_backward[1] = stat$xfactor_backward[1] / sum(df$xfactor)
    
    temp = leftjoin(df, peaks[["other"]])
    m = which(with(temp, itime >= lower & itime < upper))
    stat$xfactor_forward[2] = sum(temp$xfactor[m] * temp$percentage[m] * temp$forward[m])
    stat$xfactor_backward[2] = sum(temp$xfactor[m] * temp$percentage[m] * !temp$forward[m])
    stat$share_forward[2] = stat$xfactor_forward[2] / sum(df$xfactor)
    stat$share_backward[2] = stat$xfactor_backward[2] / sum(df$xfactor)
    
    temp = leftjoin(df, peaks[["afternoon"]])
    m = which(with(temp, itime >= lower & itime < upper))
    stat$xfactor_forward[3] = sum(temp$xfactor[m] * temp$percentage[m] * temp$forward[m])
    stat$xfactor_backward[3] = sum(temp$xfactor[m] * temp$percentage[m] * !temp$forward[m])
    stat$share_forward[3] = stat$xfactor_forward[3] / sum(df$xfactor)
    stat$share_backward[3] = stat$xfactor_backward[3] / sum(df$xfactor)
    
    return(stat)
})

# Demand share for hoo_leg2 and hoo_leg3 classes is the amount of trips in
# hoo_leg2 and hoo_leg3 classes divided by the amount of trips in the whole hoo
# class (without separate legs).
trips_hoo = subset(trips, model_type %in% c("hoo_leg2", "hoo_leg3"))
trips_hoo = subset(trips_hoo, !is.na(itime))
trips_hoo = fold(trips_hoo, .(mode_name), xfactor=sum(xfactor))
for (i in rows.along(trips_hoo)) {
    m = which(shares$model_type %in% c("hoo_leg2", "hoo_leg3") &
                  shares$mode_name %in% trips_hoo$mode_name[i])
    shares$share_forward[m] = shares$xfactor_forward[m] / trips_hoo$xfactor[i]
    shares$share_backward[m] = shares$xfactor_backward[m] / trips_hoo$xfactor[i]
}

shares = unpick(shares, xfactor_forward, xfactor_backward)

model_types = c(unique(read.delims("models.txt")$model_type), "hoo_leg2", "hoo_leg3")
mode_names = rev(unique(read.delims("modes.txt")$mode_name))

all = expand.grid(model_type=model_types,
                  mode_name=mode_names,
                  scenario=c("aht","pt","iht"),
                  stringsAsFactors=TRUE)
shares = leftjoin(all, shares, missing=0)
shares = arrange(shares, model_type, mode_name, scenario)

save(shares, file="shares.RData")
write.csv2(shares, file="shares.csv", row.names=FALSE)
