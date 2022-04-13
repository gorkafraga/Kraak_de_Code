% REJECT MARKED EPOCHS AND RUN ICA 
% =========================================================================
% Reads files with marked bad segments, reject and run ICA
% =========================================================================
clear all
dirbadsegments = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\task EEG\bad segments index task' ;
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\task EEG\ICA_redo';
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\task EEG\ICA_redo';
%% find input files: 
cd (dirinput);
list = dir('*editChans.set');                
names = {list.name}; % find epoched files

%% loop
for ss = 1:length(names);
    fileinput = names{ss};
    ppnr = fileinput(2:4) ; % get participant code from filename
    % load dataset
    eeglab;
    EEG = pop_loadset('filename',fileinput);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    %retrieve epochs marked as a bad (saved from previous inspection as matlab file)
    cd (dirbadsegments);
    badsegfile2load = dir(['*',ppnr,'*.mat']); % find the .m file for current subj
    load (badsegfile2load.name); % loads the variable 'badsegs'. 
    EEG.reject.rejmanual = badsegs;  
    EEG = eeg_checkset(EEG);
    cd(dirinput)
    EEG = pop_rejepoch( EEG, EEG.reject.rejmanual ,0);% reject epochs marked as bad
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset(EEG);
    
    % Run ICA in remaining epochs
    EEG = pop_runica( EEG, 'runica', 'chanind', [1:(length(EEG.chanlocs)-8)], 'extended', 1); %takes all channels available except the 8 external
        
    % save dataset name and file
    outputname = strrep(fileinput,'.set' ,'_epClean_ICA');
    EEG.setname=outputname;
    pop_saveset (EEG,outputname,diroutput);

    clear EEG ALLEEG badsegs
    close all 
end