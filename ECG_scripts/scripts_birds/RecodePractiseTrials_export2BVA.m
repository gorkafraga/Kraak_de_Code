%% Edit marker with info whether response is correct or incorrect in consistent trials.
%STIMULI: 1 consistent/match 2 consistent/mismatch 4 inconsistent/match 8 inconsistent/mismatch. 
%RESPONSES: 16 left 32 right.
%FEEDBACK:64 correct 128 incorrect, 192 too slow
% if stimuli = 1 or 2 and feedback is correct: include "C" suffix in response (e.g. '16C') else include 'E' (e.g. '16E')
% Prevent issue with multiple responses trials are first separated (till next Stim. occurrence)
% % Mark trials in which two triggers were sent simultaneously, resulting in
% % marker '0' . Include suffix 'Simu'. Exclude later? (might indicate simultaneous press of two buttons
% % ------------------------------------------------------------------------------------------------
%%%%%%%%%%%%%%%%% IMPORT/ FILTERS / RECODE EVENTS to 8 bits codes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================================================
clear all ; close all; 
%%
addpath ('Z:\fraga\eeglab14_1_1b'); 
dirinput = 'Z:\fraga\ECG_ABMP\ECG_Kraak_Adults\ECG_adults_bird\eeglab_sets';
diroutput = 'Z:\fraga\ECG_ABMP\ECG_Kraak_Adults\ECG_adults_bird\';
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

%% Convert all events types to double
% for i = 1:length(EEG.event);
%     EEG.event(i).type = str2double(EEG.event(i).type);
% end
% %% Recode markers - convert from dec to bin and take last 8 bits to match triggers coded in presentation
% eventInfo = squeeze(struct2cell(EEG.urevent));
% E = cell2mat(eventInfo(1,:));
% Ebin = dec2bin(E);
% Erecoded = bin2dec(Ebin(:,9:16));
% for i = 1:length(EEG.event);
%     EEG.urevent(i).type = Erecoded(i);
%     EEG.event(i).type = Erecoded(i);
% end
%% Recode the 30 first (practice)consistent trials with a 666 numeric code as they are from the practice block.
counter = 0;
for i = 1:length(EEG.event);% events loop
   if any(EEG.event(i).type==[1 2]); %add current tmp to 'mytrials' and start new row if it's a stimuli 
        counter=counter + 1;
        if counter <= 30; 
            EEG.event(i).type = 666;
        end
    end
end
%% convert EEG.event types to strings
%EEG = eeg_checkset(EEG,'eventconsistency');
%%
%EEG = pop_saveset (EEG,strrep(fileinput, '.set', '_reco'), diroutput);
cd (diroutput)
EEG = pop_writebva(EEG,strrep(fileinput, '.set', '_reco'));
cd(dirinput)
end
