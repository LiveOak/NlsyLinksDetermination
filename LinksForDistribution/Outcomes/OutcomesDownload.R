require(RODBC)
require(plyr)
require(lubridate)
rm(list=ls(all=TRUE))

pathOutput <- "F:/Projects/Nls/Links2011/LinksForDistribution/Outcomes/Outcomes.csv"
pathInputGen1Fertility <- "F:/Projects/Nls/Links2011/OutsideData/AfiAmen2012-09-20/AfiAfm.csv"
# pathPoliticalInput <- "F:/Projects/RDev/NlsyLinksStaging/Datasets/PoliticalData.csv"
# pathAsqtInput <- "F:/Projects/RDev/NlsyLinksStaging/Datasets/Gen1Afqt.csv"

odbcCloseAll()
channel <- odbcConnect(dsn="BeeNlsLinks")
odbcGetInfo(channel)
keepExistingTable <- FALSE
ds <- sqlFetch(channel, sqtable="dbo.vewOutcomes" )
odbcClose(channel)
#Don't forget to make Gen1ID the primary key in the table.

ds$AfqtRescaled2006Gaussified <- qnorm(ds$AfqtRescaled2006) #convert from roughly uniform distribution [0, 100], to something Guassianish.
ds$AfqtRescaled2006Gaussified <- pmax(pmin(ds$AfqtRescaled2006Gaussified, 3), -3) #The scale above had 0s and 100s, so clamp that in at +/-3.
ds$Yob <- year(ds$Mob)

ds <- ddply(ds, c("Gender"), transform, HeightZGender=scale(HeightInchesLateTeens))
ds$HeightZGender <- pmax(pmin(ds$HeightZGender, 3), -3)  

ds <- ddply(ds, c("Gender", "Yob"), transform, HeightZGenderYob=scale(HeightInchesLateTeens))
ds$HeightZGenderYob <- pmax(pmin(ds$HeightZGenderYob, 3), -3)
# ds$HeightZGenderYob <- ifelse(ds$HeightZGenderYob>6, NA,ds$HeightZGenderYob)
# ds$HeightZGenderYob <- ifelse(ds$HeightZGenderYob< -6, NA,ds$HeightZGenderYob)


ds <- ddply(ds, .(Gender), transform, WeightZGender=scale(WeightPoundsLateTeens))
# ds$WeightZGender <- pmax(pmin(ds$WeightZGender, 3), -3)

ds <- ddply(ds, c("Gender", "Yob"), transform, WeightZGenderYob=scale(WeightPoundsLateTeens))
# ds$WeightZGenderYob <- pmax(pmin(ds$WeightZGenderYob, 3), -3)

ds$BmiLateTeens <- 703 * ds$WeightPoundsLateTeens / (ds$HeightInchesLateTeens*ds$HeightInchesLateTeens)

# dsPolitical <- read.csv(pathPoliticalInput, stringsAsFactors=F)
# summary(dsPolitical)
# # table(dsPolitical$Intell)
# dsPolitical$Intell <- ifelse(dsPolitical$Intell==".", NA, dsPolitical$Intell)
# dsPolitical$IQ <- as.numeric(dsPolitical$Intell)
# dsPolitical$SubjectTag <- dsPolitical$ID * 100
# dsPolitical <- dsPolitical[, c("SubjectTag", "IQ")]
# dsPolitical$IQLog <- log(dsPolitical$IQ)
# 
# dsPolitical$IQGuassified <- qnorm(dsPolitical$IQ/100) #convert from roughly uniform distribution [0, 100], to something Guassianish.
# dsPolitical$IQGuassified <- pmax(pmin(dsPolitical$IQGuassified, 3.3), -3.3) #The scale above had 0s and 100s, so clamp that in at +/-3.3.
# # dsPolitical$IQGuassified <- as.numeric(scale(dsPolitical$IQGuassified))
# # dsPolitical$IQGuassified <- scale(dsPolitical$IQGuassified, center=FALSE,scale=apply(x,2,sd,na.rm=TRUE))

dsGen1Fertility <- read.csv(pathInputGen1Fertility, stringsAsFactors=F)
dsGen1Fertility$SubjectTag <- dsGen1Fertility$ID * 100
dsGen1Fertility$Afi <- as.numeric(ifelse(dsGen1Fertility$Afi==".", NA, dsGen1Fertility$Afi))
dsGen1Fertility$Afm <- as.numeric(ifelse(dsGen1Fertility$Afm==".", NA, dsGen1Fertility$Afm))
dsGen1Fertility <- dsGen1Fertility[, -c(1, 2,3)]
# summary(dsGen1Fertility)
ds <- merge(x=ds, y=dsGen1Fertility, by="SubjectTag")

HistogramWithCurve <- function( scores, title="", breaks=30) {
  hist(scores, breaks=breaks, freq=F, main=title)
  curve(dnorm(x, mean=mean(scores, na.rm=T),  sd=sd(scores, na.rm=T)), add=T)
  
}
par(mar=c(2,2,2,0), mgp=c(1,0,0), tcl=0)
HistogramWithCurve(ds$HeightZGenderYob, "HeightZGenderYob")


HistogramWithCurve(ds$HeightZGender, "HeightZGender")
HistogramWithCurve(ds$WeightZGenderYob, "WeightZGenderYob")
HistogramWithCurve(ds$WeightZGender, "WeightZGender")
HistogramWithCurve(ds$HeightZGender, "HeightZGender")
HistogramWithCurve(ds$AfqtRescaled2006Gaussified, "AfqtRescaled2006Gaussified")
HistogramWithCurve(ds$Afi, "Afi", breaks=20)
HistogramWithCurve(ds$Afm, "Afm", breaks=20)

write.csv(ds, pathOutput, row.names=F)


