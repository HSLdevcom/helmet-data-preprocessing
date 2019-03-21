#!/usr/bin/env python2
# -*- coding: utf-8 -*-


import unittest
from tours import location


class LocationsTest(unittest.TestCase):
    def test_eucd(self):
        location1 = location.Location(tid=1,
                                      ttype=1,
                                      tx=0,
                                      ty=0,
                                      zone=1)
        location2 = location.Location(tid=1,
                                      ttype=1,
                                      tx=3,
                                      ty=4,
                                      zone=1)
        distance = location1.eucd(location2)
        self.assertAlmostEqual(distance, 5)
