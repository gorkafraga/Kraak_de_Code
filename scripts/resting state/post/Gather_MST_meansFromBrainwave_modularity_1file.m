%% Gather MST data from Brainwave outputs
% ================================================================
% - compute means across segments
% - Save in xls
clear all
dirinput = 'X:\fraga\project ABMP\ABMP_EEG\Kraak_analysis\Kraak EEG\resting-state EEG\output_post\Brainwave_anal';
diroutput = 'X:\fraga\project ABMP\ABMP_EEG\Kraak_analysis\Kraak EEG\resting-state EEG\output_post\Brainwave_anal\output gathered';
cd(dirinput); 
%% read data (1st line header not included)
band= 'Delta';
fileinput = [band,'_avgRef.txt'];
fileoutput = ['means_',strrep(fileinput,'.txt','.xls')];
fid=fopen(fileinput,'r');
format1='%s ';
format=repmat(format1,1,68);
test2=textscan(fid,format,'Delimiter',' ','EndofLine','\r\n','HeaderLines',1,'MultipleDelimsAsOne',1, 'CollectOutput', 1);
test2=test2{1,1};
data=cellstr(test2);
%%
%get ppnr, segment and metric info
ppnr = unique(data(:,1));
segment = unique(data(:,2));
metric = unique(data(:,3));
            
%individual subject data
submeans = cell(length(ppnr),length(metric));
for s= 1:length(ppnr)
    temp1 = strmatch(ppnr(s),data(:,1),'exact');
    subjectdata = data(temp1,:);
    for m= 1:length(metric)
        temp2 = strmatch(metric(m),subjectdata(:,3),'exact');
        metric2avg = subjectdata(temp2,:);
        temp3 = cell(size(metric2avg,1),1);
            for r=1:size(metric2avg,1);
                temp3 {r,:} =  cell2mat(metric2avg(r,4));
            end
             avgmetrics = mean(str2double(temp3),1);
    submeans{s,m} = avgmetrics;
    end
end  
 
%rownames = cell2mat(ppnr); rownames=rownames(:,2:4);
 submeans = [ppnr,submeans];
 submeans = [['subject', [strcat('Post_',[band,'_'],metric)]'];submeans]; 
%% save....
cd(diroutput);

if exist(fileoutput,'file') == 0;
    xlswrite (fileoutput,submeans);
 else disp('CANNOT SAVE FILE, IT ALREADY EXISTS!!');
end 

