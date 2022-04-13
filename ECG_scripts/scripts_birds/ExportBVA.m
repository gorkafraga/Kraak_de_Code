%% Load datasets and export to bva
%-----------------------------------
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\task EEG\imported';
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\task EEG\bva';
% Load and export
eeglab
files = dir('*bp_reco.set');
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
 