rm(list=ls(all=TRUE))
require(RODBC)
require(scales)
require(ggplot2)
require(plyr)
require(colorspace)
includedRelationshipPaths <- c(2)
# includedRelationshipPaths <- c(1)

# dsArchive <- read.csv("./MicroscopicViews/CrosstabHistoryArchive.csv")
# # dsArchive <- dsArchive[, -3] #Drop RImplicit2004 column
# dsArchive$RFull <- NA_real_

oName <- "HeightZGenderAge"
oName_1 <- paste0(oName, "_1")
oName_2 <- paste0(oName, "_2")

startTime <- Sys.time()
sql <- "SELECT  [AlgorithmVersion],[Subject1Tag],[Subject2Tag],[RFull]FROM [NlsLinks].[Process].[tblRelatedValuesArchive]"
channel <- RODBC::odbcDriverConnect("driver={SQL Server};Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")
odbcGetInfo(channel)
ds <- sqlQuery(channel, sql, stringsAsFactors=F)
odbcCloseAll()
# colnames(dsRaw) # head(dsRaw)
# colnames(dsArchive)
# ds <- plyr::rbind.fill(ds, dsArchive)

versionNumbers <- sort(unique(ds$AlgorithmVersion))
dsProportionLinked <- data.frame(Version=versionNumbers, OfTotal=NA_integer_, OfDV=NA_integer_)

dsOutcomes <- read.csv(file="./LinksForDistribution/Outcomes/ExtraOutcomes79.csv", stringsAsFactors=F)

for( versionNumber in versionNumbers ) {
  dsSlice <- ds[ds$AlgorithmVersion==versionNumber, ]  
  dsSlice$R <- dsSlice$RFull
  dsLink <- CreatePairLinksSingleEntered(outcomeDataset=dsOutcomes, linksPairDataset=dsSlice, linksNames="RFull", outcomeNames=oName)
  ofTotal <- mean(!is.na(dsLink$RFull)) 
  ofDV <- mean(!is.na(dsLink[!is.na(dsLink[, oName_1]) & !is.na(dsLink[, oName_2]), "RFull"])) 
  
  dsProportionLinked[dsProportionLinked$Version==versionNumber, c("OfTotal", "OfDV")] <- c(ofTotal, ofDV)
}
(elapsed <- Sys.time() - startTime)

g <- ggplot(dsProportionLinked, aes(x=Version)) +
  geom_line(aes(y=OfDV),  color="blue") +
  geom_line(aes(y=OfTotal), color="black") +
  scale_y_continuous(name="Percent Linked", labels=percent) +
#   xlab("Disagreement (Implicit vs Explicit)") +
  coord_cartesian(ylim=c(.85, 1)) + 
  theme_bw() + theme(legend.position = "none") 
g
ggsave(filename="./MicroscopicViews/VersionComparison/ProportionLinked.png", plot=g)
