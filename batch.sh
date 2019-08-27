#!/bin/bash
# -*- coding: utf-8-unix -*-
read_default() {
    read -p "$1: [$2] " REPLY && echo "${REPLY:-$2}"
}
OUTPUT=$(read_default "Path to output folder" "/output")

(cd area/ && sh batch.sh)
(cd survey/ && sh batch.sh)
pipenv run python ./tours/main.py input-config-heha.json
pipenv run python ./tours/main.py input-config-hlt.json
(cd estimation/ && sh batch.sh)
(cd secondary/ && sh batch.sh)

cp -ruv tours/tours-*.csv $OUTPUT/

cp -ruv estimation/alternatives/columns-*.txt $OUTPUT/

cat estimation/alternatives/alternatives-peripheral-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-peripheral-test.txt
cat estimation/alternatives/alternatives-constructed-peripheral-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-constructed-peripheral-test.txt
cat estimation/alternatives/alternatives-constructed-metropolitan-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-constructed-metropolitan-test.txt
cat estimation/alternatives/alternatives-wss-metropolitan-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-wss-metropolitan-test.txt
cat estimation/alternatives/alternatives-spb-metropolitan-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-spb-metropolitan-test.txt
cat estimation/alternatives/alternatives-other-metropolitan-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-other-metropolitan-test.txt
cat estimation/alternatives/alternatives-wbo-metropolitan-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-wbo-metropolitan-test.txt

cat estimation/alternatives/alternatives-peripheral-*.txt | fold -w 180 -s > $OUTPUT/alternatives-peripheral.txt
cat estimation/alternatives/alternatives-constructed-peripheral-*.txt | fold -w 180 -s > $OUTPUT/alternatives-constructed-peripheral.txt
cat estimation/alternatives/alternatives-constructed-metropolitan-*.txt | fold -w 180 -s > $OUTPUT/alternatives-constructed-metropolitan.txt
cat estimation/alternatives/alternatives-wss-metropolitan-*.txt | fold -w 180 -s > $OUTPUT/alternatives-wss-metropolitan.txt
cat estimation/alternatives/alternatives-spb-metropolitan-*.txt | fold -w 180 -s > $OUTPUT/alternatives-spb-metropolitan.txt
cat estimation/alternatives/alternatives-other-metropolitan-*.txt | fold -w 180 -s > $OUTPUT/alternatives-other-metropolitan.txt
cat estimation/alternatives/alternatives-wbo-metropolitan-*.txt | fold -w 180 -s > $OUTPUT/alternatives-wbo-metropolitan.txt

cp -ruv secondary/alternatives/columns-*.txt $OUTPUT/

cat secondary/alternatives/alternatives-metropolitan-secondary-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-metropolitan-secondary-test.txt
cat secondary/alternatives/alternatives-metropolitan-secondary-*.txt | fold -w 180 -s > $OUTPUT/alternatives-metropolitan-secondary.txt
