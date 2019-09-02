# -*- coding: windows-1252-dos -*-
library(strafica)

observations = load1(ancfile("estimation/observations-metropolitan.RData"))

background = load1(ancfile("estimation/background.RData"))
background = subset(background, survey %in% 0 & (rzone_capital_region | rzone_surrounding_municipality))

background = subset(background, pid %nin% observations$pid)
stat0 = dfsas(no_of_homebased_tours=0,
              class_t=0,
              class_k=0,
              class_o=0,
              class_a=0,
              class_m=0,
              class_tko=0,
              xfactor=sum(background$xfactor),
              n=nrow(background))

combinations = mcddply(observations, .(pid), function(df) {
    stat = data.frame(pid=df$pid[1])
    stat$no_of_homebased_tours = sum(df$ttype %in% 1:5)
    stat$class_t = sum(df$ttype %in% 1)
    stat$class_k = sum(df$ttype %in% 2)
    stat$class_o = sum(df$ttype %in% 3)
    stat$class_a = sum(df$ttype %in% 4)
    stat$class_m = sum(df$ttype %in% 5)
    stat$class_tko = sum(df$ttype %in% 1:3)
    stat$xfactor = df$xfactor[1]
    return(stat)
})


# 0 tours

# stat0 includes only people who have made zero tours (zero home-based tours,
# zero non-home-based tours). combinations will include people with one or more
# tours, including people who have made zero home-based tours and one or several
# non-home-based tours.
combinations0 = subset(combinations, no_of_homebased_tours %in% 0)
combinations0$n = 1
stat0 = rbind_list(stat0, combinations0)
stat0 = fold(stat0, .(no_of_homebased_tours, class_t, class_k, class_o, class_a, class_m),
             xfactor=sum(xfactor),
             n=sum(n))
all0 = stat0


# 1-4 tours
combinations1 = subset(combinations, no_of_homebased_tours %in% 1:3)
stat1 = fold(combinations1, .(no_of_homebased_tours, class_t, class_k, class_o, class_a, class_m),
             xfactor=sum(xfactor),
             n=length(pid))

all1 = expand.grid(no_of_homebased_tours=0,
                   class_t=0:3,
                   class_k=0:3,
                   class_o=0:3,
                   class_a=0:3,
                   class_m=0:3)
all1$no_of_homebased_tours = rowSums(all1)
all1 = subset(all1, no_of_homebased_tours %in% 1:3)
all1 = leftjoin(all1, stat1, missing=0)
all1 = arrange(all1, no_of_homebased_tours, -class_t, -class_k, -class_o, -class_a, -class_m)


# 4+ tours
combinations2 = subset(combinations, no_of_homebased_tours >= 4)
stat2 = fold(combinations2, .(no_of_homebased_tours, class_tko, class_a, class_m),
             xfactor=sum(xfactor),
             n=length(pid))

all2 = expand.grid(no_of_homebased_tours=0,
                   class_tko=0:4,
                   class_a=0:4,
                   class_m=0:4)
all2$no_of_homebased_tours = rowSums(all2)
all2 = subset(all2, no_of_homebased_tours %in% 4)
all2 = arrange(all2, no_of_homebased_tours, -class_tko, -class_a, -class_m)
all2$xfactor = 0
all2$n = 0

for (i in rows.along(all2)) {
    selected = with(stat2, class_tko >= all2$class_tko[i] & class_a >= all2$class_a[i] & class_m >= all2$class_m[i])
    all2$xfactor[i] = sum(stat2$xfactor[selected])
    all2$n[i] = sum(stat2$n[selected])
    stat2 = stat2[!selected, ]
}


.rep = function(x, times) {
    times = na.to.zero(times)
    return(rep(x=x, times=times))
}

# Output
all = rbind_list(all0, all1, all2)
all = pick(all, no_of_homebased_tours, class_t, class_k, class_o, class_tko, class_a, class_m, xfactor, n)
all$name = unlist(mclapply(rows.along(all), function(i) {
    types = c(.rep("T", times=all$class_t[i]),
              .rep("K", times=all$class_k[i]),
              .rep("O", times=all$class_o[i]),
              .rep("TKO", times=all$class_tko[i]),
              .rep("A", times=all$class_a[i]),
              .rep("M", times=all$class_m[i]))
    paste(types, collapse=" - ")
}))
write.delim(all, fname="no_of_tours_by_type.txt")
