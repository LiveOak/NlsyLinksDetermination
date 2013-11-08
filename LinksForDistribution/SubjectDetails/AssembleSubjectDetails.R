rm(list=ls(all=TRUE))
require(RODBC)

channel <- RODBC::odbcDriverConnect("driver={SQL Server}; Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")
dsSubjectDetails79 <- sqlQuery(channel, "SELECT * FROM NlsLinks.dbo.vewSubjectDetails79")
algorithmVersion <- max(sqlQuery(channel, "SELECT MAX(AlgorithmVersion) as AlgorithmVersion  FROM [NlsLinks].[Process].[tblRelatedValuesArchive]"))
odbcClose(channel)

fileName <- sprintf("./LinksForDistribution/SubjectDetails/SubjectDetailsV%d.csv", algorithmVersion)

write.csv(dsSubjectDetails79, file=fileName, row.names=FALSE)
summary(dsSubjectDetails79)
