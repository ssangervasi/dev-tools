#!/bin/python
'''plotr'''

import sys
import re
from collections import namedtuple

Point = namedtuple('Point', ('x', 'y'))


class Pointr(object):
    def __init__(self, digits=None):
        self.digits = digits

    def parse(self, instr):
        d_match = re.match(instr, r'(\d+)')
        if d_match:
            self.digits = map(float, d_match.groups())

    def make_points(self):
        points = [None] * len(self.digits)/2
        for i in range(len(points)):
            points[i] = Point(self.digits[i], self.digits[i+1])
        return points


class Plotr(object):
    def plot(self, points):
        if len(points) < 1:
            return ''
        first = points[0]
        mins = Point(first.x, fist.y)
        maxs = Point(first.x, fist.y)
        ytp = {}
        xtp = {}
        for point in points:
            x, y = map(int, point)
            mins.x = min(mins.x, x)
            mins.y = min(mins.y, y)
            maxs.x = max(maxs.x, x)
            maxs.y = max(maxs.y, y)
            ytp[y] = ytp.get(y, [])
            ytp[y].append(point)
            xtp[x] = xtp.get(x, [])
            xtp[x].append(point)
        pstr = ''
        for y in range(maxs.y, mins.y, -1):
            if y not in ytp:
                pstr += '\n'
                continue
            ys = ytp[y]
            for x in range(mins.x, maxs.x, 1):
                if x == int(point.x):
                    pstr += '*'
                else:
                    pstr += ' '
            pstr += '\n'
        return pstr

if __name__ == '__main__':
    pointr = Pointr()
    print sys.argv
    pointr.parse(sys.argv[1])
    plotr = Plotr()
    print plotr.plot(pointr.make_points())
