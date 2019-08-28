#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import pandas
from math import isnan

TYPE_HOME = 1

TYPE_GROUP = {
    1: 1,
    2: 2,
    3: 3,
    4: 5,
    5: 5,
    6: 7,
    7: 6,
    8: 6,
    9: 6,
    10: 6,
    11: 6,
    12: 4,
}

TYPE_PRIORITY = {
    1: 1,
    2: 2,
    3: 3,
    4: 5,
    5: 5,
    6: 5,
    7: 5,
    8: 5,
    9: 5,
    10: 5,
    11: 5,
    12: 4,
}


def collapse(list_of_printables, sep=" - "):
    text = sep.join(str(x) for x in list_of_printables)
    return text


def if_nan_then(x, y):
    if isnan(x):
        return y
    else:
        return x


def read_people(filepath, survey):
    if survey == "heha":
        return read_people_from_heha(filepath)
    elif survey == "hlt":
        return read_people_from_hlt(filepath)
    else:
        raise ValueError("Survey type not supported!")


def read_trips(filepath, survey):
    if survey == "heha":
        return read_trips_from_heha(filepath)
    elif survey == "hlt":
        return read_trips_from_hlt(filepath)
    else:
        raise ValueError("Survey type not supported!")


def read_locations(filepath, survey):
    if survey == "heha":
        return read_locations_from_heha(filepath)
    elif survey == "hlt":
        return read_locations_from_hlt(filepath)
    else:
        raise ValueError("Survey type not supported!")


def read_people_from_hlt(fname):
    df = pandas.read_csv(fname,
                         sep=";",
                         decimal=",",
                         skipinitialspace=True,
                         usecols=[
                                 "pid",
                                 "xfactor",
                                 "rzone"],
                         dtype={
                                 "pid": int,
                                 "xfactor": float,
                                 "rzone": int,
                                 })
    return df


def read_trips_from_hlt(fname):
    df = pandas.read_csv(fname,
                         sep=";",
                         decimal=",",
                         skipinitialspace=True,
                         usecols=[
                                 "pid",
                                 "eid",
                                 "number",
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
                                 "pid": int,
                                 "eid": int,
                                 "number": int,
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
                    "pid",
                    "kerroin",
                    "ap_sij19",
                    ],
            dtype={
                    "pid": int,
                    "kerroin": float,
                    "ap_sij19": int,
                    })
    columns = {
        "kerroin": "xfactor",
        "ap_sij19": "rzone",
        }
    df.rename(columns=columns, inplace=True)
    return df


def read_trips_from_heha(fname):
    df = pandas.read_csv(fname,
                         sep=";",
                         decimal=",",
                         skipinitialspace=True,
                         usecols=[
                                 "pid",
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
                                 "pid": int,
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
