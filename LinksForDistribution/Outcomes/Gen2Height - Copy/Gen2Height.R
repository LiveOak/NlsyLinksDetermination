#This next line is run when the whole file is executed, 
#   but not when knitr calls individual chunks.
rm(list=ls(all=TRUE)) #Clear the memory for any variables set from any previous runs.
pathInputKellyOutcomes <-  file.path(getwd(), "OutsideData/KellyHeightWeightMath2012-03-09/ExtraOutcomes79FromKelly2012March.csv")
pathOutputSubjectHeight <- file.path(getwd(), "LinksForDistribution/Outcomes/Gen2Height/Gen2Height.csv")

## @knitr LoadPackages
require(RODBC)
require(plyr)
require(ggplot2)
require(scales)
require(mgcv) #For GAM smoother
require(MASS) #For RLM
# require(parallel)

## @knitr DefineBoundaries
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


## @knitr LoadData
#Equivalent ages for 1981 Heights are 16-24 (ignoring two 15-year-old and 1 26-year-old)
# SELECT count([AgeSelfReportYears]), FLOOR([AgeCalculateYears]) AS Age
# FROM [NlsLinks].[Process].[tblSurveyTime]
# WHERE SurveyYear=1981
# GROUP BY floor([AgeCalculateYears]) ORDER BY Age

channel <- odbcConnect("BeeNlsLinks")
dsHeightLong <- sqlQuery(channel, 
  "SELECT SubjectTag, SurveyYear, Item, Value
    FROM NlsLinks.Process.tblResponse
    WHERE Generation=2 AND Item in (501, 502) 
    ORDER BY SubjectTag, SurveyYear" 
)#Items 501 & 502 are HeightInFeetOnly and HeightInInchesOnly
dsSubjectYear <- sqlQuery(channel, 
  "SELECT tblSurveyTime.SubjectTag, tblSurveyTime.SurveyYear, 
  Floor(tblSurveyTime.AgeCalculateYears) AS Age, tblSubject.Generation, tblSubject.Gender
  FROM NlsLinks.Process.tblSurveyTime 
    INNER JOIN NlsLinks.Process.tblSubject ON tblSurveyTime.SubjectTag = tblSubject.SubjectTag
  WHERE Generation=2 AND  (AgeCalculateYears IS NOT NULL)
  ORDER BY SubjectTag, SurveyYear"
)
odbcClose(channel)
summary(dsHeightLong)
summary(dsSubjectYear)
comma(c(nrow(dsHeightLong), nrow(dsSubjectYear)))

## @knitr CalculateTotalInches
CombineHeightUnits <- function( df ) {
  feet <- df[df$Item==501, 'Value']
  feet <- ifelse(feetOnlyMin <= feet & feet <= feetOnlyMax, feet, NA)  
  inches <- df[df$Item==502, 'Value']
  inches <- ifelse(inchesOnlyMin <= inches & inches <= inchesOnlyMax, inches, NA)
  return( data.frame(InchesTotal=feet*12 + inches) )
} # system.time( )#23.94 sec
#Combine to one row per SubjectYear combination
dsHeightYear <- ddply(dsHeightLong, c("SubjectTag", "SurveyYear"), CombineHeightUnits)
nrow(dsHeightYear)

#Filter out records with undesired height values
dsHeightYear <- dsHeightYear[inchesTotalMin <= dsHeightYear$InchesTotal & dsHeightYear$InchesTotal <= inchesTotalMax, ]
dsHeightYear <- dsHeightYear[!is.na(dsHeightYear$InchesTotal), ]
nrow(dsHeightYear)
summary(dsHeightYear)
qplot(dsHeightYear$InchesTotal, binwidth=1) #Make sure ages are normalish with no extreme values.
rm(dsHeightLong)

## @knitr JoinSubjectYearAndHeightYear
dsLong <- join(x=dsSubjectYear, y=dsHeightYear, type="inner", by=c("SubjectTag", "SurveyYear"))
nrow(dsLong)
ggplot(dsLong, aes(x=Age, y=InchesTotal, group=SubjectTag)) + geom_line(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)
rm(dsSubjectYear, dsHeightYear)

## @knitr Standarize
dsLong <- dsLong[ageMin <= dsLong$Age & dsLong$Age <= ageMax, ]
nrow(dsLong)
dsLong <- ddply(dsLong, c("Gender"), transform, HeightZGender=scale(InchesTotal))
dsLong <- ddply(dsLong, c("Gender", "Age"), transform, HeightZGenderAge=scale(InchesTotal))
nrow(dsLong)
qplot(dsLong$HeightZGenderAge, binwidth=.25) #Make sure ages are normalish with no extreme values.

## @knitr DetermineZForClipping
ggplot(dsLong, aes(x=Age, y=HeightZGenderAge, group=SubjectTag)) + 
  annotate("rect", xmin=min(dsLong$Age), xmax=max(dsLong$Age), ymin=zMin, ymax= zMax, fill="gray99") +
  geom_line(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)
dsLong <- dsLong[zMin <= dsLong$HeightZGenderAge & dsLong$HeightZGenderAge <= zMax, ]
nrow(dsLong)

## @knitr ReduceToOneRecordPerSubject
ds <- ddply(dsLong, "SubjectTag", subset, rank(-Age)==1)
summary(ds)
# SELECT [Mob], [LastSurveyYearCompleted], [AgeAtLastSurvey]
#   FROM [NlsLinks].[dbo].[vewSubjectDetails79]
#   WHERE Generation=2 and AgeAtLastSurvey >=16
#After the 2010 survey, there were 7,201 subjects who were at least 16 at the last survey.
nrow(ds) 
qplot(ds$Age, binwidth=.5) #Make sure ages are within window, and favoring older values
qplot(ds$HeightZGenderAge, binwidth=.25) #Make sure ages are normalish with no extreme values.


## @knitr ComparingWithKelly 
#   Compare against Kelly's previous versions of Gen2 Height
dsKelly <- read.csv(pathInputKellyOutcomes, stringsAsFactors=FALSE)
dsKelly <- dsKelly[, c("SubjectTag", "HeightStandarizedFor19to25")]
dsOldVsNew <- join(x=ds, y=dsKelly, by="SubjectTag", type="full")

#See if the new version is missing a lot of values that the old version caught.
#   The denominator isn't exactly right, because it doesn't account for the 2010 values missing in the new version.
table(is.na(dsOldVsNew$HeightZGenderAge), is.na(dsOldVsNew$HeightStandarizedFor19to25), dnn=c("NewIsMissing", "OldIsMissing"))
#View the correlation
cor(dsOldVsNew$HeightZGenderAge,dsOldVsNew$HeightStandarizedFor19to25, use="complete.obs")
#Compare against an x=y identity line.
ggplot(dsOldVsNew, aes(x=HeightStandarizedFor19to25, y=HeightZGenderAge)) + geom_point(shape=1) + geom_abline() + geom_smooth(method="loess")

# @knitr WriteToCsv
write.csv(ds, pathOutputSubjectHeight, row.names=FALSE)

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
#   dsHeightWide <- ddply(dsHeightLong, c("SubjectTag", "SurveyYear"), CombineHeightUnits)
#   dsHeightWide$FeetOnly <- ifelse(feetOnlyMin <= dsHeightWide$FeetOnly & dsHeightWide$FeetOnly <= feetOnlyMax, dsHeightWide$FeetOnly, NA)
#   dsHeightWide$InchesOnly <- ifelse(inchesOnlyMin <= dsHeightWide$InchesOnly & dsHeightWide$InchesOnly <= inchesOnlyMax, dsHeightWide$InchesOnly, NA)
#   dsHeightWide$InchesTotal <- dsHeightWide$FeetOnly*12 + dsHeightWide$InchesOnly
#   dsHeightWide <- dsHeightWide[, !(colnames(dsHeightWide) %in% c("FeetOnly", "InchesOnly"))]
# }) #24.93 sec
