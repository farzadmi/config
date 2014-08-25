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
                                                                
Copyright 2013, by the California Institute of Technology. ALL RIGHTS RESERVED.
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
This script inserts null gaps into the point target simulator data to simulate
the effect of swath gaps as they might appear in a SweepSAR system 
--------------------------------------------------------------------------------

Written by Stephen Horst (sjhorst@jpl.nasa.gov) - 13May14

CHANGELOG:
--

"""

import shutil
import numpy as np
import os
import argparse
import struct
import traceback
import logging

# Make sure pyradarlib is properly installed
try:
    import pyradarlib as prl
except ImportError:
    print("This module depends on a working copy of pyradarlib.")
    print("Obtain via GIT within the JPL firewall:           git clone git@dreadnought:pyradarlib.git")
    print("Install by executing within the source directory: python3 setup.py install")

logging.basicConfig(level=logging.DEBUG)

# Define input arguments
parser = argparse.ArgumentParser(description="Insert transmit gaps into raw point target simulator data")
parser.add_argument('config_filename', help='Path to the RDF configuration file describing the gaps to insert.')
parser.add_argument('-r', '--random', dest='random', action='store_true',
        help='Override the gap content parameter with random noise.') 

# Parse input arguments
args = parser.parse_args()

# Read configuration file
conf = prl.read.rdf(args.config_filename)

# Execute the gap insertion process
if conf['Input Filename'] != conf['Output Filename']:
    shutil.copyfile(conf['Input Filename'], conf['Output Filename'])
    shutil.copyfile(conf['Input Filename']+'.meta', conf['Output Filename']+'.rsc')
    inname = conf['Input Filename'].split('.')
    outname = conf['Output Filename'].split('.')
    shutil.copyfile('hdr_data_points_' + inname[0] + '.meta', 'hdr_data_points_' + outname[0] + '.rsc')

# Read meta-data of the file
meta = prl.read.rsc(conf['Output Filename'] + '.rsc')

tol = 1e-12 # Tolerance used for float comparison

header = meta['XMIN'] - 1
Fs = meta['RANGE_SAMPLING_FREQUENCY']
pulseWidth = meta['PULSE_LENGTH']
PRI = 1/meta['PRF']
if conf['Bias Override'].lower() == 'true':
    bias = conf['Bias Value']
else:
    bias = np.round(meta['I_BIAS'])
roundTrip = 2*meta['STARTING_RANGE']/3e8
numPulses = meta['YMAX'] - meta['YMIN']
pulsesInAir = np.floor(roundTrip/PRI)
dataShift = roundTrip - pulsesInAir*PRI

sz_rangeline = meta['XMAX']
sz_data = int((sz_rangeline - header)/2)
sz_gap = int(pulseWidth*Fs)
sz_file = os.path.getsize(conf['Output Filename'])

windowDuration = sz_data/Fs

print('Radar Timing Parameters:')
print('ADC Sampling Interval: {0} us'.format(1/Fs/1e-6))
print('Radar PRI: {0} us'.format(PRI/1e-6))
print('Receive Window Duration: {0} us'.format(windowDuration/1e-6))
print('Round Trip Time to near edge of Rx window: {0} us'.format(roundTrip/1e-6))
print('Time between Rx window and prior pulse: {0} us'.format(dataShift/1e-6))

# Create a PRI clock with time tags of all PRI events
baseClock = PRI*np.ones(numPulses + pulsesInAir)

if conf['Gap Type'].lower() == 'constant':
    priClock = baseClock

elif conf['Gap Type'].lower() == 'random':
    # Modify Offsets for random distribution
    delta = np.random.uniform(conf['PRI Min Delta']*1e-6, conf['PRI Max Delta']*1e-6, len(baseClock))
    priClock = baseClock + delta

elif conf['Gap Type'].lower() == 'linear':
    # Modify offsets for a linear ramp type
    pulsesPerLeg = np.round(conf['PRI Ramp Duration']/PRI + 1)
    deltaBound = (pulsesPerLeg - 1)/2*PRI*conf['PRI Ramp Rate']*1e-6
    deltaLeg = np.linspace(-deltaBound, deltaBound, pulsesPerLeg)
    if conf['Ramp Reset Style'].lower() == 'fold':
        # If the ramp folds back over, do the negated slope values
        revLeg = deltaLeg[::-1]
        deltaLeg = np.concatenate((deltaLeg, revLeg))
    # Repeat the offset values until it matches the length of the data
    delta = np.tile(deltaLeg, np.ceil(len(baseClock)/len(deltaLeg)))[:len(baseClock)]
    priClock = baseClock + delta

elif conf['Gap Type'].lower() == 'dwell':
    if np.mod(conf['Number of Steps Per Cycle'], 4):
        raise ValueError('Please specify a number divisible by 4 for the burst cycle.')
    delta = np.empty(0)
    for burstNum in range(conf['Number of Steps Per Cycle']//4):
        burst = (burstNum)*conf['PRI Step Size']*1e-6*np.ones(pulsesInAir)
        delta = np.concatenate((delta, burst))
    for burstNum in range(conf['Number of Steps Per Cycle']//4,-conf['Number of Steps Per Cycle']//4,-1):
        burst = (burstNum)*conf['PRI Step Size']*1e-6*np.ones(pulsesInAir)
        delta = np.concatenate((delta, burst))
    for burstNum in range(-conf['Number of Steps Per Cycle']//4, 0):
        burst = (burstNum)*conf['PRI Step Size']*1e-6*np.ones(pulsesInAir)
        delta = np.concatenate((delta, burst))
    # Repeat the offset values until it matches the length of the data
    delta = np.tile(delta, np.ceil(len(baseClock)/len(delta)))[:len(baseClock)]
    priClock = baseClock + delta

else:
    raise ValueError('Invalid Gap Type Selection {0}.'.format(conf['Gap Type']))

# Create a master clock in time from the PRF spacings
pulseClock = np.zeros(len(priClock) + 1)
for N in range(1, len(priClock)+1):
    pulseClock[N] = pulseClock[N - 1] + priClock[N - 1]

# Create receive window start times based on round trip time (apply offset shift here)
rxWindowStart = (pulseClock + roundTrip - dataShift - conf['Pulse Shift Offset']*1e-6)[:numPulses]
rxWindowIndex = np.arange(header, sz_file, sz_rangeline, dtype=np.int64)

with open(conf['Output Filename'], "r+b") as outfile:
    try:
        for rxWin, fileIndex in zip(np.nditer(rxWindowStart), np.nditer(rxWindowIndex)):
            # Find number of gaps to insert within each rangeline
            gapTime = pulseClock[np.logical_and(pulseClock + pulseWidth >= rxWin - tol, pulseClock <= rxWin + windowDuration + tol)]
            for gap in gapTime:
                # Generate Gap Contents
                if conf['Gap Content'].lower() == 'noise' or args.random:
                    # Read the current range line
                    outfile.seek(fileIndex)
                    dt = np.dtype(np.uint8)
                    rawval = np.fromfile(outfile, dtype=dt, count=2*sz_data)
                    # Compute the 1-sigma standard deviation
                    Ivar = np.std(rawval[::2])
                    Qvar = np.std(rawval[1::2])
                    # Generate a normal random sequence for the gap
                    Ival = np.random.normal(0, Ivar, sz_gap)
                    Qval = np.random.normal(0, Qvar, sz_gap)
                    # Pack the sequence for storage in the file
                    blank = np.empty(2*sz_gap)
                    blank[::2] = np.round(Ival) + bias
                    blank[1::2] = np.round(Qval) + bias
                    blank = blank.astype(np.uint8)
                else:
                    blank = 2*sz_gap*bytes.fromhex('%X' % bias)

                # Convert gap time to samples (*2 to get position in file)
                gapSampleLoc = np.round((gap - rxWin)*Fs)
                # If the boudary of the gap exeeds the edges of the receive window, truncate it
                if gapSampleLoc < 0:
                    print('Trimming gap at near edge of receive window.')
                    blank = blank[int(2*np.abs(gapSampleLoc)):] 
                    gapSampleLoc = np.float64(0)
                elif gapSampleLoc + sz_gap > sz_data:
                    print('Trimming gap at far edge of receive window.')
                    trim = (gapSampleLoc + sz_gap) - sz_data
                    blank = blank[:-2*int(trim)]

                # Write gap to data
                outfile.seek(fileIndex + 2*gapSampleLoc.astype(np.int))
                outfile.write(blank)
    except:
        traceback.print_exc(file=sys.stdout)
        import pdb; pdb.set_trace()
