#!/usr/bin/env python3
"""
               JETPR IFORNIAINSTITUTEOFTECH  RATOR               
               OPULS NOLOGYJETPROPULSIONLABO YCALI               
               IONLA RATORYCALIFORNIAINSTITU FORNI              
               BORAT TEOFT             ECHNO AINST               
               ORYCA LOGYJETPROPULSIONLABORA ITUTE               
               LIFOR TORYC ALIFORNIAINSTITUT OFTEC               
    NIAINSTITUTEOFTE EOFTE  CHNOLOGYJETPROP  HNOLOGYJETPROPUL    
   CHNOLOGYJETPROPUL ULSIO                   SIONLABORATORYCAL   
  SIONLABORATORYCAL  NLABO                    IFORNIAINSTITUTEO  
                                                              
  Jet Propulsion Laboratory - California Institute of Technology 

Copyright 2014, by the California Institute of Technology. ALL RIGHTS RESERVED.
United States Government sponsorship acknowledged. Any commercial use must be 
negotiated with the Office of Technology Transfer at the California Institute of
Technology.

This software may be subject to U.S. export control laws and regulations. By 
accepting this document, the user agrees to comply with all applicable U.S. 
export laws and regulations. User has the responsibility to obtain export 
licenses, or other export authority as may be required before exporting such 
information to foreign countries or providing access to foreign persons.

Module Description:
--------------------------------------------------------------------------------    
Find distinct peaks in a dataset and return their values to a file
--------------------------------------------------------------------------------

Written by Stephen Horst (sjhorst@jpl.nasa.gov) - 6Aug14

CHANGELOG:
--

"""

import numpy as np
import argparse

# Make sure pyradarlib is properly installed
try:
    import pyradarlib as prl
except ImportError:
    print("This module depends on a working copy of pyradarlib.")
    print("Obtain via GIT within the JPL firewall:           git clone git@dreadnought:pyradarlib.git")
    print("Install by executing within the source directory: python3 setup.py install")

parser = argparse.ArgumentParser(description="Find local peaks above a specified threshold")
parser.add_argument('filename', help='Path to image file to process.')
parser.add_argument('-o', '--output', dest='output', default='pt_locations',
        help='Specify the output file name. Default is "pt_locations"')
parser.add_argument('-t', '--threshold', dest='threshold', required=True, type=float,
        help='Specify the threshold in dB for relevant peaks', default=10)

# Parse input arguments
args = parser.parse_args()

print("Opening the image file.")
data = prl.node.field(args.filename, dtype='c8')

courseLoc = np.where(prl.dB20(data[:]) > args.threshold)
print("Found {0} pixels greater than threshold value.".format(len(courseLoc[0])))

sz_region = 17
peaks = []
xprev = 0
yprev = 0
print("Begin searching for local maxima...")
for x,y in zip(courseLoc[1][:], courseLoc[0][:]):
    if (x-xprev) + (y-yprev) > 2:
        zone = data.region(( y,x ), ( sz_region, sz_region ), method='cspan')
        pk = zone.argpeak()
        pk = (pk[0] - sz_region//2 + y, pk[1] - sz_region//2 + x)
        if pk not in peaks:
            print("Found a local maxima at ({0},{1}).".format(pk[0], pk[1]))
            peaks.append(pk)
    xprev = x
    yprev = y
print("Found {0} point target(s).".format(len(peaks)))

extension = 'csv'
header = "# Point Target index locations in [azimuth, range] format\n"

with open(args.output+'.'+extension, 'w') as fid:
    fid.write(header)
    for plist in peaks:
        fid.write('{0}, {1}\n'.format(plist[0], plist[1]))
