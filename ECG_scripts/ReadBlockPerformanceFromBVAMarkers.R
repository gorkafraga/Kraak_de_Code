# Read block performance data from BVA markers
#===================================================================
rm(list=ls(all=TRUE))

dirinput <- 'Z:/fraga/ECG_ABMP/ECG_Kraak_Adults/ecg_adults_bird/bva_markers/'
diroutput <- 'Z:/fraga/ECG_ABMP/ECG_Kraak_Adults/ecg_adults_bird/bva_markers/Redo_redit'
setwd(dirinput)

files <- list.files(path=dirinput,pattern=paste('*EKGMarker.txt',sep=''))

for (i in 1:length(files)) {
  fileinput <- files[i]
  #load data
  data<- read.table(fileinput,header = T, sep=",",skip=1) # skip first line
  colnames(data)<- c(colnames(data)[1],paste("",colnames(data)[2:length(data)], sep=" ")) # fix colnames so it will be saved with a space before each
    
  attach(data)
  #find last practice trial
  practiceIdx <- which(data$` Description` == 666)
  lastPracticeIdx <- practiceIdx[length(practiceIdx)]
  if (length(lastPracticeIdx)== 0){
    lastPracticeIdx <- 1}
  
  
   #find all feedback after practice
    feedbackIdx = which((data$` Description` == 128 | data$` Description` == 64 ) & (data$` Position` > data$ ` Position`[lastPracticeIdx]))
    feedbackIdx <- feedbackIdx[2:length(feedbackIdx)] # first should relate to the last practice trial 
   #find all inconsistent stimuli (some may be erroneously assign as stimuli)
    stimidx <- which((data$` Description`== 4 | data$` Description` == 8 | data$` Description` == 1 | data$` Description` == 2))
   
  #label in additional column (1 = feedback to inconsistent trials 2 = resps and stim in inconsistent trials)   
    data$feed = 0
    for (j in 1:length(feedbackIdx)) {
    dif <- stimidx-feedbackIdx[j]
    prestim <- max(dif[dif<0]) #this should be the closest preceding stimuli to the current feedbackIdx. 
    if ((data$` Description`[feedbackIdx[j]+prestim]) == 4 | (data$` Description`[feedbackIdx[j]+prestim]) == 8){
      data$feed[feedbackIdx[j]] <- 1
      data$feed[(feedbackIdx[j]+prestim)] <- 2
      }
    }
  nfeeds <-  dim(data[data$feed==1,])[1] #n feedback in inconsistent trials (expected 400)
  #label the block each feedback belongs (assumes if missing is from the last)
  data$Block = 0
  data[which(data$feed == 1),]$Block[1:100] <- 1 # block 1 (100 inconsistent stimuli per block) ...
  data[which(data$feed == 1),]$Block[101:200] <- 2
  data[which(data$feed == 1),]$Block[201:300] <- 3
  data[which(data$feed == 1),]$Block[301:nfeeds] <- 4
  
  #lable the Quartile each feedback belongs (assumes if missing is from the last)
  data$Quartile = 0
  data[which(data$Block == 1),]$Quartile[1:25] <- 1
  data[which(data$Block == 2),]$Quartile[1:25] <- 1
  data[which(data$Block == 3),]$Quartile[1:25] <- 1
  data[which(data$Block == 4),]$Quartile[1:25] <- 1
  data[which(data$Block == 1),]$Quartile[26:50] <- 2
  data[which(data$Block == 2),]$Quartile[26:50] <- 2
  data[which(data$Block == 3),]$Quartile[26:50] <- 2
  data[which(data$Block == 4),]$Quartile[26:50] <- 2
  data[which(data$Block == 1),]$Quartile[51:75] <- 3
  data[which(data$Block == 2),]$Quartile[51:75] <- 3
  data[which(data$Block == 3),]$Quartile[51:75] <- 3
  
  if (length(which(data$Block == 4)) < 75) { # prevents crashing when subject missess more than the last quartile
    data[which(data$Block == 4),]$Quartile[51:length(which(data$Block == 4))] <- 3
    data[which(data$Block == 1),]$Quartile[76:100] <- 4
    data[which(data$Block == 2),]$Quartile[76:100] <- 4
    data[which(data$Block == 3),]$Quartile[76:100] <- 4  
    } else {    (data[which(data$Block == 4),]$Quartile[51:75] <- 3) 
  data[which(data$Block == 1),]$Quartile[76:100] <- 4
  data[which(data$Block == 2),]$Quartile[76:100] <- 4
  data[which(data$Block == 3),]$Quartile[76:100] <- 4  
  data[which(data$Block == 4),]$Quartile[76:length(which(data$Block == 4))] <- 4  
  }
  
  
  # Label feedback according to block and quartile
  blocks <- c(1:4)
  for (b in 1:length(blocks)){
    quartiles <- unique(data[which(data$Block == blocks[b]),]$Quartile) # this prevents from crashing if a complete quartile is missing 
    for (q in 1:length(quartiles)){
      data[data$` Description`== 64 & data$Block == blocks[b] & data$Quartile == quartiles[q],]$` Description` <- paste("Goed_","B",blocks[b],"_q",quartiles[q],sep="")
      data[data$` Description` == 128 & data$Block == blocks [b] & data$Quartile == quartiles[q],]$` Description` <- paste("Fout_","B",blocks[b],"_q",quartiles[q],sep="")
    }
  }
  
  # save stuff
  setwd(diroutput)
  outputname <- gsub("_256Hz_reco_EKGMarker.txt","_Redited.txt",fileinput)
  headText<- c("Sampling rate: 256Hz, SamplingInterval: 3.90625ms")
  write.table(headText,file=outputname,sep=",",quote = FALSE,append = T, row.names=F, col.names=F)
  write.table(data[,1:(length(data)-3)],file=outputname,sep=",",quote = FALSE,append = T, row.names=F, col.names=T) 
  setwd(dirinput)
  rm(data)
}