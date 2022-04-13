%%%%%%%%%%%%%%%%% IMPORT/INTERPOLATE/RECODE EVENTS/%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================================================
clear all; close all;
addpath ('X:\fraga\eeglab14_1_1b'); 
dirinput = 'Z:\fraga students\bdf_children';
diroutput = 'Z:\fraga students\EVA_ECG\raw_data_recoded';
chanlocsdir = 'X:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\channelsThetaPhi-74channels.elp';
%% Makes use of ALL filenames in input directory
    cd (dirinput); 
    list = dir('*lsb.bdf');    % find dataset files in directory
    names = {list.name};
% Channels 
 chanlabels = {'Fp1','AF7','AF3','F1','F3','F5','F7','FT7','FC5','FC3','FC1','C1','C3','C5','T7','TP7','CP5','CP3','CP1','P1','P3','P5','P7','P9',...
    'PO7','PO3','O1','Iz','Oz','POz','Pz','CPz','Fpz','Fp2','AF8','AF4','Afz','Fz','F2','F4','F6','F8','FT8','FC6','FC4','FC2','FCz','Cz',...
    'C2','C4','C6','T8','TP8','CP6','CP4','CP2','P2','P4','P6','P8','P10','PO8','PO4','O2'};

%%  
eeglab
for ss= 1:length(names);
      fileinput = names{ss};
      ppnr = fileinput(2:4) ;

%% Import bdf
EEG = pop_biosig([dirinput,'/',fileinput], 'importannot','off','blockepoch','off','ref',[69 70] ,'refoptions',{'keepref' 'off'});
%Load the channel locations file, specify BESA coordinates 
EEG = pop_chanedit(EEG,'load',chanlocsdir,'besa');
% save
outputfilename = [fileinput(1:end-4)];
%EEG = pop_saveset (EEG, outputfilename, diroutput);

%%
%Downsample to 256 Hz 
EEG = pop_resample(EEG, 256);
EEG = pop_saveset (EEG, [outputfilename,'_256Hz'], diroutput);

% export recoded file to Analyzer
 pop_writebva(EEG,[diroutput,'\',fileinput(1:end-4),'_recoded']);
  clear EEG
  close all
end
