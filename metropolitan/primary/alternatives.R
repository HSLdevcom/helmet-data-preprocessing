# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))


# Load input files
message("Loading input files...")
time.start = Sys.time()
zones = read.csv2(ancfile("area/zones.csv"), stringsAsFactors=FALSE)
matrices = as.data.frame(data.table::fread(ancfile("area/matrices.csv"),
                                           stringsAsFactors=FALSE))
average = as.data.frame(data.table::fread("average.csv",
                                          stringsAsFactors=FALSE))
progress.final(time.start)


# Process static data about alternative end points

message("Processing static data...")
time.start = Sys.time()
azone_columns = c("cbd",
                  "job_density",
                  "population_density",
                  "housing",
                  "cars_per_people",
                  "population",
                  "jobs",
                  "jobs_service",
                  "jobs_shopping",
                  "students_high_school",
                  "students_university",
                  "students_primary_school",
                  "parking_fee_work",
                  "parking_fee_other")
stopifnot(all(azone_columns %in% colnames(zones)))
columns = mclapply.stop(azone_columns, function(name) {
    row = as.data.frame(t(zones[, name, drop=FALSE]))
    zone = zones$zone
    colnames(row) = sprintf("azone_%d_%s", zone, name)
    return(row)
})
# Create one row of data that will be identical to every observation.
row = do.call(cbind, columns)
progress.final(time.start)


# Process matrix data about alternative end points

message("Processing matrix data...")
time.start = Sys.time()

# Join original matrices and average matrices.
matrices$izone = zones$zone[match(matrices$izone, zones$zone_orig)]
matrices$jzone = zones$zone[match(matrices$jzone, zones$zone_orig)]
matrices = matrices[, c("izone",
                        "jzone",
                        "same_municipality",
                        "same_zone",
                        "area",
                        grep("bicycle|pedestrian|cost_transit", colnames(matrices), value=TRUE))]
average$izone = zones$zone[match(average$izone, zones$zone_orig)]
average$jzone = zones$zone[match(average$jzone, zones$zone_orig)]
matrices = leftjoin(matrices, average)
post.gc(rm(average))


# Create a list of square matrices to make joining easier
#   Note: This is an opposite procedure to what happened in 'matrices.R'.
matrix_columns = colnames(matrices)[!grepl("^izone$|^jzone$", colnames(matrices))]
matrix_list = vector("list", length(matrix_columns))
names(matrix_list) = matrix_columns
for (i in seq_along(matrix_columns)) {
    value = matrix_columns[i]
    value_matrix = matrices[, c("izone", "jzone", value)]
    colnames(value_matrix) = c("izone", "azone", value)
    value_matrix = tidyr::spread(value_matrix,
                                 key="azone", value=value, sep="_")
    # We are assumign that the matrix is ordered so that the zone order is
    # identical in rows and columns!
    value_matrix = unpick(value_matrix, izone)
    colnames(value_matrix) = sprintf("%s_%s", colnames(value_matrix), value)
    matrix_list[[value]] = as.matrix(value_matrix)
}
post.gc(rm(matrices))
progress.final(time.start)


# Join data

write_estimation_data = function(alternatives,
                                 batch_size,
                                 model_name,
                                 row,
                                 matrix_list,
                                 columns) {
    nbatch = ceiling(nrow(alternatives) / batch_size)
    average_columns = grep("^avg_", colnames(alternatives), value=TRUE)
    auxiliary_columns = grep("^aux_", colnames(alternatives), value=TRUE)
    
    messagef("Writing estimation data in batches for model '%s'...", model_name)
    time.start = Sys.time()
    for (i in seq(nbatch)) {
        
        if (i %% 5 == 0) progress.eta(time.start, i, nbatch)
        
        start = (i - 1) * batch_size + 1
        stop = i * batch_size
        stop = pclip(stop, 1, nrow(alternatives))
        batch = alternatives[start:stop, ]
        
        static_azone_data = row[rep(1, times=nrow(batch)), ]
        batch = cbind(batch, static_azone_data)
        
        # Origin-, year-, group-, and direction-dependent average matrices
        for (avg in average_columns) {
            emme = mclapply.stop(rows.along(batch), function(j) {
                mat1 = paste(batch[j, avg], "there", sep="_")
                mat2 = paste(batch[j, avg], "back", sep="_")
                matrix_sum1 = get_impedance(matrix_list[[mat1]],
                                            from=batch$izone[j])
                matrix_sum2 = get_impedance(matrix_list[[mat2]],
                                            to=batch$izone[j])
                matrix_sum2 = t(matrix_sum2)
                matrix_sum = matrix_sum1 + matrix_sum2
                matrix_sum = as.data.frame(matrix_sum, row.names=NULL)
                colnames(matrix_sum) = sprintf("X%d", seq(ncol(matrix_sum)))
                return(matrix_sum)
            })
            emme = rbind_all(emme)
            colnames(emme) = sprintf("azone_%d_%s", seq(ncol(emme)), gsub("avg_", "", avg))
            batch = cbind(batch, emme)
        }
        
        # Origin-, year-, and group-dependent
        for (aux in auxiliary_columns) {
            emme = mclapply.stop(rows.along(batch), function(j) {
                mat = batch[j, aux]
                matrix_sum1 = get_impedance(matrix_list[[mat]],
                                            from=batch$izone[j])
                matrix_sum2 = get_impedance(matrix_list[[mat]],
                                            to=batch$izone[j])
                matrix_sum2 = t(matrix_sum2)
                matrix_sum = matrix_sum1 + matrix_sum2
                matrix_sum = as.data.frame(matrix_sum, row.names=NULL)
                colnames(matrix_sum) = sprintf("X%d", seq(ncol(matrix_sum)))
                return(matrix_sum)
            })
            emme = rbind_all(emme)
            colnames(emme) = sprintf("azone_%d_%s", seq(ncol(emme)), gsub("aux_", "", aux))
            batch = cbind(batch, emme)
        }
        
        # Origin-dependent
        batch = cbind(batch, get_matrix_value(matrix_list[["same_zone"]], from=batch$izone))
        batch = cbind(batch, get_matrix_value(matrix_list[["area"]], from=batch$izone))
        
        # Home-dependent
        batch = cbind(batch, get_matrix_value(matrix_list[["same_municipality"]], from=batch$rzone))
        
        # Organize columns
        hits = sapply(rows.along(columns), function(i) {
            grep(columns$column[i], colnames(batch), value=TRUE)
        })
        columns$hits = sapply(hits, length)
        stopifnot(all(columns$hits %in% c(1, nrow(zones))))
        batch = batch[, unlist(hits)]
        
        # The following lines add some running time...
        # check_class(batch, exclude=c("integer","numeric"))
        # check.na(batch)
        
        stopifnot(all(sapply(batch, class) %in% c("integer", "numeric")))
        
        fname = sprintf("alternatives/alternatives-%s-%d_%d.txt",
                        model_name,
                        start,
                        stop)
        write_alogit(batch, fname=fname)
    }
    progress.final(time.start)
    return(colnames(batch))
}


alternatives = load1("observations.RData")

# From which matrix travel times and lengths are read from?
alternatives$aux_ttime_bicycle = sprintf("ttime_bicycle_%d", alternatives$year)
alternatives$aux_length_bicycle_separate_cycleway = sprintf("length_bicycle_separate_cycleway_%d", alternatives$year)
alternatives$aux_length_bicycle_adjacent_cycleway = sprintf("length_bicycle_adjacent_cycleway_%d", alternatives$year)
alternatives$aux_length_bicycle_mixed_traffic = sprintf("length_bicycle_mixed_traffic_%d", alternatives$year)

alternatives$aux_cost_transit_work = sprintf("cost_transit_work_%d", alternatives$year)
alternatives$aux_cost_transit_other = sprintf("cost_transit_other_%d", alternatives$year)

alternatives$aux_ttime_pedestrian = sprintf("ttime_pedestrian_%d", alternatives$year)
alternatives$aux_length_pedestrian = sprintf("length_pedestrian_%d", alternatives$year)

alternatives$avg_ttime_car = sprintf("ttime_car_%d_%s",
                                     alternatives$year,
                                     alternatives$mtype)
alternatives$avg_cost_car = sprintf("cost_car_%d_%s",
                                    alternatives$year,
                                    alternatives$mtype)
alternatives$avg_ttime_transit = sprintf("ttime_transit_%d_%s",
                                         alternatives$year,
                                         alternatives$mtype)

matrices_needed = unique(unlist(alternatives[, grepl("^aux_", names(alternatives))]))
stopifnot(all(matrices_needed %in% names(matrix_list)))

columns = read.delims("order.txt")
columns$column = sprintf("^%s$", columns$column)

hb_work_school_study = c(1,2,3)
hb_shopping_service = c(4)
hb_other = c(5)
nhb = c(6,7)

data_columns = write_estimation_data(alternatives=subset(alternatives,
                                                         ttype %in% hb_work_school_study),
                                     batch_size=100,
                                     model_name="wss",
                                     row=row,
                                     matrix_list=matrix_list,
                                     columns=columns)
message("Writing column names...")
writeLines(data_columns, "alternatives/columns-wss.txt")

data_columns = write_estimation_data(alternatives=subset(alternatives,
                                                         ttype %in% hb_shopping_service),
                                     batch_size=100,
                                     model_name="spb",
                                     row=row,
                                     matrix_list=matrix_list,
                                     columns=columns)
message("Writing column names...")
writeLines(data_columns, "alternatives/columns-spb.txt")

data_columns = write_estimation_data(alternatives=subset(alternatives,
                                                         ttype %in% hb_other),
                                     batch_size=100,
                                     model_name="other",
                                     row=row,
                                     matrix_list=matrix_list,
                                     columns=columns)
message("Writing column names...")
writeLines(data_columns, "alternatives/columns-other.txt")

data_columns = write_estimation_data(alternatives=subset(alternatives,
                                                         ttype %in% nhb),
                                     batch_size=100,
                                     model_name="wbo",
                                     row=row,
                                     matrix_list=matrix_list,
                                     columns=columns)
message("Writing column names...")
writeLines(data_columns, "alternatives/columns-wbo.txt")
