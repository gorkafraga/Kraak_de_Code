%% Task data - make 4 s epochs
% =================================================================
% Epochs: 4 sec segments from a 4 minutes baseline .
% ==============================================================
clear all
clear all
%%
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\task EEG\eeglab_imported';
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\task EEG\epoched';
cd (dirinput);
%% find files
list = dir ('*256Hz_bp*.set');
listCell = struct2cell(list);
names = listCell(1,:);
%% Loop thru subjects
for ss=61:length(names); % !
      fileinput = names{ss};
      ppnr = fileinput(2:4) ;
      outputname = strrep(fileinput,'.set','_ep4s.set');
 if ~isempty(dir(fileinput));
    eeglab;
    % load set 
    EEG = pop_loadset('filename',fileinput);
   
    %% Recode the 30 first (practice)consistent trials with a 666 numeric code as they are from the practice block.
    % first  convert all events to number     
        for i = 1:length(EEG.event);
           if  ischar(EEG.event(i).type)
            EEG.event(i).type = str2double(EEG.event(i).type); 
            %disp(['check',num2str(i)])
            else
            end
        end
     % recode practise trials
         
     counter = 0;
        for i = 1:length(EEG.event);% events loop
           if any(EEG.event(i).type==[1 2]); %add current tmp to 'mytrials' and start new row if it's a stimuli 
                counter=counter + 1;
                if counter < 29; 
                    EEG.event(i).type = 666;
                elseif counter == 29; 
                    EEG.event(i).type = 666;
                    lastpracticeidx=i;
                end
            end
        end
      % recode first stimuli after practice as 'taskStart' 
          if  any(EEG.event(lastpracticeidx+4).type == [1 2 4 8]) && EEG.event(lastpracticeidx+3).type == 3
                 EEG.event(lastpracticeidx+4).type = 'taskStart';
          elseif any(EEG.event(lastpracticeidx+5).type == [1 2 4 8]) && EEG.event(lastpracticeidx+4).type == 3
                 EEG.event(lastpracticeidx+5).type = 'taskStart' ;
          else
              disp('Not certain where task starts!!')
          end
%       counter = 0;
%         for i = 1:length(EEG.event);% events loop
%            if any(EEG.event(i).type ==[1 2 4 8])&& EEG.event(i-1).type == 3 && EEG.event(i-1).type == 
%                     EEG.event(i).type = 'taskStart';
%                 
%             end
%         end
%     
 
     %% epoch (5 min from start of the task
      EEG = eeg_checkset(EEG,'eventconsistency'); %convert to string
      EEG = pop_epoch(EEG, {'taskStart'}, [0 60*5]); % takes 5 minutes of data
     % in some files there is a 'duration' field that interferes with new
     % events. Delete:
     if isfield(EEG.event,'duration');
      EEG.event = rmfield(EEG.event,'duration');
     else
     end
        % Add markers to define segments of different lengths 
             idx2sec = 0:(EEG.srate*2):EEG.pnts;
             idx4sec = 0:(EEG.srate*4):EEG.pnts;           
             idx6sec = 0:(EEG.srate*6):EEG.pnts;
             idx8sec = 0:(EEG.srate*8):EEG.pnts;
             idx10sec = 0:(EEG.srate*10):EEG.pnts;
             idx12sec = 0:(EEG.srate*12):EEG.pnts;

            for i = 1:length(idx2sec);
                tmpEvent2(i).type = '2s';
                tmpEvent2(i).latency=idx2sec(i);
                tmpEvent2(i).urevent=[];
                
             end; clear i  
             
            for i = 1:length(idx4sec);
                tmpEvent4(i).type = '4s';
                tmpEvent4(i).latency=idx4sec(i);
                tmpEvent4(i).urevent=[];
                
            end; clear i    
             
            for i = 1:length(idx6sec);
                tmpEvent6(i).type = '6s';
                tmpEvent6(i).latency=idx6sec(i);
                tmpEvent6(i).urevent=[];
               
             end; clear i 
                  
            for i = 1:length(idx8sec);
                tmpEvent8(i).type = '8s';
                tmpEvent8(i).latency=idx8sec(i);
                tmpEvent8(i).urevent=[];
               
             end; clear i 
              
            for i = 1:length(idx10sec);
                tmpEvent10(i).type = '10s';
                tmpEvent10(i).latency=idx10sec(i);
                tmpEvent10(i).urevent=[];
               
             end; clear i 
             
            for i = 1:length(idx12sec);
                tmpEvent12(i).type = '12s';
                tmpEvent12(i).latency=idx12sec(i);
                tmpEvent12(i).urevent=[];
             
             end; clear i 

    % Incorporate new markers to the EEG.event array             
          EEG.event = [EEG.event,tmpEvent2,tmpEvent4,tmpEvent6,tmpEvent8,tmpEvent10,tmpEvent12];
          clear tmpEvent2 tmpEvent4 tmpEvent6 tmpEvent8 tmpEvent10              

    %% epoch 
    EEG = pop_epoch( EEG, {'4s'}, [0 4]); %make 4 s epochs
    EEG.setname=outputname;
    %% save 
    pop_saveset (EEG,outputname,diroutput);
%%
    clear EEG ALLEEG
    close all 
  
    else disp(['file ',outputname,' not found']);
    end
end