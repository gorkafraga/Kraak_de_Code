%% Load datasets and export to bva
%-----------------------------------
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_post\ICAs_ADJUST_Rej';
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_post\Clean_export2BVA';
cd (dirinput)
%% Load and export
eeglab
files = dir('*_ICsRej.set');
names = {files.name};
for i = 1:length(names); 
    
    fileinput = names{i};
    EEG = pop_loadset(fileinput, dirinput);
    if ~isempty(dir(fileinput))
       cd (diroutput)
       EEG = pop_writebva(EEG,fileinput); 
       cd (dirinput)
    end
end
clear all;
 