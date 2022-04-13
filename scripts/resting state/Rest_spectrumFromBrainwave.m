% Compute averages from Brainwave FFT SPECTRUM file
% ================================================================================================
clear all; close all;
dirinput=  'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\Edit Channels_brainwaveOutput'; 
diroutput =  'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\Edit Channels_brainwaveOutput';
band = 'theta';
cd (dirinput)
% Define group files to read 
group = {'typical', 'Dyslexics'};
%% loop
for G=1:length(group);
fileinput = ['Spectrum_',group{G},'_avgRef_theta.txt'];
chanlabels = {'Fp1','AF7','AF3','F1','F3','F5','F7','FT7','FC5','FC3','FC1','C1','C3','C5','T7','TP7','CP5','CP3','CP1','P1','P3','P5','P7','P9',...
    'PO7','PO3','O1','Iz','Oz','POz','Pz','CPz','Fpz','Fp2','AF8','AF4','Afz','Fz','F2','F4','F6','F8','FT8','FC6','FC4','FC2','FCz','Cz',...
    'C2','C4','C6','T8','TP8','CP6','CP4','CP2','P2','P4','P6','P8','P10','PO8','PO4','O2'};
%band= 'Theta';
%% Read data (1st line header not included)
%data
fid=fopen(fileinput,'r');
format1='%s ';
format=repmat(format1,1,1029);
test2=textscan(fid,format,'Delimiter',' ','EndofLine','\r\n','HeaderLines',0,'MultipleDelimsAsOne',1, 'CollectOutput', 1);
test2=test2{1,1};
data=cellstr(test2);
data = data(:,2:end); %remove 1st column (junk)
ppnames=[];segmentno=[];
% get participant names 
for r=1:size(data,1);
    tmpstrng = char(data{r,1});
    ppnames{r} = tmpstrng(1:4);
    segmentno{r}=tmpstrng(10:end-4);
end;
ppnr = unique(ppnames);
% get segment names
segments = unique(segmentno);

%% Compute average of all segments per subject and grand average 
   for s= 1:length(ppnr);
        subjectdata = data(strmatch(ppnr(s),data(:,1)),:);
        temp =  mean(str2double(subjectdata(:,5:end-1)),1)/4; % avg converted to Hz
        groupdata(s,:) = [strrep(ppnr(s),'Segment','avg'),num2cell(temp)];  
          %eval(sprintf('%s=temp1',)) % assign the value to corresponding measure name.
   end
groupdata(length(ppnr)+1,:)=['Total',num2cell(mean(cell2mat(groupdata(:,2:end)),1))]; %% add grand average at the end
%% Plot in one figure with subplots
   srate = 1024; nyquist = srate/2;    N = 4096;   
   hz = linspace(0,srate/2,floor(N/2)+1);
   
   offsets = mean(cell2mat(groupdata(:,find(hz==50)+1:end)),2); 
  % data to plot 
    for row=1:size(groupdata,1);
        data2plot(row,:) = cell2mat(groupdata(row,2:find(hz==50)+1))-offsets(row);%substract individual baselines (offsets) for each subject 
    end 
figure;

for g=1:size(data2plot,1);
   subplot(8,5,g);
   plot(hz(1:find(hz==50)),data2plot(end,:),'LineStyle','-','color','r');hold on;
   plot(hz(1:find(hz==50)),data2plot(g,:),'LineStyle','-','color','b');hold on;
   set(gca,'YLim',[0,3],'XLim',[0,50]);
     % Title
     if g < size(data2plot,1); 
     junk = char(ppnr(g));
     title(junk(1:4));
     elseif g == size(data2plot,1);
          subplot(8,5,g);
           plot(hz(1:find(hz==50)),data2plot(end,:),'LineStyle','-','color','r');hold on;
         title('mean')
     end
set(gca, 'FontSize',8,'XTick',[4 8 13 30 49])
end
set(gcf,'color','w','NextPlot','add');
axes;
h = title(group(G),'FontSize',16); set(gca,'Visible','off');set(h,'Visible','on');
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
set(gcf,'PaperPositionMode','auto');
% save 
saveas (gcf,[diroutput,'\','Plot_spec_',group{G}], 'tiff');
close gcf
assignin('base',['mean',num2str(G)],data2plot(end,:)); % it will save group means as mean1 and mean2 to use after the group loop for group comparison plot
%% Plot as separate plots
figure 
for s=1:size(data2plot,1)-1;
   plot(hz(1:find(hz==50)),data2plot(end,:),'LineStyle','-.','color','r');hold on;
   plot(hz(1:find(hz==50)),data2plot(s,:),'LineStyle','-','color','b');hold on;
   set(gca,'YLim',[0,3],'XLim',[0,50]);
     % Title
     set(gca, 'FontSize',8,'XTick',[4 8 13 30 49]); set(gcf,'color','w','NextPlot','add');
axes;
h = title(group(G),'FontSize',16); set(gca,'Visible','off');set(h,'Visible','on');
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
set(gcf,'PaperPositionMode','auto');
% save 
saveas (gcf,[diroutput,'\','Spectrum_',group{G},'_',ppnr{s}], 'tiff');
close gcf
end
samplesize(G)=size(data2plot,1)-1;
clear groupdata data2plot data
end;

%% PLOT group comparison
   plot(hz(1:find(hz==50)),mean1,'LineStyle','-','color','b','Linewidth',2);hold on;
   plot(hz(1:find(hz==50)),mean2,'LineStyle','-','color','r','Linewidth',2);hold on;
   ylim = [0 3];
   set(gca,'YLim',ylim,'XLim',[0.5,49]);
   legend(['Typical',' (N = ',num2str(samplesize(1)),')'],['Dyslexics',' (N = ',num2str(samplesize(2)),')']);legend('boxoff');
   set(findall(gcf,'type','text'),'fontName','Times New Roman','fontSize',14)
   set(gcf, 'Position', get(0,'Screensize'))
   set(gca,'XTick',[4 8 13 30 49],'fontSize',12,'fontName','Times New Roman');
   set(gcf,'color','w','NextPlot','add');
   box off 
  plot([4,4],ylim,'Color',[0.6,0.6,0.6]);   plot([8,8],ylim,'Color',[0.6,0.6,0.6]);   plot([13,13],ylim,'Color',[0.6,0.6,0.6]);   plot([30,30],ylim,'Color',[0.6,0.6,0.6]);

%% save
  saveas (gcf,[diroutput,'\',group{1},'vs',group{2}], 'tiff');
close gcf