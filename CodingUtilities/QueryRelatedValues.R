require(RODBC)
rm(list=ls(all=TRUE))

channel <- odbcConnect("BeeNlsLinks")
ds <- sqlQuery(channel, paste("SELECT * FROM dbo.vewRelatedValues", sep=""))
odbcClose(channel)

ds$GenerationSubject1 <- 2
ds$GenerationSubject2 <- 2

firstGen1 <- (ds$GenerationSubject1 == 1)
secondGen1 <- (ds$GenerationSubject2 == 1)
ds$Subject1ID <- rep(NA, nrow(ds))
ds$Subject2ID <- rep(NA, nrow(ds))

ds$Subject1ID[firstGen1] <- ds$Subject1Tag[firstGen1] / 100
ds$Subject2ID[secondGen1] <- ds$Subject1Tag[secondGen1] / 100

ds$Subject1ID[!firstGen1] <- ds$Subject1Tag[!firstGen1]
ds$Subject2ID[!secondGen1] <- ds$Subject2Tag[!secondGen1]

# for( i in seq(nrow(ds))) {
#   if(ds$GenerationSubject1[i] == 1 )
# }

#ds
write.csv(ds, "F:/Projects/Nls/Links2011/Links2011V50.csv", row.names=FALSE)
summary(ds)


nrow(ds)
ds <- subset(ds, !is.na(RExplicitPass1))
nrow(ds)

#print(paste(ds$Label, "=", ds$ID, ","))
  
#s <- ""
#for( i in 1:nrow(ds) ) {
#  s <- paste(s, ds$Label[i], "=", ds$ID[i], ",\n")
#}
#s
