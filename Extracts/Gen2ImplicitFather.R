require(RODBC)
rm(list=ls(all=TRUE))
pathCsv <- "F:/Projects/Nls/Links2011/Extracts/Gen2ImplicitFather.csv"
#pathCsv2008 <- "D:/Projects/Nls/Links2010/Datasets/Gen2Links2008.csv"
ds <- read.csv(pathCsv, header=TRUE)

#A DSN must be defined for this to work.  In a 64-bit OS, it can be tricky: http://support.microsoft.com/kb/942976
odbcCloseAll()
channel <- odbcConnect(dsn="BeeNlsLinks")
odbcGetInfo(channel)
keepExistingTable <- FALSE
sqlSave(channel, dat=ds, tablename="Extract.tblGen2ImplicitFather", safer=keepExistingTable, rownames=FALSE, append=FALSE)
odbcClose(channel)
#Don't forget to make Gen2ID the primary key in the table.

# table(ds$Y0003200, ds$Y0007300)
# summary(ds)
