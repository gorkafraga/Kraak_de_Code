%% Save the index of bad segments
%=========================================================================================
diroutput = 'X:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_post\bad segments index post';
filename2save = strrep(EEG.filename,'.set','_marked.set');
cd (diroutput)
badsegs = EEG.reject.rejmanual; 

save(strrep(EEG.filename,'.set','_marked.mat'),'badsegs');

EEG = pop_saveset (EEG, filename2save,diroutput);
eeglab redraw
clear all 
eeglab
