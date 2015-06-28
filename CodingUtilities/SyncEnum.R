library(RODBC)
rm(list=ls(all=TRUE))

channel <- odbcConnect("BeeNlsLinks")
#ds <- sqlQuery(channel, paste("SELECT * FROM Process.tblItem", sep=""))
ds <- sqlQuery(channel, paste("SELECT * FROM Process.tblLUMarkerType", sep=""))
odbcClose(channel)
ds
summary(ds)
#print(paste(ds$Label, "=", ds$ID, ","))
print(noquote(paste(ds$Label, "=", ds$ID, ",  ")))
cat(noquote(paste(ds$Label, "=", ds$ID, ",  \n")))

# s <- ""
# for( i in 1:nrow(ds) ) {
#  #s <- paste(s, ds$Label[i], "=", ds$ID[i], ",         ")
#   print(noquote(paste(s, ds$Label[i], "=", ds$ID[i], ",         ")))
# }
# s