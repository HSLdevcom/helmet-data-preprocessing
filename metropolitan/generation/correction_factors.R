# -*- coding: utf-8-unix -*-
library(strafica)

modelled_combinations = read.delims("modelled_combinations.txt")
ttypes = load1("ttypes.RData")

ttypes$not_modelled = ttypes$ttypes_model %nin% modelled_combinations$tour_combination
ttypes$too_long = ttypes$homebased_tours > 4

fold(ttypes, .(homebased_tours, not_modelled, too_long),
     n=length(pid))

people = load1(ancfile("primary/background.RData"))
people = pick(people, pid, xfactor)
ttypes = leftjoin(ttypes, people)

# People with 0 or 1 homebased tours have all been modelled.

# People with 3 homebased tours:
m1 = which(ttypes$homebased_tours == 2 & !ttypes$not_modelled)
m2 = which(ttypes$homebased_tours == 2 & ttypes$not_modelled)
sum(ttypes$xfactor[m2]) / sum(ttypes$xfactor[m1])

# People with 3 homebased tours:
m1 = which(ttypes$homebased_tours == 3 & !ttypes$not_modelled)
m2 = which(ttypes$homebased_tours == 3 & ttypes$not_modelled)
sum(ttypes$xfactor[m2]) / sum(ttypes$xfactor[m1])

# People with 4 homebased tours:
m1 = which(ttypes$homebased_tours >= 4 & !ttypes$not_modelled)
m2 = which(ttypes$homebased_tours >= 4 & ttypes$not_modelled)
sum(ttypes$xfactor[m2]) / sum(ttypes$xfactor[m1])
m3 = which(ttypes$homebased_tours >= 4 & ttypes$too_long)
sum((ttypes$homebased_tours[m3] - 4) / 4 * ttypes$xfactor[m3]) / sum(ttypes$xfactor[m1])

