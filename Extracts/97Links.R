library(RODBC)
library(plyr)
library(ggplot2)
rm(list=ls(all=TRUE))
pathCsv <- "./Extracts/97Links.csv"
ds <- read.csv(pathCsv, header=TRUE)

# unique(ds$R1193000)
# 
# table(unique(ds$R1193000))
# 
# dsCount <- count(ds, "R1193000")  #The equivalent of HHID
# dsCount <- dsCount[dsCount$freq > 1, ] #Check  the number of nonsingleton families
# dsCount$LinkCount <- (dsCount$freq) * (dsCount$freq - 1) / 2 #Calculate the unique pairs.
# table(dsCount$freq)#, dsCount$LinkCount)
# sum(dsCount$LinkCount) #Sum the counts of unique pairs.
# 
# #hist(dsCount$LinkCount )
# ggplot(dsCount, aes(x=LinkCount)) + geom_bar(stat="bin", binwidth=1) + geom_text(aes(label=..count..), stat="bin", binwidth=1, color="tomato", size=7)
# 
# range(ds$R0536402)
# ds$Dob <- ISOdate(ds$R0536402, ds$R0536401, 15)
# table(ds$R0536401)
# ggplot(ds, aes(x=R0536402)) + geom_bar(binwidth=1, color="white") + coord_cartesian(xlim=c(1970, 2012))

# #A DSN must be defined for this to work.  In a 64-bit OS, it can be tricky: http://support.microsoft.com/kb/942976
# odbcCloseAll()
# channel <- RODBC::odbcDriverConnect("driver={SQL Server}; Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")
# odbcGetInfo(channel)
# keepExistingTable <- FALSE
# sqlSave(channel, dat=ds, tablename="Extract.tblGen1Links", safer=keepExistingTable, rownames=FALSE, append=FALSE)
# odbcClose(channel)
# #Don't forget to make Gen1ID the primary key in the table.