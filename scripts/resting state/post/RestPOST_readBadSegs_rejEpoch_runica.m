% REJECT MARKED EPOCHS AND RUN ICA 
% =========================================================================
% Reads files with marked bad segments, reject and run ICA
% =========================================================================
clear all
dirbadsegments = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_post\bad segments index post' ;
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_post\redoICA';
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_post\redoICA';
cd (dirinput);
%% Define Input: 
list = dir(cd);                
listCell = struct2cell(list);
files = listCell(1,3:end);
names = files(~cellfun('isempty', strfind(files,'editChans.set'))); % only files iwth bad segments marked

%% loop
for ss = 1:length(names); % !!!
    fileinput = names{ss};
    ppnr = fileinput(2:4) ;
    % load dataset
    eeglab;
    EEG = pop_loadset('filename',fileinput);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    %retrieve epochs marked as a bad (from previous inspection)
    cd (dirbadsegments);
    badsegfile2load = dir(['*',ppnr,'*.mat']); % find the .m file for current subj
    load (badsegfile2load.name); % will load the variable 'badsegs'. 
    EEG.reject.rejmanual = badsegs;
    EEG = eeg_checkset(EEG);
    cd(dirinput)
    % reject epochs marked as bad
    EEG = pop_rejepoch( EEG, EEG.reject.rejmanual ,0);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset(EEG);
    % Run ICA in remaining epochs
    EEG = pop_runica( EEG, 'runica', 'chanind', [1:(length(EEG.chanlocs)-8)], 'extended', 1); %takes all channels available except the 8 external
        
    % save data set and file
    outputname = strrep(fileinput,'.set' ,'_epClean_ICA');
    EEG.setname=outputname;
    pop_saveset (EEG,outputname,diroutput);

    clear EEG ALLEEG badsegs
    close all 
end