require(RODBC)
rm(list=ls(all=TRUE))

path <- "./DBFiles/BackupOfNonSubjectData"

# channel <- odbcConnect("BeeNlsLinks", uid="NlsyReadWrite", pwd="nophi")
channel <- RODBC::odbcDriverConnect("driver={SQL Server};Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")

dsItem <- sqlQuery(channel, paste("SELECT * FROM Process.tblItem", sep=""))
dsLUExtractSource <- sqlQuery(channel, paste("SELECT * FROM Process.tblLUExtractSource", sep=""))
dsLUMarkerEvidence <- sqlQuery(channel, paste("SELECT * FROM Process.tblLUMarkerEvidence", sep=""))
dsLUMarkerType <- sqlQuery(channel, paste("SELECT * FROM Process.tblLUMarkerType", sep=""))
dsLURelationshipPath <- sqlQuery(channel, paste("SELECT * FROM Process.tblLURelationshipPath", sep=""))
dsLUSurveySource <- sqlQuery(channel, paste("SELECT * FROM Process.tblLUSurveySource", sep=""))
dsVariable <- sqlQuery(channel, paste("SELECT * FROM Process.tblVariable", sep=""))
dsMz <- sqlQuery(channel, paste("SELECT * FROM Process.tblMzManual", sep=""))
dsRArchive <- sqlQuery(channel, paste("SELECT * FROM Process.tblRelatedValuesArchive", sep=""))

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
