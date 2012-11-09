require(RODBC)
require(plyr)
rm(list=ls(all=TRUE))

#A DSN must be defined for this to work.  In a 64-bit OS, it can be tricky: http://support.microsoft.com/kb/942976
odbcCloseAll()
channel <- odbcConnect(dsn="BeeNlsLinks")
odbcGetInfo(channel)
keepExistingTable <- FALSE
#dsRelated <- sqlFetch(channel, sqtable="Process.tblRelatedStructure")
dsRelatedLeft <- sqlQuery(channel, query="SELECT * FROM Process.tblRelatedStructure WHERE RelationshipPath=1 AND Subject1Tag<Subject2Tag")
dsRoster <- sqlFetch(channel, sqtable="Process.tblRosterGen1")
odbcClose(channel)

# dsRelated$IDLeft <- pmin(dsRelated$Subject1Tag, dsRelated$Subject2Tag)
# dsLeft 

dsRelatedLeft$Tags <- paste(dsRelatedLeft$Subject1Tag, dsRelatedLeft$Subject2Tag)
dsRoster$Tags <- paste(dsRoster$SubjectTagResponder, dsRoster$SubjectTagTarget)
ds <- merge(x=dsRelatedLeft, y=dsRoster,by.x="Tags", by.y="Tags")
dsRoster$Tags <- paste(dsRoster$SubjectTagTarget, dsRoster$SubjectTagResponder)
ds <- merge(x=ds, y=dsRoster,by.x="Tags", by.y="Tags")

table(ds$Response.x, ds$Response.y) #X is on the left, Y is on the right; # sort(unique(ds$Response.x))
dsTallied <- as.data.frame(table(ds$Response.x, ds$Response.y))
dsTallied <- dsTallied[dsTallied$Freq>0, ]
dsTallied <- dsTallied[order(dsTallied$Var1, dsTallied$Var2), ]
nrow(dsTallied)


dsTallied$Var1 <- as.numeric(as.character(dsTallied$Var1))
dsTallied$Var2 <- as.numeric(as.character(dsTallied$Var2))
dsTallied$ResponseLower <- pmin(dsTallied$Var1, dsTallied$Var2)
dsTallied$ResponseUpper <- pmax(dsTallied$Var1, dsTallied$Var2)
dsTallied <- dsTallied[, c("ResponseLower", "ResponseUpper", "Freq")]
dsTallied <- dsTallied[order(dsTallied$ResponseLower, dsTallied$ResponseUpper), ]
sum(dsTallied$Freq)
numcolwise(sum)(dsTallied)
class(dsTallied$Freq)

# dsTalliedUnique <- ddply(.data=dsTallied, .variables=c("ResponseLower", "ResponseUpper"), sum)
dsTalliedUnique <- ddply(.data=dsTallied, .variables=c("ResponseLower", "ResponseUpper"), numcolwise(sum))
dsTalliedUnique



class(dsTalliedUnique$V1)
sum(dsTalliedUnique$V1)

# # max(table(tags))
# # ds <- merge(x=dsRelatedLeft, y=dsRoster, by.x=c("Subject1Tag, Subject2Tag"), by.y=c("SubjectTagResponder, SubjectTagTarget"))
# cbind(dsRelatedLeft$Subject1Tag, dsRoster$SubjectTagResponder)
# merge(x=dsRelatedLeft, y=dsRelatedLeft, by.x=c("Subject1Tag, Subject2Tag"), by.y=c("Subject1Tag, Subject2Tag"))
# merge(x=dsRelatedLeft, y=dsRelatedLeft, by.x="ID", by.y="ID")
# dsRelatedLeft$Subject1Tag
#   sum(is.na(dsRelatedLeft$ID))

channel <- odbcConnect(dsn="BeeNlsLinks")
odbcGetInfo(channel)
keepExistingTable <- FALSE
sqlSave(channel, dat=dsTalliedUnique, tablename="Process.tblLURosterGen1Assignment", safer=keepExistingTable, rownames=FALSE, append=FALSE)
odbcClose(channel)
#Don't forget to make Gen1ID the primary key in the table.