rm(list=ls(all=TRUE))
pathLinks <- "F:/Projects/Nls/Links2011/Analysis/Df/2011-11-13/Links2011V28.csv"
pathHeight <- "F:/Projects/Nls/Links2011/Analysis/Df/2011-11-13/Standardized.csv"
pathOutput <- "F:/Projects/Nls/Links2011/Analysis/Df/2011-11-13/DoubleEntered.csv"

dsLinks <- read.csv(pathLinks)
dsLinksLeftHand <- subset(dsLinks, select=c("Subject1Tag", "Subject2Tag", "R")) #'Lefthand' is my slang for Subjec1Tag is less than the Subject2Tag
dsLinksRightHand <- subset(dsLinks, select=c("Subject2Tag", "Subject1Tag", "R"))
colnames(dsLinksRightHand) <- c("Subject1Tag", "Subject2Tag", "R")
rm(dsLinks) #Clear from memory

dsHeight <- read.csv(pathHeight)
dsHeight1 <- subset(dsHeight, select=c("CID", "CRace", "CGender", "htst", "age_ht")) #Add things like "CGender" here
dsHeight2 <- subset(dsHeight, select=c("CID", "CRace", "CGender", "htst", "age_ht")) #Add things like "CGender" here
colnames(dsHeight1) <- c("CID", "CRace1", "CGender1", "HtSt1", "AgeHt1")
colnames(dsHeight2) <- c("CID", "CRace2", "CGender2","HtSt2", "AgeHt2")
rm(dsHeight) #Clear from memory

dsLeftHand <- merge(x=dsLinksLeftHand, y=dsHeight1, by.x="Subject1Tag", by.y="CID")
dsLeftHand <- merge(x=dsLeftHand, y=dsHeight2, by.x="Subject2Tag", by.y="CID")

dsRightHand <- merge(x=dsLinksRightHand, y=dsHeight1, by.x="Subject1Tag", by.y="CID")
dsRightHand <- merge(x=dsRightHand, y=dsHeight2, by.x="Subject2Tag", by.y="CID")
rm(dsLinksLeftHand, dsLinksRightHand, dsHeight1, dsHeight2)

ds <- rbind(dsLeftHand, dsRightHand) #'RowBind' the two datasets
rm(dsLeftHand, dsRightHand)

write.csv(ds, pathOutput)

#Cut the youngins
ageFloor <- 19
ds <- subset(ds, AgeHt1>=ageFloor & AgeHt2>=ageFloor)
#Set the remaining ambiguous pairs to an fixed constant.
ds[is.na(ds$R), "R"] <- .375

require(e1071)
#Total sample
brief <- summary(lm(HtSt1 ~ 1 + HtSt2 + R + HtSt2*R, data=ds))
coeficients <- coef(brief)
count <- length(brief$residuals)
hSquared <- coeficients["HtSt2:R", "Estimate"]
cSquared <- coeficients["HtSt2", "Estimate"]
eSquared <- 1 - hSquared - cSquared
mean(ds$HtSt1)
sd(ds$HtSt1)
skewness(ds$HtSt1)
dsResult <- data.frame(N=count, H2=hSquared, C2=cSquared, E2=eSquared, Mean=mean(ds$HtSt1), SD=sd(ds$HtSt1), Skew=skewness(ds$HtSt1))
