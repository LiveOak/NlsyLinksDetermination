require(RODBC)
require(plyr)
require(lubridate)
rm(list=ls(all=TRUE))

####################################
### Declare variables
####################################

generation <- 1
pathInputFertility <- "./OutsideData/AfiAmen2012-09-20/AfiAfm.csv"
# pathPoliticalInput <- "./Datasets/PoliticalData.csv"
# pathAsqtInput <- "./Datasets/Gen1Afqt.csv"
pathOutput <- "./ForDistribution/Outcomes/OutcomesGen1.csv"

####################################
### Connect to database and data files
####################################

channel <- RODBC::odbcDriverConnect("driver={SQL Server}; Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")
odbcGetInfo(channel)
keepExistingTable <- FALSE
dsLong <- sqlQuery(channel, paste0("SELECT * FROM Process.vewOutcome WHERE Generation=", generation))
dsSubject <- sqlQuery(channel, paste0("SELECT SubjectTag, ExtendedID, SubjectID, Generation FROM Process.tblSubject WHERE Generation=", generation))

odbcClose(channel)

####################################
### Create Wide Dataset
####################################
ds <- count(dsLong, vars=c("SubjectTag", "SubjectID", "Generation"))
ds <- plyr::rename(ds, replace=c("freq"="OutcomeCount"))

# variablesToDropEventually <- c("ExtendedID", "Gender", "Mob", "Yob", "Age", "HeightInchesLateTeens", 
#                                "WeightPoundsLateTeens",  "BmiLateTeens") #"AfqtRescaled2006",

# ds$AfqtRescaled2006Gaussified <- qnorm(ds$Gen1AfqtRescaled2006) #convert from roughly uniform distribution [0, 100], to something Guassianish.
# ds$AfqtRescaled2006Gaussified <- pmax(pmin(ds$AfqtRescaled2006Gaussified, 3), -3) #The scale above had 0s and 100s, so clamp that in at +/-3.
# ds$Yob <- year(ds$Mob)
# heightSurveyDate <- ISOdate(1982, 7, 1)
# ds$Age <- floor(difftime(heightSurveyDate, ds$Mob, units="days") / 365.25)
# table(floor(ds$Age))
# ds$Age <- ifelse(ds$Age==27, NA, ds$Age)
# 
# ds <- ddply(ds, c("Gender"), transform, HeightZGender=scale(HeightInchesLateTeens))
# ds$HeightZGender <- pmax(pmin(ds$HeightZGender, 3), -3)  
# 
# ds <- ddply(ds, c("Gender", "Age"), transform, HeightZGenderAge=scale(HeightInchesLateTeens))
# ds$HeightZGenderAge <- pmax(pmin(ds$HeightZGenderAge, 3), -3)
# 
# 
# ds <- ddply(ds, .(Gender), transform, WeightZGender=scale(WeightPoundsLateTeens))
# # ds$WeightZGender <- pmax(pmin(ds$WeightZGender, 3), -3)
# 
# ds <- ddply(ds, c("Gender", "Age"), transform, WeightZGenderAge=scale(WeightPoundsLateTeens))
# # ds$WeightZGenderYob <- pmax(pmin(ds$WeightZGenderYob, 3), -3)
# 
# ds$BmiLateTeens <- 703 * ds$WeightPoundsLateTeens / (ds$HeightInchesLateTeens*ds$HeightInchesLateTeens)
# 
# dsGen1Fertility <- read.csv(pathInputFertility, stringsAsFactors=F)
# dsGen1Fertility$SubjectTag <- dsGen1Fertility$ID * 100
# dsGen1Fertility$Afi <- as.numeric(ifelse(dsGen1Fertility$Afi==".", NA, dsGen1Fertility$Afi))
# dsGen1Fertility$Afm <- as.numeric(ifelse(dsGen1Fertility$Afm==".", NA, dsGen1Fertility$Afm))
# dsGen1Fertility <- dsGen1Fertility[, -c(1, 2,3)]
# # summary(dsGen1Fertility)
# ds <- ds[, !(colnames(ds) %in% variablesToDropEventually)]
# ds <- merge(x=ds, y=dsGen1Fertility, by="SubjectTag")
# 
# HistogramWithCurve <- function( scores, title="", breaks=30) {
#   hist(scores, breaks=breaks, freq=F, main=title)
#   curve(dnorm(x, mean=mean(scores, na.rm=T),  sd=sd(scores, na.rm=T)), add=T)  
# }
# par(mar=c(2,2,2,0), mgp=c(1,0,0), tcl=0)
# 
# HistogramWithCurve(ds$HeightZGenderAge, "HeightZGenderAge")
# HistogramWithCurve(ds$HeightZGender, "HeightZGender")
# HistogramWithCurve(ds$WeightZGenderAge, "WeightZGenderAge")
# HistogramWithCurve(ds$WeightZGender, "WeightZGender")
# HistogramWithCurve(ds$AfqtRescaled2006Bounded, "AfqtRescaled2006Bounded")
# HistogramWithCurve(ds$AfqtRescaled2006Gaussified, "AfqtRescaled2006Gaussified")
# HistogramWithCurve(ds$Afi, "Afi", breaks=20)
# HistogramWithCurve(ds$Afm, "Afm", breaks=20)
# 
# write.csv(ds, pathOutput, row.names=F)
# 

