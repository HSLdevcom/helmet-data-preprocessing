#!/bin/bash
# -*- coding: utf-8-unix -*-
(sh primary/ && sh process.sh)
(sh secondary/ && sh process.sh)
(sh constructed/ && sh process.sh)
(sh generation/ && sh process.sh)
