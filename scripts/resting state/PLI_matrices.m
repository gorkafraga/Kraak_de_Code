%PLI matrices
% use script 'PLI_means' to get groupdata.
cd 'Z:\fraga\EEG_Gorka\Analysis_RESTING STATE_Graph\Analysis_brainwave\Phase Lag Index\Average Reference\Group matrices';
% Use the variable GROUPDATA created from the script "PLI_means"
%------------ manually :
% typical readers
sel = [1,3,5:7,9:18];
groupdata_peakExcl = groupdata(:,:,sel,:);
 M = mean(groupdata_peakExcl,4);
 groupmean = mean(M, 3);
 
 dlmwrite('Theta_DysPeakExclOutTheta_groupMat.edge',groupmean,' ');

% Dyslexics readers
 sel2 = [1,2,4,5,7:9,11,13:27,29:34];
groupdata_peakExcl = groupdata(:,:,sel2,:);
 M = mean(groupdata_peakExcl,4);
 groupmean = mean(M, 3);
  dlmwrite('dyslexics_groupMat.edge',groupmean,' ');