rm(list=ls(all=TRUE))
# library(RODBC)
library(plyr)
# library(xtable)
library(ggplot2)
# includedRelationshipPaths <- c(2)
# includedRelationshipPaths <- c(1)
includedRelationshipPaths <- c(1, 2)

# # sql <- paste("SELECT Process.tblRelatedValuesArchive.ID, Process.tblRelatedValuesArchive.AlgorithmVersion, Process.tblRelatedStructure.RelationshipPath, Process.tblRelatedValuesArchive.Subject1Tag, Process.tblRelatedValuesArchive.Subject2Tag, Process.tblRelatedValuesArchive.MultipleBirthIfSameSex, Process.tblRelatedValuesArchive.IsMz, Process.tblRelatedValuesArchive.Subject1LastSurvey, Process.tblRelatedValuesArchive.Subject2LastSurvey, Process.tblRelatedValuesArchive.RRoster, Process.tblRelatedValuesArchive.RImplicitPass1, Process.tblRelatedValuesArchive.RImplicit, Process.tblRelatedValuesArchive.RImplicit2004, Process.tblRelatedValuesArchive.RExplicitOldestSibVersion, Process.tblRelatedValuesArchive.RExplicitYoungestSibVersion, Process.tblRelatedValuesArchive.RExplicitPass1, Process.tblRelatedValuesArchive.RExplicit, Process.tblRelatedValuesArchive.RPass1, Process.tblRelatedValuesArchive.R 
# #   FROM Process.tblRelatedValuesArchive INNER JOIN Process.tblRelatedStructure ON Process.tblRelatedValuesArchive.Subject1Tag = Process.tblRelatedStructure.Subject1Tag AND Process.tblRelatedValuesArchive.Subject2Tag = Process.tblRelatedStructure.Subject2Tag 
# #     WHERE Process.tblRelatedStructure.RelationshipPath IN (", paste0(includedRelationshipPaths, collapse=","), ") 
# #       AND (Process.tblRelatedValuesArchive.AlgorithmVersion IN (SELECT TOP (2) AlgorithmVersion FROM Process.tblRelatedValuesArchive AS tblRelatedValuesArchive_1 
# #     GROUP BY AlgorithmVersion ORDER BY AlgorithmVersion DESC))")
# 
# sql <- paste("SELECT Process.tblRelatedValuesArchive.ID, Process.tblRelatedValuesArchive.AlgorithmVersion, Process.tblRelatedStructure.RelationshipPath, Process.tblRelatedValuesArchive.Subject1Tag, Process.tblRelatedValuesArchive.Subject2Tag, Process.tblRelatedValuesArchive.MultipleBirthIfSameSex, Process.tblRelatedValuesArchive.IsMz, Process.tblRelatedValuesArchive.Subject1LastSurvey, Process.tblRelatedValuesArchive.Subject2LastSurvey, Process.tblRelatedValuesArchive.RRoster, Process.tblRelatedValuesArchive.RImplicitPass1, Process.tblRelatedValuesArchive.RImplicit, Process.tblRelatedValuesArchive.RImplicit2004, Process.tblRelatedValuesArchive.RExplicitOldestSibVersion, Process.tblRelatedValuesArchive.RExplicitYoungestSibVersion, Process.tblRelatedValuesArchive.RExplicitPass1, Process.tblRelatedValuesArchive.RExplicit, Process.tblRelatedValuesArchive.RPass1, Process.tblRelatedValuesArchive.R
#   FROM Process.tblRelatedValuesArchive INNER JOIN Process.tblRelatedStructure ON Process.tblRelatedValuesArchive.Subject1Tag = Process.tblRelatedStructure.Subject1Tag AND Process.tblRelatedValuesArchive.Subject2Tag = Process.tblRelatedStructure.Subject2Tag
#   WHERE Process.tblRelatedStructure.RelationshipPath IN (", paste0(includedRelationshipPaths, collapse=","), ") 
#     AND (Process.tblRelatedValuesArchive.AlgorithmVersion IN (51, 50))")
# 
# 
# sql <- gsub(pattern="\\n", replacement=" ", sql)
# sqlDescription <- "SELECT * FROM Process.tblArchiveDescription" #AlgorithmVersion, Description
# 
# startTime <- Sys.time()
# channel <- RODBC::odbcDriverConnect("driver={SQL Server}; Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")
# odbcGetInfo(channel)
# 
# dsRaw <- sqlQuery(channel, sql, stringsAsFactors=F)
# # dsRaw <- head(dsRaw)
# dsDescription <- sqlQuery(channel, sqlDescription, stringsAsFactors=F)
# odbcCloseAll()
# (elapsedTime <- Sys.time() - startTime)
# nrow(dsRaw)
# 
# save(dsRaw, file="E:/Debug/ds.rdata")
load(file="E:/Debug/ds.rdata")



olderVersionNumber <- min(dsRaw$AlgorithmVersion)
# olderDescription <- dsDescription[dsDescription$AlgorithmVersion==olderVersionNumber, 'Description']
newerVersionNumber <- max(dsRaw$AlgorithmVersion)
# newerDescription <- dsDescription[dsDescription$AlgorithmVersion==newerVersionNumber, 'Description']

columnsToConsider <- c("RImplicit2004", "RImplicit", "RExplicit", "RRoster", "RelationshipPath")
# dsLatestGen2Sibs <- dsRaw[dsRaw$AlgorithmVersion==newerVersionNumber & dsRaw$RelationshipPath %in% includedRelationshipPaths, ]
# dsPreviousGen2Sibs <- dsRaw[dsRaw$AlgorithmVersion==olderVersionNumber & dsRaw$RelationshipPath %in% includedRelationshipPaths, ]
dsLatest <- dsRaw[dsRaw$AlgorithmVersion==newerVersionNumber, ]
dsPrevious <- dsRaw[dsRaw$AlgorithmVersion==olderVersionNumber, ]

# head(dsLatest, 30)
# head(dsPrevious, 30)


# dsCollapsedLatest <- ddply(dsLatest, .variables=columnsToConsider, .fun=nrow)
dsCollapsedLatest <- plyr::count(dsLatest, vars=columnsToConsider)
dsCollapsedLatest <- plyr::rename(dsCollapsedLatest, replace=c("freq"="Count"))
dsCollapsedLatest <- dsCollapsedLatest[order(-dsCollapsedLatest$Count),]

dsCollapsedPrevious <- plyr::count(dsPrevious, vars=columnsToConsider)
dsCollapsedPrevious <- plyr::rename(dsCollapsedPrevious, replace=c("freq"="Count"))
dsCollapsedPrevious <- dsCollapsedPrevious[order(-dsCollapsedPrevious$Count), ]

ds <- merge(x=dsCollapsedLatest, y=dsCollapsedPrevious, by=columnsToConsider, all=T)
ds[is.na(ds$Count.x), "Count.x"] <- 0
ds[is.na(ds$Count.y), "Count.y"] <- 0
ds$Delta <- ds$Count.x - ds$Count.y
ds <- ds[ , -which(colnames(ds)=="Count.y")]
colnames(ds)[which(colnames(ds)=="Count.x")] <- "Count"

DetermineGoodRowIDs <- function( dsTable ) {
  return( which(dsTable$RImplicit==dsTable$RExplicit) )
}
# DetermineGoodRowIDs(ds)

DetermineBadRowIDs <- function( dsTable ) {
  return( which(abs(dsTable$RImplicit - dsTable$RExplicit) >= .25) )
}
# DetermineBadRowIDs(ds)

CreateRoc <- function( relationshipPathID ) {
  dsT <- ds[ds$RelationshipPath==relationshipPathID, ]
  idGoodRows <- DetermineGoodRowIDs(dsT)
  idSosoRows <- which((dsT$RImplicit==.375 | is.na(dsT$RImplicit)) & !is.na(dsT$RExplicit))
  idBadRows <- DetermineBadRowIDs(dsT)
  
  goodSumLatest <- sum(dsT[idGoodRows, "Count"])
  badSumLatest <- sum(dsT[idBadRows, "Count"])
  
  goodSumPrevious <- goodSumLatest - sum(dsT[idGoodRows, "Delta"])
  badSumPrevious <- badSumLatest - sum(dsT[idBadRows, "Delta"])
  dsRoc <- data.frame(Version=c(newerVersionNumber, olderVersionNumber), Agree=c(goodSumLatest, goodSumPrevious), Disagree=c(badSumLatest, badSumPrevious))
  write.csv(dsRoc, file="E:/Debug/dsRoc.csv", row.names=FALSE)
  save(file="E:/Debug/dsRoc.rdata", dsRoc)
  load(file="E:/Debug/dsRoc.rdata")
  
  
  rocLag1 <- ggplot(dsRoc, aes(y=Agree, x=Disagree, label=Version)) +
     layer(geom="path") +    layer(geom="text") 
#     # coord_cartesian(xlim=c(0, 8000), ylim=c(0, 8000))#+ #xlim(0, 8000)
  return( rocLag1 )
}
# windows()
CreateRoc(relationshipPathID=2)