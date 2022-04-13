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
dirinput = 'Z:\fraga students\EVA_ECG\raw_data_recoded';
diroutput = 'Z:\fraga students\EVA_ECG\raw_data_recoded';
cd (dirinput); 
% Get input files 
list = dir('*256Hz.set');                
names = {list.name};    

%% Subject loop
eeglab;
groupCount=[];
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
%% Recode markers - convert from dec to bin and take last 8 bits to match triggers coded in presentation
eventInfo = squeeze(struct2cell(EEG.urevent));
E = cell2mat(eventInfo(1,:));
Ebin = dec2bin(E);
Erecoded = bin2dec(Ebin(:,9:16));
for i = 1:length(EEG.event);
    EEG.urevent(i).type = Erecoded(i);
    EEG.event(i).type = Erecoded(i);
end
%% find first inconsistent trial as a reference (no pratice trials are possible afterwards)
inconsistentIdx =[];
for i = 1:length(EEG.event);% events loop
   if any(EEG.event(i).type==[4 8])
inconsistentIdx = [inconsistentIdx,i];
   end
end
top=inconsistentIdx(1);
% Find marker 3 (indicating start of task after practice?)
idx3 =[];
for i = 1:length(EEG.event);% events loop
   if EEG.event(i).type== 3
    idx3 = [idx3,i];
   end
end
if ~isempty(idx3)
first3=idx3(1);
end


%% NOW START COUNTING AS PRACTICE TRIALS THE FIRST 30 CONSISTENT TRIALS (Before first inconsistent)
counter = 0;
counterPractice = 0;
for i = 1:length(EEG.event);% events loop
   if any(EEG.event(i).type==[1 2]); %add current tmp to 'mytrials' and start new row if it's a stimuli 
        counter=counter + 1;
        if (counter <= 30 && i < top); 
            EEG.event(i).type = 666;
            counterPractice = counterPractice + 1;
        end
    end
end
%% convert EEG.event types to strings
EEG = eeg_checkset(EEG,'eventconsistency');
EEG = pop_saveset (EEG,strrep(fileinput, '.set', '_reco_1'), diroutput);
cd (diroutput)
EEG = pop_writebva(EEG,strrep(fileinput, '.set', '_reco_1'));
cd(dirinput)
%save practice count in group array
groupCount = [groupCount;[fileinput,num2cell(counterPractice)]];
end
cd(diroutput);
outputfilename = 'groupPractice_count.xls';
if exist(outputfilename,'file') == 0;
    xlswrite (outputfilename,groupCount);
 else disp('CANNOT SAVE FILE, IT ALREADY EXISTS!!');
end 
