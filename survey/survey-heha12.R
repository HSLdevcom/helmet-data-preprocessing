# -*- coding: utf-8-unix -*-
library(strafica)
library(readxl)
library(lubridate)

matk = load1(ancfile("input/raw-heha12.RData"))
matk$length = matk$PITUUS
matk$eid = matk$matkaid

taus = pick(matk,
            juokseva, montako_matkaa, kerroin, ika, sukup_laaj,
            ap_kela, montako_autoa, onko_ajokortti, miten_usein_auto_kaytettavissa, toimi,
            kotitalous_0_6v, kotitalous_kaikki, ap_sij19,
            lippu_hsl_kausi, lippu_hsl_arvo, lippu_mobiililippu, lippu_muu_kausi, lippu_muu_arvo)
taus = rename(taus, ap_sij19=rzone, kerroin=xfactor)
taus = dedup(taus, juokseva)

matk = subset(matk, montako_matkaa > 0)


###
### Location types
###

types = read.delims("types-heha12.txt", fileEncoding="utf-8")
m = match(matk$LP, types$type_heha2012)
matk$itype = types$type_heha2018[m]
m = match(matk$MP, types$type_heha2012)
matk$jtype = types$type_heha2018[m]
# Children under 18 go to school (3) and adults at and over 18 go to university.
m = which(matk$ika >= 18 & matk$itype == 3)
matk$itype[m] = 12
m = which(matk$ika >= 18 & matk$jtype == 3)
matk$jtype[m] = 12


###
### Coordinates
###

matk$ix = matk$lp_x
matk$iy = matk$lp_y
matk$jx = matk$mp_x
matk$jy = matk$mp_y


###
### Home coordinates
###

matk$rx = matk$ap_x
matk$ry = matk$ap_y
# If trip is going home but missing coordinates, they are copied from
# background information.
m = which(matk$itype == 1 & is.na(matk$ix) & is.na(matk$iy))
matk$ix[m] = matk$rx[m]
matk$iy[m] = matk$ry[m]
m = which(matk$jtype == 1 & is.na(matk$jx) & is.na(matk$jy))
matk$jx[m] = matk$rx[m]
matk$jy[m] = matk$ry[m]


###
### Time
###

hms_string_from_datetime = function(x, start_from=4) {
    y = sprintf("%02d:%02d:%02d",
                ifelse(hour(x)>=start_from, hour(x), hour(x)+24),
                minute(x),
                second(x))
    y = as.character(y)
    m = which(is.na(x))
    y[m] = NA
    return(y)
}

matk$idatetime = ymd_hms(matk$LPdttm, tz="Europe/Helsinki")
matk$itime = hms_string_from_datetime(matk$idatetime)
matk$jdatetime = ymd_hms(matk$MPdttm, tz="Europe/Helsinki")
matk$jtime = hms_string_from_datetime(matk$jdatetime)

# If a trip is missing all four attributes, it is most likely an error.
matk = subset(matk, !(is.na(itime) & is.na(jtime) & is.na(LP) & is.na(MP)))


###
### Trip number
###

# Arranging by person identifier and time
matk = arrange(matk, juokseva, itime)

matk = mcddply(matk, .(juokseva), function(df) {
    df$number = rows.along(df)
    return(df)
})


###
### Time spent on location
###

times = mcddply(matk, .(juokseva), function(df) {
    if (nrow(df) == 1) return(NULL)
    times = data.frame(type=NA, staytime=NA)
    for (i in rows.along(df)) {
        if (i == nrow(df)) break
        if (df$jtype[i]==df$itype[i+1]) {
            staytime = df$jdatetime[i] %--% df$idatetime[i+1]
            staytime = as.duration(staytime)
            staytime = staytime / dminutes(1)
            times = rbind_list(times,
                               data.frame(type=df$jtype[i],
                                          staytime=staytime))
        }
    }
    times = subset(times, !is.na(type))
    return(times)
})
fold(times, .(type), tmed=median(staytime), tmean=mean(staytime), tmin=min(staytime), tmax=max(staytime))


###
### Imputation
###

# Staytimes are given in minutes based on estimated in previous part.
flip_trip = function(trip,
                     staytimes=c(90, 420, 300, 10, 30, 90, 90, 90, 90, 30, 45, 240)) {
    # Argument trip refers to one row in travel survey data
    stopif(nrow(trip) != 1)
    flipped_trip = trip
    flipped_trip[,] = NA
    flipped_trip$juokseva = trip$juokseva
    flipped_trip$username = trip$username
    flipped_trip$xfactor = trip$xfactor
    flipped_trip$eid = 0
    flipped_trip$ix = trip$jx
    flipped_trip$iy = trip$jy
    flipped_trip$jx = trip$ix
    flipped_trip$jy = trip$iy
    flipped_trip$itype = trip$jtype
    flipped_trip$jtype = trip$itype
    flipped_trip$lp_sij19 = trip$mp_sij19
    flipped_trip$mp_sij19 = trip$lp_sij19
    # 30 minutes is spent on the location
    staytime = staytimes[trip$jtype]
    flipped_trip$idatetime = trip$jdatetime + minutes(staytime)
    flipped_trip$itime = hms_string_from_datetime(flipped_trip$idatetime)
    # Trip back takes as long as the first trip
    flipped_trip$jdatetime = flipped_trip$idatetime + (trip$jdatetime - trip$idatetime)
    flipped_trip$jtime = hms_string_from_datetime(flipped_trip$jdatetime)
    flipped_trip$Paakulkutapa = trip$Paakulkutapa
    flipped_trip$length = trip$length
    flipped_trip$number = trip$number + 0.5
    flipped_trip$imputated = TRUE
    flipped_trip = unpick(flipped_trip,
                          LPdttm, MPdttm,
                          dt1, tm1, dt2, tm2,
                          LPdttm_, MPdttm_)
    return(flipped_trip)
}

matk$imputated = FALSE
matk = mcddply(matk, .(juokseva), function(df) {
    n = nrow(df)

    if (n > 1 && all(df$itype %in% 1) && all(df$jtype %nin% 1)) {
        # There are more than one trip and all trips begin from home but never
        # arrive there.
        new_trips = mclapply.stop(rows.along(df), function(i) {
            return(flip_trip(df[i,,drop=FALSE]))
        })
        new_trips = rbind_all(new_trips)

        df = rbind_list(df, new_trips)
        df = arrange(df, number)
        df$number = rows.along(df)

        return(df)
    }

    new_trips = df[0,,drop=FALSE]
    for (i in rows.along(df)) {
        last = (i == n)
        starts_home = (df$itype[i] %in% 1)
        next_starts_home = ifelse(last, TRUE, df$itype[i+1] %in% 1)
        no_overnight = (df$jtype[i] %in% c(2,3,4,5,8,11,12))
        does_not_end_home = (df$jtype[i] %nin% c(1))

        if ((last && starts_home && no_overnight) ||
                (starts_home && next_starts_home && does_not_end_home)) {

            #
            # Imputate if
            #
            # 1. This trip is the last or the only one, it starts from home, and
            #    it ends somewhere where people do not traditionally stay
            #    overnight,
            #
            # or
            #
            # 2. This trip starts from home as well as the next trip, but this
            #    trip did not end home.
            #

            new_trip = flip_trip(df[i,,drop=FALSE])
            new_trips = rbind_list(new_trips, new_trip)

        }
    }

    df = rbind_list(df, new_trips)
    df = arrange(df, number)
    df$number = rows.along(df)
    return(df)
})
m = which(matk$imputated)
matk$eid[m] = max(matk$eid) + seq(length(m))


###
### Unique locations
###

ikoht = pick(matk, juokseva, eid, number, itype, ix, iy)
ikoht = rename(ikoht, itype=type, ix=x, iy=y)
ikoht$from = TRUE
jkoht = pick(matk, juokseva, eid, number, jtype, jx, jy)
jkoht = rename(jkoht, jtype=type, jx=x, jy=y)
jkoht$from = FALSE
koht = rbind_list(ikoht, jkoht)
koht = arrange(koht, juokseva, number, -from)

.eucd = function(x, y, tx, ty) {
    dist = eucd(x, y, tx, ty)
    m = which(is.na(dist))
    dist[m] = 1000000L
    return(dist)
}

# Rule of thumb: two locations are same if they have same type and their
# distance is at most DISTANCE meters.
DISTANCE = 250
koht = mcddply(koht, .(juokseva), function(df) {
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
            if (!ended_here_last & df$type[i] %in% c(4, 5)) {
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
koht$tid = with(koht, classify(juokseva, tid))

# Adding location identifiers to trip table.
ikoht = pick(subset(koht, from), juokseva, number, tid)
ikoht = rename(ikoht, tid=itid)
matk = leftjoin(matk, ikoht)
ikoht = pick(subset(koht, !from), juokseva, number, tid)
jkoht = rename(ikoht, tid=jtid)
matk = leftjoin(matk, jkoht)

# Creating a table of unique locations.
ipaik = pick(matk, itid, itype, ix, iy, lp_sij19)
jpaik = pick(matk, jtid, jtype, jx, jy, mp_sij19)
paik = rbind_list(rename(ipaik, itid=tid, itype=ttype, ix=x, iy=y, lp_sij19=zone),
                  rename(jpaik, jtid=tid, jtype=ttype, jx=x, jy=y, mp_sij19=zone))
paik = dedup(paik, tid)
paik = arrange(paik, tid)


###
### Modes
###

modes = read.delims("modes-heha12.txt", fileEncoding="utf-8")
m = match(matk$PKTAPA2, modes$PKTAPA2)
matk$mode = modes$mode[m]
m = is.na(matk$mode)
matk$mode[m] = -1


###
### New person ids
###

taus = arrange(taus, juokseva)
taus$pid_orig = taus$juokseva
taus$pid = rows.along(taus) + 100000L
matk = leftjoin(matk, pick(taus, juokseva, pid), by="juokseva")


###
### Python fixes
###

m = which(is.na(matk$ap_sij19))
matk$ap_sij19[m] = -1


###
### Output
###

matk = downclass(matk)
write.csv2(matk, file="matkat-heha12.csv", row.names=FALSE)
taus = downclass(taus)
write.csv2(taus, file="tausta-heha12.csv", row.names=FALSE)
paik = downclass(paik)
write.csv2(paik, file="paikat-heha12.csv", row.names=FALSE)

npeople = nrow(taus)
ntrips = nrow(matk)
xpeople = sum(taus$xfactor)
xtrips = sum(taus$xfactor[match(matk$pid, taus$pid)])
sprintf("People: %.0f (n=%d)", xpeople, npeople)
sprintf("Trips: %.0f (n=%d)", xtrips, ntrips)
sprintf("Trips per people: %.2f", xtrips/xpeople)
