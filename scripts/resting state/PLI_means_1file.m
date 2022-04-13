clear all
% 1 Read PLI connectivity matrices from brainwave output
% 2 Average segments for each subject and compute average matrix
% 3 Compute submatrices/subaverages
% =====================================================================
dirinput=  'X:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\ASCIIs interpolation 1file\Brainwave_Alpha';
diroutput = 'X:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\Meichen Yu';
cd (dirinput)
%% define filenames
band= 'Alpha';
group = '_';
fileinput = ['Matrix_',band,'_avgRef.txt'];
fileoutput = ['PLI_',band,'_',group,'_total_means.xls'];
fileoutput_clusters = ['PLI_',band,'_',group,'_clusters_means.xls'];

%----------------------------------------------------------------------------------------
fid=fopen(fileinput,'r');
format1='%s ';
format=repmat(format1,1,64);
tmp=textscan(fid,format,'Delimiter',' ','EndofLine','\r\n','MultipleDelimsAsOne',1, 'CollectOutput', 1);
data=cellstr(tmp{1,1});
%% Find subject and segment info
headersidx = find(~cellfun('isempty',strfind(data(:,2),'segments')));
subjects = {};
for i = 1:length(headersidx);
    subjects(i) = data(headersidx(i),2);
end
subjects = unique(subjects)';

headersidx = find(~cellfun('isempty',strfind(data(:,1),'Epoch')));
segments = {};
for i = 1:length(headersidx);
    segments(i) = data(headersidx(i),2);
end
segments = unique(segments)';
%% Gather matrices for each subject

groupdata  = zeros(64,64,length(subjects),length(segments)); % Big matrix containing connectivity matrices (64,64) per subject and per segment.    
for ss= 1:length(subjects);
    subjidx = strmatch(subjects(ss),data(:,2),'exact');
    for seg=1:length(subjidx);
       temp  = data(subjidx(seg)+2:subjidx(seg)+2+63,:); %matrix for segment(seg) and subject(ss)
        segdatanum = zeros(64,64);
        for r=1:size(temp,1);
            for c=1:size(temp,2);
                segdatanum(r,c)= str2num(temp{r,c});
            end
        end
     groupdata(:,:,ss,seg)= segdatanum; 
    end
end
%% calculate mean of the upper tri of each matrix
groupmeans=zeros(length(subjects),1+length(segments));
for ss=1:length(subjects);
    subjectsegs=zeros(length(segments),1);
    for seg=1:length(segments);
     uptri= triu(groupdata(:,:,ss,seg));
    subjectsegs(seg)=mean(uptri(uptri~=0)); 
    end
    groupmeans(ss,:)=[mean(subjectsegs);subjectsegs]';
end
names = cell2mat(subjects);
names = str2num(names(:,2:4));
header = ['subject', 'mean', segments']; 
table2save = [header;num2cell([names,groupmeans])];
%% calculate means for submatrices (clusters)
 chanlabels = {'Fp1','AF7','AF3','F1','F3','F5','F7','FT7','FC5','FC3','FC1','C1','C3','C5','T7','TP7','CP5','CP3','CP1','P1','P3','P5','P7','P9',...
    'PO7','PO3','O1','Iz','Oz','POz','Pz','CPz','Fpz','Fp2','AF8','AF4','Afz','Fz','F2','F4','F6','F8','FT8','FC6','FC4','FC2','FCz','Cz',...
    'C2','C4','C6','T8','TP8','CP6','CP4','CP2','P2','P4','P6','P8','P10','PO8','PO4','O2'};

frontal = {'Fp1','AF3','AF7','F1','F3','F5','F7','Fp2','AF4','AF8','F2','F4','F6','F8'};
frontal_L = {'Fp1','AF3','AF7','F1','F3','F5','F7'};
frontal_R = {'Fp2','AF4','AF8','F2','F4','F6','F8'};
central = {'FC1','FC3','FC5','C1','C3','C5','CP1','CP3','CP5','FC2','FC4','FC6','C2','C4','C6','CP2','CP4','CP6'};
central_L = {'FC1','FC3','FC5','C1','C3','C5','CP1','CP3','CP5'};
central_R = {'FC2','FC4','FC6','C2','C4','C6','CP2','CP4','CP6'};
temp = {'FT7','T7','TP7','FT8','T8','TP8'};
temp_L = {'FT7','T7','TP7'};
temp_R= {'FT8','T8','TP8'};
parietoccip = {'O1','PO3','PO7','P1','P3','P5','P7','P9','O2','PO4','PO8','P2','P5','P6','P8','P10'};
parietoccip_L = {'O1','PO3','PO7','P1','P3','P5','P7','P9'};
parietoccip_R = {'O2','PO4','PO8','P2','P5','P6','P8','P10'};
left = {'Fp1','AF3','AF7','F1','F3','F5','F7','FC1','FC3','FC5','C1','C3','C5','CP1','CP3','CP5','FT7','T7','TP7','O1','PO3','PO7','P1','P3','P5','P7','P9'};
right = {'Fp2','AF4','AF8','F2','F4','F6','F8','FC2','FC4','FC6','C2','C4','C6','CP2','CP4','CP6','FT8','T8','TP8','O2','PO4','PO8','P2','P5','P6','P8','P10'};

clusters= {'frontal','frontal_L','frontal_R','central','central_L','central_R','temp','temp_L','temp_R','parietoccip','parietoccip_L','parietoccip_R','left','right'};
groupmeans_clusters=zeros(length(subjects),length(clusters));
for clus = 1:length(clusters);
  currentcluster = eval(clusters{clus});
  %Find chan idxs for current clusters (that is row or col in the connectivity matrix)
  chanidx=zeros(length(currentcluster),1);
  for rr =1:length(currentcluster);
  chanidx(rr) = strmatch(lower(currentcluster(rr)),lower(chanlabels),'exact');
  end
  
   data2use = groupdata(chanidx,chanidx,:,:);% select from data matrices only the electrodes in this cluster
    for ss=1:length(subjects);
        subjectsegs_clus=zeros(length(segments),1);
        for seg=1:length(segments);
         uptri= triu(data2use(:,:,ss,seg));
        subjectsegs_clus(seg)=mean(uptri(uptri~=0)); 
        end
        groupmeans_clusters(ss,clus)=mean(subjectsegs_clus);
    end
end
names = cell2mat(subjects);
names = str2num(names(:,2:4));
header_clusters = ['subject',strcat([band,'_'],clusters)];
table2save_clusters = [header_clusters;num2cell([names,groupmeans_clusters])];

%% save
cd (diroutput)
xlswrite (fileoutput,table2save);
xlswrite (fileoutput_clusters,table2save_clusters);
%%
 


