#install.packages("NlsyLinks") #Currently, the default package location (on CRAN) has only Gen2Siblings
#install.packages("NlsyLinks", repos="http://R-Forge.R-project.org") #Uncomment this line to get beyond Gen2Siblings.
require(NlsyLinks)

#Set the working directory (change this for your computer).
pathDirectory <- "F:/Projects/Nls/NlsyLinksDetermination/LinksForDistribution"


#Uncomment this line to retain all links.  (Comment out the other assignments to 'desiredPaths')
# desiredPaths <- c("Gen1Housemates", "Gen2Siblings", "Gen2Cousins", "ParentChild", "AuntNiece")

#Uncomment this line to get just the Gen1Housemates. (Comment out the other assignments to 'desiredPaths')
desiredPaths <- c("Gen1Housemates")

#Uncomment this line to get just the Gen2Siblings (Comment out the other assignments to 'desiredPaths')
# desiredPaths <- c("Gen2Siblings")

#Uncomment this line to get just the Cross-generational links (Comment out the other assignments to 'desiredPaths')
# desiredPaths <- c("ParentChild", "AuntNiece")

#"Subject1Tag", "Subject2Tag", "RelationshipPath", 
variablesToKeep <- c("Subject1ID", "Subject2ID", "ExtendedID", "R", "RFull", "MathStandardized_1", "HeightZGenderAge_1", "MathStandardized_2", "HeightZGenderAge_2")
dsLinking <- Links79PairExpanded[Links79PairExpanded$RelationshipPath %in% desiredPaths, variablesToKeep]
# dsLinking <- Links79PairExpanded[Links79PairExpanded$RelationshipPath %in% desiredPaths, ]

#Uncomment this line to write to a CSV file with headers.
# write.csv(dsLinking, 'Gen1LinksForBrianV36.csv', row.names=F)


write.csv(dsLinking, file=file.path(pathDirectory, 'Gen1HousematesLinksV52.csv'), row.names=FALSE)

# dsLinking$RelationshipPath <- as.character(dsLinking$RelationshipPath) #For the sake of SAS, so the value is in there as a string, and doesn't require the format crap in SAS code.

#install.packages("plyr")
require(plyr)
count(dsLinking, vars="R")
table(dsLinking$R)
sum(is.na(dsLinking$R))

#install.packages("foreign")
require(foreign)
write.foreign(df=dsLinking, 
  datafile=file.path(pathDirectory, 'Gen1HousematesLinksForSasV52.csv'), 
  codefile=file.path(pathDirectory, 'Gen1HousematesSasCodeForLinksV52.sas'),
  package="SAS")




