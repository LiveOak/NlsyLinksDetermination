# require(RODBC)
require(plyr)
# require(lubridate)
rm(list=ls(all=TRUE))

pathInputGen1 <- "./LinksForDistribution/Outcomes/OutcomesGen1.csv"
pathInputGen2 <- "./LinksForDistribution/Outcomes/OutcomesGen2.csv"
pathOutput <- "./LinksForDistribution/Outcomes/ExtraOutcomes79.csv"

dsGen1 <- read.csv(pathInputGen1, stringsAsFactors=FALSE)
dsGen2 <- read.csv(pathInputGen2, stringsAsFactors=FALSE)

ds <- rbind.fill(dsGen1, dsGen2)

length(ds$HeightZGenderAge)

write.csv(ds, pathOutput, row.names=F)
