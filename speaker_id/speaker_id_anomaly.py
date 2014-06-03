#!/usr/bin/env python
# ----------------------------------------------------------------------
# Numenta Platform for Intelligent Computing (NuPIC)
# Copyright (C) 2013, Numenta, Inc.  Unless you have an agreement
# with Numenta, Inc., for a separate license for this software code, the
# following terms and conditions apply:
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
#
# http://numenta.org/licenses/
# ----------------------------------------------------------------------

"""
A simple client to create a CLA anomaly detection model for hotgym.
The script prints out all records that have an abnormally high anomaly
score.
"""

import csv
import scipy.io
import logging
from numpy import concatenate

from nupic.frameworks.opf.modelfactory import ModelFactory

import nupic_output

import model_params

_LOGGER = logging.getLogger(__name__)

_DATA_FILE = "speakerId_v1.mat"

_OUTPUT_PATH = "anomaly_scores.csv"

_ANOMALY_THRESHOLD = 0.9


def createModel(num_channels):
    mp = model_params.MODEL_PARAMS
    
    
    for i in range(num_channels):
        if i == 0:
            continue
        
        e_base = dict(mp['modelParams']['sensorParams']['encoders']['ch0'])
        e_base['fieldname'] = ('ch%s') % (i)
        e_base['name'] = ('ch%s') % (i)
        mp['modelParams']['sensorParams']['encoders'][('ch%s') % (i)] = e_base
    
    
    return ModelFactory.create(mp)


def runSIDAnomaly():
    plot = False
    
    # Load data
    mat = scipy.io.loadmat(_DATA_FILE)
    train = mat['Xtrain']
    train = train[0:1100,:]
    test = mat['Xtest']
    test = concatenate((test[0:5000], test[0:1100]),axis=0)
    num_channels = train.shape[1]
    
    # Create Model
    model = createModel(num_channels)
    model.enableInference({'predictedField': 'ch0'})
  
    
    channels = []
    for j in range(num_channels):
        channels.append(('ch%s') % (j))
    
    print "Starting training"
    for _ in range(5):
        cnt = 0
        for record in train:
            if cnt % 100 == 0:
                print cnt
            
            modelInput = dict(zip(channels,record))
            result = model.run(modelInput)
            cnt = cnt + 1
    
    # Run Tests
    model.disableLearning()
    csvWriter = csv.writer(open(_OUTPUT_PATH,"wb"))
    csvWriter.writerow(["timestep", "anomaly_score"])
    
    cnt = 0
    print "Starting Testing"
    for record in test:
        if cnt % 100 == 0:
            print cnt
        
        modelInput = dict(zip(channels,record))
        result = model.run(modelInput)
    
        anomalyScore = result.inferences['anomalyScore']     
        
        csvWriter.writerow([cnt, anomalyScore])
            
        cnt = cnt + 1
       
    

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    runSIDAnomaly()
