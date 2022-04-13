% Remove(not interpolate) bad electrodes - EEG RESTING-STATE KdC-Adults
%========================================================================
clear global
clear all
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\task EEG\ICA_redo';
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\task EEG\ICA_redo';
 cd (dirinput);

chanlabels = {'Fp1','AF7','AF3','F1','F3','F5','F7','FT7','FC5','FC3','FC1','C1','C3','C5','T7','TP7','CP5','CP3','CP1','P1','P3','P5','P7','P9',...
    'PO7','PO3','O1','Iz','Oz','POz','Pz','CPz','Fpz','Fp2','AF8','AF4','Afz','Fz','F2','F4','F6','F8','FT8','FC6','FC4','FC2','FCz','Cz',...
    'C2','C4','C6','T8','TP8','CP6','CP4','CP2','P2','P4','P6','P8','P10','PO8','PO4','O2'};

%%
list = dir(cd);
listCell = struct2cell(list);
files = listCell(1,3:end);
names = files(~cellfun('isempty', strfind(files,'ep4s.set'))); % load sets with marked bad epochs

for ss= 1:length(names);
      fileinput = names{ss};
      outputfilename = fileinput(1:end-4);
      ppnr = fileinput(2:4) ;
 
EEG = pop_loadset('filename',fileinput);
%% LIST OF ELECTRODES TO REMOVE PER SUBJECT
s = str2num(ppnr); 
chans2remove = {'none'}; % the default is none. But...
 if s==1;
      chans2remove = {'T7','O1','P10'};     
 elseif s==2;
      chans2remove = {'P8','FC3'};  
  elseif s==6;
      chans2remove = {'POz'};
  elseif s==7;
      chans2remove = {'FC3'};
  elseif s==29;
      chans2remove = {'FT8'};
  elseif s==29;
      chans2remove = {'FT8'};
  elseif s==101;
      chans2remove = {'FC1'};
  elseif s==104;
      chans2remove = {'PO7'};
  elseif s==105;
      chans2remove = {'PO8','POz','P9'};
  elseif s==107;
      chans2remove = {'FC6','CP4','P4'};
   elseif s==114;
      chans2remove = {'P2'};
 end

%%
if isempty(strmatch('none',chans2remove))==1 ;  % If there are channels to interpolate...
        for c = 1:length(chans2remove);
                 chans2removeNum(c) = find(strcmp(chans2remove{c},chanlabels));% get numeric array of electrodes
        end 
     chansNum = 1:length(EEG.chanlocs);
     chansNum(chans2removeNum)=[]; % Give indexes of channels without those for interpolation
     EEG = pop_select (EEG, 'channel', chansNum); % import with linked earlobes as ref

    
%% save with suffix
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
