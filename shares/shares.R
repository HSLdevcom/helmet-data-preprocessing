# -*- coding: utf-8-unix -*-
library(strafica)

tours = load1("tours.RData")
trips = load1("trips.RData")

peaks = list(morning=load1("peak_morning.RData"),
             other=load1("peak_other.RData"),
             afternoon=load1("peak_afternoon.RData"))

shares = ddply(trips, .(model_type, mode_name), function(df) {
    
    stat = dfsas(model_type=df$model_type[1],
                 mode_name=df$mode_name[1],
                 scenario=c("aht","pt","iht"),
                 xfactor_forward=0,
                 xfactor_backward=0)
    
    all = df
    df = subset(df, !is.na(itime))
    
    temp = leftjoin(df, peaks[["morning"]])
    m = which(with(temp, itime >= lower & itime < upper))
    xfactor_forward = sum(temp$xfactor[m] * temp$percentage[m] * temp$forward[m])
    xfactor_backward = sum(temp$xfactor[m] * temp$percentage[m] * !temp$forward[m])
    share_forward = xfactor_forward / sum(df$xfactor)
    share_backward = xfactor_backward / sum(df$xfactor)
    # Expansion factors are raised to account for missing itimes.
    stat$xfactor_forward[1] = share_forward * sum(all$xfactor)
    stat$xfactor_backward[1] = share_backward * sum(all$xfactor)
    
    temp = leftjoin(df, peaks[["other"]])
    m = which(with(temp, itime >= lower & itime < upper))
    xfactor_forward = sum(temp$xfactor[m] * temp$percentage[m] * temp$forward[m])
    xfactor_backward = sum(temp$xfactor[m] * temp$percentage[m] * !temp$forward[m])
    share_forward = xfactor_forward / sum(df$xfactor)
    share_backward = xfactor_backward / sum(df$xfactor)
    # Expansion factors are raised to account for missing itimes.
    stat$xfactor_forward[2] = share_forward * sum(all$xfactor)
    stat$xfactor_backward[2] = share_backward * sum(all$xfactor)
    
    temp = leftjoin(df, peaks[["afternoon"]])
    m = which(with(temp, itime >= lower & itime < upper))
    xfactor_forward = sum(temp$xfactor[m] * temp$percentage[m] * temp$forward[m])
    xfactor_backward = sum(temp$xfactor[m] * temp$percentage[m] * !temp$forward[m])
    share_forward = xfactor_forward / sum(df$xfactor)
    share_backward = xfactor_backward / sum(df$xfactor)
    # Expansion factors are raised to account for missing itimes.
    stat$xfactor_forward[3] = share_forward * sum(all$xfactor)
    stat$xfactor_backward[3] = share_backward * sum(all$xfactor)
    
    return(stat)
})

# The unit of demand shares is "trips per tour".
shares = leftjoin(shares, tours)
shares$share_forward = shares$xfactor_forward / shares$weight
shares$share_backward = shares$xfactor_backward / shares$weight
shares = unpick(shares, xfactor_forward, xfactor_backward, weight)


###
### Output
###

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
