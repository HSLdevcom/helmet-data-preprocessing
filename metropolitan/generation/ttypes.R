# -*- coding: utf-8-unix -*-
library(strafica)

.rep = function(x, times) {
    times = na.to.zero(times)
    return(rep(x=x, times=times))
}

observations = load1(ancfile("primary/observations.RData"))
combinations = mcddply(observations, .(pid), function(df) {
    stat = data.frame(pid=df$pid[1])
    stat$homebased_tours = sum(df$ttype %in% 1:5)
    stat$class_t = sum(df$ttype %in% 1)
    stat$class_k = sum(df$ttype %in% 2)
    stat$class_o = sum(df$ttype %in% 3)
    stat$class_a = sum(df$ttype %in% 4)
    stat$class_m = sum(df$ttype %in% 5)
    stat$class_tko = sum(df$ttype %in% 1:3)
    return(stat)
})
# Remove people with zero home-based tours
combinations = subset(combinations, homebased_tours > 0)

# Lists all tour types regardless of how many there are
combinations$ttypes_long = unlist(mclapply(rows.along(combinations), function(i) {
    types = c(.rep("T", times=combinations$class_t[i]),
              .rep("K", times=combinations$class_k[i]),
              .rep("O", times=combinations$class_o[i]),
              .rep("A", times=combinations$class_a[i]),
              .rep("M", times=combinations$class_m[i]))
    paste(types, collapse=" - ")
}))


# People with 4 or more tours have short tour types. Tour types are chosen by
# prioritizing tour types: typically, having even one TKO tour overrides
# everything else.
priority = expand.grid(homebased_tours=0,
                   class_tko=0:4,
                   class_a=0:4,
                   class_m=0:4)
priority$homebased_tours = rowSums(priority)
priority = subset(priority, homebased_tours %in% 4)
priority = arrange(priority, homebased_tours, -class_tko, -class_a, -class_m)
priority$ttypes_name = unlist(mclapply(rows.along(priority), function(i) {
    types = c(.rep("TKO", times=priority$class_tko[i]),
              .rep("A", times=priority$class_a[i]),
              .rep("M", times=priority$class_m[i]))
    paste(types, collapse=" - ")
}))

combinations$ttypes_short = ifelse(combinations$homebased_tours < 4,
                                   combinations$ttypes_long, NA)
for (i in rows.along(priority)) {
    selected = with(combinations,
                    is.na(combinations$ttypes_short) &
                        class_tko >= priority$class_tko[i] &
                        class_a >= priority$class_a[i] &
                        class_m >= priority$class_m[i])
    combinations$ttypes_short[selected] = priority$ttypes_name[i]
}


# Modeling is done with exploded TKO-A-A-M, TKO-A-M-M, and TKO-M-M-M tour types.
combinations$ttypes_model = combinations$ttypes_short

m = which(combinations$ttypes_short %in% "TKO - A - A - M" &
              grepl("^T", combinations$ttypes_long))
combinations$ttypes_model[m] = "T - A - A - M"
m = which(combinations$ttypes_short %in% "TKO - A - A - M" &
              grepl("^K", combinations$ttypes_long))
combinations$ttypes_model[m] = "K - A - A - M"
m = which(combinations$ttypes_short %in% "TKO - A - A - M" &
              grepl("^O", combinations$ttypes_long))
combinations$ttypes_model[m] = "O - A - A - M"

m = which(combinations$ttypes_short %in% "TKO - A - M - M" &
              grepl("^T", combinations$ttypes_long))
combinations$ttypes_model[m] = "T - A - M - M"
m = which(combinations$ttypes_short %in% "TKO - A - M - M" &
              grepl("^K", combinations$ttypes_long))
combinations$ttypes_model[m] = "K - A - M - M"
m = which(combinations$ttypes_short %in% "TKO - A - M - M" &
              grepl("^O", combinations$ttypes_long))
combinations$ttypes_model[m] = "O - A - M - M"

m = which(combinations$ttypes_short %in% "TKO - M - M - M" &
              grepl("^T", combinations$ttypes_long))
combinations$ttypes_model[m] = "T - M - M - M"
m = which(combinations$ttypes_short %in% "TKO - M - M - M" &
              grepl("^K", combinations$ttypes_long))
combinations$ttypes_model[m] = "K - M - M - M"
m = which(combinations$ttypes_short %in% "TKO - M - M - M" &
              grepl("^O", combinations$ttypes_long))
combinations$ttypes_model[m] = "O - M - M - M"

save(combinations, file="ttypes.RData")
