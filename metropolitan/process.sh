#!/bin/bash
# -*- coding: utf-8-unix -*-
(cd primary/ && sh process.sh)
(cd secondary/ && sh process.sh)
(cd constructed/ && sh process.sh)
(cd generation/ && sh process.sh)
