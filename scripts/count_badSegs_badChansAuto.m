%% count marked bad epochs and Bad Channels (automaticaly marked)
%  save count in xls file
% ==============================================================
clear all
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\4_ICA_ADJUST_clean';
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre';
cd (dirinput);   
%% 
list = dir(cd);                 % find dataset files in directory
listCell = struct2cell(list);
files = listCell(1,3:end);
names = files(~cellfun('isempty', strfind(files,'ICA.set')));
 %% Subject loop
 groupcountSegs = {}; ppnrcodes = {}; groupcountChanRej = {};
for s= 1:length(names);   
    fileinput = names{s};
    ppnr = fileinput(1:(end-4));
     % Load data set
      EEG = pop_loadset('filename',fileinput); % load dataset (contains both trial types)
        ppnrcodes = [ppnrcodes;ppnr];
        groupcountSegs=[groupcountSegs;size(EEG.data,3)];
        groupcountChanRej = [groupcountChanRej;length(EEG.reject.indelec)];
end
data2save =  [['ppnr';ppnrcodes],['Segments';groupcountSegs],['BadChansAutoRej';groupcountChanRej]];
%% save 
cd(diroutput);
outputfilename = 'group_badSegments_badChansAuto_count.xls';
if exist(outputfilename,'file') == 0;
    xlswrite (outputfilename,data2save);
 else disp('CANNOT SAVE FILE, IT ALREADY EXISTS!!');
end 

cd(dirinput)