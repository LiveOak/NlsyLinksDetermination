rm(list=ls(all=TRUE))
require(RODBC)
require(ggplot2)
require(colorspace)
includedRelationshipPaths <- c(2)
# includedRelationshipPaths <- c(1)
archivePath <- "F:/Projects/Nls/NlsyLinksDetermination/MicroscopicViews/CrosstabHistoryArchive.csv"

dsArchive <- read.csv(archivePath)
dsArchive <- dsArchive[, -3] #Drop RImplicit2004 column


deviceWidth <-4.4 #20 #10 #6.5
# if( names(dev.cur()) != "null device" ) dev.off()
# aspectRatio <- 1
# deviceHeight <- 3.99 #deviceWidth * aspectRatio
# windows(width=deviceWidth, height=deviceHeight)

startTime <- Sys.time()
sql <- "SELECT     Process.tblRelatedStructure.RelationshipPath, Process.tblRelatedValuesArchive.RImplicit, Process.tblRelatedValuesArchive.RExplicit, 
                      Process.tblRelatedValuesArchive.AlgorithmVersion, COUNT(Process.tblRelatedValuesArchive.ID) AS Count
FROM         Process.tblRelatedValuesArchive INNER JOIN
                      Process.tblRelatedStructure ON Process.tblRelatedValuesArchive.Subject1Tag = Process.tblRelatedStructure.Subject1Tag AND 
                      Process.tblRelatedValuesArchive.Subject2Tag = Process.tblRelatedStructure.Subject2Tag
GROUP BY Process.tblRelatedStructure.RelationshipPath, Process.tblRelatedValuesArchive.RImplicit, Process.tblRelatedValuesArchive.RExplicit, 
                      Process.tblRelatedValuesArchive.AlgorithmVersion"

# sql <- "SELECT     Process.tblRelatedValuesArchive.ID, Process.tblRelatedValuesArchive.AlgorithmVersion, Process.tblRelatedStructure.RelationshipPath, Process.tblRelatedValuesArchive.Subject1Tag, 
#                       Process.tblRelatedValuesArchive.Subject2Tag, Process.tblRelatedValuesArchive.MultipleBirth, Process.tblRelatedValuesArchive.IsMz, 
#                       Process.tblRelatedValuesArchive.Subject1LastSurvey, Process.tblRelatedValuesArchive.Subject2LastSurvey, Process.tblRelatedValuesArchive.RImplicitPass1, 
#                       Process.tblRelatedValuesArchive.RImplicit, Process.tblRelatedValuesArchive.RImplicitSubject, Process.tblRelatedValuesArchive.RImplicitMother, 
#                       Process.tblRelatedValuesArchive.RImplicit2004, Process.tblRelatedValuesArchive.RExplicitOldestSibVersion, 
#                       Process.tblRelatedValuesArchive.RExplicitYoungestSibVersion, Process.tblRelatedValuesArchive.RExplicitPass1, Process.tblRelatedValuesArchive.RExplicit, 
#                       Process.tblRelatedValuesArchive.RPass1, Process.tblRelatedValuesArchive.R, Process.tblRelatedValuesArchive.RPeek                  
# FROM         Process.tblRelatedValuesArchive INNER JOIN
#                       Process.tblRelatedStructure ON Process.tblRelatedValuesArchive.Subject1Tag = Process.tblRelatedStructure.Subject1Tag AND 
#                       Process.tblRelatedValuesArchive.Subject2Tag = Process.tblRelatedStructure.Subject2Tag"
channel <- odbcConnect(dsn="BeeNlsLinks")
odbcGetInfo(channel)
dsRaw <- sqlQuery(channel, sql, stringsAsFactors=F)
odbcCloseAll()
dsRaw <- rbind(dsRaw, dsArchive)
dsRaw <- dsRaw[dsRaw$RelationshipPath %in% includedRelationshipPaths, ]



versionNumbers <- sort(unique(dsRaw$AlgorithmVersion))
columnsToConsider <- c("RImplicit", "RExplicit", "Count")
dsRoc <- data.frame(Version=versionNumbers, Good=NA_integer_, Bad=NA_integer_)

for( versionNumber in versionNumbers ) {
  dsSlice <- dsRaw[dsRaw$AlgorithmVersion==versionNumber, columnsToConsider]  
  
  goodSum <- sum(dsSlice[dsSlice$RImplicit==dsSlice$RExplicit, "Count"], na.rm=T)#goodSum <- sum(dsSlice$RImplicit==dsSlice$RExplicit, na.rm=T)
  badSum <- sum(dsSlice[abs(dsSlice$RImplicit - dsSlice$RExplicit) >= .25, "Count"], na.rm=T)
  dsRoc[dsRoc$Version==versionNumber, c("Good", "Bad")] <- c(goodSum, badSum)
}



#dsRoc$ColorVersion <- sequential_hcl(n=length(versionNumbers))
#colorVersion <- factor(sequential_hcl(n=lengWth(versionNumbers)))
#names(colorVersion) <- versionNumbers
colorVersion <- (sequential_hcl(n=length(versionNumbers), c=c(80, 80), l = c(90, 30)))
g <- ggplot(dsRoc, aes(y=Good, x=Bad, label=Version, color=Version)) +
  scale_colour_gradientn(colours=colorVersion) +#, color=ColorVersion)
  scale_x_continuous(name="Disagreement (Implicit vs Explicit)") +#   scale_x_continuous(name="") +
  scale_y_continuous(name="Agreement") +
  layer(geom="path") + layer(geom="text") +
  #coord_cartesian(xlim=c(0, 8000), ylim=c(0, 8000)) + #coord_equal() +
  theme(legend.position = "none") 
print(g)
(elapsed <- Sys.time() - startTime)