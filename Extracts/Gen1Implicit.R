require(RODBC)
rm(list=ls(all=TRUE))
pathCsv <- "F:/Projects/Nls/NlsyLinksDetermination/Extracts/Gen1Implicit.csv"
ds <- read.csv(pathCsv, header=TRUE)

#A DSN must be defined for this to work.  In a 64-bit OS, it can be tricky: http://support.microsoft.com/kb/942976
odbcCloseAll()
channel <- odbcConnect(dsn="BeeNlsLinks")
odbcGetInfo(channel)
keepExistingTable <- FALSE
sqlSave(channel, dat=ds, tablename="Extract.tblGen1Implicit", safer=keepExistingTable, rownames=FALSE, append=FALSE)
odbcClose(channel)
#Don't forget to make Gen1ID the primary key in the table.

table(ds$T3036100, ds$H0002400)