% Remove(no interpolate) bad electrodes - EEG RESTING-STATE KdC-Adults
%========================================================================
clear global
clear all
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\s107';
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\s107';
 cd (dirinput);

chanlabels = {'Fp1','AF7','AF3','F1','F3','F5','F7','FT7','FC5','FC3','FC1','C1','C3','C5','T7','TP7','CP5','CP3','CP1','P1','P3','P5','P7','P9',...
    'PO7','PO3','O1','Iz','Oz','POz','Pz','CPz','Fpz','Fp2','AF8','AF4','Afz','Fz','F2','F4','F6','F8','FT8','FC6','FC4','FC2','FCz','Cz',...
    'C2','C4','C6','T8','TP8','CP6','CP4','CP2','P2','P4','P6','P8','P10','PO8','PO4','O2'};

%%
list = dir(cd);
listCell = struct2cell(list);
files = listCell(1,3:end);
names = files(~cellfun('isempty', strfind(files,'.set')));

for ss= 1:length(names);
      fileinput = names{ss};
      outputfilename = fileinput(1:end-4);
      ppnr = fileinput(2:4) ;
 
EEG = pop_loadset('filename',fileinput);
%% LIST OF ELECTRODES TO REMOVE PER SUBJECT
s = str2num(ppnr); 
chans2remove = {'none'}; % the default is none. But...
 if s == 1; 
     chans2remove = {'T7','P9','O1'};  
  elseif s==2;
      chans2remove = {'P8','TP8','FC3'};
  elseif s==6;
       chans2remove = {'T8'};
  elseif s==9;
       chans2remove = {'F8'};
  elseif s==12;
       chans2remove = {'FC6','P2'};
  elseif s==17;
       chans2remove = {'P5'};
  elseif s==18;
       chans2remove = {'PO7','P2'};
  elseif s==19;
       chans2remove = {'PO7'}; 
  elseif s==21;
       chans2remove = {'P2'};
  elseif s==23;
        chans2remove = {'P10'};
  elseif s==26;
       chans2remove = {'C3','Iz'}; 
  elseif s==27;
        chans2remove = {'F6','F7'};
  elseif s==28;
        chans2remove = {'POz', 'P2','PO4'};
  elseif s==29;
       chans2remove = {'FT8','POz','P2'}; 
  elseif s==32;
       chans2remove = {'POz'}; 
  elseif s==36;
        chans2remove = {'T8','T7','TP7'};
  elseif s==101;
        chans2remove = {'CP2','P4','CPz','FC1','FC3'};
  elseif s==104;
        chans2remove = {'C4','FC4','P2','POz', 'PO7'};
  elseif s==105;
        chans2remove = {'POz','Oz','Pz','PO8','PO3', 'P9'};
  elseif s==107;
        chans2remove = {'FC6','T7'};
   elseif s==110;
        chans2remove = {'C6'};
   elseif s==111;
        chans2remove = {'T7'};
   elseif s==114;
        chans2remove = {'P2'};
  elseif s==115;
        chans2remove = {'P3'};
   elseif s==117;
        chans2remove = {'P9'};
   elseif s==118;
        chans2remove = {'FC1','P2','P6'};
   elseif s==122;
        chans2remove = {'P2'};
   elseif s==123;
        chans2remove = {'P2','T8'};
   elseif s==126;
        chans2remove = {'P2'};
  elseif s==127;
        chans2remove = {'POz'};
   elseif s==128;
        chans2remove = {'POz','T8','T7','TP7'};
 end


if isempty(strmatch('none',chans2remove))==1 ;  % If there are channels to interpolate...
        for c = 1:length(chans2remove);
                 chans2removeNum(c) = find(strcmp(chans2remove{c},chanlabels));% get numeric array of electrodes
        end 
     chansNum = 1:length(EEG.chanlocs);
     chansNum(chans2removeNum)=[]; % Give indexes of channels without those for interpolation
     EEG = pop_select (EEG, 'channel', chansNum); % import with linked earlobes as ref

    
     % save with suffix
      outputfilename = fileinput(1:end-4);
      EEG = pop_saveset (EEG, [outputfilename,'_editChans'], diroutput);
    cd (dirinput);
     clear EEG chans2removeNum

elseif  isempty(strmatch('none',chans2remove))==0; % If there are no channels to interpolate 
%     
      outputfilename = fileinput(1:end-4);
      EEG = pop_saveset (EEG, [outputfilename,'_editChans0'], diroutput); % this line is commented to prevent saving redundant files
  
     close all
end
   clear EEG ALLEEG
end
