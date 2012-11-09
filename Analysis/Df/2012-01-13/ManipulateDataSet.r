rm(list=ls(all=TRUE)) #Clear all the variables before starting a new run.

directory <- "F:/Projects/Nls/Links2011/Analysis/Df/2012-01-13/"
pathLinks <- paste(directory, "Links2011V28.csv", sep="")
pathDv <-  paste(directory, "BMI_Sex_Intell.csv", sep="")
pathOutputSingle <-  paste(directory, "SingleEntered.csv", sep="")
pathOutputDouble <-  paste(directory, "DoubleEntered.csv", sep="")

dsLinks <- read.csv(pathLinks)
dsLinksLeftHand <- subset(dsLinks, select=c("Subject1Tag", "Subject2Tag", "R", "MultipleBirth")) #'Lefthand' is my slang for Subjec1Tag is less than the Subject2Tag
dsLinksRightHand <- subset(dsLinks, select=c("Subject2Tag", "Subject1Tag", "R", "MultipleBirth"))
#colnames(dsLinksRightHand) <- c("Subject1Tag", "Subject2Tag", "R", "MultipleBirth")
colnames(dsLinksRightHand)[colnames(dsLinksRightHand)=="Subject1Tag"] <- "SubjectTempTag"
colnames(dsLinksRightHand)[colnames(dsLinksRightHand)=="Subject2Tag"] <- "Subject1Tag"
colnames(dsLinksRightHand)[colnames(dsLinksRightHand)=="SubjectTempTag"] <- "Subject2Tag"

rm(dsLinks) #Clear from memory

dsDv <- read.csv(pathDv)
dsHeight1 <- subset(dsDv, select=c("ID", "Race", "Gender", "HtSt19to25", "AgeHt", "Bmi", "Afi", "Afm", "Afd", "MathStd", "ReadRecStd"))
dsHeight2 <- subset(dsDv, select=c("ID", "Race", "Gender", "HtSt19to25", "AgeHt", "Bmi", "Afi", "Afm", "Afd", "MathStd", "ReadRecStd")) 
colnames(dsHeight1) <- c("SubjectID", "Race_1", "Gender_1", "HtSt19to25_1", "AgeHt_1", "Bmi_1", "Afi_1", "Afm_1", "Afd_1", "MathStd_1", "ReadRecStd_1")
colnames(dsHeight2) <- c("SubjectID", "Race_2", "Gender_2","HtSt19to25_2", "AgeHt_2", "Bmi_2", "Afi_2", "Afm_2", "Afd_2", "MathStd_2", "ReadRecStd_2")
rm(dsDv) #Clear from memory

dsLeftHand <- merge(x=dsLinksLeftHand, y=dsHeight1, by.x="Subject1Tag", by.y="SubjectID")
dsLeftHand <- merge(x=dsLeftHand, y=dsHeight2, by.x="Subject2Tag", by.y="SubjectID")
write.csv(dsLeftHand, pathOutputSingle)

dsRightHand <- merge(x=dsLinksRightHand, y=dsHeight1, by.x="Subject1Tag", by.y="SubjectID")
dsRightHand <- merge(x=dsRightHand, y=dsHeight2, by.x="Subject2Tag", by.y="SubjectID")
rm(dsLinksLeftHand, dsLinksRightHand, dsHeight1, dsHeight2)

ds <- rbind(dsLeftHand, dsRightHand) #'RowBind' the two datasets
rm(dsLeftHand, dsRightHand)

write.csv(ds, pathOutputDouble)

#Cut the youngins
#ageFloor <- 19
#ds <- subset(ds, AgeHt_1>=ageFloor & AgeHt_2>=ageFloor)
#Set the remaining ambiguous pairs to an fixed constant.
#ds[is.na(ds$R), "R"] <- .375

require(e1071)
#Total sample
ds$Dv_1 <- ds$HtSt19to25_1
ds$Dv_2 <- ds$HtSt19to25_2
dsClean <- subset(ds, !is.na(Dv_1) & !is.na(Dv_2) & !is.na(R))
brief <- summary(lm(Dv_1 ~ 1 + Dv_2 + R + Dv_2*R, data=dsClean))
coeficients <- coef(brief)
count <- length(brief$residuals)
hSquared <- coeficients["Dv_2:R", "Estimate"]
cSquared <- coeficients["Dv_2", "Estimate"]
eSquared <- 1 - hSquared - cSquared
mean(dsClean$Dv_1)
sd(dsClean$Dv_1)
skewness(dsClean$Dv_1)
dsResult <- data.frame(N=count, H2=hSquared, C2=cSquared, E2=eSquared, Mean=mean(dsClean$Dv_1), SD=sd(dsClean$Dv_1), Skew=skewness(dsClean$Dv_1))

