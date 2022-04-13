%% Save variable containing indexes of bad segments in matlab file 
%=========================================================================
clear all; close all; 
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_post\';
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_post\BAD SEGMENT INDEXES'; 
cd (dirinput); 


%% Define Input: 
list = dir(cd);                
listCell = struct2cell(list);
files = listCell(1,3:end);
names = files(~cellfun('isempty', strfind(files,'marked.set'))); % only files iwth bad segments marked
eeglab;
%% loop
for ss = 1:length(names);
    fileinput = names{ss};
     
    % load dataset
    EEG = pop_loadset('filename',fileinput);
    % save bad segment indexes
    badsegs = EEG.reject.rejmanual; 
    outputname = strrep(fileinput,'marked.set','badSegIndexes'); 
    
    cd (diroutput)
    save(outputname,'badsegs');
    cd (dirinput);
    
    clear ALLEEG EEG badsegs
    close all  
end
 