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
(cd peripheral/primary/ && sh batch.sh)
(cd peripheral/constructed/ && sh batch.sh)

cp -ruv tours/tours-*.csv $OUTPUT/

cp -ruv metropolitan/primary/alternatives/columns-wss.txt $OUTPUT/columns-wss-metropolitan.txt
cp -ruv metropolitan/primary/alternatives/columns-spb.txt $OUTPUT/columns-spb-metropolitan.txt
cp -ruv metropolitan/primary/alternatives/columns-other.txt $OUTPUT/columns-other-metropolitan.txt
cp -ruv metropolitan/primary/alternatives/columns-wbo.txt $OUTPUT/columns-wbo-metropolitan.txt
cp -ruv metropolitan/constructed/alternatives/columns.txt $OUTPUT/columns-constructed-metropolitan.txt
cp -ruv metropolitan/secondary/alternatives/columns.txt $OUTPUT/columns-metropolitan-secondary.txt
cp -ruv metropolitan/secondary/alternatives/columns.txt $OUTPUT/columns-metropolitan-secondary.txt

cat metropolitan/primary/alternatives/alternatives-wss-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-wss-metropolitan-test.txt
cat metropolitan/primary/alternatives/alternatives-spb-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-spb-metropolitan-test.txt
cat metropolitan/primary/alternatives/alternatives-other-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-other-metropolitan-test.txt
cat metropolitan/primary/alternatives/alternatives-wbo-1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-wbo-metropolitan-test.txt
cat metropolitan/constructed/alternatives/alternatives--1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-constructed-metropolitan-test.txt
cat metropolitan/secondary/alternatives/alternatives--1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-metropolitan-secondary-test.txt

cat metropolitan/primary/alternatives/alternatives-wss-*.txt | fold -w 180 -s > $OUTPUT/alternatives-wss-metropolitan.txt
cat metropolitan/primary/alternatives/alternatives-spb-*.txt | fold -w 180 -s > $OUTPUT/alternatives-spb-metropolitan.txt
cat metropolitan/primary/alternatives/alternatives-other-*.txt | fold -w 180 -s > $OUTPUT/alternatives-other-metropolitan.txt
cat metropolitan/primary/alternatives/alternatives-wbo-*.txt | fold -w 180 -s > $OUTPUT/alternatives-wbo-metropolitan.txt
cat metropolitan/constructed/alternatives/alternatives--*.txt | fold -w 180 -s > $OUTPUT/alternatives-constructed-metropolitan.txt
cat metropolitan/secondary/alternatives/alternatives--*.txt | fold -w 180 -s > $OUTPUT/alternatives-metropolitan-secondary.txt

cp -ruv peripheral/primary/alternatives/columns.txt $OUTPUT/columns-peripheral.txt
cp -ruv peripheral/constructed/alternatives/columns.txt $OUTPUT/columns-constructed-peripheral.txt

cat peripheral/primary/alternatives/alternatives--1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-peripheral-test.txt
cat peripheral/constructed/alternatives/alternatives--1_100.txt | fold -w 180 -s > $OUTPUT/alternatives-constructed-peripheral-test.txt

cat peripheral/primary/alternatives/alternatives--*.txt | fold -w 180 -s > $OUTPUT/alternatives-peripheral.txt
cat peripheral/constructed/alternatives/alternatives--*.txt | fold -w 180 -s > $OUTPUT/alternatives-constructed-peripheral.txt

