% RECODE MARKERS (8BITS) AND EXPORT TO BVA
%==========================================================================================================
clear all ; close all; 
%%
addpath ('Z:\fraga\eeglab14_1_1b'); 
dirinput = 'Z:\fraga\ECG_ABMP\ECG_Kraak_Adults\ECG_adults';
diroutput = 'Z:\fraga\ECG_ABMP\ECG_Kraak_Adults\ECG_adults';
cd (dirinput); 
%% Get input files 
list = dir('*256Hz.set');                
names = {list.name};    
eeglab;
%% Subject loop
for ss = 1:length(names);
    cd(dirinput)
      fileinput = names{ss};
      ppnr = fileinput(2:4) ;
%% Load data set
    EEG = pop_loadset('filename',fileinput);    

% %% Convert all events types to double
% for i = 1:length(EEG.event);
%     EEG.event(i).type = str2double(EEG.event(i).type);
% end
%% Recode markers - convert from dec to bin and take last 8 bits to match triggers coded in presentation
eventInfo = squeeze(struct2cell(EEG.urevent));
E = cell2mat(eventInfo(1,:));
Ebin = dec2bin(E);
Erecoded = bin2dec(Ebin(:,9:16));
for i = 1:length(EEG.event);
    EEG.urevent(i).type = Erecoded(i);
    EEG.event(i).type = Erecoded(i);
end
% convert EEG.event types to strings
EEG = eeg_checkset(EEG,'eventconsistency');
%EEG = pop_saveset (EEG,strrep(fileinput, '.set', '_reco'), diroutput);
cd (diroutput)
pop_writebva(EEG, strrep(fileinput,'.set','_recoded'));
cd (dirinput)
end
