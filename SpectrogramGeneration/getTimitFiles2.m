% getTimitFiles2.m
%
% Get desired TIMIT data for use with CLA.

dirRootTimit = '/Users/roosmj1/Data/TIMIT/TIMIT/';

load /Users/roosmj1/Documents/APL/HMAX/Code/makeStimuli/timitMetadata;

bPlot = true;


%% Specify what type of sentences to use for training, and find them
bMale = ([md.bMale])';
bTrain = ([md.bTrain])';
%bSA = [md.sentType]'=='A';
bSent = strcmp({md.strSent}','SA1');

ixUse = find(bMale & bTrain & bSent);
nUse = length(ixUse);
nUse = 100;

output = cell(1,nUse);
label = cell(1,nUse);
onset = cell(1,nUse);
for cnt = 1:nUse
	mdThis = md(ixUse(cnt))';
	
	% Build filename for spectrogram and read it in
	%	example filename: SA1_DR1_TEST_FAKS0_audSpec.tiff
	specType = 'audSpec';	% 'audSpec' or 'logSpec'
	if mdThis.bTrain, strSet = 'TRAIN'; else strSet = 'TEST'; end
	strDR = ['DR' num2str(mdThis.dialReg)];
	filename = [mdThis.strSent '_' strDR '_' strSet '_' mdThis.strSpeaker '_' specType '.tiff'];
	
	im = imread([mdThis.path '/' filename]);

	if bPlot
		figure(1);
		hAx = subplot(3,1,1);
		imagesc(im); axis xy;
		title([mdThis.strSpeaker ', ' mdThis.strSent]);
		set(hAx,'YTickLabel',[]);
		set(hAx,'XTickLabel',[]);
	end
	
	% can we lpf across frequency?
	im = resample(double(im),1,8);
	im = uint8(im);
	if bPlot
		hAx = subplot(3,1,2);
		imagesc(im); axis xy;
		ylabel('Frequency');
		set(hAx,'YTickLabel',[]);
		set(hAx,'XTickLabel',[]);
	end
	
	% can we lpf across time?
	im = resample(double(im'),1,16)';
	im = uint8(im);
	if bPlot
		hAx = subplot(3,1,3);
		imagesc(im); axis xy;
		xlabel('Time');
		set(hAx,'YTickLabel',[]);
		set(hAx,'XTickLabel',[]);
	end
	
	% Read in wav file
	%[s,fs] = readsph([md(ixUse(cnt)).path '/' md(ixUse(cnt)).strSent '.WAV']);
	
	output{cnt} = im;
	label{cnt} = ones(1,size(im,2));
	onset{cnt} = zeros(1,size(im,2));  onset{cnt}(1) = 1;
end
output = cell2mat(output);
labelTrain = cell2mat(label);
onsetTrain = cell2mat(onset);
% Discard higher frequencies
specGramsTrain = output(1:12,:);
save audSpecGramsTrain specGramsTrain labelTrain onsetTrain



%% Specify what type of sentences to use for testing, and find them
bMale = ([md.bMale])';
bTrain = ([md.bTrain])';
%bSA = [md.sentType]'=='A';
bSA1 = strcmp({md.strSent}','SA1');
bSI = [md.sentType]'=='I';
bSent = bSA1 | bSI;

ixUse = find(bMale & ~bTrain & bSent);
nUse = length(ixUse);
nUse = 100;

output = cell(1,nUse);
label = cell(1,nUse);
onset = cell(1,nUse);
for cnt = 1:nUse
	mdThis = md(ixUse(cnt))';
	
	% Build filename for spectrogram and read it in
	%	example filename: SA1_DR1_TEST_FAKS0_audSpec.tiff
	specType = 'audSpec';	% 'audSpec' or 'logSpec'
	if mdThis.bTrain, strSet = 'TRAIN'; else strSet = 'TEST'; end
	strDR = ['DR' num2str(mdThis.dialReg)];
	filename = [mdThis.strSent '_' strDR '_' strSet '_' mdThis.strSpeaker '_' specType '.tiff'];
	
	im = imread([mdThis.path '/' filename]);

	if bPlot
		figure(2);
		hAx = subplot(3,1,1);
		imagesc(im); axis xy;
		set(hAx,'YTickLabel',[]);
		set(hAx,'XTickLabel',[]);
		title([mdThis.strSpeaker ', ' mdThis.strSent]);
	end
	
	% can we lpf across frequency?
	im = resample(double(im),1,8);
	im = uint8(im);
	if bPlot
		hAx = subplot(3,1,2);
		imagesc(im); axis xy;
		ylabel('Frequency');
		set(hAx,'YTickLabel',[]);
		set(hAx,'XTickLabel',[]);
	end
	
	% can we lpf across time?
	im = resample(double(im'),1,16)';
	im = uint8(im);
	if bPlot
		hAx = subplot(3,1,3);
		imagesc(im); axis xy;
		xlabel('Time');
		set(hAx,'YTickLabel',[]);
		set(hAx,'XTickLabel',[]);
	end
	
	% Read in wav file
	%[s,fs] = readsph([md(ixUse(cnt)).path '/' md(ixUse(cnt)).strSent '.WAV']);
	
	output{cnt} = im;
	label{cnt} = ones(1,size(im,2)) * bSA1(ixUse(cnt));
	onset{cnt} = zeros(1,size(im,2));  onset{cnt}(1) = 1;
end
%bTrue = bSA1(ixUse);
output = cell2mat(output);
labelTest = cell2mat(label);
onsetTest = cell2mat(onset);
% Discard higher frequencies
specGramsTest = output(1:12,:);
save audSpecGramsTest specGramsTest labelTest onsetTest



return




%% Specify what type of sentences to use for testing, and find them
bMale = ([md.bMale])';
bTrain = ([md.bTrain])';
ixUse = find(bMale & ~bTrain);

nUse = length(ixUse);
for cnt = 1:nUse
	mdThis = md(ixUse(cnt))';
	
	% Build filename for spectrogram and read it in
	%filename = [mdThis.namebase '_' mdThis.dialReg '_' mdThis.   ];
	%im = imread([mdThis.path '/' filename]);

	% Read in wav file
	[s,fs] = readsph([md(ixUse(cnt)).path '/' md(ixUse(cnt)).strSent '.WAV']);
	
	% DO WHATEVER AND STORE RESULTS
end



%% Specify what type of sentences to use for testing, and find them
bMale = ([md.bMale])';
bTrain = ([md.bTrain])';
ixUse = find(~bMale & ~bTrain);

nUse = length(ixUse);
for cnt = 1:nUse
	mdThis = md(ixUse(cnt))';
	
	% Build filename for spectrogram and read it in
	%filename = [mdThis.namebase '_' mdThis.dialReg '_' mdThis.   ];
	%im = imread([mdThis.path '/' filename]);

	% Read in wav file
	[s,fs] = readsph([md(ixUse(cnt)).path '/' md(ixUse(cnt)).strSent '.WAV']);
	
	% DO WHATEVER AND STORE RESULTS
end


