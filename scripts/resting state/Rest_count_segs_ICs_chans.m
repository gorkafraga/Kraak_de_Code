%% COUNT SEGMENTS AND ICA COMPONENTS - SAVE IN EXCEL
% =========================================================================
clear all; close all; 
addpath 'Z:\fraga\eeglab14_1_1b'
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\Edit Channels\ICs rej';
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\Edit Channels\ICs rej';
cd (dirinput);
% list files
filelist = dir('*ICsRej.set');  
files = {filelist.name}; 
% define inputs
header= {'ppnr','badSegs_4sec','ICs_kept', 'ICs_rej','Chans_rej'} ;

for n=1:length(files);
    tmp=files{n};
    ppnr(n)= {tmp(1:4)};
end; 
ppnr = unique(ppnr);
%% 
eeglab;
% loop. 
countEp = []; countICsKept = [];countICsRej=[]; countChans = []; 
 for f = 1:length(files);
                fileinput = files{f};
                % Load dataset
                 EEG = pop_loadset('filename',fileinput); % load dataset
                [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG);
                % count and save in corresponding column
                countEp(f) =  size(EEG.data,3);
                countICsKept(f) =  size(EEG.icaweights,1);                                                   
                countICsRej(f) =  size(EEG.icaweights,2)- size(EEG.icaweights,1);
                countChans(f) = 64-length(EEG.chanlocs);
end
%% add headers and reorganize
data2save = [header;[ppnr',[num2cell(countEp)',num2cell(countICsKept)',num2cell(countICsRej)',num2cell(countChans)']]]; 

% %% save in Excel
cd(diroutput);
outputfilename = 'count_badSegs_rejICs.xls';
if exist(outputfilename,'file') == 0;
    xlswrite (outputfilename,data2save);
 else disp('CANNOT SAVE FILE, IT ALREADY EXISTS!!');
end 