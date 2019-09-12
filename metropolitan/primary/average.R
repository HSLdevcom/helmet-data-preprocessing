# -*- coding: utf-8-unix -*-
library(strafica)

matrices = as.data.frame(data.table::fread(ancfile("area/matrices.csv"),
                                           stringsAsFactors=FALSE))

# Average travel time, length, and car cost matrices
observations = load1("observations.RData")

create_time_averaging_weights = function(mtypes, peaks, xfactors) {
    weights = dfsas(mtype=mtypes,
                    peak=peaks,
                    xfactor=xfactors)
    weights = subset(weights, !is.na(peak))
    weights = fold(weights, .(mtype, peak), xfactor=sum(xfactor))
    weights = tidyr::spread(weights, key=peak, value=xfactor)
    cols = c("morning","afternoon","other")
    weights[, cols] = weights[, cols] / rowSums(weights[, cols])
    return(weights)
}

# Calculating weights for tours to direction 1
weights_there = create_time_averaging_weights(mtypes=observations$mtype,
                                         peaks=ifelse(observations$inverted,
                                                      observations$jpeak,
                                                      observations$ipeak),
                                         xfactors=observations$xfactor)
weights_there$direction = "there"

# Calculating weights for tours to direction 2
weights_back = create_time_averaging_weights(mtypes=observations$mtype,
                                         peaks=ifelse(observations$inverted,
                                                      observations$ipeak,
                                                      observations$jpeak),
                                         xfactors=observations$xfactor)
weights_back$direction = "back"

weights = rbind_list(weights_there,
                     weights_back)
print(weights)

# Generate matrices based on weights
columns = c("ttime_car",
            "length_car",
            "cost_car",
            "ttime_transit")
average = matrix(NA, nrow=nrow(matrices), ncol=length(columns)*nrow(weights))
average_names = rep(NA, length(columns)*nrow(weights))
n = 0
for (i in seq_along(columns)) {
    for (j in rows.along(weights)) {
        n = n + 1
        morning = sprintf("%s_aht_%d", columns[i], weights$year[j])
        afternoon = sprintf("%s_iht_%d", columns[i], weights$year[j])
        other = sprintf("%s_pt_%d", columns[i], weights$year[j])
        stopifnot(morning %in% colnames(matrices))
        stopifnot(afternoon %in% colnames(matrices))
        stopifnot(other %in% colnames(matrices))
        average[, n] = weights$morning[j]*matrices[, morning] +
            weights$afternoon[j]*matrices[, afternoon] +
            weights$other[j]*matrices[, other]
        average_names[n] = sprintf("%s_%d_%s",
                                   columns[i],
                                   weights$year[j],
                                   weights$mtype[j])
    }
}
average = as.data.frame(average)
colnames(average) = average_names
average = cbind(pick(matrices, izone, jzone),
                average)
head(average)

# Output
data.table::fwrite(average, file="average.csv")
