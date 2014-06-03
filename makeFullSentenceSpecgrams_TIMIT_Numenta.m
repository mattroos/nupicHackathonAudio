% makeFullSentenceSpecgrams_TIMIT.m
%
% Used to generate audio spectrograms for all sentences in the TIMIT
% corpus.
%
% Matt Roos
% 4/30/14

%return

%dirTimitRoot = '/usr/local/share/Databases/TIMIT/';
dirTimitRoot = '/Users/roosmj1/DATA/TIMIT/TIMIT/';

fs = 16000;	% same fs for all TIMIT files


% Add paths
% addpath('/usr/local/MATLAB/Toolboxes/voicebox/');
% addpath('/usr/local/MATLAB/Toolboxes/nsl/nsltools/');
addpath('~/Documents/MATLAB/Toolboxs/nsltools/','-begin');
addpath('~/Documents/MATLAB/Toolboxs/voicebox/','-begin');


%% Delete unwanted files (e.g., old specgram .tiff files)
% dirWork = pwd;
% cd(dirTimitRoot);
% tic
% filenamesSA = getfiles('SA*.tiff',1);
% filenamesSX = getfiles('SX*.tiff',1);
% filenamesSI = getfiles('SI*.tiff',1);
% filenames = [filenamesSA; filenamesSX; filenamesSI];
% toc
% cd(dirWork);
% tic
% for iSent = 1:length(filenames)
% 	eval(sprintf('!rm %s',filenames{iSent}));
% end
% toc


%% Get list of all desired TIMIT .WAV files and full pathnames
dirWork = pwd;
cd(dirTimitRoot);
disp('Getting filenames...');
filenamesSA = getfiles('SA*.WAV',1);
filenamesSX = getfiles('SX*.WAV',1);
filenamesSI = getfiles('SI*.WAV',1);
filenames = [filenamesSA; filenamesSX; filenamesSI];
%filenames = filenamesSA;
cd(dirWork);
%load tempFilenames


%% Generate spectrograms

% Define parameters for auditory spectrograms
paras(1) = 4;		% frame jump, in ms, e.g., 4, 8, 16, 32 ms
paras(2) = 8;		% Time constant, in ms, e.q., 4, 8, 16, 32, 64 ms
paras(3) = 0.1;		% Nonlinear factor, e.g., .1
paras(4) = 0;		% Octave shift, e.g., -1 for 8k, 0 for 16k (sampling rate)

% if matlabpool('size')==0
% 	matlabpool;
% end

% Define parameters for regular spectrogram computed at frequencies that
% match those of auditory spectrogram
fLog = 2.^(log2(182):1/24:log2(7150));	% center frequencies used by NSL toolbox default
dbRange = 50;


nSent = length(filenames);
%fprintf(1,'Total=%0.4d, Processing=%0.4d',nSent,0);
fprintf(1,'Processing %d sentences.\n',nSent);
t = clock;
for iSent = 1:nSent
	[pathstr,namebase,~] = fileparts(filenames{iSent});
		
	% Load the sentence
	[s,fs,wrd,phn] = readsph(filenames{iSent},'wt');
	
	% Generate output filename components
	iSep = find(pathstr==filesep);
	person = pathstr(iSep(end)+1:end);
	district = pathstr(iSep(end-1)+1:iSep(end)-1);
	testTrainSet = pathstr(iSep(end-2)+1:iSep(end-1)-1);
	
	% Get audio spectrogram and save
	y = wav2aud(s,paras,'p',0);
	y = y/max(y(:));	% scale to [0,1]
	outfilename = [namebase '_' district '_' testTrainSet '_' person '_audSpec.tiff'];
	%imwrite(y',[pathstr filesep outfilename],'tiff');
	figure(1);
	hAx = subplot(3,1,3);
	imagesc(y'); axis xy;
	set(hAx,'YTickLabel',[]);
	set(hAx,'XTickLabel',[]);
	xlabel('Time');
	title('Cochlear Spectrogram');
	
	
	% Get log-frequency spectrogram and save
	nFFT = 1024;
	tFrame = nFFT/fs;
	[specLog,~,tSpecLog] = spectrogram(s,hanning(nFFT),round((tFrame-0.004)*fs),fLog,fs);
	specLog = 10*log10(abs(specLog));
	mx = max(specLog(:)); specLog = specLog-mx;
	specLog(specLog<-dbRange) = -dbRange;
	specLog = (specLog+dbRange)/dbRange;	% scale to [0,1]
	outfilename = [namebase '_' district '_' testTrainSet '_' person '_logSpec.tiff'];
	%imwrite(specLog,[pathstr filesep outfilename],'tiff');
	hAx = subplot(3,1,2);
	imagesc(specLog); axis xy;
	set(hAx,'YTickLabel',[]);
	set(hAx,'XTickLabel',[]);
	ylabel('Frequency');
	title('Logarithmic Frequency Spectrogram');
	
	% Get linear-frequency spectrogram and save
	nFFT = 1024;
	tFrame = nFFT/fs;
	[specLin,~,tSpecLin] = spectrogram(s,hanning(nFFT),round((tFrame-0.004)*fs),nFFT,fs);
	specLin = 10*log10(abs(specLin));
	mx = max(specLin(:)); specLin = specLin-mx;
	specLin(specLin<-dbRange) = -dbRange;
	specLin = (specLin+dbRange)/dbRange;	% scale to [0,1]
	outfilename = [namebase '_' district '_' testTrainSet '_' person '_linSpec.tiff'];
	%imwrite(specLin,[pathstr filesep outfilename],'tiff');
	hAx = subplot(3,1,1);
	imagesc(specLin); axis xy;
	set(hAx,'YTickLabel',[]);
	set(hAx,'XTickLabel',[]);
	title('Linear Frequency Spectrogram');
	
	figTextSize(gcf,16,true);
	export_fig('specgramTypes.pdf','-pdf');
	return
	
	tLeft = etime(clock,t)/iSent * (nSent-iSent) / 3600;
	fprintf(1,'%d of %d sentences done. About %0.2f hours to go.\n',iSent,nSent,tLeft);
end
fprintf(1,'\n\n');


return
%%
% Here is a linux command that copies all the TIMIT files to a remote server:
% roosmj1@neurostream:/usr/local/share/Databases/TIMIT$ rsync -vr ./ roosmj1@darkhelmet:/mnt/neuroShare/AUDIO_HMAX/images/timit/TIMIT

% Here is a linux command that copies all the TIMIT .tiff files to a remote server:
% rsync -avzm --include "*/" --include "*.tiff" --exclude "*" /usr/local/share/Databases/TIMIT roosmj1@darkhelmet:/mnt/neuroShare/AUDIO_HMAX/images/timit
%

% Here is a linux command that copies all the TIMIT .mat files from a remote server to local machine:
% rsync -avzm --include "*/" --include "*.mat" --exclude "*" roosmj1@darkhelmet:/mnt/neuroShare/AUDIO_HMAX/images/timit/TIMIT /usr/local/share/Databases



%rsync -avzm --include "*/" --include "SA*.tiff" --exclude "*" /usr/local/share/Databases/TIMITscaled roosmj1@darkhelmet:/mnt/neuroShare/AUDIO_HMAX/images/timitSA
% rsync -avzm --include "*/" --include "*.mat" --exclude "*" /usr/local/share/Databases/TIMIT/TIMIT/TIMIT /usr/local/share/Databases/TIMIT







