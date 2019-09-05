# -*- coding: windows-1252-dos -*-
library(strafica)

observations = load1(ancfile("estimation/observations-metropolitan.RData"))
combinations = mcddply(observations, .(pid), function(df) {
    stat = data.frame(pid=df$pid[1])
    stat$homebased_tours = sum(df$ttype %in% 1:5)
    stat$class_t = sum(df$ttype %in% 1)
    stat$class_k = sum(df$ttype %in% 2)
    stat$class_o = sum(df$ttype %in% 3)
    stat$class_a = sum(df$ttype %in% 4)
    stat$class_m = sum(df$ttype %in% 5)
    stat$class_tko = sum(df$ttype %in% 1:3)
    stat$ttypes_name = NA
    return(stat)
})
combinations = subset(combinations, homebased_tours > 0)

.rep = function(x, times) {
    times = na.to.zero(times)
    return(rep(x=x, times=times))
}

combinations$full_ttypes = unlist(mclapply(rows.along(combinations), function(i) {
    types = c(.rep("T", times=combinations$class_t[i]),
              .rep("K", times=combinations$class_k[i]),
              .rep("O", times=combinations$class_o[i]),
              .rep("A", times=combinations$class_a[i]),
              .rep("M", times=combinations$class_m[i]))
    paste(types, collapse=" - ")
}))
combinations$ttypes_name = ifelse(combinations$homebased_tours <= 3,
                                  combinations$full_ttypes,
                                  NA)


# 4+ tours
priority = expand.grid(no_of_homebased_tours=0,
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

for (i in rows.along(priority)) {
    selected = with(combinations,
                    is.na(ttypes_name) &
                        class_tko >= priority$class_tko[i] &
                        class_a >= priority$class_a[i] &
                        class_m >= priority$class_m[i])
    combinations$ttypes_name[selected] = priority$ttypes_name[i]
}

save(combinations, file="ttypes.RData")
