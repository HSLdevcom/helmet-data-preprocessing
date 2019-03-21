import unittest
from tours import constants


class ConstantsTest(unittest.TestCase):
    def test(self):
        list = {"foo", "bar", "  baz.."}
        joined = constants.collapse(list)
        self.assertEqual(joined, "  baz.. - foo - bar")
