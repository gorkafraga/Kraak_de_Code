%% HIGH-PASS FILTER +  EPOCH DATA ~ RESTING-STATE (ADULTS);
% =================================================================
% High-pass filter .05
% Epochs: 4 sec segments from a 4 minutes baseline .
% Data after inspection and interpolation of bad channels.
% SR is 2048 Hz
% ==============================================================
clear global
clear all
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\s107';
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\s107';
cd (dirinput);
%%
list = dir ('*timesCoded*.set');
listCell = struct2cell(list);
names = listCell(1,:);
%%
for ss= 1:length(names);
      fileinput = names{ss};
      ppnr = fileinput(2:4) ;
      outputname = strrep(fileinput,'.set','_ep4s');
      outputname = strrep(outputname, '_timesCoded','rest_hp'); % shorten filename

if ~isempty(dir(fileinput));
    eeglab;
    % load set 
    EEG = pop_loadset('filename',fileinput);
    %% highpass filter
      EEG = pop_eegfiltnew( EEG, 0.5, 0); 
    %% epoch 
    EEG = pop_epoch( EEG, {'4'}, [0 4]); %make 4 s epochs
    EEG.setname=outputname;
    % save 
    pop_saveset (EEG,outputname,diroutput);

    clear EEG ALLEEG
    close all 
    else disp(['file ',outputname,' not found']);
    end
end