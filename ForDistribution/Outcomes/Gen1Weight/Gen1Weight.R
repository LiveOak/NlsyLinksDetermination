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

poundsMin <- 90 
poundsMax <- 350 

ageMin <- 16
ageMax <- 24
zMin <- -3
zMax <- -zMin 

####################################################################################
## @knitr LoadData
channel <- RODBC::odbcDriverConnect("driver={SQL Server}; Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")
dsLong <- sqlQuery(channel, 
                   "SELECT * 
                    FROM [NlsLinks].[Process].[vewOutcome]
                    WHERE Generation=1 AND ItemLabel in ('Gen1WeightPounds') 
                    ORDER BY SubjectTag, SurveyYear" 
                   , stringsAsFactors=FALSE
)
dsSubject <- sqlQuery(channel, 
                    "SELECT SubjectTag 
                    FROM [NlsLinks].[Process].[tblSubject]
                    WHERE Generation=1 
                    ORDER BY SubjectTag" 
                    , stringsAsFactors=FALSE
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

dsYear <- plyr::rename(x=dsYear, replace=c("Value"="Pounds"))
####################################################################################
## @knitr FilterValuesAndAges
#Filter out records with undesired Weight values
qplot(dsYear$Pounds, binwidth=1, main="Before Filtering Out Extreme Weights") #Make sure ages are normalish with no extreme values.
dsYear <- dsYear[!is.na(dsYear$Pounds), ]
dsYear <- dsYear[poundsMin <= dsYear$Pounds & dsYear$Pounds <= poundsMax, ]
nrow(dsYear)
summary(dsYear)
qplot(dsYear$Pounds, binwidth=1, main="After Filtering Out Extreme Weights") #Make sure ages are normalish with no extreme values.

#Filter out records with undesired age values
ggplot(dsYear, aes(x=Age, y=Pounds, group=SubjectTag)) + geom_line(alpha=.2) + geom_point(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)
dsYear <- dsYear[!is.na(dsYear$Age), ]
dsYear <- dsYear[ageMin <= dsYear$Age & dsYear$Age <= ageMax, ]
nrow(dsYear)
ggplot(dsYear, aes(x=Age, y=Pounds, group=SubjectTag)) + geom_line(alpha=.2) + geom_point(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)

####################################################################################
## @knitr Standarize
dsYear <- ddply(dsYear, c("Gender"), transform, WeightZGender=scale(Pounds))
dsYear <- ddply(dsYear, c("Gender", "Age"), transform, WeightZGenderAge=scale(Pounds))
nrow(dsYear)
qplot(dsYear$WeightZGenderAge, binwidth=.25) #Make sure ages are normalish with no extreme values.

####################################################################################
## @knitr DetermineZForClipping
ggplot(dsYear, aes(x=Age, y=WeightZGenderAge, group=SubjectTag)) + 
  annotate("rect", xmin=min(dsYear$Age), xmax=max(dsYear$Age), ymin=zMin, ymax= zMax, fill="gray99") +
  geom_line(alpha=.2) + geom_point(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)
dsYear <- dsYear[zMin <= dsYear$WeightZGenderAge & dsYear$WeightZGenderAge <= zMax, ]
nrow(dsYear)
ggplot(dsYear, aes(x=Age, y=WeightZGenderAge, group=SubjectTag)) + 
  annotate("rect", xmin=min(dsYear$Age), xmax=max(dsYear$Age), ymin=zMin, ymax= zMax, fill="gray99") +
  geom_line(alpha=.2) + geom_point(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)

####################################################################################
## @knitr ReduceToOneRecordPerSubject
ds <- ddply(dsYear, "SubjectTag", subset, rank(-Age)==1)
nrow(ds) 
summary(ds)
# SELECT [Mob], [LastSurveyYearCompleted], [AgeAtLastSurvey]
#   FROM [NlsLinks].[dbo].[vewSubjectDetails79]
#   WHERE Generation=2 and AgeAtLastSurvey >=16
#After the 2010 survey, there were 7,201 subjects who were at least 16 at the last survey.
ds <- plyr::join(x=dsSubject, y=ds, by="SubjectTag", type="left", match="first")
nrow(ds) 

qplot(ds$Age, binwidth=.5) #Make sure ages are within window, and favoring older values
qplot(ds$WeightZGenderAge, binwidth=.25) #Make sure ages are normalish with no extreme values.

####################################################################################
## @knitr WriteToCsv
write.csv(ds, pathOutput, row.names=FALSE)

