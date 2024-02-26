# -*- coding: utf-8-unix -*-
library(strafica)

# This is an R rewrite of batch.sh to be run in Windows without Docker.

# Note that this is not the recommended way of doing things anymnore. At least,
# consider using 'here' instead of paths and working directories.

verbose_source <- function(file, encoding="UTF-8", ...) {
  message(sprintf("*** Running %s... ***", basename(file)))
  invisible(source(file, encoding=encoding, ...))
}

ROOT_DIRECTORY <- getwd()

setwd("area")
verbose_source("zones.R")
verbose_source("matrices.R")
setwd(ROOT_DIRECTORY)

setwd("survey")
verbose_source("raw-heha.R")
verbose_source("survey-heha.R")
verbose_source("survey-hlt.R")
setwd(ROOT_DIRECTORY)

# TODO: Find out how to set up a pipenv environment and run these commands. Can
# we do it inside R or do we need to open a terminal window?
# pipenv run python ./tours/main.py input-config-heha.json
# pipenv run python ./tours/main.py input-config-hlt.json

setwd("metropolitan/primary/")
verbose_source("background.R")
verbose_source("tours.R")
verbose_source("observations.R")
verbose_source("average.R")
setwd(ROOT_DIRECTORY)

setwd("metropolitan/secondary/")
verbose_source("tours.R")
verbose_source("observations.R")
setwd(ROOT_DIRECTORY)

setwd("metropolitan/constructed/")
verbose_source("tours.R")
verbose_source("observations.R")
setwd(ROOT_DIRECTORY)

setwd("peripheral/primary/")
verbose_source("background.R")
verbose_source("tours.R")
verbose_source("observations.R")
verbose_source("average.R")
setwd(ROOT_DIRECTORY)

setwd("peripheral/constructed/")
verbose_source("tours.R")
verbose_source("observations.R")
setwd(ROOT_DIRECTORY)

setwd("metropolitan/primary/")
verbose_source("alternatives.R")
setwd(ROOT_DIRECTORY)

setwd("metropolitan/secondary/")
verbose_source("alternatives.R")
setwd(ROOT_DIRECTORY)

setwd("metropolitan/constructed/")
verbose_source("alternatives.R")
setwd(ROOT_DIRECTORY)

setwd("metropolitan/generation/")
verbose_source("ttypes.R")
verbose_source("alternatives.R")
setwd(ROOT_DIRECTORY)

setwd("peripheral/primary/")
verbose_source("alternatives.R")
setwd(ROOT_DIRECTORY)

setwd("peripheral/constructed/")
verbose_source("alternatives.R")
setwd(ROOT_DIRECTORY)

setwd("generation")
verbose_source("generation-peripheral.R")
verbose_source("generation-metropolitan.R")
verbose_source("generation-metropolitan-secondary.R")
setwd(ROOT_DIRECTORY)

setwd("calibration")
verbose_source("tours.R")
verbose_source("demand.R")
verbose_source("length.R")
verbose_source("own_zone_demand.R")
verbose_source("car_user.R")
verbose_source("driver_share.R")
verbose_source("demand_from_zones.R")
verbose_source("output.R")
setwd(ROOT_DIRECTORY)

setwd("shares")
verbose_source("tours.R")
verbose_source("trips.R")
verbose_source("peak_morning.R")
verbose_source("peak_afternoon.R")
verbose_source("peak_other.R")
verbose_source("shares.R")
setwd(ROOT_DIRECTORY)

# TODO: Study how files in batch.sh were moved and renamed if you wish to
# improve readability. Now, files are left in directories where they were first
# printed.

# TODO: Fold estimation data files to 180 characters so that they are readable
# by Alogit. This can be done in command like like so:
# cat metropolitan/primary/alternatives/alternatives-wss-*.txt | fold -w 180 -s > $OUTPUT/alternatives-metropolitan-wss.txt
