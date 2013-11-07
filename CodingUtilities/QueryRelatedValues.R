rm(list=ls(all=TRUE))
require(RODBC)

channel <- RODBC::odbcDriverConnect("driver={SQL Server}; Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")
ds <- sqlQuery(channel, "SELECT * FROM dbo.vewRelatedValues ORDER BY ExtendedID, Subject1Tag, Subject2Tag")
odbcClose(channel)

isGen1Subject1 <- grepl("^\\d{1,7}00$", ds$Subject1Tag, perl=TRUE);
isGen1Subject2 <- grepl("^\\d{1,7}00$", ds$Subject2Tag, perl=TRUE);

ds$GenerationSubject1 <- ifelse(isGen1Subject1, 1L, 2L)
ds$GenerationSubject2 <- ifelse(isGen1Subject2, 1L, 2L)

ds$Subject1ID <- ifelse(isGen1Subject1, ds$Subject1Tag / 100, ds$Subject1Tag)
ds$Subject2ID <- ifelse(isGen1Subject2, ds$Subject2Tag / 100, ds$Subject2Tag)

if( any((ds$Subject1ID %% 1) != 0) ) stop("A Gen2 subject was accidentally classified as Gen1.")
if( any((ds$Subject2ID %% 1) != 0) ) stop("A Gen2 subject was accidentally classified as Gen1.")

ds$Subject1ID <- as.integer(ds$Subject1ID)
ds$Subject2ID <- as.integer(ds$Subject2ID)

write.csv(ds, "./Links2011V83.csv", row.names=FALSE)
summary(ds)

# table(ds$RelationshipPath, is.na(ds$RFull))
