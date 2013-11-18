#This next line is run when the whole file is executed, 
#   but not when knitr calls individual chunks.
rm(list=ls(all=TRUE)) #Clear the memory for any variables set from any previous runs.


## @knitr LoadPackages
require(RODBC)
require(plyr)
require(ggplot2)
require(scales)
require(mgcv) #For GAM smoother
require(MASS) #For RLM
require(testit) #For Assert

## @knitr DefineGlobals
pathOutput <- "./ForDistribution/Outcomes/Gen1Height/Gen1Height.csv"

inchesTotalMin <- 56 #4'8"
inchesTotalMax <- 80 #7'0"
feetOnlyMin <- 4
feetOnlyMax <- 8
inchesOnlyMin <- 0
inchesOnlyMax <- 11
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
                    WHERE Generation=1 AND ItemLabel in ('Gen1HeightInches') 
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

dsYear <- plyr::rename(x=dsYear, replace=c("Value"="InchesTotal"))
####################################################################################
## @knitr FilterValuesAndAges
#Filter out records with undesired height values
qplot(dsYear$InchesTotal, binwidth=1, main="Before Filtering Out Extreme Heights") #Make sure ages are normalish with no extreme values.
dsYear <- dsYear[!is.na(dsYear$InchesTotal), ]
dsYear <- dsYear[inchesTotalMin <= dsYear$InchesTotal & dsYear$InchesTotal <= inchesTotalMax, ]
nrow(dsYear)
summary(dsYear)
qplot(dsYear$InchesTotal, binwidth=1, main="After Filtering Out Extreme Heights") #Make sure ages are normalish with no extreme values.

#Filter out records with undesired age values
ggplot(dsYear, aes(x=Age, y=InchesTotal, group=SubjectTag)) + geom_line(alpha=.2) + geom_point(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)
dsYear <- dsYear[!is.na(dsYear$Age), ]
dsYear <- dsYear[ageMin <= dsYear$Age & dsYear$Age <= ageMax, ]
nrow(dsYear)
ggplot(dsYear, aes(x=Age, y=InchesTotal, group=SubjectTag)) + geom_line(alpha=.2) + geom_point(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)

####################################################################################
## @knitr Standarize
dsYear <- ddply(dsYear, c("Gender"), transform, HeightZGender=scale(InchesTotal))
dsYear <- ddply(dsYear, c("Gender", "Age"), transform, HeightZGenderAge=scale(InchesTotal))
nrow(dsYear)
qplot(dsYear$HeightZGenderAge, binwidth=.25) #Make sure ages are normalish with no extreme values.

####################################################################################
## @knitr DetermineZForClipping
ggplot(dsYear, aes(x=Age, y=HeightZGenderAge, group=SubjectTag)) + 
  annotate("rect", xmin=min(dsYear$Age), xmax=max(dsYear$Age), ymin=zMin, ymax= zMax, fill="gray99") +
  geom_line(alpha=.2) + geom_point(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)
dsYear <- dsYear[zMin <= dsYear$HeightZGenderAge & dsYear$HeightZGenderAge <= zMax, ]
nrow(dsYear)
ggplot(dsYear, aes(x=Age, y=HeightZGenderAge, group=SubjectTag)) + 
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
qplot(ds$HeightZGenderAge, binwidth=.25) #Make sure ages are normalish with no extreme values.

####################################################################################
## @knitr WriteToCsv
write.csv(ds, pathOutput, row.names=FALSE)

## @knitr Write to SQL Server database
# channel <- odbcConnect("BeeNlsLinks")
# keepExistingTable <- FALSE
# sqlSave(channel, dat=ds, tablename="Extract.tblGen2OutcomesHeight", safer=keepExistingTable, rownames=FALSE, append=FALSE)
# odbcClose(channel)

## @knitr Alternate way to reduce to one record per SubjectYear
# CombineHeightUnits <- function( df ) {
#   feet <- df[df$Item==501, 'Value']
#   inches <- df[df$Item==502, 'Value']
#   return( data.frame(FeetOnly=feet, InchesOnly=inches))#, InchesTotal=inchesTotal) )
# }
# system.time({  
#   dsHeightWide <- ddply(dsLong, c("SubjectTag", "SurveyYear"), CombineHeightUnits)
#   dsHeightWide$FeetOnly <- ifelse(feetOnlyMin <= dsHeightWide$FeetOnly & dsHeightWide$FeetOnly <= feetOnlyMax, dsHeightWide$FeetOnly, NA)
#   dsHeightWide$InchesOnly <- ifelse(inchesOnlyMin <= dsHeightWide$InchesOnly & dsHeightWide$InchesOnly <= inchesOnlyMax, dsHeightWide$InchesOnly, NA)
#   dsHeightWide$InchesTotal <- dsHeightWide$FeetOnly*12 + dsHeightWide$InchesOnly
#   dsHeightWide <- dsHeightWide[, !(colnames(dsHeightWide) %in% c("FeetOnly", "InchesOnly"))]
# }) #24.93 sec