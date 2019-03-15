#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import pandas

TYPE_HOME = 1
TYPE_WORK = 2
TYPE_SCHOOL = 3

TYPE_GROUP = {
    1: 1,
    2: 2,
    3: 3,
    4: 5,
    5: 5,
    6: 5,
    7: 6,
    8: 6,
    9: 6,
    10: 6,
    11: 6,
    12: 4,
}

GROUP_NAME = {
    1: "koti",
    2: "työ",
    3: "koulu",
    4: "opiskelu",
    5: "asiointi",
    6: "muu",
}


def collapse(list_of_printables, sep=" - "):
    text = sep.join(str(x) for x in list_of_printables)
    return text


def read_people_from_hlt(fname):
    df = pandas.read_csv(fname,
                         sep=";",
                         decimal=",",
                         skipinitialspace=True,
                         usecols=[
                                 "T_TAUSTAID",
                                 "xfactor"],
                         dtype={
                                 "T_TAUSTAID": int,
                                 "xfactor": float
                                 })
    columns = {
        "T_TAUSTAID": "pid"
        }
    df.rename(columns=columns, inplace=True)
    return df


def read_trips_from_hlt(fname):
    df = pandas.read_csv(fname,
                         sep=";",
                         decimal=",",
                         skipinitialspace=True,
                         usecols=[
                                 "M_TAUSTAID",
                                 "M_TRIPROUTESID",
                                 "matnro",
                                 "ix",
                                 "iy",
                                 "itype",
                                 "itime",
                                 "jx",
                                 "jy",
                                 "jtype",
                                 "jtime",
                                 "itid",
                                 "jtid",
                                 "mode",
                                 "length"
                                 ],
                         dtype={
                                 "M_TAUSTAID": int,
                                 "M_TRIPROUTESID": int,
                                 "matnro": int,
                                 "ix": float,
                                 "iy": float,
                                 "itype": int,
                                 "itime": str,
                                 "jx": float,
                                 "jy": float,
                                 "jtype": int,
                                 "jtime": str,
                                 "itid": int,
                                 "jtid": int,
                                 "mode": int,
                                 "length": float,
                                 })
    columns = {
            "M_TAUSTAID": "pid",
            "M_TRIPROUTESID": "eid",
            "matnro": "number",
            "ix": "ix",
            "iy": "iy",
            "itype": "itype",
            "itime": "itime",
            "jx": "jx",
            "jy": "jy",
            "jtype": "jtype",
            "jtime": "jtime",
            }
    df.rename(columns=columns, inplace=True)
    return df


def read_locations_from_hlt(fname):
    df = pandas.read_csv(fname,
                         sep=";",
                         decimal=",",
                         skipinitialspace=True,
                         usecols=[
                                 "tid",
                                 "ttype",
                                 "x",
                                 "y",
                                 "zone"
                                 ],
                         dtype={
                                 "tid": int,
                                 "ttype": int,
                                 "x": float,
                                 "y": float,
                                 "zone": int
                                 })
    return df


def read_people_from_heha(fname):
    df = pandas.read_csv(
            fname,
            sep=";",
            decimal=",",
            skipinitialspace=True,
            usecols=[
                    "juokseva",
                    "paino6"
                    ],
            dtype={
                    "juokseva": int,
                    "paino6": float
                    })
    columns = {
        "juokseva": "pid",
        "paino6": "xfactor"
        }
    df.rename(columns=columns, inplace=True)
    return df


def read_trips_from_heha(fname):
    df = pandas.read_csv(fname,
                         sep=";",
                         decimal=",",
                         skipinitialspace=True,
                         usecols=[
                                 "juokseva",
                                 "matkaid",
                                 "matnro",
                                 "ix",
                                 "iy",
                                 "itype",
                                 "itime",
                                 "jx",
                                 "jy",
                                 "jtype",
                                 "jtime",
                                 "itid",
                                 "jtid",
                                 "mode",
                                 "PITUUS",
                                 ],
                         dtype={
                                 "juokseva": int,
                                 "matkaid": int,
                                 "matnro": int,
                                 "ix": float,
                                 "iy": float,
                                 "itype": int,
                                 "itime": str,
                                 "jx": float,
                                 "jy": float,
                                 "jtype": int,
                                 "jtime": str,
                                 "itid": int,
                                 "jtid": int,
                                 "mode": int,
                                 "PITUUS": float,
                                 })
    columns = {
            "juokseva": "pid",
            "matkaid": "eid",
            "matnro": "number",
            "ix": "ix",
            "iy": "iy",
            "itype": "itype",
            "itime": "itime",
            "jx": "jx",
            "jy": "jy",
            "jtype": "jtype",
            "jtime": "jtime",
            "PITUUS": "length",
            }
    df.rename(columns=columns, inplace=True)
    return df


def read_locations_from_heha(fname):
    df = pandas.read_csv(fname,
                         sep=";",
                         decimal=",",
                         skipinitialspace=True,
                         usecols=[
                                 "tid",
                                 "ttype",
                                 "x",
                                 "y",
                                 "zone"
                                 ],
                         dtype={
                                 "tid": int,
                                 "ttype": int,
                                 "x": float,
                                 "y": float,
                                 "zone": int
                                 })
    return df
