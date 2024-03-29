#!/usr/bin/env python3

import argparse
import numpy as np
import os

class tgtstat(object):
    def __init__(self):
        self.mag = np.array([])
        self.res = np.array([])
        self.ISLR = np.array([])
        self.PSLR = np.array([])

# Make sure pyradarlib is properly installed
try:
    import pyradarlib as prl
except ImportError:
    print("This module depends on a working copy of pyradarlib.")
    print("Obtain via GIT within the JPL firewall:           git clone git@dreadnought:pyradarlib.git")
    print("Install by executing within the source directory: python3 setup.py install")

# Define Input Arguments
parser = argparse.ArgumentParser(description="Analyze Point Target metrics of a given file")
parser.add_argument('filename', help='Path to the filename containing the data to analyze')
parser.add_argument('-l', '--location', dest='location', default=None, 
        help='Optional. Specify a file containing target locations in csv format.')
parser.add_argument('-w', '--window', dest='window', default=1024,  type=int,
        help='Optional. Specify the window size used to analyze the point target. Default is 1024 pixels.')
parser.add_argument('-o', '--output', dest='output', default='output', 
        help='Optional. Specify the output filename that stores results. Default is output.csv')
parser.add_argument('-c', '--cuts', dest='cuts', action='store_true',
        help='Optional. Generate point target range and azimuth cuts for each target.')
parser.add_argument('-s', '--save', dest='save', action='store_true',
        help='Optional. Save the ISLR bounds in a file named "ISLR_bounds" to be used on future pytang runs with the -b flag.')
parser.add_argument('-b', '--bounds', dest='bounds', action='store_true',
        help='Optional. Load the contents of file "ISLR_bounds" in the executing directory to load bounds for computing the ISLR mainlobe.')

args = parser.parse_args()

print('***** Processing Point Targets in ' + args.filename + ' *****')

print('Loading data file...')
data = prl.node.field(args.filename, dtype='c8')

if args.location is not None:
    print('Loading target location file...')
    loc = np.loadtxt(args.location, dtype=np.int, delimiter=',')
else:
    raise NotImplementedError('Only works with target files at the moment.')

rangePoints = loc[:,1]
azPoints = loc[:, 0]
delta = int(np.floor(args.window/2))

if args.bounds:
    rcbounds = np.genfromtxt('ISLR_range_bounds', delimiter=',')
    acbounds = np.genfromtxt('ISLR_azimuth_bounds', delimiter=',')
elif args.save:
    rcbounds = []
    acbounds = []

rc = tgtstat()
ac = tgtstat()
for count, (targrange, targaz) in enumerate(zip(rangePoints, azPoints)):
    pt = data.region((targaz-2*delta, targaz+2*delta), (targrange-delta, targrange+delta))
    pk = pt.argpeak()

    rangeCut = pt.rangeCut(pk[0], timeref='total')
    azimuthCut = pt.azimuthCut(pk[1])

    print('Interpolating range cut...')
    rangeCut.resample(100e6)
    print('Interpolating Azimuth Cut...')
    azimuthCut.resample(20e3)

    if args.cuts:
        rangeCut.save(args.output+'_pt'+str(count)+'_rangecut', 'csv')
        azimuthCut.save(args.output+'_pt'+str(count)+'_azimuthcut', 'csv')

    if args.save:
        rcbounds.append(rangeCut.mainlobeBounds(0) - rangeCut.argpeak())
        acbounds.append(azimuthCut.mainlobeBounds(0) - azimuthCut.argpeak())

    print('Calculating Point Target Statistics for Range Cut...')
    rc.mag = np.append( rc.mag, rangeCut.peak() )
    rc.res = np.append( rc.res, rangeCut.resolution(level=3) )
    rc.PSLR = np.append( rc.PSLR, rangeCut.PSLR() )
    if args.bounds:
        rc.ISLR = np.append( rc.ISLR, rangeCut.ISLR(tuple(rcbounds[count])) )
    else:
        rc.ISLR = np.append( rc.ISLR, rangeCut.ISLR() )

    print('Calculating Point Target Statistics for Azimuth Cut...')
    ac.mag = np.append( ac.mag, azimuthCut.peak() )
    ac.res = np.append( ac.res, azimuthCut.resolution(level=3, direction='azimuth') )
    ac.PSLR = np.append( ac.PSLR, azimuthCut.PSLR() )
    if args.bounds:
        ac.ISLR = np.append( ac.ISLR, azimuthCut.ISLR(tuple(acbounds[count])) )
    else:
        ac.ISLR = np.append( ac.ISLR, azimuthCut.ISLR() )

    print("""\
    Point Target Analysis #{0}:
    Magnitude: {1} dB, {2} dB
    Resolution: {3} m, {4} m
    ISLR: {5} dB, {6} dB
    PSLR: {7} dB, {8} dB

    """.format(count, rc.mag[-1], ac.mag[-1],
        rc.res[-1], ac.res[-1],
        rc.ISLR[-1], ac.ISLR[-1],
        rc.PSLR[-1], ac.PSLR[-1]))

header = 'Magnitude (dB), Resolution (m), ISLR (dB), PSLR (dB)'
np.savetxt(args.output+'_range_stats.csv', np.transpose((rc.mag, rc.res, rc.ISLR, rc.PSLR)), delimiter=',', header=header, newline=os.linesep)
np.savetxt(args.output+'_azimuth_stats.csv', np.transpose((ac.mag, ac.res, ac.ISLR, ac.PSLR)), delimiter=',', header=header, newline=os.linesep)
if args.save:
    np.savetxt('ISLR_range_bounds', rcbounds, delimiter=',', newline=os.linesep)
    np.savetxt('ISLR_azimuth_bounds', acbounds, delimiter=',', newline=os.linesep)
