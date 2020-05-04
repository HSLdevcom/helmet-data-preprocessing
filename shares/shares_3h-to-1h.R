# -*- coding: utf-8-unix -*-
library(strafica)

trips = load1("trips.RData")
trips$model_type[trips$hoo] = "hoo"

assignment_classes = read.delims("assignment_classes.txt")
trips = leftjoin(trips, assignment_classes, by = "model_type")
trips$transport_class = paste(trips$mode_name, trips$assignment_class, sep = "_")

peaks = list(morning=load1("peak_morning.RData"),
             other=load1("peak_other.RData"),
             afternoon=load1("peak_afternoon.RData"))

shares_mode_name = ddply(trips, .(mode_name), function(df) {
    
    stat = dfsas(mode_name=df$mode_name[1],
                 scenario=c("aht","pt","iht"),
                 share=0)
    
    all = df
    # Expansion factors are raised to account for missing itimes.
    df = subset(df, !is.na(itime))
    df$xfactor = (sum(all$xfactor) / sum(df$xfactor)) * df$xfactor
    
    df_aht = subset(df, itime >= "06:00:00" & itime < "09:00:00")
    df_pt = subset(df, itime >= "09:00:00" & itime < "15:00:00")
    df_iht = subset(df, itime >= "15:00:00" & itime < "18:00:00")
    
    temp = leftjoin(df_aht, peaks[["morning"]])
    m = which(with(temp, itime >= lower & itime < upper))
    xfactor = sum(temp$xfactor[m] * temp$percentage[m])
    stat$share[1] = xfactor / sum(df_aht$xfactor)
    
    temp = leftjoin(df_pt, peaks[["other"]])
    m = which(with(temp, itime >= lower & itime < upper))
    xfactor = sum(temp$xfactor[m] * temp$percentage[m])
    stat$share[2] = xfactor / sum(df_pt$xfactor)
    
    temp = leftjoin(df_iht, peaks[["afternoon"]])
    m = which(with(temp, itime >= lower & itime < upper))
    xfactor = sum(temp$xfactor[m] * temp$percentage[m])
    stat$share[3] = xfactor / sum(df_iht$xfactor)
    
    return(stat)
})

shares_transport_class = ddply(trips, .(transport_class), function(df) {
    
    stat = dfsas(transport_class=df$transport_class[1],
                 scenario=c("aht","pt","iht"),
                 share=0)
    
    all = df
    # Expansion factors are raised to account for missing itimes.
    df = subset(df, !is.na(itime))
    df$xfactor = (sum(all$xfactor) / sum(df$xfactor)) * df$xfactor
    
    df_aht = subset(df, itime >= "06:00:00" & itime < "09:00:00")
    df_pt = subset(df, itime >= "09:00:00" & itime < "15:00:00")
    df_iht = subset(df, itime >= "15:00:00" & itime < "18:00:00")
    
    temp = leftjoin(df_aht, peaks[["morning"]])
    m = which(with(temp, itime >= lower & itime < upper))
    xfactor = sum(temp$xfactor[m] * temp$percentage[m])
    stat$share[1] = xfactor / sum(df_aht$xfactor)
    
    temp = leftjoin(df_pt, peaks[["other"]])
    m = which(with(temp, itime >= lower & itime < upper))
    xfactor = sum(temp$xfactor[m] * temp$percentage[m])
    stat$share[2] = xfactor / sum(df_pt$xfactor)
    
    temp = leftjoin(df_iht, peaks[["afternoon"]])
    m = which(with(temp, itime >= lower & itime < upper))
    xfactor = sum(temp$xfactor[m] * temp$percentage[m])
    stat$share[3] = xfactor / sum(df_iht$xfactor)
    
    return(stat)
})


###
### Output
###

mode_names = rev(unique(read.delims("modes.txt")$mode_name))

all = expand.grid(mode_name=mode_names,
                  scenario=c("aht","pt","iht"),
                  stringsAsFactors=TRUE)
shares = leftjoin(all, shares_mode_name, missing=0)
shares = arrange(shares, mode_name, scenario)

save(shares, file="shares_by_mode_3h-to-1h.RData")
write.csv2(shares, file="shares_by_mode_3h-to-1h.csv", row.names=FALSE)

all = expand.grid(transport_class=paste(mode_names, c("work", "leisure"), sep = "_"),
                  scenario=c("aht","pt","iht"),
                  stringsAsFactors=TRUE)
shares = leftjoin(all, shares_transport_class, missing=0)
shares = arrange(shares, mode_name, scenario)

save(shares, file="shares_by_transport_class_3h-to-1h.RData")
write.csv2(shares, file="shares_by_transport_class_3h-to-1h.csv", row.names=FALSE)
