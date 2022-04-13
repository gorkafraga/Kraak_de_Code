%%%%%%%%%%%%%%%%% IMPORT/ FILTERS / RECODE EVENTS to 8 bits codes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================================================
clear all
clear global
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\raw_pre\';
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\ECG';
 cd (dirinput); 
%% Define Input: 
% Makes use of ALL filenames in input directory!
    list = dir('*.bdf');     % find dataset files in directory
    listCell = struct2cell(list);
    names = listCell(1,:);
%% Subject loop
for ss= 1:length(names);
      fileinput = names{ss};
      outputfilename = fileinput(1:end-4);
      ppnr = fileinput(2:4) ;
%% Import bdf
    eeglab;
    % import with linked earlobes as ref
    EEG = pop_biosig([dirinput,'/',fileinput], 'importannot','off','blockepoch','off','ref',[73 74] ,'refoptions',{'keepref' 'on'}); 
    % Remove heart rate electrodes
    EEG = pop_select (EEG, 'channel', [65 66]); 
    % downsample 
    EEG = pop_resample( EEG, 256);   
   
%% Recode markers - find marker indicating start of baseline
        e = squeeze(struct2cell(EEG.urevent));
        typev = cell2mat(e(1,:));% event  types in a cell array 
        startIdx = find(typev == 62464,1,'last');%returns the index of last occurrence of 62464
        if isempty(startIdx);
            startIdx = find(typev == 62468,1,'last');
            if  isempty(startIdx);
            startIdx = find(typev == 63492,1,'last');
            end
        end
        % rename 
        EEG.urevent(startIdx).type = 'Start';
        EEG.event(startIdx).type = 'Start';
     
     eeglab redraw;
     %save
      % EEG = pop_saveset (EEG, [outputfilename,'_72ch_recode'], diroutput);
             
    %% Extract epoch from ' Start' marker till the end of the recording
      EEG = pop_epoch(EEG, {'Start'}, [0 (EEG.xmax -(EEG.event(startIdx).latency/EEG.srate))]); % times from 'Start' till the end
      eeglab redraw; 
         %% Add markers to define segments of different lengths 
             idx2sec = 0:(EEG.srate*2):EEG.pnts;
             idx4sec = 0:(EEG.srate*4):EEG.pnts;           
             idx6sec = 0:(EEG.srate*6):EEG.pnts;
             idx8sec = 0:(EEG.srate*8):EEG.pnts;
             idx10sec = 0:(EEG.srate*10):EEG.pnts;
             idx12sec = 0:(EEG.srate*12):EEG.pnts;

            for i = 1:length(idx2sec);
                tmpEvent2(i).type = '2';
                tmpEvent2(i).latency=idx2sec(i);
                tmpEvent2(i).urevent=[];
             end; clear i  
             
            for i = 1:length(idx4sec);
                tmpEvent4(i).type = '4';
                tmpEvent4(i).latency=idx4sec(i);
                tmpEvent4(i).urevent=[];
             end; clear i    
             
            for i = 1:length(idx6sec);
                tmpEvent6(i).type = '6';
                tmpEvent6(i).latency=idx6sec(i);
                tmpEvent6(i).urevent=[];
             end; clear i 
                  
            for i = 1:length(idx8sec);
                tmpEvent8(i).type = '8';
                tmpEvent8(i).latency=idx8sec(i);
                tmpEvent8(i).urevent=[];
             end; clear i 
              
            for i = 1:length(idx10sec);
                tmpEvent10(i).type = '10';
                tmpEvent10(i).latency=idx10sec(i);
                tmpEvent10(i).urevent=[];
             end; clear i 
             
            for i = 1:length(idx12sec);
                tmpEvent12(i).type = '12';
                tmpEvent12(i).latency=idx12sec(i);
                tmpEvent12(i).urevent=[];
             end; clear i 
   
% Incorporate new markers to the EEG.event array             
 EEG.event = [EEG.event,tmpEvent2,tmpEvent4,tmpEvent6,tmpEvent8,tmpEvent10,tmpEvent12];
  clear tmpEvent2 tmpEvent4 tmpEvent6 tmpEvent8 tmpEvent10 tmpEvent12             
 %save
 EEG = pop_saveset(EEG,[outputfilename,'_256Hz_ECG'], diroutput); %#ok<NASGU>

clear ALLEEG EEG CURRENTSET EEG.event
close all
cd (dirinput)
end