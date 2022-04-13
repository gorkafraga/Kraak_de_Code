%% ADJUST -  automatic artifact detection (ICA-based) and rejection of those ICs 
% ================================================================================
% - Loads files with ICA weights
% - Runs ADJUST algorithm
% - Remove ICs detected as artifactual
% - Count remaining components
%% =================================================================================
clear all; close all
dirinput = 'X:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_post\ICAs_redo';
diroutput = 'X:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_post\ICAs_redo';
cd(dirinput)
%% input files
list = dir('*epClean_ICA.set');                
names = {list.name};
%% RUN ADJUST
eeglab;
countIC=[];
for s = 1:length(names);
    fileinput = names{s};
    ppnr=fileinput(1:4);
    % load dataset
     EEG = pop_loadset('filename',fileinput);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    % first remove all non-scalp channels
    EEG =  pop_select(EEG,'channel',[1:(length(EEG.chanlocs)-8)]);
    % run ADJUST to identify bad channels
    cd(diroutput)
    out = [ppnr,'.txt']; %name of report file from ADJUST
   [art, horiz, vert, blink, disc,...
  soglia_DV, diff_var, soglia_K, med2_K, meanK, soglia_SED, med2_SED, SED, soglia_SAD, med2_SAD, SAD, ...
   soglia_GDSF, med2_GDSF, GDSF, soglia_V, med2_V, nuovaV, soglia_D, maxdin]=ADJUST (EEG,out);
   cd(dirinput)
    % reject those components
    EEG = pop_subcomp( EEG,art, 0);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    % save IC count in matrix (with ppnr)
    countIC = [countIC;[ppnr,num2cell(length(art)),num2cell((100*length(art))/size(EEG.data,1))]];
    
    % save data set and file
    outputname = strrep(fileinput,'.set' ,'_ICsRej');
    EEG.setname=outputname;
    pop_saveset (EEG,outputname,diroutput);

    clear  EEG CURRENTSET    
end

%% save count of ICs
cd(diroutput);
countIC = [{'ppnr','ICrej','rejPercentFromTotal'};countIC];
outputfilename = 'count_rejICs_ADJUST.xls';
if exist(outputfilename,'file') == 0;
    xlswrite (outputfilename,countIC);
 else disp('CANNOT SAVE FILE, IT ALREADY EXISTS!!');
end 
