rm(list=ls(all=TRUE))
dirinput <- "Z:/fraga/EEG_ABMP/Kraak_analysis/Kraak EEG/resting-state EEG/output_pre/Edit Channels/BrainVisionAnalyzer"
diroutput <- "Z:/fraga/EEG_ABMP/Kraak_analysis/Kraak EEG/resting-state EEG/output_pre/Edit Channels/BrainVisionAnalyzer/fft areas gathered"
setwd(dirinput)

band <- c('delta','theta','alpha','alpha1','alpha2','beta','gamma')
combo <- {}
for (b in 1:length(band)){
   fileinput <- paste('Area_',band[b],'.txt',sep='') 
   data <- as.matrix(read.table(fileinput,row.names=1,header=TRUE))
   colnames(data) <- paste(band[b],'_fftarea_',colnames(data),sep='')
   colnames(data) <-gsub('New1.','',colnames(data))
   combo <- cbind(combo,data)
} 
combo_pools <- {}
for (b in 1:length(band)){
  fileinput <- paste('Area_',band[b],'_pools.txt',sep='') 
  data <- as.matrix(read.table(fileinput,row.names=1,header=TRUE))
  colnames(data) <- paste(band[b],'_fftArea_',colnames(data),sep='')
  colnames(data) <-gsub('.Average_pools','',colnames(data))
  colnames(data) <-gsub('left','L',colnames(data))
  colnames(data) <-gsub('right','R',colnames(data))
  combo_pools <- cbind(combo_pools,data)
} 
setwd(diroutput)   
write.table(combo,'area_mean_combined.txt',row.names = TRUE)
write.table(combo_pools,'area_mean_combined_pools.txt',row.names = TRUE)