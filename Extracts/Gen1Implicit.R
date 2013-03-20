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


#Verify that you need to check only H0001600 to ignore H0001700 and H0001800
table(ds$H0001600, ds$H0001700) 
table(ds$H0001600, ds$H0001800)

#Verify that you need to check only H0002400 to ignore H0002500 and H0002600
table(ds$H0002400, ds$H0002500) 
table(ds$H0002400, ds$H0002600)

#Verify that you need to check only H0013600 to ignore H0013700 and H0013800
table(ds$H0013600, ds$H0013700) 
table(ds$H0013600, ds$H0013800)

#Verify that you need to check only H0014700 to ignore H0014700 and H0014800
table(ds$H0014700, ds$H0014800) 
table(ds$H0014700, ds$H0014900)

table(ds$H0001600, ds$H0002400) 

table(ds[ds$R2303200>70, 'R2505400']) #Father's age
table(ds[ds$R2303200>70, 'R2303200']) #Father's age

#table(ds[ds$R2303600>70, 'R2505800']) #Mother's age
table(ds[ds$R2303600>70, 'R2303600']) #Mother's age

table(ds$R2302900, ds$R2303100)

ds[1: 100, c("R0000100", "R2839200")]
ds[1: 100, c("R0000100", "R2737900")]
table(ds$R2839200)
