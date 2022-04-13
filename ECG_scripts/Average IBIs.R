##YY CONDITION SCRIPT ##

# NOTE: THIS FILE NEEDS TO BE RUN SEPERATELY FOR EACH CONDITION
# OPEN R
# Changd dir to were the export files are located [one folder per condition]
# Choose "open script" in R and open this file
# Change the following path to the correct path were the files to be analyzed are located. Note, there should be no other files than those you'd like to analyze in this folder
rm(list=ls())
dirinput <- "Z:/fraga/ECG_ABMP/ECG_Kraak_Adults/ECG_adults_bird/bva_output/quartiles_redo"
diroutput <- "Z:/fraga/ECG_ABMP/ECG_Kraak_Adults/ECG_adults_bird/bva_output/quartiles_redo"
## Setting WD to correct path
setwd(dirinput)

condition <-"Pos_q4"
files <- list.files(path=dirinput,pattern=paste('s*_',condition,'_IBIs.txt',sep=''))
outputname <- paste('IBIs_gathered_',condition,'.txt',sep='')
# This line creates variable names

names <- t(c("ID", "IBI_min2", "IBI_min1", "IBI_0", "IBI_1", "IBI_2","IBI_3"))


# This stores variable names to condition specific text file
# Change file name to your relevant condition
setwd(diroutput)
write.table(names, file=outputname, append=F, sep=" ", dec=",", row.names=F, col.names=F)
setwd(dirinput)

# loop through files (i.e., feedback condition specific data of all participants)
for (i in 1:length(files))
{
  # read in data file of ith participant
  data <- read.table(files[i], dec=".", header=T)
  
  # select ibi-2, ibi-1, ibi0, ibi1, ibi2, ibi3
  data2 <- data[,c(4,7,10,13,16,19)]
  
  # create mean ibi difference scores, referenced to ibi-2
  IBI_min2 	<- mean(data2[,1]) # ibi-2 = baseline ibi
  IBI_min1 	<- mean(data2[,2]-data2[,1])
  IBI_0		<- mean(data2[,3]-data2[,1])
  IBI_1 	<- mean(data2[,4]-data2[,1])
  IBI_2 	<- mean(data2[,5]-data2[,1])
  IBI_3 	<- mean(data2[,6]-data2[,1])

  # collect ibi-2 and ibi difference scores in a vector
  all_ibis <- t(c(IBI_min2, IBI_min1, IBI_0, IBI_1, IBI_2, IBI_3)) # loop through files (i.e., feedback condition specific data of all participants)
                       # write ibi-2 and ibi difference scores to text file
  setwd(diroutput)
                    # Here you can again change the file name to the current condition name
                    write.table(t(c(files[i],all_ibis)), file=outputname, append=T, sep=" ", dec=",", row.names=F, col.names=F)
  setwd(dirinput)
} 