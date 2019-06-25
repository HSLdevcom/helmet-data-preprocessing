# -*- coding: windows-1252-dos -*-
library(strafica)

matrices = as.data.frame(data.table::fread(ancfile("area/matrices.csv"),
                                           stringsAsFactors=FALSE))

# Average travel time, length, and car cost matrices
observations = rbind_list(load1("observations-metropolitan.RData"),
                          load1("observations-peripheral.RData"))
weights = dfsas(year=c(observations$year, observations$year),
                xfactor=c(observations$xfactor, observations$xfactor),
                mtype=c(observations$mtype, observations$mtype),
                peak=c(observations$ipeak, observations$jpeak))
weights = subset(weights, !is.na(peak))
weights = fold(weights, .(year, mtype, peak), xfactor=sum(xfactor))
weights = tidyr::spread(weights, peak, xfactor)
weights[, c("morning","afternoon","other")] = weights[, c("morning","afternoon","other")] / rowSums(weights[, c("morning","afternoon","other")])

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
