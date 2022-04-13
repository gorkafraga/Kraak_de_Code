%% EPOCH DATA ~ RESTING-STATE (ADULTS);
% =================================================================
% Epochs: 4 sec segments from a 4 minutes baseline correction.
% Data after inspection and interpolation of bad channels.
% SR is 2048 Hz
% ==============================================================

% Interpolate bad electrodes - EEG RESTING-STATE KdC-Adults
%========================================================================
clear global
clear all
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\';
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\';
 cd (dirinput);

list = dir(cd);
listCell = struct2cell(list);
files = listCell(1,3:end);
names = files(~cellfun('isempty', strfind(files,'.set')));

for ss= 1:length(names);
      fileinput = names{ss};
      outputfilename = fileinput(1:end-4);
      ppnr = fileinput(2:4) ;
      
eeglab;
% load set 
EEG = pop_loadset('filename',fileinput);
%% epoch 
outputname = strrep(fileinput,'.set','_ep4s');
outputname = strrep(outputname, 'rest_72ch_timesCoded','rest'); % shorten filename

EEG = pop_epoch( EEG, {'4'}, [0 4]); %make 4 s epochs
EEG.setname=outputname;

% save 
pop_saveset (EEG,outputname,diroutput);

clear EEG ALLEEG
close all 
end