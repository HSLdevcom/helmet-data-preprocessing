#!/bin/bash
if (( $# < 1 )); then
  echo 1>&2 "Usage: $0 DIRECTORY_TO_RAW_DATA <OUTPUT_DIRECTORY>"
  exit 1
fi

INPUT_FOLDER=${PWD}/$1
echo "Mounting and reading input data from local dir ${INPUT_FOLDER}"

OUTPUT_FOLDER=${PWD}/${2:-'estimation/alternatives'}
echo "Mounting and writing output to local dir ${OUTPUT_FOLDER}"

# Mount external dependencies (proprietary libraries and data)
docker run -it --rm \
  -v ${INPUT_FOLDER}:/helmet-data-preprocessing/data/raw/ \
  -v ${OUTPUT_FOLDER}:/helmet-data-preprocessing/output/ \
  -v ${PWD}/strafica:/helmet-data-preprocessing/strafica \
  helmet-data-preprocessing
