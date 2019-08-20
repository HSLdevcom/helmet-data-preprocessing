#!/bin/bash
# -*- coding: utf-8-unix -*-
(cd area/ && sh batch.sh)
(cd survey/ && sh batch.sh)
pipenv run python ./tours/main.py input-config-heha.json
pipenv run python ./tours/main.py input-config-hlt.json
(cd estimation/ && sh batch.sh)
(cd secondary/ && sh batch.sh)

cat estimation/alternatives/alternatives-peripheral-1_100.txt | fold -w 180 -s > output/estimation/alternatives-peripheral-test.txt
cat estimation/alternatives/alternatives-constructed-peripheral-1_100.txt | fold -w 180 -s > output/estimation/alternatives-constructed-peripheral-test.txt
cat estimation/alternatives/alternatives-constructed-metropolitan-1_100.txt | fold -w 180 -s > output/estimation/alternatives-constructed-metropolitan-test.txt
cat estimation/alternatives/alternatives-wss-metropolitan-1_100.txt | fold -w 180 -s > output/estimation/alternatives-wss-metropolitan-test.txt
cat estimation/alternatives/alternatives-spb-metropolitan-1_100.txt | fold -w 180 -s > output/estimation/alternatives-spb-metropolitan-test.txt
cat estimation/alternatives/alternatives-other-metropolitan-1_100.txt | fold -w 180 -s > output/estimation/alternatives-other-metropolitan-test.txt
cat estimation/alternatives/alternatives-wbo-metropolitan-1_100.txt | fold -w 180 -s > output/estimation/alternatives-wbo-metropolitan-test.txt

cat estimation/alternatives/alternatives-peripheral-*.txt | fold -w 180 -s > output/estimation/alternatives-peripheral.txt
cat estimation/alternatives/alternatives-constructed-peripheral-*.txt | fold -w 180 -s > output/estimation/alternatives-constructed-peripheral.txt
cat estimation/alternatives/alternatives-constructed-metropolitan-*.txt | fold -w 180 -s > output/estimation/alternatives-constructed-metropolitan.txt
cat estimation/alternatives/alternatives-wss-metropolitan-*.txt | fold -w 180 -s > output/estimation/alternatives-wss-metropolitan.txt
cat estimation/alternatives/alternatives-spb-metropolitan-*.txt | fold -w 180 -s > output/estimation/alternatives-spb-metropolitan.txt
cat estimation/alternatives/alternatives-other-metropolitan-*.txt | fold -w 180 -s > output/estimation/alternatives-other-metropolitan.txt
cat estimation/alternatives/alternatives-wbo-metropolitan-*.txt | fold -w 180 -s > output/estimation/alternatives-wbo-metropolitan.txt

cat secondary/alternatives/alternatives-metropolitan-secondary-1_100.txt | fold -w 180 -s > output/estimation/alternatives-metropolitan-secondary-test.txt
cat secondary/alternatives/alternatives-metropolitan-secondary-*.txt | fold -w 180 -s > output/estimation/alternatives-metropolitan-secondary.txt
