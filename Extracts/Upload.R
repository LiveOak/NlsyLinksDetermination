require(RODBC)
rm(list=ls(all=TRUE))

# pathCsv <- "./Extracts/RosterGen1.csv"
# tableName <- "Process.tblLURosterGen1"
# 
# pathCsv <- "./Extracts/GeocodeSanitized.csv"
# tableName <- "Extract.tblGeocodeSanitized"
# 
# pathCsv <- "./Extracts/Gen2OutcomesWeight.csv"
# tableName <- "Extract.tblGen2OutcomesWeight"

pathCsv <- "./Extracts/Gen2OutcomesMath.csv"
tableName <- "Extract.tblGen2OutcomesMath"

ds <- read.csv(pathCsv, header=TRUE)


odbcCloseAll()
channel <- RODBC::odbcDriverConnect("driver={SQL Server}; Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")
odbcGetInfo(channel)
keepExistingTable <- FALSE
sqlSave(channel, dat=ds, tablename=tableName, safer=keepExistingTable, rownames=FALSE, append=FALSE)
odbcClose(channel)
#Don't forget to declare a primary key in the database table.