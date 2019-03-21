#!/usr/bin/env python2
# -*- coding: utf-8 -*-


import unittest
from tours import constants


class ConstantsTest(unittest.TestCase):
    def test_collapse_multiple_elements(self):
        items = ["foo", "bar", "  baz.."]
        joined = constants.collapse(items)
        self.assertEqual(joined, "foo - bar -   baz..")
