## Count no segments ## 
rm(list=ls())
dirinput <- "Z:/fraga/ECG_ABMP/ECG_Kraak_Adults/ECG_adults/bva_output/"
diroutput <- "Z:/fraga/ECG_ABMP/ECG_Kraak_Adults/ECG_adults"
setwd(dirinput)

condition <-"FC"
# Find list of file (edit pattern to specify the files)
files <- list.files(path=dirinput,pattern=paste("s*_",condition,"_IBIs.txt", sep=''))
#Change output name to your relevant condition!
outputname <- paste("count_",condition,"_segs.txt", sep='')
# Create column names
names <- t(c("ID", "count"))
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
  # the number of rows is the number of segments (header is ignored)
  noSegments <- dim(data)[1]
 setwd(diroutput)
  write.table(t(c(files[i],noSegments)), file=outputname, append=T, sep=" ", dec=",", row.names=F, col.names=F)
  setwd(dirinput)
} 