#!/bin/bash
# -*- coding: utf-8-unix -*-
(cd area/ && sh batch.sh)
(cd survey/ && sh batch.sh)
pipenv run python ./tours/main.py input-config-heha.json
pipenv run python ./tours/main.py input-config-hlt.json
(cd estimation/ && sh batch.sh)

cat estimation/alternatives/alternatives-peripheral-1_100.txt | fold -w 180 -s > output/estimation/alternatives-peripheral-test.txt
cat estimation/alternatives/alternatives-constructed-peripheral-1_100.txt | fold -w 180 -s > output/estimation/alternatives-constructed-peripheral-test.txt
cat estimation/alternatives/alternatives-constructed-metropolitan-1_100.txt | fold -w 180 -s > output/estimation/alternatives-constructed-metropolitan-test.txt
cat estimation/alternatives/alternatives-wss-metropolitan-1_100.txt | fold -w 180 -s > output/estimation/alternatives-wss-metropolitan-test.txt
cat estimation/alternatives/alternatives-spbo-metropolitan-1_100.txt | fold -w 180 -s > output/estimation/alternatives-spbo-metropolitan-test.txt
cat estimation/alternatives/alternatives-wbo-metropolitan-1_100.txt | fold -w 180 -s > output/estimation/alternatives-wbo-metropolitan-test.txt
cat estimation/alternatives/alternatives-secondary-metropolitan-1_100.txt | fold -w 180 -s > output/estimation/alternatives-secondary-metropolitan-test.txt

cat estimation/alternatives/alternatives-peripheral-*.txt | fold -w 180 -s > output/estimation/alternatives-peripheral.txt
cat estimation/alternatives/alternatives-constructed-peripheral-*.txt | fold -w 180 -s > output/estimation/alternatives-constructed-peripheral.txt
cat estimation/alternatives/alternatives-constructed-metropolitan-*.txt | fold -w 180 -s > output/estimation/alternatives-constructed-metropolitan.txt
cat estimation/alternatives/alternatives-wss-metropolitan-*.txt | fold -w 180 -s > output/estimation/alternatives-wss-metropolitan.txt
cat estimation/alternatives/alternatives-spbo-metropolitan-*.txt | fold -w 180 -s > output/estimation/alternatives-spbo-metropolitan.txt
cat estimation/alternatives/alternatives-wbo-metropolitan-*.txt | fold -w 180 -s > output/estimation/alternatives-wbo-metropolitan.txt
cat estimation/alternatives/alternatives-secondary-metropolitan-*.txt | fold -w 180 -s > output/estimation/alternatives-secondary-metropolitan.txt

