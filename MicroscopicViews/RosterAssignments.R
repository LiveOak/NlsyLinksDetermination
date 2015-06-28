library(RODBC)
library(plyr)
rm(list=ls(all=TRUE))
pathOutput <- 'F:/Projects/Nls/Links2011/MicroscopicViews/RosterAssignments.csv'

#A DSN must be defined for this to work.  In a 64-bit OS, it can be tricky: http://support.microsoft.com/kb/942976
odbcCloseAll()
channel <- RODBC::odbcDriverConnect("driver={SQL Server}; Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")
odbcGetInfo(channel)
keepExistingTable <- FALSE
# dsRelatedLeft <- sqlQuery(channel, query="SELECT * FROM Process.tblRelatedStructure WHERE RelationshipPath=1 AND Subject1Tag<Subject2Tag")
dsAssignment <- sqlFetch(channel, sqtable="Process.tblLURosterGen1Assignment")
dsLabel <- sqlFetch(channel, sqtable="Process.tblLURosterGen1")

odbcClose(channel)

ds <- merge(x=dsAssignment, y=dsLabel, by.x="ResponseLower", by.y="ResponseCode")
ds <- merge(x=ds, y=dsLabel, by.x="ResponseUpper", by.y="ResponseCode")

write.csv(ds, file=pathOutput, row.names=F)