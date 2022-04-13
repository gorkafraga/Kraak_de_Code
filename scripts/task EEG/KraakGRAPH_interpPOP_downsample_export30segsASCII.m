%% Interpolate channels // Downsample(1024 Hz) //  Export as text file (Brainwave format).
% =========================================================================================
% Note: uses dummy EEG dataset with all channels
clear all; close all;
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\task EEG\ICA_redo' ;
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\task EEG\ICA_redo';
diroutput_BVA = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\task EEG\ICA_redo'; 
dirdummy = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\task EEG';
%diroutput_BVA = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\ASCIIs interpolation 1file\segments_bva';
chanlocsfile = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\channelsThetaPhi-64scalp.elp'; 

chanlabels = {'Fp1','AF7','AF3','F1','F3','F5','F7','FT7','FC5','FC3','FC1','C1','C3','C5','T7','TP7','CP5','CP3','CP1','P1','P3','P5','P7','P9',...
    'PO7','PO3','O1','Iz','Oz','POz','Pz','CPz','Fpz','Fp2','AF8','AF4','Afz','Fz','F2','F4','F6','F8','FT8','FC6','FC4','FC2','FCz','Cz',...
    'C2','C4','C6','T8','TP8','CP6','CP4','CP2','P2','P4','P6','P8','P10','PO8','PO4','O2'};
%% Get list of input files
cd (dirinput);
list = dir('*ICsRej.set');                
names = {list.name}; 
%% read dummy file with chan location
EEG = pop_loadset('filename','dummy64ChanLocs.set','filepath',dirdummy);
dummyEEG = EEG;
clear EEG
%% Begin loop
for ss = 1:length(names);
    fileinput = names{ss};
    ppnr = fileinput(2:4) ;
    % load dataset
    eeglab;
    EEG = pop_loadset('filename',fileinput);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
 % rereference
   % EEG = pop_reref( EEG, [] );    
 %%  Interpolate removed channels  
   EEG =pop_interp(EEG,dummyEEG.chanlocs, 'spherical');
   EEG = eeg_checkset(EEG);
   eeglab redraw;
   
 %% downsample
    EEG = pop_resample( EEG, 1024);   
    EEG = eeg_checkset(EEG);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

    %  %% Export to BVA 
    EEG = pop_select( EEG,'trial',[1:30]);
    pop_writebva(EEG,[diroutput_BVA,'\',fileinput]);
 %% Save segments in a single txt file
cd (diroutput);    
 data2save = [];  
 fileoutput = [fileinput(1:4),'_4s_segments.txt'];

 for seg = 1:30
         % arrange data in format : ch = cols and data points = rows
         data2save = [data2save;num2cell(EEG.data(:,:,seg)')];
 end
 data2save = double(cell2mat(data2save));
    % save as text file
             fileID = fopen(fileoutput,'w');
             %formatspec1='%s '; formatspec1=[repmat(formatspec1,1,64),'\n'];
             formatspec2='%6.3f\t';formatspec2= [repmat(formatspec2,1,64),'\n'];
              [nrows,ncols] = size(data2save);
               %fprintf(fileID,formatspec1,data2save{1,:});
                    for row = 1:nrows
                    fprintf(fileID,formatspec2,data2save(row,:)); % export all rows with format spec 2
                    end
            fclose('all');
       clear data2save;
 %end
    cd(dirinput); 
end