require(RODBC)
rm(list=ls(all=TRUE))

channel <- RODBC::odbcDriverConnect("driver={SQL Server};Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")
ds <- sqlQuery(channel, paste("SELECT * FROM dbo.vewRelatedValues", sep=""))
odbcClose(channel)


isGen1Subject1 <- grepl("\\d{1,}00\\b", ds$Subject1Tag, perl=TRUE);
isGen1Subject2 <- grepl("\\d{1,}00\\b", ds$Subject2Tag, perl=TRUE);

ds$GenerationSubject1 <- ifelse(isGen1Subject1, 1, 2)
ds$GenerationSubject2 <- ifelse(isGen1Subject2, 1, 2)

ds$Subject1ID <- ifelse(isGen1Subject1, ds$Subject1Tag / 100, ds$Subject1Tag)
ds$Subject2ID <- ifelse(isGen1Subject2, ds$Subject1Tag / 100, ds$Subject2Tag)


ds <- ds[order(ds$ExtendedID, ds$Subject1Tag, ds$Subject2Tag), ]

write.csv(ds, "./Links2011V83.csv", row.names=FALSE)
summary(ds)


nrow(ds)
ds <- subset(ds, !is.na(RExplicitPass1))
nrow(ds)

#print(paste(ds$Label, "=", ds$ID, ","))
  
#s <- ""
#for( i in 1:nrow(ds) ) {
#  s <- paste(s, ds$Label[i], "=", ds$ID[i], ",\n")
#}
#s
