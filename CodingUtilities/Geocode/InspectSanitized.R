rm(list=ls(all=TRUE)) #Clear any old variables from the R session's memory.
# install.packages("NlsyLinks", repos="http://R-Forge.R-project.org") #Install the NlsyLinks package, if it's not already installed.
# install.packages("plyr") #Install the plyr package, if it's not already installed.
# install.packages("lubridate") #Install the lubridate package, if it's not already installed.
library(NlsyLinks) #Load the package into memory.
library(plyr) #Load the package into memory.
# library(lubridate) #Load the package into memory.

#Declare the locations of the datasets to read and write.
# pathDirectory <- "J:/backup_my_workstation/projects/rodgers_kinship/Sanitized" #Use this line when running on Karima's machine.
# pathIn <- file.path(pathDirectory, "kinship_data.csv")
pathDirectory <- "F:/Projects/Nls/Links2011/CodingUtilities/Geocode" #Karima, please modify this line for your computer.
pathIn <- file.path(pathDirectory, "SanitizedReal.csv")

idsOfIllegalBirthdays1979 <- c(1753, 4933, 5271, 6727, 6833, 8024, 9159, 11817)

dsGeocode <- read.csv(pathIn, stringsAsFactors=FALSE)


#Extract the pairs of subjects related in the first generation.
ds <- Links79PairExpanded[Links79PairExpanded$RelationshipPath=="Gen1Housemates", ]

ds <- merge(x=ds, y=dsGeocode, by=c("Subject1Tag", "Subject2Tag"))
colnames(ds)

dsClose <- ds[abs(ds$DobDifferenceInDays1979V1979) < 10, ]
ds[ds$IsMz=="Yes", ]
ds[ds$IsMz=="DoNotKnow", ]
