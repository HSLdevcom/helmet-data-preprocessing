# -*- coding: utf-8-unix -*-
library(strafica)

YEAR = 2016

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

# Calculating weights from origin
weights_there = create_time_averaging_weights(mtypes=observations$mtype,
                                              peaks=observations$ipeak,
                                              xfactors=observations$xfactor)
weights_there$direction = "there"

# Calculating weights to origin
weights_back = create_time_averaging_weights(mtypes=observations$mtype,
                                             peaks=observations$jpeak,
                                             xfactors=observations$xfactor)
weights_back$direction = "back"

weights = rbind_list(weights_there,
                     weights_back)
print(weights)
write.csv2(weights, file="weights.csv", row.names=FALSE)

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
        morning = sprintf("%s_aht_%d", columns[i], YEAR)
        afternoon = sprintf("%s_iht_%d", columns[i], YEAR)
        other = sprintf("%s_pt_%d", columns[i], YEAR)
        stopifnot(morning %in% colnames(matrices))
        stopifnot(afternoon %in% colnames(matrices))
        stopifnot(other %in% colnames(matrices))
        average[, n] = weights$morning[j]*matrices[, morning] +
            weights$afternoon[j]*matrices[, afternoon] +
            weights$other[j]*matrices[, other]
        average_names[n] = sprintf("%s_%d_%s_%s",
                                   columns[i],
                                   YEAR,
                                   weights$mtype[j],
                                   weights$direction[j])
    }
}
average = as.data.frame(average)
colnames(average) = average_names
average = cbind(pick(matrices, izone, jzone),
                average)
head(average)

# Output
data.table::fwrite(average, file="average.csv")
