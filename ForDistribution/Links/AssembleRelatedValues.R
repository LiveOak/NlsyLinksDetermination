rm(list=ls(all=TRUE))
require(RODBC)
require(plyr)

channel <- RODBC::odbcDriverConnect("driver={SQL Server}; Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")
ds <- sqlQuery(channel, "SELECT * FROM dbo.vewRelatedValues ORDER BY ExtendedID, SubjectTag_S1, SubjectTag_S2")
algorithmVersion <- max(sqlQuery(channel, "SELECT MAX(AlgorithmVersion) as AlgorithmVersion  FROM [NlsLinks].[Process].[tblRelatedValuesArchive]"))
odbcClose(channel)

isGen1_S1 <- grepl("^\\d{1,7}00$", ds$SubjectTag_S1, perl=TRUE);
isGen1_S2 <- grepl("^\\d{1,7}00$", ds$SubjectTag_S2, perl=TRUE);

ds$Generation_S1 <- ifelse(isGen1_S1, 1L, 2L)
ds$Generation_S2 <- ifelse(isGen1_S2, 1L, 2L)

ds$SubjectID_S1 <- ifelse(isGen1_S1, ds$SubjectTag_S1 / 100, ds$SubjectTag_S1)
ds$SubjectID_S2 <- ifelse(isGen1_S2, ds$SubjectTag_S2 / 100, ds$SubjectTag_S2)

if( any((ds$SubjectID_S1 %% 1) != 0) ) stop("A Gen2 subject was accidentally classified as Gen1.")
if( any((ds$SubjectID_S2 %% 1) != 0) ) stop("A Gen2 subject was accidentally classified as Gen1.")

ds$SubjectID_S1 <- as.integer(ds$SubjectID_S1)
ds$SubjectID_S2 <- as.integer(ds$SubjectID_S2)


fileName <- sprintf("./ForDistribution/Links/Links2011V%d.csv", algorithmVersion)

plyr::count(ds, vars=c("RelationshipPath", "R"))

write.csv(ds, file=fileName, row.names=FALSE)
summary(ds)

# table(ds$RelationshipPath, is.na(ds$RFull))
