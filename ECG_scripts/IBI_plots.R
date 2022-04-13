library(reshape2)
library(ggplot2)

IBIS$IDI <- factor(IBIS$ID)
IBISlong <- melt(IBIS,id.vars = "Dyslexia",measure.vars = c("FC_IBI_min1","FC_IBI_0","FC_IBI_1","FC_IBI_2"), 
     variable.name = "condition")
 
IBISc <- summarySE(IBISlong, measurevar="value", groupvars=c("Dyslexia","condition"))


# Standard error of the mean
ggplot(IBISc, aes(x=condition, y=value, colour=Dyslexia)) + 
  geom_errorbar(aes(ymin=value-se, ymax=value+se), width=.1) +
  geom_line() +
  geom_point()
# The errorbars overlapped, so use position_dodge to move them horizontally
pd <- position_dodge(0.1) # move them .05 to the left and right
ggplot(IBISc, aes(x=condition, y=value, colour=Dyslexia)) + 
  geom_errorbar(aes(ymin=value-se, ymax=value+se), width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd)
# Use 95% confidence interval instead of SEM
ggplot(IBISc, aes(x=condition, y=value, colour=Dyslexia)) + 
  geom_errorbar(aes(ymin=value-ci, ymax=value+ci), width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd)
# Black error bars - notice the mapping of 'group=Dyslexia' -- without it, the error
# bars won't be dodged!
ggplot(IBISc, aes(x=condition, y=value, colour=Dyslexia, group=Dyslexia)) + 
  geom_errorbar(aes(ymin=value-ci, ymax=value+ci), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3)





########################## chapucillas below:





#separate group data and make it longitudinal
dys <- melt(IBIS[IBIS$Dyslexia==1,],id.vars = "ID",measure.vars = c("FC_IBI_min1","FC_IBI_0","FC_IBI_1","FC_IBI_2"), 
       variable.name = "condition")
dysC <- summarySEwithin(dys, measurevar="value", withinvars="condition",
                        idvar="ID", na.rm=FALSE, conf.interval=.95)
 

ctrl <- melt(IBIS[IBIS$Dyslexia==0,],id.vars = "ID",measure.vars = c("FC_IBI_min1","FC_IBI_0","FC_IBI_1","FC_IBI_2"), 
            variable.name = "condition")
ctrlC <- summarySEwithin(ctrl, measurevar="value", withinvars="condition",
                        idvar="ID", na.rm=FALSE, conf.interval=.95)


############################################################################>
# Make the graph with the 95% confidence interval
ggplot(ctrlC, aes(x=condition, y=value, group=1,color='blue')) +
  geom_line() +
  geom_errorbar(width=.1, aes(ymin=value-ci, ymax=value+ci)) +
  geom_point(shape=21, size=3, fill="white") +
  ylim(-10,60)
par(new=T)

ggplot(dysC, aes(x=condition, y=value, group=1)) +
  geom_line() +
  geom_errorbar(width=.1, aes(ymin=value-ci, ymax=value+ci)) +
  geom_point(shape=21, size=3, fill="white") 
  
par(new=F)

