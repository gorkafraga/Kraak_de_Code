%% count marked bad epochs and save count in xls file
% ==============================================================
clear all
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\epoched 4s';
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\epoched 4s';
cd (dirinput);           % Makes use of ALL filenames in input directory!

list = dir(cd);                 % find dataset files in directory
listCell = struct2cell(list);
files = listCell(1,3:end);
names = files(~cellfun('isempty', strfind(files,'marked.set')));

 %% Subject loop
 groupcounttotal= {};
 groupcountrej = {};
 groupcountkeep = {};
 ppnrcodes = {}; 
for s= 1:length(names);   
    fileinput = names{s};
    ppnr = fileinput(1:(end-4));
     % Load data set
      EEG = pop_loadset('filename',fileinput); % load dataset (contains both trial types)
        groupcountrej = [groupcountrej;length(find(EEG.reject.rejmanual))];
        ppnrcodes = [ppnrcodes;ppnr];
        groupcountkeep=[groupcountkeep;length(find(abs(1-(EEG.reject.rejmanual))))];
        groupcounttotal = [groupcounttotal;length(EEG.reject.rejmanual)];
end
data2save =  [['ppnr';ppnrcodes],['reject';groupcountrej],['keep';groupcountkeep],['total';groupcounttotal]];
%% save 
cd(diroutput);
outputfilename = 'group_badSegments_count.xls';
if exist(outputfilename,'file') == 0;
    xlswrite (outputfilename,data2save);
 else disp('CANNOT SAVE FILE, IT ALREADY EXISTS!!');
end 

cd(dirinput)