require(RODBC)
rm(list=ls(all=TRUE))
pathCsv <- "F:/Projects/Nls/Links2011/Extracts/Gen2BirthDateFromGen1.csv"
#pathCsv2008 <- "D:/Projects/Nls/Links2010/Datasets/Gen2Links2008.csv"
ds <- read.csv(pathCsv, header=TRUE)

##A DSN must be defined for this to work.  In a 64-bit OS, it can be tricky: http://support.microsoft.com/kb/942976
#odbcCloseAll()
#channel <- odbcConnect(dsn="BeeNlsLinks")
#odbcGetInfo(channel)
#keepExistingTable <- FALSE
#sqlSave(channel, dat=ds, tablename="Extract.tblGen2Links", safer=keepExistingTable, rownames=FALSE, append=FALSE)
#odbcClose(channel)
##Don't forget to make Gen2ID the primary key in the table.

summary(ds)

subset(ds, R0000100==6692) #Her sons don't have birthdays.  I was hoping she'd report them instead.  Wrong.
