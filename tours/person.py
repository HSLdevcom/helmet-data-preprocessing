#!/usr/bin/env python2
# -*- coding: utf-8 -*-


class Person(object):
    def __init__(self, pid, xfactor, rzone):
        self.pid = int(pid)          # integer
        self.xfactor = float(xfactor)  # float
        self.rzone = int(rzone)    # list
        self.diary = []         # list of Trip instances
        self.tours = []         # list of Tour instances

    def get_id(self):
        return self.pid

    def get_xfactor(self):
        return self.xfactor

    def get_rzone(self):
        return self.rzone

    def get_diary(self):
        return self.diary

    def get_tours(self):
        return self.tours

    def set_diary(self, diary):
        self.diary = diary

    def set_tours(self, tours):
        self.tours = tours

    def get_number_of_trips(self):
        return len(self.get_diary())

    def get_number_of_trips_in_tours(self):
        i = 0
        for tour in self.get_tours():
            i = i + tour.get_number_of_trips()
        return i

    def makes_trips(self):
        return self.get_number_of_trips() > 0

    def to_dict(self):
        res = {
                "pid": self.get_id(),
                "xfactor": self.get_xfactor(),
                "rzone": self.get_rzone(),
                }
        return res
