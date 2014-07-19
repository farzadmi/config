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
This script processes an image file in single precision IQ format and creates 
histograms of the amplitude and phase of the entire scene. 
--------------------------------------------------------------------------------

Written by Stephen Horst (sjhorst@jpl.nasa.gov) - 3Jun14

CHANGELOG:
--

"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.pylab as mpyl
import argparse
import struct
import math

colorlist = ['blue', 'red', 'green', 'cyan', 'magenta']

parser = argparse.ArgumentParser(description="Create a histogram of magnitude and phase of a processed scene.")
parser.add_argument('filenames', nargs='+', help='Path to image files to process. Any number of images can be processed and overlaid but at least one must be specified.')
parser.add_argument('-r', '--ref', dest='reference',
        help='Reference image to perform the diff with the list of test images. This is required.')
parser.add_argument('-o', '--output', dest='output', required=True,
        help='Optional. Specify the prefix name of the output file (e.g. <prefix>_mag.png)', default='scene')
parser.add_argument('-n', '--normalize', action='store_true', dest='normalize', 
        help='Optional. Normalize the y-axis such that the sum of all bins equals 1 (a valid PDF distribution).')
parser.add_argument('-w', '--writeout', action='store_true', dest='writeout', 
        help='Optional. Write the diff result to a file in the same format it was read.')

# Parse input arguments
args = parser.parse_args()

dt = np.dtype(np.complex64)

print('Importing reference image file...')
refvals = np.fromfile(args.reference, dtype=dt)

ymaxmag = 0
ymaxphs = 0

plt.figure()

for index, img in enumerate(args.filenames):
    print('*** Begin processing image #{0}'.format(index+1))
    print('Importing image file...')
    values = np.fromfile(img, dtype=dt)

    print('Calculating complex diff...')
    diff = values / (refvals + 1e-15)
    values = None

    if args.writeout:
        print('Writing diff to file...')
        with open(img + '_diff.slc', 'wb') as fid:
            diff.tofile(fid, format='ff')

    print('Calculating magnitude and phase...')
    magdiff = 10*np.log10(np.abs(diff)+1e-15)
    phsdiff = np.arctan2(diff.imag, diff.real)*180/np.pi

    print('Store magnitude histogram...')
    plt.subplot(211)
    n = plt.hist(magdiff, bins=500, histtype='step', color=colorlist[index], label=img, normed=args.normalize)
    n = n[0]
    n[np.argmax(n)] = 0
    if np.max(n) > ymaxmag:
        ymaxmag = np.max(n)

    print('Storing phase histogram...')
    plt.subplot(212)
    n = plt.hist(phsdiff, bins=500, histtype='step', color=colorlist[index], label=img, normed=args.normalize)
    n = n[0]
    n[np.argmax(n)] = 0
    if np.max(n) > ymaxmag:
        ymaxphs = np.max(n)

plt.subplot(211)
plt.xlabel('Change in Pixel Magnitude (dB)')
if args.normalize:
    plt.ylabel('Normalized Pixel Count')
else:
    plt.ylabel('Pixel Count')
#plt.title('Delta Magnitude Histogram')
plt.ylim(0, 1.05*ymaxmag)
plt.xlim(-30, 30)
plt.legend(bbox_to_anchor=(0., 1.02, 1., 0.102), loc=3, ncol=2, mode='expand', borderaxespad=0,
        fontsize=12)

plt.subplot(212)
plt.xlabel('Change in Pixel Phase (deg)')
if args.normalize:
    plt.ylabel('Normalized Pixel Count')
else:
    plt.ylabel('Pixel Count')
#plt.title('Delta Phase Histogram')
plt.ylim(0, 1.05*ymaxphs)
plt.xlim(-180, 180)

plt.savefig(args.output + '_hist.png', bbix_inches='tight')
