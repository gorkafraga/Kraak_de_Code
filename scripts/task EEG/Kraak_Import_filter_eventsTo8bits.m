%%%%%%%%%%%%%%%%% IMPORT/ FILTERS / RECODE EVENTS to 8 bits codes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================================================
clear all ; close all; 
addpath ('Z:\fraga\eeglab14_1_1b'); 
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\task EEG\';
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\task EEG\imported';
chanlocsfile = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\channelsThetaPhi-72channels_noECG.elp';
 cd (dirinput); 
%% Get input files 
list = dir('*lsb.bdf');                
names = {list.name};    
% Channels 
 chanlabels = {'Fp1','AF7','AF3','F1','F3','F5','F7','FT7','FC5','FC3','FC1','C1','C3','C5','T7','TP7','CP5','CP3','CP1','P1','P3','P5','P7','P9',...
    'PO7','PO3','O1','Iz','Oz','POz','Pz','CPz','Fpz','Fp2','AF8','AF4','Afz','Fz','F2','F4','F6','F8','FT8','FC6','FC4','FC2','FCz','Cz',...
    'C2','C4','C6','T8','TP8','CP6','CP4','CP2','P2','P4','P6','P8','P10','PO8','PO4','O2'}; % useful for plots later on
%% Subject loop
for ss = 1:length(names);
    cd(dirinput)
      fileinput = names{ss};
      ppnr = fileinput(2:4) ;
%% Import bdf
eeglab
EEG = pop_biosig([dirinput,'/',fileinput], 'importannot','off','blockepoch','off','ref',[73 74] ,'refoptions',{'keepref' 'on'}); % import with linked earlobes as ref
% Remove heart rate electrodes
EEG = pop_select (EEG, 'channel', [1:64 67:74]); % 
%Load the channel locations file, specify BESA coordinates 
EEG = pop_chanedit(EEG,'load',chanlocsfile,'besa');
% save set
%outputfilename = [fileinput(1:end-4)];
%EEG = pop_saveset (EEG, outputfilename, diroutput);
%% Downsample
EEG = pop_resample(EEG, 256);
%EEG = pop_saveset (EEG, [outputfilename,'_bp_512Hz'], diroutput);
%% Basic FIR filter ---> Bandpass filter, first lowpass then highpass filter
%Lowpass filter - keeps data under 70 Hz
    EEG = pop_eegfiltnew( EEG, 0, 70);
%Highpass filter - keeps data above 1 Hz (takes long time)
    EEG = pop_eegfiltnew( EEG, 0.016, 0);
% save 
%EEG = pop_saveset (EEG,[outputfilename,'_bp'], diroutput);

%% Recode markers - convert from dec to bin and take last 8 bits to match triggers coded in presentation
eventInfo = squeeze(struct2cell(EEG.urevent));
E = cell2mat(eventInfo(1,:));
Ebin = dec2bin(E);
Erecoded = bin2dec(Ebin(:,9:16));
for i = 1:length(EEG.event);
    EEG.urevent(i).type = Erecoded(i);
    EEG.event(i).type = Erecoded(i);
end
outputfilename = [fileinput(1:end-4)];
EEG = eeg_checkset(EEG);
EEG = pop_saveset (EEG,strrep(fileinput, '.bdf', '_256Hz_bp'), diroutput);
end

