require(RODBC)
require(plyr)
require(lubridate)
rm(list=ls(all=TRUE))

generation <- 1
pathInputHeight <- "./ForDistribution/Outcomes/Gen1Height/Gen1Height.csv"
pathInputWeight <- "./ForDistribution/Outcomes/Gen1Weight/Gen1Weight.csv"
pathOutput <- "./ForDistribution/Outcomes/OutcomesGen1.csv"

channel <- RODBC::odbcDriverConnect("driver={SQL Server}; Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")
odbcGetInfo(channel)
ds <- sqlQuery(channel, paste0("SELECT SubjectTag FROM Process.tblSubject WHERE Generation=", generation))
odbcClose(channel)


### Merge Height
dsHeight <- read.csv(pathInputHeight, stringsAsFactors=F)
dsHeight <- dsHeight[, c("SubjectTag", "ZGender", "ZGenderAge")]
dsHeight <- plyr::rename(dsHeight, replace=c("ZGender"="HeightZGender", "ZGenderAge"="HeightZGenderAge"))
ds <- merge(x=ds, y=dsHeight, by="SubjectTag", all.x=TRUE)
rm(dsHeight)

### Merge Weight
dsWeight <- read.csv(pathInputWeight, stringsAsFactors=F)
dsWeight <- dsWeight[, c("SubjectTag", "ZGender", "ZGenderAge")]
dsWeight <- plyr::rename(dsWeight, replace=c("ZGender"="WeightZGender", "ZGenderAge"="WeightZGenderAge"))
ds <- merge(x=ds, y=dsWeight, by="SubjectTag", all.x=TRUE)
rm(dsWeight)




HistogramWithCurve <- function( scores, title="", breaks=30) {
  hist(scores, breaks=breaks, freq=F, main=title)
  curve(dnorm(x, mean=mean(scores, na.rm=T),  sd=sd(scores, na.rm=T)), add=T)  
}
par(mar=c(2,2,2,0), mgp=c(1,0,0), tcl=0)

HistogramWithCurve(ds$HeightZGenderAge, "HeightZGenderAge")
HistogramWithCurve(ds$HeightZGender, "HeightZGender")
HistogramWithCurve(ds$HeightZGenderAge, "WeightZGenderAge")
HistogramWithCurve(ds$HeightZGender, "WeightZGender")
# HistogramWithCurve(ds$MathStandardized, "MathStandardized")

write.csv(ds, pathOutput, row.names=F)
