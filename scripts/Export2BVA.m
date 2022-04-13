%Read downsampled/recode markers/ export to bva
%==========================================================================
% ============================================================================== 
clear all
clear global
close all
dirinput = 'X:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_post\' ; % input directory with no subfolders 
diroutput = 'C:\Users\Gorka\Documents\Yang_dummy\ILJA SLIGTE' ; % should be different than input folder and should not be subfolder of input folder!
chanlocfile ='C:\Users\Gorka\Documents\Yang_dummy\channelsThetaPhi-2extRemoved.elp'; %path and filename to txt file with electrode coordinates
cd (dirinput); 
%% list files
list = dir(cd);
listCell = struct2cell(list);
files = listCell(1,3:end);
names = files(~cellfun('isempty', strfind(files,'.set')));

%% subj loop
groupCount= []; 
for ss=1:length(names);
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; 
    fileinput = names{ss};
    % load dataset 
    EEG = pop_loadset('filename',fileinput); 
    % Remove last 2 external (ext 7&8) electrodes 
    EEG = pop_select (EEG, 'channel', 1:70); 
    % Load the channel locations file, specify BESA coordinates
    EEG = pop_chanedit(EEG,'load',chanlocfile,'besa'); % include directory were channel location txt file is located 
     %EEG = pop_saveset (EEG, outputfilename, diroutput); 
    eeglab redraw;
    %% Rename events
    % Numeric sufix codes are 1 (cued), 0 (free), 2(error) and 3 (practice)
    % First rename the 128 s as before, then use those codes to rename the preceeding 64s.
    countP= 0;counte= 0; countC = 0; countF=0; 
    for e = 1:length(EEG.event);
        if (EEG.event(e).type == 6) && (EEG.event(e-1).type == 128);
            if (EEG.event(e).latency - EEG.event(e-1).latency)< 1000;
               EEG.event(e-1).type = 1281;  
               countC = countC + 1;
            else EEG.event(e-1).type = 1280;  
                countF = countF + 1;
            end
        elseif (EEG.event(e).type == 6) &&(EEG.event(e-1).type ~= 1) && ~ isempty(find(EEG.event(e-2).type == 128));
                EEG.event(e-2).type = 1280; 
                countF = countF + 1;
        elseif (EEG.event(e).type == 128) && (EEG.event(e+1).type == 64);
                     counte = counte + 1;
                EEG.event(e).type = 1282;

        elseif (EEG.event(e).type == 128) && (EEG.event(e+1).type == 1);
                     countP = countP + 1;
                EEG.event(e).type = 1283;
        end        
    end; clear e; 
    %% rename events: rename last 64 before 128. This will indicate the disengage-response
    count64f= 0; count64c = 0;
    for e = 1:length(EEG.event);
        if (EEG.event(e).type == 1281) && (EEG.event(e-1).type == 64);
            EEG.event(e-1).type = '64c';
            count64c= count64c + 1;
        elseif (EEG.event(e).type == 1280) && (EEG.event(e-1).type == 64);
            EEG.event(e-1).type = '64f';
            count64f = count64f + 1;
        end
    end
   clear e; 
 
% %% save counter
%   cd (diroutput);
%   count = [{'count64c','count64f'};{count64c,count64f}];
%   count = table(count);
%   writetable(count,strrep(fileinput,'.set','_count_disengage.txt'))
%   cd(dirinput);   
%  
%  %% EPOCH data
%   EEG = eeg_checkset(EEG,'eventconsistency'); 
%   % EPOCHING
%    EEG_C = pop_epoch( EEG, {'64c'}, [-3 1]); EEG_C.setname = strrep(EEG.setname,'resampled','64C'); 
%       % baseline removal. 
%        EEG_C = pop_rmbase( EEG_C, [-3000 -2500]);
%   
%   % EPOCHING
%    EEG_F = pop_epoch(EEG,{'64f'}, [-3 1]);EEG_F.setname=strrep(EEG.setname,'resampled','64F');
%        % baseline removal. 
%        EEG_F = pop_rmbase( EEG_F, [-3000 -2500]);
  
   % Save sets
%    pop_saveset (EEG_C,  strrep(fileinput,'.set','_recode_ep64C'), diroutput);
%    pop_saveset (EEG_F,  strrep(fileinput,'.set','_recode_ep64F'), diroutput);

%% Save to bVA
  pop_writebva(EEG,[diroutput,'\',fileinput(1:end-4),'_recoded']);



 % groupCount = [groupCount;[str2num(fileinput(2:6)),length(EEG_C.epoch),length(EEG_F.epoch)]]; 
 % clear EEG_C EEG_F ALLEEG EEG CURRENTSET EEG.event
  close all
end

ppnr = {}; for n = 1:length(names);tmp = names{n}; ppnr =[ppnr,tmp(1:6)];end; ppnr = unique(ppnr);
% groupCount = [{'filename', '64c_epochs','64f_epochs'};[ppnr',num2cell(groupCount)]]; 
% %% save total count of epochs 
% cd(diroutput);
% outputfilename = 'Total_epochs_count.xls';
% if exist(outputfilename,'file') == 0;
%     xlswrite (outputfilename,groupCount);
%  else disp('CANNOT SAVE FILE, IT ALREADY EXISTS!!');
% end 
% 
% 
% 



   