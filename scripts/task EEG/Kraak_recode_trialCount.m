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
dirinput = 'V:\fraga students\EVA_ECG\ECG_adults\eeglab';
diroutput = 'V:\fraga students\EVA_ECG\ECG_adults\bva_data';
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
for i = 1:length(EEG.event);
    EEG.event(i).type = str2double(EEG.event(i).type);
end
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
%EEG = eeg_checkset(EEG,'eventconsistency');
%%  trials
counter = 0;
   mytrials = {}; 
   tmp = [];
for i = 1:length(EEG.event);% events loop
    tmp = [tmp,EEG.event(i).type]; % add current marker to a temporal variable
    if any(EEG.event(i).type == [1 2 4 8]); %add current tmp to 'mytrials' and start new row if it's a stimuli 
        counter=counter + 1;
        mytrials(counter)={tmp(1:end-1)}; %now each row is a cell  containing info for each trial(stim+resp+feedback markers)
        tmp=[];
        tmp = [tmp,EEG.event(i).type];
    elseif i==length(EEG.event);
        counter=counter+1;
         mytrials(counter)={tmp(1:end)};
    end
end
%%
for j = 1:length(mytrials);
    if (any(mytrials{j}==1) ||any(mytrials{j}==2)) && any(mytrials{j}==64); % if stim is consistent and feedback is correct ...
       currTrial = num2cell(mytrials{j}); 
       if ~isempty(find(mytrials{j}==32,1)); 
            RespIdx =find(mytrials{j}==32,1); 
            currTrial{RespIdx}= [num2str(currTrial{RespIdx}),'Cor']; % add suffix to the marker corresponding to a response(either 16 or 32);    
            mytrials{j}=currTrial;
       elseif ~isempty(find(mytrials{j}==16,1)); 
           RespIdx =find(mytrials{j}==16,1); 
            currTrial{RespIdx}= [num2str(currTrial{RespIdx}),'Cor']; % add suffix to the marker corresponding to a response(either 16 or 32);    
            mytrials{j}=currTrial;
       end           
    elseif (any(mytrials{j}==1) ||any(mytrials{j}==2))&& any(mytrials{j}==128);% if stim is consistent and feedback is incorrect ...
         currTrial = num2cell(mytrials{j});
       if ~isempty(find(mytrials{j}==32,1)); 
            RespIdx =find(mytrials{j}==32,1); 
            currTrial{RespIdx}= [num2str(currTrial{RespIdx}),'Err']; % add suffix to the marker corresponding to a response(either 16 or 32);    
            mytrials{j}=currTrial;
       elseif ~isempty(find(mytrials{j}==16,1)); 
           RespIdx =find(mytrials{j}==16,1); 
            currTrial{RespIdx}= [num2str(currTrial{RespIdx}),'Err']; % add suffix to the marker corresponding to a response(either 16 or 32);    
            mytrials{j}=currTrial;
       end      
    elseif ~isempty(find(mytrials{j}==3,1))&& j==1;
         currTrial = num2cell(mytrials{j});
         currTrial{end}= 'startExperiment';
         mytrials{j} = currTrial;
    elseif ~isempty(find(mytrials{j}==3,1));
         currTrial = num2cell(mytrials{j});
         currTrial{find(mytrials{j}==3,1)}= 'Block';
         mytrials{j} = currTrial;
         disp(currTrial); disp([num2str(j)]);
     elseif ~isempty(find(mytrials{j}==192,1));
         currTrial = num2cell(mytrials{j});
         currTrial{end}= 'miss';
         mytrials{j} = currTrial;
    end   
end
%% Now mytrials contains the events recoded. Reshape it to match the EEG.event.type matrix.
mytrials_long = [];
for m = 1:length(mytrials);
    if ~iscell(mytrials{m});
        mytrials{m} = num2cell(mytrials{m}); 
    end
    mytrials_long = [mytrials_long,mytrials{m}];
end

%%  copy them into the EEG event array
hitC = 0;
errorC = 0;
missC = 0;
for e = 1:length(EEG.event);
    EEG.event(e).type= mytrials_long{e};
    if ~isempty(regexp(mat2str(mytrials_long{e}),'Co'));
        hitC=hitC+1
    elseif ~isempty(regexp(mat2str(mytrials_long{e}),'Er'));
        errorC=errorC+1
    elseif ~isempty(regexp(mat2str(mytrials_long{e}),'miss'));
        missC=missC+1
    end  
end
csvwrite(strrep(fileinput, '.set', '_Corr.txt'),hitC);
csvwrite(strrep(fileinput, '.set', '_Error.txt'),errorC);
csvwrite(strrep(fileinput, '.set', '_Miss.txt'),missC);
% convert EEG.event types to strings
EEG = eeg_checkset(EEG,'eventconsistency');
EEG = pop_saveset (EEG,strrep(fileinput, '.set', '_reco'), diroutput);
end
