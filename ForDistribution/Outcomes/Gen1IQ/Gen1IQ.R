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
pathOutput <- "./ForDistribution/Outcomes/Gen1IQ/Gen1IQ.csv"

DVMin <- -10
DVMax <- 10
feetOnlyMin <- 4
feetOnlyMax <- 8
inchesOnlyMin <- 0
inchesOnlyMax <- 11
ageMin <- 16
ageMax <- 24
zMin <- -3
zMax <- -zMin 

extractVariablesString <- "'Gen1AfqtScaled3Decimals'"

####################################################################################
## @knitr LoadData
# dsExtract <- read.csv(file="D:/Projects/BG/Links2011/NlsyLinksDetermination/Extracts/Gen1Outcomes.csv", stringsAsFactors=F)

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


# # Compare
# dsExtract$SubjectTag <- dsExtract$R0000100*100
# dsExtract$DV <- dsExtract$R0618301
# dsExtract$DV <- ifelse(dsExtract$DV<0, NA, dsExtract$DV)
# dsCompare <- merge(x=dsExtract, y=dsLong, by="SubjectTag", all=TRUE)
# 
# 
# qplot(dsCompare$DV, dsCompare$Value)
# table(!is.na(dsCompare$DV), !is.na(dsCompare$Value))


####################################################################################
## @knitr TweakData
dsLong$Age <- floor(ifelse(!is.na(dsLong$AgeCalculateYears), dsLong$AgeCalculateYears, dsLong$AgeSelfReportYears)) #This could still be null.
dsLong$AgeCalculateYears <- NULL
dsLong$AgeSelfReportYears <- NULL

testit::assert("All outcomes should have a loop index of zero", all(dsLong$LoopIndex==0))
dsLong$LoopIndex <- NULL

#The NLS Investigator can return only integers, so it multiplied everything by 10000.  See R06183.01.
#   Then I divide by 100 again to convert it to a proportion.
dsLong$Value <- dsLong$Value/(1000 * 100)
dsYear <- dsLong[, c("SubjectTag", "SurveyYear", "Age", "Gender", "Value")]
nrow(dsYear)
rm(dsLong)

####################################################################################
## @knitr Gaussify

qplot(dsYear$Value, binwidth=.05, main="Before Gaussification")

dsYear$AfqtRescaled2006Gaussified <- qnorm(dsYear$Value) #convert from roughly uniform distribution [0, 100], to something Gaussianish.
dsYear$AfqtRescaled2006Gaussified <- pmax(pmin(dsYear$AfqtRescaled2006Gaussified, 3), -3) #The scale above had 0s and 100s, so clamp that in at +/-3.
dsYear <- plyr::rename(x=dsYear, replace=c("AfqtRescaled2006Gaussified"="DV"))

# dsYear <- plyr::rename(x=dsYear, replace=c("Value"="DV"))


####################################################################################
## @knitr FilterValuesAndAges
#Filter out records with undesired DV values
qplot(dsYear$DV, binwidth=.25, main="Before Filtering Out Extreme DV values")
dsYear <- dsYear[!is.na(dsYear$DV), ]
dsYear <- dsYear[DVMin <= dsYear$DV & dsYear$DV <= DVMax, ]
nrow(dsYear)
summary(dsYear)
qplot(dsYear$DV, binwidth=.25, main="After Filtering Out Extreme DV values")

#Filter out records with undesired age values
qplot(dsYear$Age, binwidth=.25, main="Before Filtering Out Extreme Ages") 
ggplot(dsYear, aes(x=Age, y=DV, group=SubjectTag)) + geom_line(alpha=.2) + geom_point(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)
dsYear <- dsYear[!is.na(dsYear$Age), ]
dsYear <- dsYear[ageMin <= dsYear$Age & dsYear$Age <= ageMax, ]
nrow(dsYear)
qplot(dsYear$Age, binwidth=.25, main="After Filtering Out Extreme Ages") 
ggplot(dsYear, aes(x=Age, y=DV, group=SubjectTag)) + geom_line(alpha=.2) + geom_point(alpha=.2) + geom_smooth(method="rlm", aes(group=NA), size=2)

####################################################################################
## @knitr Standarize
# dsYear <- ddply(dsYear, c("Gender"), transform, ZGenderAge=scale(DV))  #WATCH OUT-This is a quick hack with age.
dsYear <- ddply(dsYear, c("Gender", "Age"), transform, ZGenderAge=scale(DV))
# dsYear$ZGenderAge <- dsYear$DV
nrow(dsYear)
qplot(dsYear$ZGenderAge, binwidth=.25)


# dsYear$ZGenderAge <- rnorm(n=nrow(dsYear))

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
#The ASFT was asked only once of the Gen1 subjects, so I don't need to reduce.
ds <- dsYear

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
