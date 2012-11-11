require(RODBC)
require(plyr)
require(lubridate)
rm(list=ls(all=TRUE))

generation <- 2
pathInputHeight <- file.path(getwd(), "LinksForDistribution/Outcomes/Gen2Height/Gen2Height.csv")
pathInputMath <- file.path(getwd(), "OutsideData/KellyHeightWeightMath2012-03-09/ExtraOutcomes79FromKelly2012March.csv")
pathOutput <- file.path(getwd(), "LinksForDistribution/Outcomes/OutcomesGen2.csv")

odbcCloseAll()
channel <- odbcConnect(dsn="BeeNlsLinks")
odbcGetInfo(channel)
keepExistingTable <- FALSE
ds <- sqlQuery(channel, paste0("SELECT * FROM dbo.vewOutcomes WHERE Generation=", generation))
odbcClose(channel)
variablesToDropEventually <- c("ExtendedID", "Gender", "Mob", "Yob", "Age", "HeightInchesLateTeens", "WeightPoundsLateTeens", "AfqtRescaled2006", "BmiLateTeens")
ds <- ds[, !(colnames(ds) %in% variablesToDropEventually)]


### Merge Height
dsHeight <- read.csv(pathInputHeight, stringsAsFactors=F)
dsHeight <- dsHeight[, c("SubjectTag", "HeightZGender","HeightZGenderAge")]
ds <- merge(x=ds, y=dsHeight, by="SubjectTag", all.x=TRUE)
rm(dsHeight)

### Merge Math
dsMath <- read.csv(pathInputMath, stringsAsFactors=F)
dsMath <- dsMath[, c("SubjectTag", "MathStandardized")]
ds <- merge(x=ds, y=dsMath, by="SubjectTag", all.x=TRUE)
rm(dsMath)



HistogramWithCurve <- function( scores, title="", breaks=30) {
  hist(scores, breaks=breaks, freq=F, main=title)
  curve(dnorm(x, mean=mean(scores, na.rm=T),  sd=sd(scores, na.rm=T)), add=T)  
}
par(mar=c(2,2,2,0), mgp=c(1,0,0), tcl=0)

HistogramWithCurve(ds$HeightZGenderAge, "HeightZGenderAge")
HistogramWithCurve(ds$HeightZGender, "HeightZGender")
HistogramWithCurve(ds$MathStandardized, "MathStandardized")

write.csv(ds, pathOutput, row.names=F)


