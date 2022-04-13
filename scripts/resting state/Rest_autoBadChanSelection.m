%% SELECT BAD CHANNELS- based on jointprob and kurtosis 
% ================================================================================
% mark and store in separate variable
%% =================================================================================
clear all; close all
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\4_ICA_ADJUST_clean';
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\bad channels automatic selection_afterICrej';
cd(dirinput)
%% input files
list = dir(cd);                
listCell = struct2cell(list);
files = listCell(1,3:end);
names = files(~cellfun('isempty', strfind(files,'ICsRej.set'))); % only files iwth bad segments marked
%% Select bad channels
eeglab; 
for s = 1:length(names);
    fileinput = names{s};
    ppnr=fileinput(1:4);
    % load dataset
     EEG = pop_loadset('filename',fileinput);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    % Select bad segments 
    [interpEEG, indelec] = pop_rejchan(EEG,'elec',[1:64],'threshold',5,'norm','on','measure','kurt');
    % Save both in EEG dataset(no name changing and in indelec)
    EEG.reject.indelec = indelec;
    pop_saveset (EEG,fileinput);
    cd (diroutput);
    save(strrep(fileinput,'.set','badChans'),'indelec'); 
    cd (dirinput); 

    clear  indelec interpEEG EEG CURRENTSET    
end





