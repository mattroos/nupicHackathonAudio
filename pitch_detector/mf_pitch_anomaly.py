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
A simple client to create a CLA anomaly detection model for pitch detection
based on the hotgym example.

"""

import csv
import scipy.io
import datetime
import logging

from nupic.data.datasethelpers import findDataset
from nupic.frameworks.opf.modelfactory import ModelFactory
from nupic.frameworks.opf.predictionmetricsmanager import MetricsManager
from nupic.data.inference_shifter import InferenceShifter

import nupic_output

import model_params

_LOGGER = logging.getLogger(__name__)

_DATA_FILE = "p11.mat"

_OUTPUT_PATH = "anomaly_scores.csv"

_ANOMALY_THRESHOLD = 0.9


def createModel():
    return ModelFactory.create(model_params.MODEL_PARAMS)


def runEEGAnomaly():
    # Create Model
    model = createModel()
    model.enableInference({'predictedField': 'ch0','predictedField': 'ch1'})


    # Load data
    mat = scipy.io.loadmat(_DATA_FILE)
    data = mat['data']
    seconds = mat['seconds']
    
    # plotting stuff?
    output = nupic_output.NuPICPlotOutput(["ch0","ch1"])
    
    #for i,t in data,seconds:
    for i, t in zip(data, seconds):
        #modelInput = dict(zip('ch1', i[0]))
        modelInput = {'ch0':i[0],'ch1':i[1]}
        result = model.run(modelInput)
        #anomalyScore = result.inferences['anomalyScore']
        
        prediction = result.inferences["multiStepBestPredictions"][1]
        output.write([t[0],t[0]],[i[0],i[1]],[prediction,prediction])
        
        #if anomalyScore > _ANOMALY_THRESHOLD:
       #     _LOGGER.info("Anomaly detected. Anomaly score: %f.", anomalyScore)

    print "Anomaly scores have been written to",_OUTPUT_PATH

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    runEEGAnomaly()
