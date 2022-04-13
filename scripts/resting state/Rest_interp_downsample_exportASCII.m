%% Interpolate channels // Downsample(1024 Hz) //  Export as text file (Brainwave format).
% =========================================================================================
clear all; close all;
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\s107' ;
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\s107';
diroutput_BVA = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\s107';
chanlocsfile = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\channelsThetaPhi-64scalp.elp'; 
chanlabels = {'Fp1','AF7','AF3','F1','F3','F5','F7','FT7','FC5','FC3','FC1','C1','C3','C5','T7','TP7','CP5','CP3','CP1','P1','P3','P5','P7','P9',...
    'PO7','PO3','O1','Iz','Oz','POz','Pz','CPz','Fpz','Fp2','AF8','AF4','Afz','Fz','F2','F4','F6','F8','FT8','FC6','FC4','FC2','FCz','Cz',...
    'C2','C4','C6','T8','TP8','CP6','CP4','CP2','P2','P4','P6','P8','P10','PO8','PO4','O2'};
cd (dirinput);

% Get input files 
list = dir('*ICsRej.set');                
names = {list.name}; 
%% loop
cd(dirinput)
%for ss = 1:length(names)
for ss = [1:7,9:19,21:37,39:length(names)];
    fileinput = names{ss};
    ppnr = fileinput(2:4) ;
    % load dataset
    eeglab;
    EEG = pop_loadset('filename',fileinput);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
 %% rereference
   % EEG = pop_reref( EEG, [] );
    
 %%  Interpolate removed channels
    s = str2num(ppnr); 
    chans2interp = {'none'}; % the default is none. But...
       if s == 1;          chans2interp = {'T7','P9','O1'};  
      elseif s==2;       chans2interp = {'P8','TP8','FC3'};
      elseif s==6;       chans2interp = {'T8'};
      elseif s==9;       chans2interp = {'F8'};
      elseif s==12;      chans2interp = {'FC6','P2'};
      elseif s==17;      chans2interp = {'P5'};
      elseif s==18;      chans2interp = {'PO7','P2'};
      elseif s==19;      chans2interp = {'PO7'}; 
      elseif s==21;      chans2interp = {'P2'};
      elseif s==23;       chans2interp = {'P10'};
      elseif s==26;           chans2interp = {'C3','Iz'}; 
      elseif s==27;            chans2interp = {'F6','F7'};
      elseif s==28;            chans2interp = {'POz', 'P2','PO4'};
      elseif s==29;           chans2interp = {'FT8','POz','P2'}; 
      elseif s==32;           chans2interp = {'POz'}; 
      elseif s==36;            chans2interp = {'T8','T7','TP7'};
      elseif s==101;            chans2interp = {'CP2','P4','CPz','FC1','FC3'};
      elseif s==104;            chans2interp = {'C4','FC4','P2','POz', 'PO7'};
      elseif s==105;            chans2interp = {'POz','Oz','Pz','PO8','PO3', 'P9'};
      elseif s==107;            chans2interp = {'FC6', 'T7'};
       elseif s==110;            chans2interp = {'C6'};
       elseif s==111;            chans2interp = {'T7'};
       elseif s==114;            chans2interp = {'P2'};
      elseif s==115;            chans2interp = {'P3'};
       elseif s==117;           chans2interp = {'P9'};
       elseif s==118;           chans2interp = {'FC1','P2','P6'};
       elseif s==114;           chans2interp = {'P2'};
      elseif s==115;            chans2interp = {'P3'};
       elseif s==117;           chans2interp = {'P9'};
       elseif s==118;           chans2interp = {'FC1','P2','P6'};
       elseif s==122;           chans2interp = {'P2'};
       elseif s==123;           chans2interp = {'P2','T8'};
        elseif s==126;          chans2interp = {'P2'};
        elseif s==127;          chans2interp = {'POz'};
        elseif s==128;         chans2interp = {'POz','T8','T7','TP7'};
     end

   if isempty(strmatch('none',chans2interp))==1 ;  % If there are channels to interpolate...
          for c = 1:length(chans2interp); % Insert 'new' channels as zeros. then load the channel location file with only scalp channels
               chans2interpNum(c) = find(strcmp(chans2interp{c},chanlabels));% get numeric array of electrodes
          end
          chans2interpNum = sort(chans2interpNum);
      %% add new channels (zeroes) where the interpolated channels will be
          newchan = [zeros(1,size(EEG.data,2))]; % add rows with zeros for new channels
          for seg = 1:size(EEG.data,3); 
              newdata = EEG.data(:,:,seg);
              for c = 1:length(chans2interpNum); 
                  newdata = insertrows(newdata,newchan,chans2interpNum(c)-1);          
              end
           tempEEG(:,:,seg) = newdata;
           clear newdata
          end
           EEG.data = tempEEG;
    %% Interpolate
            EEG = eeg_checkset(EEG);
            EEG = pop_chanedit(EEG,'load',chanlocsfile,'besa');              
            %%%%%%% interpolate  %%%
           for c = 1:length(chans2interp);
               EEG =pop_interp(EEG,chans2interpNum(c), 'spherical');
           end
               EEG = eeg_checkset(EEG);
               eeglab redraw;
  clear tempEEG newdata chans2interpNum

     elseif  isempty(strmatch('none',chans2interp))==0; 
   end
    eeglab redraw; 
 %% downsample
    EEG = pop_resample( EEG, 1024);   
    EEG = eeg_checkset(EEG);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
 %% Export to BVA 
   pop_writebva(EEG,[diroutput_BVA,'\',fileinput]);

%% Export epochs as separate ASCII txt file with channels as cols and datapoints as rows
cd (diroutput);    
   % for seg = 1:size(EEG.data,3); % loop through epochs
   for seg = 1:30
         fileoutput = [fileinput(1:4),'_4sSeg_',num2str(seg),'.txt'];
         % arrange data in format : ch = cols and data points = rows
         data2save = [chanlabels;num2cell(EEG.data(:,:,seg)')];
        % save as text file
             fileID = fopen(fileoutput,'w');
             formatspec1='%s '; formatspec1=[repmat(formatspec1,1,64),'\n'];
             formatspec2='%.3f ';formatspec2= [repmat(formatspec2,1,64),'\n'];
              [nrows,ncols] = size(data2save);
               fprintf(fileID,formatspec1,data2save{1,:});
                    for row = 2:nrows
                    fprintf(fileID,formatspec2,data2save{row,:});
                    end
            fclose('all');
       clear data2save;
    end
    cd(dirinput); 
end