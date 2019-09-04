#!/bin/bash
# -*- coding: utf-8-unix -*-
read_default() {
    read -p "$1: [$2] " REPLY && echo "${REPLY:-$2}"
}
OUTPUT=$(read_default "Path to output folder" "/output")
git rev-parse HEAD > $OUTPUT/hash

(cd area/ && sh batch.sh)
(cd survey/ && sh batch.sh)
pipenv run python ./tours/main.py input-config-heha.json
pipenv run python ./tours/main.py input-config-hlt.json
(cd metropolitan/primary/ && sh batch.sh)
(cd metropolitan/constructed/ && sh batch.sh)
(cd metropolitan/secondary/ && sh batch.sh)
(cd peripehral/primary/ && sh batch.sh)
(cd peripehral/constructed/ && sh batch.sh)

cp -ruv tours/tours-*.csv $OUTPUT/

cp -ruv metropolitan/primary/alternatives/columns-*.txt $OUTPUT/columns-metropolitan.txt
cp -ruv metropolitan/constructed/alternatives/columns-*.txt $OUTPUT/columns-constructed-metropolitan.txt
cp -ruv metropolitan/secondary/alternatives/columns-*.txt $OUTPUT/columns-metropolitan-secondary.txt

cp -ruv peripheral/primary/alternatives/columns-*.txt $OUTPUT/columns-peripheral.txt
cp -ruv peripheral/constructed/alternatives/columns-*.txt $OUTPUT/columns-constructed-peripheral.txt

cat metropolitan/primary/alternatives/alternatives--1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-peripheral-test.txt
cat metropolitan/primary/alternatives/alternatives-constructed-peripheral-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-constructed-peripheral-test.txt
cat metropolitan/primary/alternatives/alternatives-constructed-metropolitan-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-constructed-metropolitan-test.txt

cat metropolitan/primary/alternatives/alternatives-wss-metropolitan-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-wss-metropolitan-test.txt
cat metropolitan/primary/alternatives/alternatives-spb-metropolitan-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-spb-metropolitan-test.txt
cat metropolitan/primary/alternatives/alternatives-other-metropolitan-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-other-metropolitan-test.txt
cat metropolitan/primary/alternatives/alternatives-wbo-metropolitan-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-wbo-metropolitan-test.txt

cat metropolitan/primary/alternatives/alternatives-peripheral-*.txt | fold -w 180 -s > $OUTPUT/alternatives-peripheral.txt
cat metropolitan/primary/alternatives/alternatives-constructed-peripheral-*.txt | fold -w 180 -s > $OUTPUT/alternatives-constructed-peripheral.txt
cat metropolitan/primary/alternatives/alternatives-constructed-metropolitan-*.txt | fold -w 180 -s > $OUTPUT/alternatives-constructed-metropolitan.txt
cat metropolitan/primary/alternatives/alternatives-wss-metropolitan-*.txt | fold -w 180 -s > $OUTPUT/alternatives-wss-metropolitan.txt
cat metropolitan/primary/alternatives/alternatives-spb-metropolitan-*.txt | fold -w 180 -s > $OUTPUT/alternatives-spb-metropolitan.txt
cat metropolitan/primary/alternatives/alternatives-other-metropolitan-*.txt | fold -w 180 -s > $OUTPUT/alternatives-other-metropolitan.txt
cat metropolitan/primary/alternatives/alternatives-wbo-metropolitan-*.txt | fold -w 180 -s > $OUTPUT/alternatives-wbo-metropolitan.txt

cp -ruv secondary/alternatives/columns-*.txt $OUTPUT/

cat secondary/alternatives/alternatives-metropolitan-secondary-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-metropolitan-secondary-test.txt
cat secondary/alternatives/alternatives-metropolitan-secondary-*.txt | fold -w 180 -s > $OUTPUT/alternatives-metropolitan-secondary.txt
