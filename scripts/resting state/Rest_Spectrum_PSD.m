% PLOT POWER SPECTRUM
%============================================================================================
% - Read data from segment ascii file ( 4096 data points each segments) 
% - Perform FFT per channel
% - Average spectra for all channels and channel clusters
clear all; close all;
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\Edit Channels\ASCIIs\' ;
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\Edit Channels\FFT spectra\';

%% list files and input parameters 
cd (dirinput);
list = dir('*segment*.txt');                
files = {list.name}; 
% Number of segments
segments = 1:30; 
% signal parameters
srate = 1024; nyquist = srate/2;  frames = 4096;  
% Plot y-axis range
ylim1 = [0 30];
ylim2 = [0 15]; %for grand averages 
%% Define regional clusters
chanlabels = {'Fp1','AF7','AF3','F1','F3','F5','F7','FT7','FC5','FC3','FC1','C1','C3','C5','T7','TP7','CP5','CP3','CP1','P1','P3','P5','P7','P9',...
    'PO7','PO3','O1','Iz','Oz','POz','Pz','CPz','Fpz','Fp2','AF8','AF4','Afz','Fz','F2','F4','F6','F8','FT8','FC6','FC4','FC2','FCz','Cz',...
    'C2','C4','C6','T8','TP8','CP6','CP4','CP2','P2','P4','P6','P8','P10','PO8','PO4','O2'};
frontal = {'Fp1','AF3','AF7','F1','F3','F5','F7','Fp2','AF4','AF8','F2','F4','F6','F8'};
frontal_L = {'Fp1','AF3','AF7','F1','F3','F5','F7'};
frontal_R = {'Fp2','AF4','AF8','F2','F4','F6','F8'};
central = {'FC1','FC3','FC5','C1','C3','C5','CP1','CP3','CP5','FC2','FC4','FC6','C2','C4','C6','CP2','CP4','CP6'};
central_L = {'FC1','FC3','FC5','C1','C3','C5','CP1','CP3','CP5'};
central_R = {'FC2','FC4','FC6','C2','C4','C6','CP2','CP4','CP6'};
tempo = {'FT7','T7','TP7','FT8','T8','TP8'};
tempo_L = {'FT7','T7','TP7'};
tempo_R= {'FT8','T8','TP8'};
parietoccip = {'O1','PO3','PO7','P1','P3','P5','P7','P9','O2','PO4','PO8','P2','P5','P6','P8','P10'};
parietoccip_L = {'O1','PO3','PO7','P1','P3','P5','P7','P9'};
parietoccip_R = {'O2','PO4','PO8','P2','P4','P6','P8','P10'};
left = {'Fp1','AF3','AF7','F1','F3','F5','F7','FC1','FC3','FC5','C1','C3','C5','CP1','CP3','CP5','FT7','T7','TP7','O1','PO3','PO7','P1','P3','P5','P7','P9'};
right = {'Fp2','AF4','AF8','F2','F4','F6','F8','FC2','FC4','FC6','C2','C4','C6','CP2','CP4','CP6','FT8','T8','TP8','O2','PO4','PO8','P2','P4','P6','P8','P10'};

clusters= {'frontal','frontal_L','frontal_R','central','central_L','central_R','tempo','tempo_L','tempo_R','parietoccip','parietoccip_L','parietoccip_R','left','right'};
%% participant names
for i = 1:length(files);
    tmp=files{i}; 
    ppnr(i) = {tmp(1:4)};
end; ppnr = unique(ppnr);
%% Loop thru subjects/ segment / channels / clusters
for s = 1:length(ppnr); %length(files);
    mkdir(diroutput, [ppnr{s}]); % create subfolder to save individual plots
   for seg = 1:length(segments);
      fileinput = [ppnr{s},'_4secSegment_',num2str(segments(seg)),'.txt'];
      %fileinput = [ppnr{s},'_sorted_Segment ',num2str(segments(seg)),'.dat'];
    if ~ exist([ppnr{s},'_4secSegment_',num2str(segments(seg)),'.txt']);
    % if   ~exist([ppnr{s},'_sorted_Segment ',num2str(segments(seg)),'.dat']);
        %disp([ppnr{s},'_sorted_Segment ',num2str(segments(seg)),'.dat not available']);
        disp([[ppnr{s},'_4secSegment_',num2str(segments(seg)),'.txt'],' not available']);
    else
          % import data      
            input = importdata(fileinput);
            data =  input.data; % double array with data points as rows, channels as cols.(without the txt header)
            N = size(data,1);  % 
            freqresolution = srate/N;    
           % frequencies and frequencies in hertzs
            frequencies = [0:freqresolution:nyquist];
            hz = linspace(0,srate/2,floor(N/2)+1);
            

    %% Compute spectrum of segment for each channel
            % Compute spectrum for each channel separately
                for ch = 1:64; 
%                      dat= data' ;
%                     [spectra,freqs] = psd(dat(ch,:));
%                     spec(s,:,ch,seg) = spectra';
                 %  fftpsd(s,:,ch,seg)  =  (1/(srate*N)) * abs(fft(data(:,ch))).^2;
                 fourierPsd(s,:,ch,seg)  = (1/(srate*N))* abs(fft(data(:,ch))).^2; 
                 fourierPsd(s,2:(end-1),ch,seg)  = 2*fourierPsd(s,2:(end-1),ch,seg); 
                end 
     %% Average spectra across channels
                   totalfourierPsd(s,:,seg) = mean(fourierPsd(s,:,:,seg),3);

     %% Average spectra across clusters
     for clus = 1:length(clusters);
          currentcluster = eval(clusters{clus});
          chanidx=zeros(length(currentcluster),1);%Find chan idxs for current cluster
          for rr =1:length(currentcluster);
            chanidx(rr) = strmatch(lower(currentcluster(rr)),lower(chanlabels),'exact');
          end
          % average spectra of channels in current cluster
          clusterdata(s,:,seg,clus) = mean(fourierPsd(s,:,chanidx,seg),3); 
          %assignin('base',[clusters{clus},'_mean'], );
          clear chanidx
     end    
    
    %% Plot segment spectrum;  
%         figure;
%         % plot(hz,2*(totalFabs(s,1:length(hz),seg)),'k- .');title([ppnr{s},'mean Spectrum segment',num2str(seg)]); 
%         plot(hz,(totalfourierPsd(s,1:length(hz),seg)),'b- .'); title([ppnr{s},'mean Spectrum segment',num2str(seg)]); 
%            xlabel('Frequencies (Hz)'), ylabel('Power mV^2');
%            set(gcf,'color','w');
%            set(gca,'ylim',[0 15], 'xlim',[0 50]);
%        %% save
%        cd (diroutput);cd(ppnr{s});
%        saveas (gcf,[ppnr{s},'_Spec_seg',num2str(seg)], 'tiff');
%        cd(dirinput)
%        close gcf
    end
   end
   
  totalfourierPsd(totalfourierPsd == 0) = NaN; % replace 0s of the missing segments by NaN to be ignored in the mean
  segsAvailable = length(find(~isnan(totalfourierPsd(s,1,:)))); % info of how many segments current subject had 

  %% Peak detection for the average spectra across channels and segments 
   smean = nanmean(totalfourierPsd(s,1:length(hz),:),3);
   range = find(hz==6):find(hz==20);% define range for peak detection based on frequencies
   [peak,loc]= max(smean(range));
   peakfreq = hz(range(loc));  
   IAF(s) = peakfreq;
%% Plot and save spectrum averaged over segments and channels 
% Include IAF info
   figure;
%    plot(hz,2*(nanmean(totalFabs(s,1:length(hz),:),3)),'k- .');title([ppnr{s},'mean Spectrum']); hold on;
     plot(hz,smean,'b- .','LineWidth',.75);title([ppnr{s},'mean Spectrum (n = ',num2str(segsAvailable),' segs)']); 
     hold on;scatter(peakfreq,peak+0.1,'v','FaceColor','r','MarkerEdgeColor','k'); % mark peak
     hold on; text(peakfreq+0.6,peak+0.2,['IAF ',num2str(peakfreq),'Hz']);     
     xlabel('Frequencies (Hz)'), ylabel('Power/Freq mV^2/Hz');
    set(gca,'ylim',ylim1, 'xlim',[0 50]);
    set(gcf,'color','w');
  % save
    cd (diroutput);
   saveas (gcf,[ppnr{s},'_Spec_mean (n=',num2str(segsAvailable),' segs)' ], 'tiff');
   cd(dirinput)
   close gcf 
   grouptotalfourierPsd(s,:) = nanmean(totalfourierPsd(s,1:length(hz),:),3);
   clear  data 
 %% Plot and save spectrum averaged over segments and CLUSTERS
  meanclusterdata  = mean(clusterdata(s,:,:,:),3); % average across segments of each cluster (indexed by 4th dim)

  figure;
   for clus= 1:length(clusters)
     data2use = squeeze(meanclusterdata);
     mean2plot = data2use(1:length(hz),clus);
     plot(hz,mean2plot,'b- .','LineWidth',.75);title([ppnr{s},'mean ',clusters{clus},' spec (n = ',num2str(segsAvailable),' segs)']); 
     xlabel('Frequencies (Hz)'), ylabel('Power/Freq mV^2/Hz'); set(gca,'ylim',ylim1, 'xlim',[0 50]);set(gcf,'color','w');
     % save
     cd (diroutput);cd(ppnr{s});
     saveas (gcf,[ppnr{s},'_',clusters{clus},'_(n',num2str(segsAvailable),' segs)' ], 'tiff');
     close gcf 
     clear data2use mean2plot
   end
   cd(dirinput)
end
% END OF SUBJECT LOOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd (diroutput);
%% save IAF info
IAF2save = [ppnr',num2cell(IAF')];
if exist('IAF','file') == 0;
    xlswrite ('IAF' ,IAF2save);
else disp('IAF file already exist, saved as IAF1' );
    xlswrite ('IAF_1' ,IAF2save);
end

%% Compute & plot group means for all channels
 for s = 1:length(ppnr); 
     tmp1 = ppnr{s}; 
     ppnrnum(s) = str2num(tmp1(2:end)); 
 end
%% Plot and save grand Averages for mean of all channels 
tmpmean = nanmean(grouptotalfourierPsd(:,1:length(hz),:),3);
cntrldata = nanmean(tmpmean(find(ppnrnum<100),:,:),1);
dysdata = nanmean(tmpmean(find(ppnrnum>100),:,:),1);
cd (diroutput);
plot(hz,cntrldata,'b- .');title([ppnr{s},'mean Spectrum ',num2str(length(segments)),'segs']); hold on;
plot(hz,dysdata,'r- .');title([ppnr{s},'mean Spectrum (n',num2str(length(segments)),'segs']); 
title( ['Group mean Spectrum (n',num2str(length(segments)),' segs)']); 
xlabel('Frequencies (Hz)'), ylabel('Power/Freq mV^2/Hz');
set(gca,'ylim',ylim2, 'xlim',[0 50]);
legend('typical', 'dyslexics')
set(gcf,'color','w');
saveas (gcf,['Group_Spec_mean (n=',num2str(length(segments)),' segs)' ], 'tiff');

close gcf 
%% Plot and save grand Averages for clusters
cd (diroutput);
for clus = 1:length(clusters);
    cntrldata2plot =  mean(clusterdata(find(ppnrnum<100),1:length(hz),:,clus),3);
    dysdata2plot =  mean(clusterdata(find(ppnrnum>100),1:length(hz),:,clus),3);
    plot(hz,mean(cntrldata2plot,1),'b- .');title([ppnr{s},' ', clusters{clus},' ',num2str(length(segments)),'segs']); hold on;
    plot(hz,mean(dysdata2plot,1),'r- .');title([ppnr{s},' ', clusters{clus},' ',num2str(length(segments)),'segs']); 
    title( ['Groups ',clusters{clus},' spec(',num2str(length(segments)),'segs)']); 
    xlabel('Frequencies (Hz)'), ylabel('Power/Freq mV^2/Hz');
    set(gca,'ylim',ylim2, 'xlim',[0 50]);legend('typical', 'dyslexics'); set(gcf,'color','w');
    saveas (gcf,['Group_spec_',clusters{clus},'_',num2str(length(segments)),'segs' ], 'tiff');
    close gcf        
end
%% Plot 
groupclustermean = squeeze(mean(clusterdata(:,:,:,:),3));
for clus= 1:length(clusters)
   tmp = [ppnr',num2cell(groupclustermean(:,1:length(hz),clus))];
     xlswrite(['spec_',clusters{clus},'.xlsx'],tmp);
end
xlswrite('spec_total2.xlsx',[ppnr',num2cell(nanmean(grouptotalfourierPsd(:,1:length(hz),:),3))]);
