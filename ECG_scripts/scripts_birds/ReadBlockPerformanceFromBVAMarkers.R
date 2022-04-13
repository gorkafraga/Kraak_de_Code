# Read block performance data from BVA markers
#===================================================================
rm(list=ls(all=TRUE))

dirinput <- 'Z:/fraga/ECG_ABMP/ECG_Kraak_Adults/ECG_adults/bva_markers'
diroutput <- 'Z:/fraga/ECG_ABMP/ECG_Kraak_Adults/ECG_adults/bva_markers/quartiles'
setwd(dirinput)

files <- list.files(path=dirinput,pattern=paste('*EKGMarker.txt',sep=''))

for (i in 1:length(files)){
fileinput <- files[i]
#load data
data<- read.table(fileinput,header = T, sep=",",skip=1) # skip first line
colnames(data)<- c(colnames(data)[1],paste("",colnames(data)[2:length(data)], sep=" ")) # fix colnames so it will be saved with a space before each

#label stimuli markers indicating block for practice trials and INCONSISTENT stimuli
data$Block = 0
stimIdx <- which(data$` Description`== 4 | data$` Description` == 8 )
data$Block[stimIdx[001:100]]<- 1 # block 1 (100 inconsistent stimuli per block) ...
data$Block[stimIdx[101:200]]<- 2
data$Block[stimIdx[201:300]]<- 3
data$Block[stimIdx[301:400]]<- 4

#Now loop thru marked stimuli to index block of response and feedback
for (j in which(data$Block == 1)){
  data$Block[j+1] <- 11
  data$Block[j+2] <- 111}
for (j in which(data$Block == 2)){
  data$Block[j+1] <- 22
  data$Block[j+2] <- 222}
for (j in which(data$Block == 3)){
  data$Block[j+1] <- 33
  data$Block[j+2] <- 333}
for (j in which(data$Block == 4)){
  data$Block[j+1] <- 44
  data$Block[j+2] <- 444}

#Rename inconsistent feedback indicating block(bX) 
idx1 <- which(data$Block == 111)
idx2 <- which(data$Block == 222)
idx3 <- which(data$Block == 333)
idx4 <- which(data$Block == 444)

#mark quartiles
quartile_1 <- c(idx1[1:25],idx2[1:25],idx3[1:25],idx4[1:25])
quartile_2 <- c(idx1[26:50],idx2[26:50],idx3[26:50],idx4[26:50])
quartile_3 <- c(idx1[51:75],idx2[51:75],idx3[51:75],idx4[51:75])
quartile_4 <- c(idx1[76:100],idx2[76:100],idx3[76:100],idx4[76:100])

data$quartile <-0
data[quartile_1,]$quartile <- 1
data[quartile_2,]$quartile <- 2
data[quartile_3,]$quartile <- 3
data[quartile_4,]$quartile <- 4

# Label feedback according to block and quartile
blocks <- c(1:4)
quartiles <- c(1:4)
for (b in 1:length(blocks)){
  for (q in 1:length(quartiles)){
    data[data$` Description`== 64 & data$Block == paste(blocks[b],blocks[b],blocks[b],sep="") & data$quartile == quartiles[q],]$` Description` <- paste("Goed_","B",blocks[b],"_q",quartiles[q],sep="")
    data[data$` Description` == 128 & data$Block == paste(blocks[b],blocks[b],blocks[b],sep="") & data$quartile == quartiles[q],]$` Description` <- paste("Fout_","B",blocks[b],"_q",quartiles[q],sep="")
  }
}

# save stuff
setwd(diroutput)
outputname <- gsub("_lsb_256Hz_reco_EKGMarker.txt","_Redited.txt",fileinput)
headText<- c("Sampling rate: 256Hz, SamplingInterval: 3.90625ms")
write.table(headText,file=outputname,sep=",",quote = FALSE,append = T, row.names=F, col.names=F)
write.table(data[,1:(length(data)-2)],file=outputname,sep=",",quote = FALSE,append = T, row.names=F, col.names=T) 
setwd(dirinput)
rm(data)
}