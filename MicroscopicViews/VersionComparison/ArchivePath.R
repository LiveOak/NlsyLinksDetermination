rm(list=ls(all=TRUE))
library(RODBC)
library(ggplot2)
library(plyr)
library(colorspace)
# includedRelationshipPaths <- c(2)
includedRelationshipPaths <- c(1)
archivePath <- "./MicroscopicViews/CrosstabHistoryArchive.csv"

dsArchive <- read.csv(archivePath)
# dsArchive <- dsArchive[, -3] #Drop RImplicit2004 column
dsArchive$RFull <- NA_real_


deviceWidth <-4.4 #20 #10 #6.5
# if( names(dev.cur()) != "null device" ) dev.off()
# aspectRatio <- 1
# deviceHeight <- 3.99 #deviceWidth * aspectRatio
# windows(width=deviceWidth, height=deviceHeight)

startTime <- Sys.time()
sql <- "SELECT     Process.tblRelatedStructure.RelationshipPath, Process.tblRelatedValuesArchive.RImplicit, Process.tblRelatedValuesArchive.RExplicit, 
                      Process.tblRelatedValuesArchive.RRoster, Process.tblRelatedValuesArchive.AlgorithmVersion, 
                      COUNT(Process.tblRelatedValuesArchive.ID) AS Count, Process.tblRelatedValuesArchive.RImplicit2004, Process.tblRelatedValuesArchive.RFull
FROM         Process.tblRelatedValuesArchive INNER JOIN
                      Process.tblRelatedStructure ON Process.tblRelatedValuesArchive.SubjectTag_S1 = Process.tblRelatedStructure.SubjectTag_S1 AND 
                      Process.tblRelatedValuesArchive.SubjectTag_S2 = Process.tblRelatedStructure.SubjectTag_S2
GROUP BY Process.tblRelatedStructure.RelationshipPath, Process.tblRelatedValuesArchive.RImplicit, Process.tblRelatedValuesArchive.RExplicit, 
                      Process.tblRelatedValuesArchive.RRoster, Process.tblRelatedValuesArchive.AlgorithmVersion, Process.tblRelatedValuesArchive.RImplicit2004, 
                      Process.tblRelatedValuesArchive.RFull"

# sql <- "SELECT     Process.tblRelatedValuesArchive.ID, Process.tblRelatedValuesArchive.AlgorithmVersion, Process.tblRelatedStructure.RelationshipPath, Process.tblRelatedValuesArchive.SubjectTag_S1, 
#                       Process.tblRelatedValuesArchive.SubjectTag_S2, Process.tblRelatedValuesArchive.MultipleBirth, Process.tblRelatedValuesArchive.IsMz, 
#                       Process.tblRelatedValuesArchive.Subject1LastSurvey, Process.tblRelatedValuesArchive.Subject2LastSurvey, Process.tblRelatedValuesArchive.RImplicitPass1, 
#                       Process.tblRelatedValuesArchive.RImplicit, Process.tblRelatedValuesArchive.RImplicitSubject, Process.tblRelatedValuesArchive.RImplicitMother, 
#                       Process.tblRelatedValuesArchive.RImplicit2004, Process.tblRelatedValuesArchive.RExplicitOldestSibVersion, 
#                       Process.tblRelatedValuesArchive.RExplicitYoungestSibVersion, Process.tblRelatedValuesArchive.RExplicitPass1, Process.tblRelatedValuesArchive.RExplicit, 
#                       Process.tblRelatedValuesArchive.RPass1, Process.tblRelatedValuesArchive.R, Process.tblRelatedValuesArchive.RPeek                  
# FROM         Process.tblRelatedValuesArchive INNER JOIN
#                       Process.tblRelatedStructure ON Process.tblRelatedValuesArchive.SubjectTag_S1 = Process.tblRelatedStructure.SubjectTag_S1 AND 
#                       Process.tblRelatedValuesArchive.SubjectTag_S2 = Process.tblRelatedStructure.SubjectTag_S2"
channel <- RODBC::odbcDriverConnect("driver={SQL Server};Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")
odbcGetInfo(channel)
dsRaw <- sqlQuery(channel, sql, stringsAsFactors=F)
odbcCloseAll()
# colnames(dsRaw) # head(dsRaw)
# colnames(dsArchive)
# table(dsRaw$AlgorithmVersion)
# table(dsClean$AlgorithmVersion)
dsRaw <- plyr::rbind.fill(dsRaw, dsArchive)
dsClean <- dsRaw[dsRaw$RelationshipPath %in% includedRelationshipPaths, ]

versionNumbers <- sort(unique(dsClean$AlgorithmVersion))
columnsToConsider <- c("RImplicit", "RExplicit", "RRoster", "RImplicit2004", "RFull", "Count")
dsRocExplicitImplicit <- data.frame(Version=versionNumbers, Good=NA_integer_, Bad=NA_integer_)
dsRocExplicitRoster <- data.frame(Version=versionNumbers, Good=NA_integer_, Bad=NA_integer_)
dsRocImplicitRoster <- data.frame(Version=versionNumbers, Good=NA_integer_, Bad=NA_integer_)
dsRocImplicit2004RFull <- data.frame(Version=versionNumbers, Good=NA_integer_, Bad=NA_integer_)
# dsProportionLinked <- data.frame(Version=versionNumbers, Total=NA_integer_, WithHeight=NA_integer_)

# dsOutcomes <- read.csv(file="./ForDistribution/Outcomes/ExtraOutcomes79.csv", stringsAsFactors=F)

for( versionNumber in versionNumbers ) {
  dsSliceRaw <- dsRaw[dsClean$AlgorithmVersion==versionNumber, columnsToConsider]  
  dsSliceClean <- dsClean[dsClean$AlgorithmVersion==versionNumber, columnsToConsider]  
  
  goodSumExplicitImplicit <- sum(dsSliceClean[dsSliceClean$RImplicit==dsSliceClean$RExplicit, "Count"], na.rm=T)
  badSumExplicitImplicit <- sum(dsSliceClean[abs(dsSliceClean$RImplicit - dsSliceClean$RExplicit) >= .25, "Count"], na.rm=T)
  dsRocExplicitImplicit[dsRocExplicitImplicit$Version==versionNumber, c("Good", "Bad")] <- c(goodSumExplicitImplicit, badSumExplicitImplicit)
  
  goodSumExplicitRoster <- sum(dsSliceClean[dsSliceClean$RRoster==dsSliceClean$RExplicit, "Count"], na.rm=T)
  badSumExplicitRoster <- sum(dsSliceClean[abs(dsSliceClean$RRoster - dsSliceClean$RExplicit) >= .25, "Count"], na.rm=T)
  dsRocExplicitRoster[dsRocExplicitRoster$Version==versionNumber, c("Good", "Bad")] <- c(goodSumExplicitRoster, badSumExplicitRoster)  
  
  goodSumImplicitRoster <- sum(dsSliceClean[dsSliceClean$RRoster==dsSliceClean$RImplicit, "Count"], na.rm=T)
  badSumImplicitRoster <- sum(dsSliceClean[abs(dsSliceClean$RRoster - dsSliceClean$RImplicit) >= .25, "Count"], na.rm=T)
  dsRocImplicitRoster[dsRocImplicitRoster$Version==versionNumber, c("Good", "Bad")] <- c(goodSumImplicitRoster, badSumImplicitRoster)
  
  goodSumImplicit2004RFull <- sum(dsSliceClean[dsSliceClean$RImplicit2004 ==dsSliceClean$RFull, "Count"], na.rm=T)
  badSumImplicit2004RFull <- sum(dsSliceClean[abs(dsSliceClean$RImplicit2004 - dsSliceClean$RFull) >= .25, "Count"], na.rm=T)
  dsRocImplicit2004RFull[dsRocImplicit2004RFull$Version==versionNumber, c("Good", "Bad")] <- c(goodSumImplicit2004RFull, badSumImplicit2004RFull)
}


reportTheme <- theme_bw() +
  theme(axis.text = element_text(colour="gray40")) +
  theme(axis.title = element_text(colour="gray40")) +
  theme(panel.border = element_rect(colour="gray80")) +
  theme(axis.ticks = element_line(colour="gray80")) + 
  theme(axis.ticks = element_blank()) +
  theme(legend.position = "none") 

#dsRoc$ColorVersion <- sequential_hcl(n=length(versionNumbers))
#colorVersion <- factor(sequential_hcl(n=lengWth(versionNumbers)))
#names(colorVersion) <- versionNumbers
desiredLabels <- sort(unique(c(69, 74, 82, range(versionNumbers), seq(from=0, to=max(versionNumbers), by=5))))
dsRocExplicitImplicitForLabels <- dsRocExplicitImplicit[dsRocExplicitImplicit$Version %in% desiredLabels, ]
dsRocExplicitImplicitForPoints <- dsRocExplicitImplicit[!(dsRocExplicitImplicit$Version %in% desiredLabels), ]

colorVersion <- sequential_hcl(n=length(versionNumbers), c=c(130,40), l=c(130,30))

g1 <- ggplot(dsRocExplicitImplicit, aes(y=Good, x=Bad, label=Version, color=Version)) +
  geom_path() +
  geom_point(shape=21, size=3, alpha=.7) +
  geom_text() +
  scale_colour_gradientn(colours=colorVersion) +#, color=ColorVersion)
  scale_x_continuous() +#   scale_x_continuous(name="") +
  scale_y_continuous(labels=scales::comma) +
  labs(x="Pairs in Disagreement (Implicit vs Explicit)", y="Pairs in Agreement") +
  reportTheme
  # coord_cartesian(xlim=c(0, 8000), ylim=c(0, 8000)) + #coord_equal()
# g1
# ggsave(filename="./MicroscopicViews/VersionComparison/RocExplicitVsImplicit.png", plot=g1)

g2 <- g1 %+% dsRocExplicitRoster + 
  labs(x="Pairs in Disagreement (Roster vs Explicit)")
ggsave(filename="./MicroscopicViews/VersionComparison/RocRosterVsExplicit.png", plot=g2)

g3 <- g1 %+% dsRocImplicitRoster + 
  labs(x="Pairs in Disagreement (Roster vs Implicit)")
ggsave(filename="./MicroscopicViews/VersionComparison/RocRosterVsImplicit.png", plot=g3)

g4 <- g1 %+% dsRocImplicit2004RFull + 
  labs(x="Pairs in Disagreement (RFull vs Implicit2004)") + 
  coord_cartesian(xlim=c(0, 9000), ylim=c(0, 9000))
ggsave(filename="./MicroscopicViews/VersionComparison/RocRFullVsImplicit2004.png", plot=g4)


g1Publish <- ggplot(dsRocExplicitImplicit, aes(y=Good, x=Bad, label=Version, color=Version)) +
  geom_path() +
  geom_point(data=dsRocExplicitImplicitForPoints, shape=21, size=3, alpha=.7) +
  geom_text(data=dsRocExplicitImplicitForLabels) +
  # geom_text() +
  scale_colour_gradientn(colours=colorVersion) +#, color=ColorVersion)
  scale_x_continuous() +#   scale_x_continuous(name="") +
  scale_y_continuous(labels=scales::comma) +
  labs(x="Pairs in Disagreement (Implicit vs Explicit)", y="Pairs in Agreement") +
  reportTheme

# g1Publish
ggsave(filename="./MicroscopicViews/VersionComparison/RocExplicitVsImplicit.png", plot=g1Publish)
(elapsed <- Sys.time() - startTime)
