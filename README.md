nupicHackathonAudio
===================

Code and data files generated during Spring 2014 Numenta hackathon




---------------------------
CLA for "sentence spotting"
---------------------------
The idea behind this hack was to see if the CLA could detect discriminate between a "known" sentence and an "unknown"
sentence (as judged by anomaly scores). Auditory spectrograms were generated for TIMIT SA1 sentecnes spoken by males.
Each sentence is the same (speakers recite the same words). Spectrograms were also generated form some TIMIT SI
sentences, each of which is unique. Spectrograms were heavily downsampled in frequency and time with the hope that
this keep computational cost relatively low.
During training, only SA1 sentences were fed to the CLA and it was allowed to adapt/train. Afterwards, adaptation
would be turned off with the expectation that SI sentences would generate higher anomaly scroes than SA1 sentences.
Due to hackathon time constraints we did not use swarming and had little time to try different parameters.

Additional files/tooboxes needed to generate auditory spectrograms and metadata:

http://www.isr.umd.edu/Labs/NSL/Software.htm

http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html

http://www.mathworks.com/matlabcentral/fileexchange/42076-getfiles


Brief file descriptions:
makeTimitMetadata.m - MATLAB script that generates structure containing TIMIT metadata.
makeFullSentenceSpectrograms_TIMIT_Numenta.m - MATLAB script to generate auditory spectrograms from TIMIT WAV files.
getTimitFiles2.m - MATLAB script for loading desired auditory spectrograms and downsampling them.
