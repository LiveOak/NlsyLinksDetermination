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
pathOutput <- "./ForDistribution/Outcomes/Gen2Height/Gen2Height.csv"

DVMin <- 56 #4'8"
DVMax <- 80 #7'0"
feetOnlyMin <- 4
feetOnlyMax <- 8
inchesOnlyMin <- 0
inchesOnlyMax <- 11
ageMin <- 16
ageMax <- 24
zMin <- -3
zMax <- -zMin 

extractVariablesString <- "'Gen2HeightFeetOnly', 'Gen2HeightInchesRemainder'"

####################################################################################
## @knitr LoadData
#Equivalent ages for 1981 Heights are 16-24 (ignoring two 15-year-old and 1 26-year-old)
# SELECT count([AgeSelfReportYears]), FLOOR([AgeCalculateYears]) AS Age
# FROM [NlsLinks].[Process].[tblSurveyTime]
# WHERE SurveyYear=1981
# GROUP BY floor([AgeCalculateYears]) ORDER BY Age

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
CombineHeightUnits <- function( df ) {
  feet <- df[df$ItemLabel=='Gen2HeightFeetOnly', 'Value']
  feet <- ifelse(feetOnlyMin <= feet & feet <= feetOnlyMax, feet, NA)  
  inches <- df[df$ItemLabel=='Gen2HeightInchesRemainder', 'Value']
  inches <- ifelse(inchesOnlyMin <= inches & inches <= inchesOnlyMax, inches, NA)
  return( data.frame(DV=feet*12 + inches) )
} 
#Combine to one row per SubjectYear combination
system.time( 
  dsYearStatic <- ddply(dsLong, c("SubjectTag", "SurveyYear", "Age", "Gender"), CombineHeightUnits)
)#17.34; 23.94 sec

dsYear <- dsYearStatic
nrow(dsYear)
rm(dsLong)

####################################################################################
## @knitr FilterValuesAndAges
#Filter out records with undesired height values
qplot(dsYear$DV, binwidth=1, main="Before Filtering Out Extreme Heights")
dsYear <- dsYear[!is.na(dsYear$DV), ]
dsYear <- dsYear[DVMin <= dsYear$DV & dsYear$DV <= DVMax, ]
nrow(dsYear)
summary(dsYear)
qplot(dsYear$DV, binwidth=1, main="After Filtering Out Extreme Heights") 

#Filter out records with undesired age values
qplot(dsYear$Age, binwidth=1, main="Before Filtering Out Extreme Ages") 
ggplot(dsYear, aes(x=Age, y=DV, group=SubjectTag)) + geom_line(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)
dsYear <- dsYear[!is.na(dsYear$Age), ]
dsYear <- dsYear[ageMin <= dsYear$Age & dsYear$Age <= ageMax, ]
nrow(dsYear)
qplot(dsYear$Age, binwidth=1, main="After Filtering Out Extreme Ages") 
ggplot(dsYear, aes(x=Age, y=DV, group=SubjectTag)) + geom_line(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)

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
  geom_line(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)
dsYear <- dsYear[zMin <= dsYear$ZGenderAge & dsYear$ZGenderAge <= zMax, ]
nrow(dsYear)
ggplot(dsYear, aes(x=Age, y=ZGenderAge, group=SubjectTag)) + 
  annotate("rect", xmin=min(dsYear$Age), xmax=max(dsYear$Age), ymin=zMin, ymax= zMax, fill="gray99") +
  geom_line(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)

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
qplot(ds$ZGenderAge, binwidth=.25) #Make sure ages are normalish with no extreme values.
table(is.na(ds$ZGenderAge))

####################################################################################
## @knitr ComparingWithKelly 
#   Compare against Kelly's previous versions of Gen2 Height
dsKelly <- read.csv(pathInputKellyOutcomes, stringsAsFactors=FALSE)
dsKelly <- dsKelly[, c("SubjectTag", "HeightStandarizedFor19to25")]
dsOldVsNew <- join(x=ds, y=dsKelly, by="SubjectTag", type="full")
nrow(dsOldVsNew)

#See if the new version is missing a lot of values that the old version caught.
#   The denominator isn't exactly right, because it doesn't account for the 2010 values missing in the new version.
table(is.na(dsOldVsNew$HeightStandarizedFor19to25), is.na(dsOldVsNew$ZGenderAge), dnn=c("NewIsMissing", "OldIsMissing"))
#View the correlation
cor(dsOldVsNew$HeightStandarizedFor19to25, dsOldVsNew$ZGenderAge, use="complete.obs")
#Compare against an x=y identity line.
ggplot(dsOldVsNew, aes(x=HeightStandarizedFor19to25, y=ZGenderAge)) + geom_point(shape=1) + geom_abline() + geom_smooth(method="loess")

####################################################################################
## @knitr WriteToCsv
write.csv(ds, pathOutput, row.names=FALSE)

####################################################################################
## @knitr DisplayVariables
dsVariable[, c("VariableCode", "SurveyYear", "Item", "ItemLabel", "Generation", "ExtractSource", "ID")]



## @knitr Write to SQL Server database
# channel <- odbcConnect("BeeNlsLinks")
# keepExistingTable <- FALSE
# sqlSave(channel, dat=ds, tablename="Extract.tblGen2OutcomesHeight", safer=keepExistingTable, rownames=FALSE, append=FALSE)
# odbcClose(channel)

## @knitr Alternate way to reduce to one record per SubjectYear
# CombineHeightUnits <- function( df ) {
#   feet <- df[df$Item==501, 'Value']
#   inches <- df[df$Item==502, 'Value']
#   return( data.frame(FeetOnly=feet, InchesOnly=inches))#, DV=DV) )
# }
# system.time({  
#   dsHeightWide <- ddply(dsLong, c("SubjectTag", "SurveyYear"), CombineHeightUnits)
#   dsHeightWide$FeetOnly <- ifelse(feetOnlyMin <= dsHeightWide$FeetOnly & dsHeightWide$FeetOnly <= feetOnlyMax, dsHeightWide$FeetOnly, NA)
#   dsHeightWide$InchesOnly <- ifelse(inchesOnlyMin <= dsHeightWide$InchesOnly & dsHeightWide$InchesOnly <= inchesOnlyMax, dsHeightWide$InchesOnly, NA)
#   dsHeightWide$DV <- dsHeightWide$FeetOnly*12 + dsHeightWide$InchesOnly
#   dsHeightWide <- dsHeightWide[, !(colnames(dsHeightWide) %in% c("FeetOnly", "InchesOnly"))]
# }) #24.93 sec
