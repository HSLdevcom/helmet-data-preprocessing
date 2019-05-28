#!/bin/bash
if [ $# < 1 ]; then
  echo 1>&2 "Usage: $0 DIRECTORY_TO_RAW_DATA <OUTPUT_DIRECTORY>"
  exit 1
fi

RAW_DATA_FOLDER=$1
echo "Mounting and reading raw data from ${RAW_DATA_FOLDER}"

OUTPUT_FOLDER=${2:-'tours/output/'}
echo "Mounting and writing output to ${OUTPUT_FOLDER}"

# Mount external dependencies (proprietary libraries and data)
docker run -it --rm \
  -v ${PWD}/${RAW_DATA_FOLDER}:/helmet-data-preprocessing/input/raw/ \
  -v ${PWD}/${OUTPUT_FOLDER}:/helmet-data-preprocessing/tours/output/ \
  -v ${PWD}/strafica:/helmet-data-preprocessing/strafica \
  helmet-data-preprocessing
