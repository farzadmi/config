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
This script processes an image file in double precision IQ format and creates 
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

parser = argparse.ArgumentParser(description="Create a histogram of magnitude and phase of a processed scene.")
parser.add_argument('filename1', help='Path to first image file to process')
parser.add_argument('filename2', nargs='?', help='Optional. Path to second image file to process, with results overlaid on the first.')
parser.add_argument('-o', '--output', dest='output',
        help='Optional. Specify the prefix name of the output file (e.g. <prefix>_mag.png)', default='scene')
parser.add_argument('-n', '--normalize', action='store_true', dest='normalize', 
        help='Optional. Normalize the y-axis such that the sum of all bins equals 1 (a valid PDF distribution).')

# Parse input arguments
args = parser.parse_args()

dt = np.dtype(np.complex64)

print('Importing first image file...')
values1 = np.fromfile(args.filename1, dtype=dt)
print('Calculating magnitude and phase...')
mag1 = 10*np.log10(np.abs(values1)+1e-15)
phs1 = np.arctan2(values1.imag, values1.real)*180/np.pi

if args.filename2:
    print('Importing second image file...')
    values2 = np.fromfile(args.filename2, dtype=dt)
    print('Calculating magnitude and phase...')
    mag2 = 10*np.log10(np.abs(values2)+1e-15)
    phs2 = np.arctan2(values2.imag, values2.real)*180/np.pi

print('Plotting magnitude histogram...')
plt.hist(mag1, bins=100, histtype='step', color='blue', label=args.filename1, normed=args.normalize)
if args.filename2:
    plt.hist(mag2, bins=100, histtype='step', color='red', label=args.filename2, normed=args.normalize)
plt.xlabel('Pixel Magnitude (dB)')
if args.normalize:
    plt.ylabel('Normalized Pixel Count')
else:
    plt.ylabel('Pixel Count')
#plt.title('Magnitude Histogram')
plt.legend(bbox_to_anchor=(0., 1.02, 1., 0.102), loc=3, ncol=2, mode='expand', borderaxespad=0,
        fontsize=12)
#plt.show()
plt.savefig(args.output + '_mag.png', bbix_inches='tight')
plt.cla()

print('Plotting phase histogram...')
plt.hist(phs1, bins=100, histtype='step', color='blue', label=args.filename1, normed=args.normalize)
if args.filename2:
    plt.hist(phs2, bins=100, histtype='step', color='red', label=args.filename2, normed=args.normalize)
if args.normalize:
    plt.ylabel('Normalized Pixel Count')
else:
    plt.ylabel('Pixel Count')
#plt.title('Phase Histogram')
plt.legend(bbox_to_anchor=(0., 1.02, 1., 0.102), loc=3, ncol=2, mode='expand', borderaxespad=0,
        fontsize=12)
#plt.show()
plt.savefig(args.output + '_phase.png', bbix_inches='tight')
