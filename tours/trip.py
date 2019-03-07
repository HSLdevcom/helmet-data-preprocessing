#!/usr/bin/env python2
# -*- coding: utf-8 -*-


import constants


class Trip(object):
    def __init__(self, eid, number, itime, jtime,
                 mode, length, ilocation, jlocation):
        self.eid = int(eid)
        self.number = int(number)
        self.itime = str(itime)
        self.jtime = str(jtime)
        self.mode = int(mode)
        self.length = float(length)
        self.ilocation = ilocation
        self.jlocation = jlocation

    def get_number(self):
        return self.number

    def get_itime(self):
        return self.itime

    def get_jtime(self):
        return self.jtime

    def get_mode(self):
        return self.mode

    def get_length(self):
        return self.length

    def get_ilocation(self):
        return self.ilocation

    def get_jlocation(self):
        return self.jlocation

    def get_itid(self):
        return self.get_ilocation().get_id()

    def get_jtid(self):
        return self.get_jlocation().get_id()

    def get_itype(self):
        return self.get_ilocation().get_type()

    def get_jtype(self):
        return self.get_jlocation().get_type()

    def starts_from_home(self):
        return self.get_itype() == constants.TYPE_HOME

    def ends_to_home(self):
        return self.get_jtype() == constants.TYPE_HOME
