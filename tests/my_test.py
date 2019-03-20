import unittest


def add_one(x):
    return x + 1


class MyTest(unittest.TestCase):
    def test(self):
        self.assertEqual(add_one(3), 4)


class MyFailingTest(unittest.TestCase):
    def test(self):
        self.assertEqual(add_one(3), 5)
