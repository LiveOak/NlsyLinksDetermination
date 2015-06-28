rm(list=ls(all=TRUE)) #Clear all the variables before starting a new run.
library(e1071) #For Skewness function
library(lattice)
library(xtable)
#################################################################################################
# Exclude some observations, define some constants and desfine a helper function
#################################################################################################
pathDoubleEntered <- "F:/Projects/Nls/Links2011/Analysis/Df/2012-01-07/BMI_Sex_Intell_DoubleEntry_Linked.csv"
# dvName1 <- "MathRaw"
# dvName1 <- "BMI"
# dvName1 <- "AFI"
#dvName1 <- "AFM"
dvName <- "HtSt19to25"
dvName1 <- paste(dvName,"_1", sep="")
dvName2 <- paste(dvName,"_2", sep="")
 
ds <- read.csv(pathDoubleEntered)
ds$Dv1 <- ds[, dvName1]
ds$Dv2 <- ds[, dvName2]


summary(ds)

# v1 <- sort(ds$Dv1)
# v2 <- sort(ds$Dv2)
v1 <- ds$Dv1
v2 <- ds$Dv2
sum(abs(v1-v2))
colMeans(cbind(v1, v2))
(mean(v1) - mean(v2))*1e16
qqplot(ds$Dv1 , ds$Dv2, xlab=dvName1, ylab=dvName2)
abline(a=0, b=1, col="tan")

h <- histogram(ds$Dv1, freq=F, col="gray70", xlab=dvName)
print(h)
#boxplot(ds$Dv1, add=T, at=.100, horizontal=T, axes=F)