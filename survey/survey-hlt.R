# -*- coding: utf-8-unix -*-
library(strafica)

matk = read.csv2(ancfile("input/HLT-aineisto/M_MATKAT.CSV"),
                 fileEncoding="cp1252",
                 stringsAsFactors=FALSE)
taus = read.csv2(ancfile("input/HLT-aineisto/T_TAUSTA.CSV"),
                 fileEncoding="cp1252",
                 stringsAsFactors=FALSE)
paik = read.csv2(ancfile("input/HLT-aineisto/PA_PAIKAT_sijoittelualueet.csv"),
                 fileEncoding="cp1252",
                 stringsAsFactors=FALSE)


###
### Joining coordinates
###

paik = pick(paik,
            PA_TAUSTAID,
            PA_TRIPROUTESID,
            PA,
            PA_ETRS_TM35FIN_E,
            PA_ETRS_TM35FIN_N,
            PA_KUNTANUMERO,
            sij2019)
paik = rename(paik,
              PA_TAUSTAID=M_TAUSTAID,
              PA_TRIPROUTESID=M_TRIPROUTESID,
              PA=PA_PAIKKAKOODI,
              PA_ETRS_TM35FIN_E=x,
              PA_ETRS_TM35FIN_N=y,
              PA_KUNTANUMERO=kunta)

# Start coordinates
paik_m1 = subset(paik, PA_PAIKKAKOODI=="M1")
paik_m1 = rename(unpick(paik_m1, PA_PAIKKAKOODI),
                 x=ix, y=iy, kunta=ikunta, sij2019=izone)
matk = leftjoin(matk, paik_m1)

# End coordinates
paik_m2 = subset(paik, PA_PAIKKAKOODI=="M2")
paik_m2 = rename(unpick(paik_m2, PA_PAIKKAKOODI),
                 x=jx, y=jy, kunta=jkunta, sij2019=jzone)
matk = leftjoin(matk, paik_m2)

# Home coordinates
paik_k1 = subset(paik, PA_PAIKKAKOODI=="K1")
paik_k1 = rename(unpick(paik_k1, PA_PAIKKAKOODI, M_TRIPROUTESID),
                 M_TAUSTAID=T_TAUSTAID,
                 x=rx, y=ry, kunta=rkunta, sij2019=rzone)
taus = leftjoin(taus, paik_k1)

# Missing values are marked as zero
matk = na.to.zero(matk, c("ix", "iy", "ikunta", "izone", "jx", "jy", "jkunta", "jzone"))
taus = na.to.zero(taus, c("rx", "ry", "rkunta", "rzone"))


###
### Combining expansion factors
###

# If a person belongs to any extra-sampled region, expansion factor is read from
# regional expansion factors. Otherwise, expansion factor is read from national
# expansion factors.
taus$xfactor = ifelse(is.na(taus$T_SEUTURAPO),
                      taus$T_VK_VP_LAAJENNUS,
                      taus$T_VK_VP_SEUTULAAJENNUS)
stopif(any(taus$xfactor < 0.1))


###
### Removing weekends
###

taus = subset(taus, T_ARKI_VL == 1)
matk = subset(matk, M_TAUSTAID %in% taus$T_TAUSTAID)


###
### Time
###

matk$itime = trimws(matk$M_LAHTOAIKA, "both")
matk$itime = substr(matk$itime, 10, 17)
matk$jtime = trimws(matk$M_MAARAAIKA, "both")
matk$jtime = substr(matk$jtime, 10, 17)
matk$itime[matk$itime == ""] = NA
matk$jtime[matk$jtime == ""] = NA
# Survey day is at 00:00-23:59 o'clock!


###
### Trip number
###

# Arranging trips by person identifier and time
matk = arrange(matk, M_TAUSTAID, itime)

# If trip has no start time, person's diary is arranged by M_TRIPROUTESID.
matk = mcddply(matk, .(M_TAUSTAID), function(df) {
    if (any(is.na(df$itime))) {
        df = arrange(df, M_TRIPROUTESID)
    }
    return(df)
})
matk = mcddply(matk, .(M_TAUSTAID), function(df) {
    df$number = rows.along(df)
    return(df)
})

# Check that missing times did not affect original time order.
mcddply(matk, .(M_TAUSTAID), function(df) {
    df = subset(df, !is.na(itime))
    df = arrange(df, itime)
    stopif(is.unsorted(df$number))
})


###
### Unique locations
###

ikoht = pick(matk, M_TAUSTAID, M_TRIPROUTESID, number, M_LTK, ix, iy)
ikoht = rename(ikoht, M_LTK=type, ix=x, iy=y)
ikoht$from = TRUE
jkoht = pick(matk, M_TAUSTAID, M_TRIPROUTESID, number, M_MTK, jx, jy)
jkoht = rename(jkoht, M_MTK=type, jx=x, jy=y)
jkoht$from = FALSE
koht = rbind_list(ikoht, jkoht)
koht = arrange(koht, M_TAUSTAID, number, -from)

.eucd = function(x, y, tx, ty) {
    dist = eucd(x, y, tx, ty)
    m = which(is.na(dist))
    dist[m] = 1000000L
    return(dist)
}

# Rule of thumb: two locations are same if they have same type and their
# distance is at most DISTANCE meters.
DISTANCE = 250
koht = mcddply(koht, .(M_TAUSTAID), function(df) {
    df$tid = 0
    number_of_unique_targets = 0
    for (i in rows.along(df)) {
        # Searching for same type of locations from previous locations.
        m = which(df$type %in% df$type[i])
        m = m[m < i]
        if (length(m) > 0) {
            # Calculating distances
            similar_targets = dfsas(m=m,
                                    dist=.eucd(df$x[i], df$y[i], df$x[m], df$y[m]),
                                    tid=df$tid[m])
            # Arranging locations from closest to farthest. In tie, location
            # with latest visit is first.
            similar_targets = arrange(similar_targets, dist, -m)
            
            # If trip is beginning and the end location of the last trip is
            # similar enough, let's move that to first.
            ended_here_last = FALSE
            j = which(similar_targets$m == (i-1))
            if (df$from[i] && (length(j) == 1) && (similar_targets$dist[j] < DISTANCE)) {
                similar_targets = rbind_list(similar_targets[ j, , drop=FALSE],
                                             similar_targets[-j, , drop=FALSE])
                ended_here_last = TRUE
            }
            
            # Kindergartens and shops will never be identified as already
            # visited locations. This prevents tours starting and ending to same
            # kindergarten/shop.
            if (!ended_here_last & df$type[i] %in% c(8, 9, 10, 11, 12)) {
                similar_targets = similar_targets[0, , drop=FALSE]
            }
            
            if (nrow(similar_targets) > 0 && similar_targets$dist[1] < DISTANCE) {
                # If the first location is close enough, the location is
                # identical.
                df$tid[i] = similar_targets$tid[1]
            } else {
                # If the first location is too far or there is no similar
                # locations, this is a new location.
                number_of_unique_targets = number_of_unique_targets + 1
                df$tid[i] = number_of_unique_targets
            }
        } else {
            # If there are no locations with the same type, this is a new
            # location.
            number_of_unique_targets = number_of_unique_targets + 1
            df$tid[i] = number_of_unique_targets
        }
    }
    return(df)
})
koht$tid = with(koht, classify(M_TAUSTAID, tid))

# Adding location identifiers to trip table.
ikoht = pick(subset(koht, from), M_TAUSTAID, number, tid)
ikoht = rename(ikoht, tid=itid)
matk = leftjoin(matk, ikoht)
ikoht = pick(subset(koht, !from), M_TAUSTAID, number, tid)
jkoht = rename(ikoht, tid=jtid)
matk = leftjoin(matk, jkoht)

# Replace trip types by the ones in HEHA
types = read.delims("types-hlt.txt", fileEncoding="utf-8")
m = match(matk$M_LTK, types$id)
matk$itype = types$type[m]
m = match(matk$M_MTK, types$id)
matk$jtype = types$type[m]
# Children under 18 go to school (3) and adults at and over 18 go to university.
m = which(taus$T_IKA >= 18)
students = taus$T_TAUSTAID[m]
m = which(matk$M_TAUSTAID %in% students & matk$itype == 3)
matk$itype[m] = 12
m = which(matk$M_TAUSTAID %in% students & matk$jtype == 3)
matk$jtype[m] = 12

# Creating a table of unique locations.
ipaik = pick(matk, itid, itype, ix, iy, izone)
jpaik = pick(matk, jtid, jtype, jx, jy, jzone)
paik = rbind_list(rename(ipaik, itid=tid, itype=ttype, ix=x, iy=y, izone=zone),
                  rename(jpaik, jtid=tid, jtype=ttype, jx=x, jy=y, jzone=zone))
paik = dedup(paik, tid)
paik = arrange(paik, tid)


###
### Modes
###

modes = read.delims("modes-hlt.txt", fileEncoding="utf-8")
m = match(matk$M_PAAKULKUTAPA, modes$id)
matk$mode = modes$mode[m]
m = is.na(matk$mode)
matk$mode[m] = -1

# If person is minor and drives a car, he or she is changed as a car passenger.
m = which(taus$T_IKA < 18)
minors = taus$T_TAUSTAID[m]
m = which(matk$mode == 4 & matk$M_TAUSTAID %in% minors)
matk$mode[m] = 5


###
### Length of trip
###

m = which(is.na(matk$M_PITUUS))
matk$length = matk$M_PITUUS
matk$length[m] = 0.0


###
### New person ids
###

taus = arrange(taus, T_TAUSTAID)
taus$pid_orig = taus$T_TAUSTAID
taus$pid = rows.along(taus) + 300000L
matk = leftjoin(matk,
                rename(pick(taus, T_TAUSTAID, pid), T_TAUSTAID=M_TAUSTAID),
                by="M_TAUSTAID")

###
### Rename columns
###

matk = rename(matk, M_TRIPROUTESID=eid)


###
### Output
###

matk = downclass(matk)
write.csv2(matk, file="matkat-hlt.csv", row.names=FALSE)
taus = downclass(taus)
write.csv2(taus, file="tausta-hlt.csv", row.names=FALSE)
paik = downclass(paik)
write.csv2(paik, file="paikat-hlt.csv", row.names=FALSE)

npeople = nrow(taus)
ntrips = nrow(matk)
xpeople = sum(taus$xfactor)
xtrips = sum(taus$xfactor[match(matk$pid, taus$pid)])
sprintf("People: %.0f (n=%d)", xpeople, npeople)
sprintf("Trips: %.0f (n=%d)", xtrips, ntrips)
sprintf("Trips per people: %.2f", xtrips/xpeople)
