#!/bin/bash

# Mount external dependencies (proprietary libraries and data)
docker run -it --rm -v ${PWD}/strafica:/helmet-data-preprocessing/strafica helmet-data-preprocessing
