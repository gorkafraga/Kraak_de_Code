%% COUNT SEGMENTS AND ICA COMPONENTS - SAVE IN EXCEL
% =========================================================================
clear all; close all; 
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_post\ICAs_ADJUST_Rej';
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_post\ICAs_ADJUST_Rej';
cd (dirinput);
% list files
filelist = dir('*ICsRej.set');  
files = {filelist.name}; 
% define inputs
header= {'ppnr','bad4s_segs','chansRemoved', 'ICs_rej', 'ICs_rej_percent'} ;

for n=1:length(files);
    tmp=files{n};
    ppnr(n)= {tmp(1:4)};
end; 
ppnr = unique(ppnr);
%% 
eeglab;
% loop. 
countEp = []; countChans = []; countICsRej=[];countICsRej_percent=[];
 for f = 1:length(files);
                fileinput = files{f};
                % Load dataset
                 EEG = pop_loadset('filename',fileinput); % load dataset
                [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG);
                % count and save in corresponding column
                countEp(f) =  size(EEG.data,3);
                countChans(f) = 64 - length(EEG.chanlocs);
                countICsRej(f) =  size(EEG.icaweights,2)- size(EEG.icaweights,1);
                countICsRej_percent(f) = (100*(size(EEG.icaweights,2)-size(EEG.icaweights,1)))/size(EEG.icaweights,2);
end
%% add headers and reorganize
data2save = [header;[ppnr',[num2cell(countEp)',num2cell(countChans)',num2cell(countICsRej)',num2cell(countICsRej_percent)']]]; 

% %% save in Excel
cd(diroutput);
outputfilename = 'Count_badSegs_rejICs.xls';
if exist(outputfilename,'file') == 0;
    xlswrite (outputfilename,data2save);
 else disp('CANNOT SAVE FILE, IT ALREADY EXISTS!!');
end 