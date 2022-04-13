%% Load datasets and export to bva
%-----------------------------------
clear all
dirinput = 'Z:\fraga\ECG_ABMP\ECG_Kraak_Adults\ECG_adults_rest\ECG';
diroutput = 'Z:\fraga\ECG_ABMP\ECG_Kraak_Adults\ECG_adults_rest\bva_data';
cd(dirinput)
%%
% Load and export
eeglab
files = dir('*_ECG.set');
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
 