require(RODBC)
rm(list=ls(all=TRUE))
pathCsv <- "./Extracts/Gen2OutcomesHeight.csv"
ds <- read.csv(pathCsv, header=TRUE)

odbcCloseAll()
channel <- odbcConnect(dsn="BeeNlsLinks")
odbcGetInfo(channel)
keepExistingTable <- FALSE
sqlSave(channel, dat=ds, tablename="Extract.tblGen2OutcomesHeight", safer=keepExistingTable, rownames=FALSE, append=FALSE)
odbcClose(channel)
#Don't forget to make Gen1ID the primary key in the table.