% makeTimitMetadata.m

return

clear

dirRootTimit = '/Users/roosmj1/Data/TIMIT/TIMIT/';
dirWord = pwd;

d = rdir([dirRootTimit '**/*.WAV']);
nSent = length(d);

md.strSent = '';
md.strSpeaker = '';
md.idSent = [];
md.idSpeaker = [];
md.dialReg = '';
md.sentType = '';	% 'I','A','X'
md.bMale = false;
md.bTrain = false;
md.words = {};
md.wordTimes = [];
md(nSent) = md(1);

for iSent = 1:nSent
	disp(iSent)
	[s,fs,wrd] = readsph(d(iSent).name,'wt');
	[path,namebase] = fileparts(d(iSent).name);
	
	md(iSent).path = path;
	md(iSent).strSent = namebase;
	md(iSent).strSpeaker = path(end-4:end);
	md(iSent).dialReg = str2double(path(end-6));
	md(iSent).sentType = namebase(2);
	md(iSent).bMale = path(end-4) == 'M';
	md(iSent).bTrain = path(end-10) == 'N'; % trai'N'
	md(iSent).words = wrd(:,2);
	md(iSent).wordTimes = cell2mat(wrd(:,1));
end

% Generate unique speaker and sentence IDs
[~,~,idSpeaker] = unique({md.strSpeaker}');
[~,~,idSent] = unique({md.strSent}');

for iSent = 1:nSent
	md(iSent).idSpeaker = idSpeaker(iSent);
	md(iSent).idSent = idSent(iSent);	
end

save timitMetadata md


