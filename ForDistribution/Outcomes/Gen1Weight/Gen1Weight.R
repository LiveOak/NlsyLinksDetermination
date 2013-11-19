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
pathOutput <- "./ForDistribution/Outcomes/Gen1Weight/Gen1Weight.csv"

DVMin <- 90 
DVMax <- 350 

ageMin <- 16
ageMax <- 24
zMin <- -3
zMax <- 5

extractVariablesString <- "'Gen1WeightPounds'"

####################################################################################
## @knitr LoadData
channel <- RODBC::odbcDriverConnect("driver={SQL Server}; Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")
dsLong <- sqlQuery(channel, paste0(
  "SELECT * 
  FROM [NlsLinks].[Process].[vewOutcome]
  WHERE Generation=1 AND ItemLabel in (", extractVariablesString, ") 
  ORDER BY SubjectTag, SurveyYear" 
  ), stringsAsFactors=FALSE
)
dsSubject <- sqlQuery(channel, 
  "SELECT SubjectTag 
  FROM [NlsLinks].[Process].[tblSubject]
  WHERE Generation=1 
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

dsYear <- dsLong[, c("SubjectTag", "SurveyYear", "Age", "Gender", "Value")]
nrow(dsYear)
rm(dsLong)

dsYear <- plyr::rename(x=dsYear, replace=c("Value"="DV"))
####################################################################################
## @knitr FilterValuesAndAges
#Filter out records with undesired DV values
qplot(dsYear$DV, binwidth=1, main="Before Filtering Out Extreme DVs")
dsYear <- dsYear[!is.na(dsYear$DV), ]
dsYear <- dsYear[DVMin <= dsYear$DV & dsYear$DV <= DVMax, ]
nrow(dsYear)
summary(dsYear)
qplot(dsYear$DV, binwidth=1, main="After Filtering Out Extreme DVs") 

#Filter out records with undesired age values
qplot(dsYear$Age, binwidth=1, main="Before Filtering Out Extreme Ages") 
ggplot(dsYear, aes(x=Age, y=DV, group=SubjectTag)) + geom_line(alpha=.2) + geom_point(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)
dsYear <- dsYear[!is.na(dsYear$Age), ]
dsYear <- dsYear[ageMin <= dsYear$Age & dsYear$Age <= ageMax, ]
nrow(dsYear)
qplot(dsYear$Age, binwidth=1, main="After Filtering Out Extreme Ages") 
ggplot(dsYear, aes(x=Age, y=DV, group=SubjectTag)) + geom_line(alpha=.2) + geom_point(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)

####################################################################################
## @knitr Standarize
# dsYear <- ddply(dsYear, c("Gender"), transform, ZGender=scale(DV))
dsYear <- ddply(dsYear, c("Gender", "Age"), transform, ZGenderAge=scale(DV))
nrow(dsYear)
qplot(dsYear$ZGenderAge, binwidth=.25) 

####################################################################################
## @knitr DetermineZForClipping
ggplot(dsYear, aes(x=Age, y=ZGenderAge, group=SubjectTag)) + 
  annotate("rect", xmin=min(dsYear$Age), xmax=max(dsYear$Age), ymin=zMin, ymax= zMax, fill="gray99") +
  geom_line(alpha=.2) + geom_point(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)
dsYear <- dsYear[zMin <= dsYear$ZGenderAge & dsYear$ZGenderAge <= zMax, ]
nrow(dsYear)
ggplot(dsYear, aes(x=Age, y=ZGenderAge, group=SubjectTag)) + 
  annotate("rect", xmin=min(dsYear$Age), xmax=max(dsYear$Age), ymin=zMin, ymax= zMax, fill="gray99") +
  geom_line(alpha=.2) + geom_point(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)

####################################################################################
## @knitr ReduceToOneRecordPerSubject
ds <- ddply(dsYear, "SubjectTag", subset, rank(-Age, ties.method="first")==1)
nrow(ds) 
summary(ds)
# SELECT [Mob], [LastSurveyYearCompleted], [AgeAtLastSurvey]
#   FROM [NlsLinks].[dbo].[vewSubjectDetails79]
#   WHERE Generation=2 and AgeAtLastSurvey >=16
#After the 2010 survey, there were 7,201 subjects who were at least 16 at the last survey.
ds <- plyr::join(x=dsSubject, y=ds, by="SubjectTag", type="left", match="first")
nrow(ds) 

qplot(ds$Age, binwidth=.5) #Make sure ages are within window, and favoring older values
qplot(ds$ZGenderAge, binwidth=.25)
table(is.na(ds$ZGenderAge))

####################################################################################
## @knitr WriteToCsv
write.csv(ds, pathOutput, row.names=FALSE)

####################################################################################
## @knitr DisplayVariables
dsVariable[, c("VariableCode", "SurveyYear", "Item", "ItemLabel", "Generation", "ExtractSource", "ID")]
