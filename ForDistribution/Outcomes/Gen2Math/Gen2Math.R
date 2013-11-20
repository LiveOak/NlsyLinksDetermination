#This next line is run when the whole file is executed, but not when knitr calls individual chunks.
rm(list=ls(all=TRUE)) #Clear the memory for any variables set from any previous runs.

####################################################################################
## @knitr LoadPackages
require(RODBC)
require(plyr)
require(ggplot2)
require(scales)
require(mgcv) #For GAM smoother
require(MASS) #For RLM
require(testit) #For Assert

####################################################################################
## @knitr DefineGlobals
pathInputKellyOutcomes <-  "./OutsideData/KellyHeightWeightMath2012-03-09/ExtraOutcomes79FromKelly2012March.csv"
pathOutput <- "./ForDistribution/Outcomes/Gen2Math/Gen2Math.csv"

# dvName <- "Gen2PiatMathRaw"
# dvName <- "Gen2PiatMathPercentile"
dvName <- "Gen2PiatMathStandard"

rawMin <- 0
rawMax <- 84
percentileMin <- 0
percentileMax <- 99
standardMin <- 65
standardMax <- 135

if(dvName=='Gen2PiatMathRaw') {
  DVMin <- rawMin
  DVMax <- rawMax
}
if(dvName=='Gen2PiatMathPercentile') {
  DVMin <- percentileMin
  DVMax <- percentileMax
}
if(dvName=='Gen2PiatMathStandard') {
  DVMin <- standardMin
  DVMax <- standardMax
}

ageMin <- 5
ageMax <- 15
zMin <- -3
zMax <- -zMin 

extractVariablesString <- paste0("'", dvName, "'")
#extractVariablesString <- "'Gen2PiatMathRaw', 'Gen2PiatMathPercentile', 'Gen2PiatMathStandard'"

####################################################################################
## @knitr LoadData
channel <- RODBC::odbcDriverConnect("driver={SQL Server}; Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")
dsLong <- sqlQuery(channel,  paste0(
  "SELECT * 
  FROM [NlsLinks].[Process].[vewOutcome]
  WHERE Generation=2 AND ItemLabel in (", extractVariablesString, ") 
  ORDER BY SubjectTag, SurveyYear" 
  ), stringsAsFactors=FALSE
)
dsSubject <- sqlQuery(channel, 
  "SELECT SubjectTag 
  FROM [NlsLinks].[Process].[tblSubject]
  WHERE Generation=2 
  ORDER BY SubjectTag" 
  , stringsAsFactors=FALSE
)
dsVariable <- sqlQuery(channel, paste0(
  "SELECT * 
  FROM [NlsLinks].[dbo].[vewVariable]
  WHERE (Translate = 1) AND ItemLabel in (", extractVariablesString, ") 
  ORDER BY Item, SurveyYear, VariableCode"                      
  ), stringsAsFactors=FALSE
)
odbcClose(channel)
summary(dsLong)
nrow(dsSubject)

####################################################################################
## @knitr TweakData
dsLong$Age <- floor(ifelse(!is.na(dsLong$AgeCalculateYears), dsLong$AgeCalculateYears, dsLong$AgeSelfReportYears)) #This could still be null.
dsLong$AgeCalculateYears <- NULL
dsLong$AgeSelfReportYears <- NULL

testit::assert("All outcomes should have a loop index of zero", all(dsLong$LoopIndex==0))
dsLong$LoopIndex <- NULL


####################################################################################
## @knitr CalculateDV

#Combine to one row per SubjectYear combination
# system.time( 
#   dsYearStatic <- ddply(dsLong, c("SubjectTag", "SurveyYear", "Age", "Gender"), nrow)
# )# sec
# table(dsYearStatic$V1)
dsYearStatic <- dsLong[, c("SubjectTag", "SurveyYear", "Age", "Gender", "Value")]
dsYearStatic <- plyr::rename(dsYearStatic, replace=c("Value"="DV"))


dsYear <- dsYearStatic
nrow(dsYear)
rm(dsLong)

####################################################################################
## @knitr FilterValuesAndAges
# #There is at least one bad value --Subject 859801 has a '0' for the Standard, which should have a min of '65'.

#Filter out records with undesired Math values
qplot(dsYear$DV, binwidth=1, main="Before Filtering Out Extreme Maths")
dsYear <- dsYear[!is.na(dsYear$DV), ]
dsYear <- dsYear[DVMin <= dsYear$DV & dsYear$DV <= DVMax, ]
nrow(dsYear)
summary(dsYear)
qplot(dsYear$DV, binwidth=1, main="After Filtering Out Extreme Maths") 

#Filter out records with undesired age values
qplot(dsYear$Age, binwidth=1, main="Before Filtering Out Extreme Ages") 
ggplot(dsYear, aes(x=Age, y=DV, group=SubjectTag)) + geom_line(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)
dsYear <- dsYear[!is.na(dsYear$Age), ]
dsYear <- dsYear[ageMin <= dsYear$Age & dsYear$Age <= ageMax, ]
nrow(dsYear)
qplot(dsYear$Age, binwidth=1, main="After Filtering Out Extreme Ages") 
ggplot(dsYear, aes(x=Age, y=DV, group=SubjectTag)) + geom_line(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)

# ####################################################################################
# ## @knitr Standarize
# dsYear <- ddply(dsYear, c("Gender"), transform, ZGender=scale(DV))
# dsYear <- ddply(dsYear, c("Gender", "Age"), transform, ZGenderAge=scale(DV))
# nrow(dsYear)
# qplot(dsYear$ZGenderAge, binwidth=.25)
# 
# ####################################################################################
# ## @knitr DetermineZForClipping
# ggplot(dsYear, aes(x=Age, y=ZGenderAge, group=SubjectTag)) + 
#   annotate("rect", xmin=min(dsYear$Age), xmax=max(dsYear$Age), ymin=zMin, ymax= zMax, fill="gray99") +
#   geom_line(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)
# dsYear <- dsYear[zMin <= dsYear$ZGenderAge & dsYear$ZGenderAge <= zMax, ]
# nrow(dsYear)
# ggplot(dsYear, aes(x=Age, y=ZGenderAge, group=SubjectTag)) + 
#   annotate("rect", xmin=min(dsYear$Age), xmax=max(dsYear$Age), ymin=zMin, ymax= zMax, fill="gray99") +
#   geom_line(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)

####################################################################################
## @knitr ReduceToOneRecordPerSubject
#ds <- ddply(dsYear, "SubjectTag", summarize, ZGenderAge=median(ZGenderAge))
ds <- ddply(dsYear, "SubjectTag", summarize, Score=median(DV), Age=median(Age))
# ds <- ddply(dsYear, "SubjectTag", summarize, Score=qnorm(median(DV)/100)) #This Gaussifies the percentile scores
nrow(ds) 
summary(ds)
ds <- plyr::join(x=dsSubject, y=ds, by="SubjectTag", type="left", match="first")
nrow(ds) 

qplot(ds$Age, binwidth=.5) #Make sure (median) ages are normalish with no extreme values.
qplot(ds$Score, binwidth=.25) #Make sure (median) scores are normalish with no extreme values.
table(is.na(ds$Score))

####################################################################################
## @knitr ComparingWithKelly 
#   Compare against Kelly's previous versions of Gen2 Math
dsKelly <- read.csv(pathInputKellyOutcomes, stringsAsFactors=FALSE)
dsKelly <- dsKelly[, c("SubjectTag", "MathStandardized")]
dsOldVsNew <- join(x=ds, y=dsKelly, by="SubjectTag", type="full")
nrow(dsOldVsNew)

#See if the new version is missing a lot of values that the old version caught.
#   The denominator isn't exactly right, because it doesn't account for the 2010 values missing in the new version.
table(is.na(dsOldVsNew$MathStandardized), is.na(dsOldVsNew$Score), dnn=c("OldIsMissing", "NewIsMissing"))
#View the correlation
cor(dsOldVsNew$MathStandardized, dsOldVsNew$Score, use="complete.obs")
#Compare against an x=y identity line.
ggplot(dsOldVsNew, aes(x=MathStandardized, y=Score)) + geom_point(shape=1) + geom_abline() + geom_smooth(method="loess")

####################################################################################
## @knitr WriteToCsv
write.csv(ds, pathOutput, row.names=FALSE)

####################################################################################
## @knitr DisplayVariables
dsVariable[, c("VariableCode", "SurveyYear", "Item", "ItemLabel", "Generation", "ExtractSource", "ID")]

