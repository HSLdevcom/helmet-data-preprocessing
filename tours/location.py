#!/usr/bin/env python2
# -*- coding: utf-8 -*-


from math import sqrt


class Location(object):
    def __init__(self, tid, ttype, tx, ty, zone):
        self.tid = int(tid)
        self.ttype = int(ttype)
        self.coord = [float(tx), float(ty)]
        self.zone = int(zone)

    def get_id(self):
        return self.tid

    def get_type(self):
        return self.ttype

    def get_coord(self):
        return self.coord

    def get_zone(self):
        return self.zone

    def eucd(self, location):
        ix = self.get_coord()[0]
        iy = self.get_coord()[1]
        jx = location.get_coord()[0]
        jy = location.get_coord()[1]
        distance = sqrt((ix - jx)**2 + (iy - jy)**2)
        return distance
