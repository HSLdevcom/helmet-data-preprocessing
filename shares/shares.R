# -*- coding: utf-8-unix -*-
library(strafica)

tours = load1("tours.RData")
trips = load1("trips.RData")

ah = dfsas(mode_name=c("car", "transit", "bike", "walk","pnr"),
             lower=c("06:00:00",
                     "06:00:00",
                     "06:00:00",
                     "06:00:00",
                     "06:00:00"),
             upper=c("09:00:00",
                     "09:00:00",
                     "09:00:00",
                     "09:00:00",
                     "09:00:00"),
             percentage=c(1, 1, 1, 1, 1))

ih = dfsas(mode_name=c("car", "transit", "bike", "walk","pnr"),
             lower=c("15:00:00",
                     "15:00:00",
                     "15:00:00",
                     "15:00:00",
                     "15:00:00"),
             upper=c("18:00:00",
                     "18:00:00",
                     "18:00:00",
                     "18:00:00",
                     "18:00:00"),
             percentage=c(1, 1, 1, 1, 1))

p = dfsas(mode_name=c("car", "transit", "bike", "walk","pnr"),
             lower1=c("06:00:00",
                     "06:00:00",
                     "06:00:00",
                     "06:00:00",
                     "06:00:00"),
             upper1=c("09:00:00",
                     "09:00:00",
                     "09:00:00",
                     "09:00:00",
                     "09:00:00"),
             lower2=c("15:00:00",
                     "15:00:00",
                     "15:00:00",
                     "15:00:00",
                     "15:00:00"),
             upper2=c("18:00:00",
                     "18:00:00",
                     "18:00:00",
                     "18:00:00",
                     "18:00:00"),
             percentage=c(1, 1, 1, 1, 1))

peaks = list(morning=load1("peak_morning.RData"),
             other=load1("peak_other.RData"),
             afternoon=load1("peak_afternoon.RData")
             )

# peaks = list(ah=ah,
#              p=p,
#              ih=ih)

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

#     temp = leftjoin(df, peaks[["ah"]])
#     m = which(with(temp, itime >= lower & itime < upper))
#     xfactor_forward = sum(temp$xfactor[m] * temp$percentage[m] * temp$forward[m])
#     xfactor_backward = sum(temp$xfactor[m] * temp$percentage[m] * !temp$forward[m])
#     share_forward = xfactor_forward / sum(df$xfactor)
#     share_backward = xfactor_backward / sum(df$xfactor)
#     # Expansion factors are raised to account for missing itimes.
#     stat$xfactor_forward[4] = share_forward * sum(all$xfactor)
#     stat$xfactor_backward[4] = share_backward * sum(all$xfactor)
    
#     temp = leftjoin(df, peaks[["p"]])
#     m = which(with(temp, (itime < lower1 | itime >= upper1) & (itime < lower2 | itime >= upper2)))
#     xfactor_forward = sum(temp$xfactor[m] * temp$percentage[m] * temp$forward[m])
#     xfactor_backward = sum(temp$xfactor[m] * temp$percentage[m] * !temp$forward[m])
#     share_forward = xfactor_forward / sum(df$xfactor)
#     share_backward = xfactor_backward / sum(df$xfactor)
#     # Expansion factors are raised to account for missing itimes.
#     stat$xfactor_forward[5] = share_forward * sum(all$xfactor)
#     stat$xfactor_backward[5] = share_backward * sum(all$xfactor)
    
#     temp = leftjoin(df, peaks[["ih"]])
#     m = which(with(temp, itime >= lower & itime < upper))
#     xfactor_forward = sum(temp$xfactor[m] * temp$percentage[m] * temp$forward[m])
#     xfactor_backward = sum(temp$xfactor[m] * temp$percentage[m] * !temp$forward[m])
#     share_forward = xfactor_forward / sum(df$xfactor)
#     share_backward = xfactor_backward / sum(df$xfactor)
#     # Expansion factors are raised to account for missing itimes.
#     stat$xfactor_forward[6] = share_forward * sum(all$xfactor)
#     stat$xfactor_backward[6] = share_backward * sum(all$xfactor)
    
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
#model_types = c(unique(tours$model_type))
mode_names = rev(unique(read.delims("modes.txt")$mode_name))

all = expand.grid(model_type=model_types,
                  mode_name=mode_names,
                #   scenario=c("aht","pt","iht","ah","p","ih"),
                  scenario=c("aht","pt","iht"),
                  stringsAsFactors=TRUE)
shares = leftjoin(all, shares, missing=0)
shares = arrange(shares, model_type, mode_name, scenario)

save(shares, file="shares.RData")
write.csv2(shares, file="shares.csv", row.names=FALSE)
