require(RODBC)
require(ggplot2)
rm(list=ls(all=TRUE))
pathCsv <- "./Extracts/Gen2Links.csv"
ds <- read.csv(pathCsv, header=TRUE)


# range(ds$C0005700)
# ggplot(ds, aes(x=C0005700)) + geom_bar(binwidth=1, color="white") + coord_cartesian(xlim=c(1970, 2012))

#A DSN must be defined for this to work.  In a 64-bit OS, it can be tricky: http://support.microsoft.com/kb/942976
odbcCloseAll()
channel <- RODBC::odbcDriverConnect("driver={SQL Server}; Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")
odbcGetInfo(channel)
keepExistingTable <- FALSE
sqlSave(channel, dat=ds, tablename="Extract.tblGen2Links", safer=keepExistingTable, rownames=FALSE, append=FALSE)
odbcClose(channel)
#Don't forget to make Gen2ID the primary key in the table.