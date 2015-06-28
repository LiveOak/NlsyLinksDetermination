library(RODBC)
rm(list=ls(all=TRUE))

path <- "./DBFiles/BackupOfNonSubjectData"

# channel <- odbcConnect("BeeNlsLinks", uid="NlsyReadWrite", pwd="nophi")
channel <- RODBC::odbcDriverConnect("driver={SQL Server}; Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")

dsItem <- sqlQuery(channel, "SELECT * FROM Process.tblItem")
dsLUExtractSource <- sqlQuery(channel, "SELECT * FROM Process.tblLUExtractSource")
dsLUMarkerEvidence <- sqlQuery(channel, "SELECT * FROM Process.tblLUMarkerEvidence")
dsLUMarkerType <- sqlQuery(channel, "SELECT * FROM Process.tblLUMarkerType")
dsLURelationshipPath <- sqlQuery(channel, "SELECT * FROM Process.tblLURelationshipPath")
dsLUSurveySource <- sqlQuery(channel, "SELECT * FROM Process.tblLUSurveySource")
dsVariable <- sqlQuery(channel, "SELECT * FROM Process.tblVariable")
dsMz <- sqlQuery(channel, "SELECT * FROM Process.tblMzManual")
dsRArchive <- sqlQuery(channel, "SELECT * FROM Process.tblRelatedValuesArchive")

odbcClose(channel)

head(dsVariable)
summary(dsVariable)

head(dsItem)
summary(dsItem)

write.csv(dsItem, file=file.path(path, "Item.csv"), row.names=F)
write.csv(dsLUExtractSource, file=file.path(path, "LUExtractSource.csv"), row.names=F)
write.csv(dsLUMarkerEvidence, file=file.path(path, "LUMarkerEvidence.csv"), row.names=F)
write.csv(dsLUMarkerType, file=file.path(path, "LUMarkerType.csv"), row.names=F)
write.csv(dsLURelationshipPath, file=file.path(path, "LURelationshipPath.csv"), row.names=F)
write.csv(dsLUSurveySource, file=file.path(path, "LUSurveySource.csv"), row.names=F)
write.csv(dsVariable, file=file.path(path, "Variable.csv"), row.names=F)
write.csv(dsMz, file=file.path(path, "MzManual.csv"), row.names=F)
write.csv(dsRArchive, file=file.path(path, "RArchive.csv"), row.names=F)
