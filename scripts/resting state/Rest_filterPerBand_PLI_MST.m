%% FILTER PER FREQUENCY BAND // Compute PLI  //  Compute MST
% =========================================================================
clear all; close all;
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\Edit Channels\ASCIIs' ;
diroutput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\Edit Channels\matlabPLI';
addpath 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\scripts\mst_scripts';
addpath 'Z:\fraga\BrainConnectivityToolbox\'; 
addpath 'Z:\fraga\NeurophysiologicalBiomarkerToolbox'; 
%% 
cd (dirinput);
list = dir('*segment*.txt');                
files = {list.name}; 
% Number of segments
segments = 1:30; 
% signal parameters
srate = 1024; nyquist = srate/2;  frames = 4096;  
%% participant names
for i = 1:length(files);
    tmp=files{i}; 
    ppnr(i) = {tmp(1:4)};
end; ppnr = unique(ppnr);
%%
for s = 1:length(ppnr); %length(files);
   for seg = 1:length(segments);
      fileinput = [ppnr{s},'_4secSegment_',num2str(segments(seg)),'.txt'];

    if ~ exist([ppnr{s},'_4secSegment_',num2str(segments(seg)),'.txt']);
        disp([[ppnr{s},'_4secSegment_',num2str(segments(seg)),'.txt'],' not available']);
    else
          % import data      
            input = importdata(fileinput);
            data =  input.data; % double array with data points as rows, channels as cols.(without the txt header)
           
          % create structure with fields necessary for pop_eegfiltnew
            EEG.srate = srate;
            EEG.data = data';
            EEG.nbchan = size(EEG.data,1);
            EEG.pnts = size(EEG.data,2);
            EEG.trials = 1;
            EEG.event = 1; 
            %% Filter 
             deltaEEG = pop_eegfiltnew( EEG, 0.5, 4); 
             thetaEEG = pop_eegfiltnew( EEG, 4, 8); 
             alphaEEG = pop_eegfiltnew( EEG, 8, 13);
             betaEEG = pop_eegfiltnew( EEG, 13, 25); 
             gammaEEG = pop_eegfiltnew( EEG, 25, 49); 
             
            %% 
            
            
            %COOR = xlsread('Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\COOR.xlsx');
            CIJ = CIJ-eye(size(CIJ)); % replace diagonal by zeros (by subtracting an identity matrix of same dimensions (1-1=0)
            meanPLI = mean(CIJ(find(triu(CIJ))));
            [CIJtree,CIJclus] = backbone_wu(CIJ,avgdeg);
                
             % Get tree 
             avgdeg = 10;
             [CIJtree,CIJclus] = backbone_wu(CIJ,avgdeg);
            
            
            
            AIJ = CIJtree;
            [x,y,z] = adjacency_plot_und(AIJ,COOR);
            plot3(x,y,z); 
            %% Derive MST
            L=[];meanPLI = [];D=[];
            counter = 0;
            for i=11:20;
                    CIJ = cellData{i};
                    avgdeg = 10;
                    counter = counter +1;
                [CIJtree,CIJclus] = backbone_wu(CIJ,avgdeg);
                 L(counter)= length(leaf_nodes(CIJtree))/64; % leaf fraction;
                 meanPLI(counter)= mean(CIJ(find(triu(CIJ))));
                 D(counter)=diameter(CIJtree)/64;
            end
%%
    
    
    
    
    
    Average spectrum per segment
            % Compute spectrum for each channel separately
                for ch = 1:64;
                   fourierabs(s,:,ch,seg) = abs(fft(data(:,ch)))/N; 
                   fourierabsNormal(s,:,ch,seg) = fourierabs(s,:,ch,seg)-mean(fourierabs(s,(length(fourierabs)/2):end,ch,seg),2);
                end 
              %Compute the average spectrum across channels
                %meanFabs(s,:,seg) = mean(fourierabs(s,:,:,seg),3);
                meanFabsNormal(s,:,seg) = mean(fourierabsNormal(s,:,:,seg),3);
                % clear data         
    % Plot segment spectrum;  
        figure;
        % plot(hz,2*(meanFabs(s,1:length(hz),seg)),'k- .');title([ppnr{s},'mean Spectrum segment',num2str(seg)]); 
        plot(hz,(meanFabsNormal(s,1:length(hz),seg)),'b- .'); title([ppnr{s},'mean Spectrum segment',num2str(seg)]); 
           xlabel('Frequencies (Hz)'), ylabel('Amplitude');
           set(gcf,'color','w');
           set(gca,'ylim',[0 8], 'xlim',[0 50]);
       %% save
       cd (diroutput);cd(ppnr{s});
       saveas (gcf,[ppnr{s},'_Spec_seg',num2str(seg)], 'tiff');
       cd(dirinput)
       close gcf
    end
   end
  meanFabsNormal(meanFabsNormal == 0) = NaN; % replace 0s of the missing segments by NaN to be ignored in the mean
  segsAvailable = length(find(~isnan(meanFabsNormal(s,1,:)))); % info of how many segments current subject had 

  %% Peak detection for the average spectra across channels and segments 
   smean = nanmean(meanFabsNormal(s,1:length(hz),:),3);
   range = find(hz==6):find(hz==20);% define range for peak detection based on frequencies
   [peak,loc]= max(smean(range));
   peakfreq = hz(range(loc));  
   IAF(s) = peakfreq;
%% Plot spectrum averaged over segments and channels 
% Include IAF info
   figure;
%    plot(hz,2*(nanmean(meanFabs(s,1:length(hz),:),3)),'k- .');title([ppnr{s},'mean Spectrum']); hold on;
     plot(hz,smean,'b- .','LineWidth',.75);title([ppnr{s},'mean Spectrum (n = ',num2str(segsAvailable),' segs)']); 
     hold on;scatter(peakfreq,peak+0.1,'v','FaceColor','r','MarkerEdgeColor','k'); % mark peak
     hold on; text(peakfreq+0.6,peak+0.2,['IAF ',num2str(peakfreq),'Hz']);     
     xlabel('Frequencies (Hz)'), ylabel('Amplitude');
    set(gca,'ylim',[0 5], 'xlim',[0 50]);
    set(gcf,'color','w');
  %% save
   cd (diroutput);
   saveas (gcf,[ppnr{s},'_Spec_mean (n=',num2str(segsAvailable),' segs)' ], 'tiff');
   cd(dirinput)
   close gcf 
   groupMeanFabsNormal(s,:) = nanmean(meanFabsNormal(s,1:length(hz),:),3);
   clear fourierabsNormal data 
end
cd (diroutput);
%% save IAF info
IAF2save = [ppnr',num2cell(IAF')];
if exist('IAF','file') == 0;
    xlswrite ('IAF' ,IAF2save);
else disp('ÌAF file already exist, saved as IAF1' );
    xlswrite ('IAF_1' ,IAF2save);
end

%% Compute & plot group means
 for s = 1:length(ppnr); 
     tmp1 = ppnr{s}; 
     ppnrnum(s) = str2num(tmp1(2:end)); 
 end
tmpmean = nanmean(groupMeanFabsNormal(:,1:length(hz),:),3); 
cntrldata = nanmean(tmpmean(find(ppnrnum<100),:,:),1);
dysdata = nanmean(tmpmean(find(ppnrnum>100),:,:),1);

% Plot grand Averages
plot(hz,cntrldata,'b- .');title([ppnr{s},'mean Spectrum ',num2str(length(segments)),'segs']); hold on;
plot(hz,dysdata,'r- .');title([ppnr{s},'mean Spectrum (n',num2str(length(segments)),'segs']); 
title( ['Group mean Spectrum (n',num2str(length(segments)),' segs)']); 
xlabel('Frequencies (Hz)'), ylabel('Amplitude');
set(gca,'ylim',[0 3], 'xlim',[0 50]);
legend('typical', 'dyslexics')
set(gcf,'color','w');

saveas (gcf,['Group_Spec_mean (n=',num2str(length(segments)),' segs)' ], 'tiff');
cd(dirinput)
close gcf 
        
% end
% if ppnrnum < 100; 
%     
