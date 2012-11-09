#install.packages("NlsyLinks") #Currently, the default package location (on CRAN) has only Gen2Siblings
#install.packages("NlsyLinks", repos="http://R-Forge.R-project.org") #Uncomment this line to get beyond Gen2Siblings.
require(NlsyLinks)

#Set the working directory (change this for your computer).
setwd('F:/Projects/Nls/Links2011/LinksForDistribution/')


#Uncomment this line to retain all links.  (Comment out the other assignments to 'desiredPaths')
# desiredPaths <- c("Gen1Housemates", "Gen2Siblings", "Gen2Cousins", "ParentChild", "AuntNiece")

#Uncomment this line to get just the Gen1Housemates. (Comment out the other assignments to 'desiredPaths')
desiredPaths <- c("Gen1Housemates")

#Uncomment this line to get just the Cross-generational links (Comment out the other assignments to 'desiredPaths')
# desiredPaths <- c("ParentChild", "AuntNiece")

dsLinking <- subset(Links79Pair, RelationshipPath %in% desiredPaths)

#Uncomment this line to write to a CSV file with headers.
# write.csv(dsLinking, 'Gen1LinksForBrianV36.csv', row.names=F)


#install.packages("plyr")
require(plyr)
count(dsLinking, vars="R")
table(dsLinking$R)
sum(is.na(dsLinking$R))

#install.packages("foreign")
require(foreign)
write.foreign(df=dsLinking, 
  datafile='Gen1LinksForBrianToBeSasedV36.csv', 
  codefile='F:/Projects/Nls/Links2011/LinksForDistribution/Gen1LinksForBrianSasCodeV36.sas',
  package="SAS")






