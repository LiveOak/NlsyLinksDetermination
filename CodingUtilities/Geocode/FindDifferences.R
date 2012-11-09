rm(list=ls(all=TRUE)) #Clear any old variables from the R session's memory.
# install.packages("NlsyLinks", repos="http://R-Forge.R-project.org") #Install the NlsyLinks package, if it's not already installed.
# install.packages("plyr") #Install the plyr package, if it's not already installed.
# install.packages("lubridate") #Install the lubridate package, if it's not already installed.
library(NlsyLinks) #Load the package into memory.
library(plyr) #Load the package into memory.
# library(lubridate) #Load the package into memory.

#Declare the locations of the datasets to read and write.
pathDirectory <- "J:/backup_my_workstation/projects/rodgers_kinship/Sanitized" #Use this line when running on Karima's machine.
pathIn <- file.path(pathDirectory, "kinship_data.csv")
# pathDirectory <- "F:/Projects/Nls/Links2011/CodingUtilities/Geocode" #Karima, please modify this line for your computer.
# pathIn <- file.path(pathDirectory, "FakeGeocode.csv")
pathOut <- file.path(pathDirectory, "Sanitized.csv")

#Declare min & max DOBs
dobStart <- ISOdate(1957, 1, 1)
dobStop <- ISOdate(1964, 12, 31)
idsOfIllegalBirthdays1979 <- c(1753, 4933, 5271, 6727, 6833, 8024, 9159, 11817)
                      

#Extract the pairs of subjects related in the first generation.
ds <- Links79Pair[Links79Pair$RelationshipPath=="Gen1Housemates", ]

#Read in the geocode dataset & create a variable to merge with.
dsGeocodeOldNames <- read.csv(file=pathIn, stringsAsFactors=FALSE)
colnames(dsGeocodeOldNames)

replaceColumns <- c("R0000100"="CaseID",
                    "R0000300"="DobMonth1979", 
                    "R0000400"="DobDay1979", 
                    "R0000500"="DobYear1979",
                    "R0410100"="DobMonth1981", 
                    "R0410200"="DobDay1981", 
                    "R0410300"="DobYear1981",
                    "R0000900"="BirthSubjectCounty",
                    "R0001000"="BirthSubjectState",
                    "R0219114"="BirthSubjectCountry",
                    "R0006200"="BirthMotherState",
                    "R0006300"="BirthMotherCountry",
                    "R0007400"="BirthFatherState",
                    "R0007500"="BirthFatherCountry"
                    )
dsGeocode <- plyr::rename(dsGeocodeOldNames, replace=replaceColumns)
colnames(dsGeocode)


dsGeocode$SubjectTag <- dsGeocode$CaseID * 100 #'SubjectTag' is something we use to be unique across both generations.

#Reconstruct the full date; account for subjects missing the DOBDay value, which could be DoNotKnow (ie, -2), InvalidSkip (ie, -3), or NonInterview (ie, -5)
dsGeocode$DobDayIsMissing1979 <- (dsGeocode$DobDay1979 %in% c(-2, -3))
defaultMissingDay <- 15 #If someone is missing a DOBDay, then assign it the 15th of the month.
dsGeocode$DobDay1979 <- ifelse(dsGeocode$DobDayIsMissing1979, defaultMissingDay, dsGeocode$DobDay1979)

#Account for the 8 Gen1 subjects with illegal birthdays (eg, Feb 31)
# dsGeocode$DobDay1979 <- pmin(dsGeocode$DobDay1979, 28)
# dsGeocode$TruncatedDobDay1979 <- (dsGeocode$DobDay1979 > 28)
dsGeocode$HasIllegalBirthday1979 <- (dsGeocode$CaseID %in% idsOfIllegalBirthdays1979)
dsGeocode$DobDay1979 <- ifelse(dsGeocode$HasIllegalBirthday1979, 28, dsGeocode$DobDay1979)

dsGeocode$Dob1979 <- ISOdate(year=dsGeocode$DobYear1979, month=dsGeocode$DobMonth1979, day=dsGeocode$DobDay1979) 
# dsGeocode$Dob1979 <- as.Date(dsGeocode$Dob1979) #Convert it to a lightweight date format #class(dsGeocode$Dob)

dsGeocode$DobDayIsMissing1981 <- (dsGeocode$DobDay1981 %in% c(-5))
dsGeocode$Dob1981 <- ISOdate(year=dsGeocode$DobYear1981, month=dsGeocode$DobMonth1981, day=dsGeocode$DobDay1981) 
# dsGeocode$Dob1981 <- as.Date(dsGeocode$Dob1981) #Convert it to a lightweight date format #class(dsGeocode$Dob1981)

#Display any remaining illegal birthdays, and stop execution.
dsGeocode[ is.na(dsGeocode$Dob1979), c("SubjectTag", "DobMonth1979", "DobDay1979", "DobYear1979")]
if( sum(is.na(dsGeocode$Dob1979)) > 0 ) stop("There is at least one Missing DOB")

datePartColumnsToDrop <- c("DobYear1979", "DobMonth1979", "DobDay1979", "DobYear1981", "DobMonth1981", "DobDay1981")
dsGeocode <- dsGeocode[, !(colnames(dsGeocode) %in% datePartColumnsToDrop)]


#Merge the geocode responses of the 'left' subject (ie, the one with the smaller ID); rename some columns.
#   When using the real geocode dataset, these five columns will need to be chagned to reflect the R/variable numbers.
ds <- merge(x=ds, y=dsGeocode, by.x="Subject1Tag", by.y="SubjectTag")
replace1 <- c(  SubjectID="SubjectID_1", 
                CaseID="CaseID_1",
                HasIllegalBirthday1979="HasIllegalBirthday1979_1",
                Dob1979="Dob1979_1", 
                Dob1981="Dob1981_1", 
                DobDayIsMissing1979="DobDayIsMissing1979_1",
                DobDayIsMissing1981="DobDayIsMissing1981_1",
                BirthSubjectCounty="BirthSubjectCounty_1", 
                BirthSubjectState="BirthSubjectState_1", 
                BirthSubjectCountry="BirthSubjectCountry_1",
                BirthMotherState="BirthMotherState_1", 
                BirthMotherCountry="BirthMotherCountry_1",
                BirthFatherState="BirthFatherState_1",
                BirthFatherCountry="BirthFatherCountry_1"
              )          
ds <- plyr::rename(ds, replace=replace1)


#Merge the geocode responses of the 'right' subject (ie, the one with the larger ID); rename some columns.
ds <- merge(x=ds, y=dsGeocode, by.x="Subject2Tag", by.y="SubjectTag")
replace2 <- c(  SubjectID="SubjectID_2", 
                CaseID="CaseID_2",
                HasIllegalBirthday1979="HasIllegalBirthday1979_2",
                Dob1979="Dob1979_2", 
                Dob1981="Dob1981_2", 
                DobDayIsMissing1979="DobDayIsMissing1979_2",
                DobDayIsMissing1981="DobDayIsMissing1981_2",
                BirthSubjectCounty="BirthSubjectCounty_2", 
                BirthSubjectState="BirthSubjectState_2", 
                BirthSubjectCountry="BirthSubjectCountry_2",
                BirthMotherState="BirthMotherState_2", 
                BirthMotherCountry="BirthMotherCountry_2", 
                BirthFatherState="BirthFatherState_2",
                BirthFatherCountry="BirthFatherCountry_2"
              )          
ds <- plyr::rename(ds, replace=replace2)



#Calculate the number of days in between their birthdays
ds$DobDifferenceInDays1979V1979 <- difftime(ds$Dob1979_1, ds$Dob1979_2, units="days")
ds$DobDifferenceInDays1979V1981 <- difftime(ds$Dob1979_1, ds$Dob1981_2, units="days")
ds$DobDifferenceInDays1981V1979 <- difftime(ds$Dob1981_1, ds$Dob1979_2, units="days")
ds$DobDifferenceInDays1981V1981 <- difftime(ds$Dob1981_1, ds$Dob1981_2, units="days")

#Declare the responses that we don't want to compare
missingCategories <- -1:-5

#Find differences for the subjects' places of birth (county, state, & country).
ds$BirthSubjectCountyMissing_1 <- (ds$BirthSubjectCounty_1 %in% missingCategories)
ds$BirthSubjectCountyMissing_2 <- (ds$BirthSubjectCounty_2 %in% missingCategories)
ds$BirthSubjectCountyEqual <- (ds$BirthSubjectCounty_1 == ds$BirthSubjectCounty_2)

ds$BirthSubjectStateMissing_1 <- (ds$BirthSubjectState_1 %in% missingCategories)
ds$BirthSubjectStateMissing_2 <- (ds$BirthSubjectState_2 %in% missingCategories)
ds$BirthSubjectStateEqual <- (ds$BirthSubjectState_1 == ds$BirthSubjectState_2)

ds$BirthSubjectCountryMissing_1 <- (ds$BirthSubjectCountry_1 %in% missingCategories)
ds$BirthSubjectCountryMissing_2 <- (ds$BirthSubjectCountry_2 %in% missingCategories)
ds$BirthSubjectCountryEqual <- (ds$BirthSubjectCountry_1 == ds$BirthSubjectCountry_2)

#Find differences for the mothers' places of birth (state & country).
ds$BirthMotherStateMissing_1 <- (ds$BirthMotherState_1 %in% missingCategories)
ds$BirthMotherStateMissing_2 <- (ds$BirthMotherState_2 %in% missingCategories)
ds$BirthMotherStateEqual <- (ds$BirthMotherState_1 == ds$BirthMotherState_2)

ds$BirthMotherCountryMissing_1 <- (ds$BirthMotherCountry_1 %in% missingCategories)
ds$BirthMotherCountryMissing_2 <- (ds$BirthMotherCountry_2 %in% missingCategories)
ds$BirthMotherCountryEqual <- (ds$BirthMotherCountry_1 == ds$BirthMotherCountry_2)

#Find differences for the fathers' places of birth (only state).
ds$BirthFatherStateMissing_1 <- (ds$BirthFatherState_1 %in% missingCategories)
ds$BirthFatherStateMissing_2 <- (ds$BirthFatherState_2 %in% missingCategories)
ds$BirthFatherStateEqual <- (ds$BirthFatherState_1 == ds$BirthFatherState_2)

ds$BirthFatherCountryMissing_1 <- (ds$BirthFatherCountry_1 %in% missingCategories)
ds$BirthFatherCountryMissing_2 <- (ds$BirthFatherCountry_2 %in% missingCategories)
ds$BirthFatherCountryEqual <- (ds$BirthFatherCountry_1 == ds$BirthFatherCountry_2)

#Declare the 15 columns that have no potentially identifying information.
sanitizedColumnNames <- c(
  "Subject1Tag", "Subject2Tag", 
  "HasIllegalBirthday1979_1","HasIllegalBirthday1979_2",
  "DobDifferenceInDays1979V1979","DobDifferenceInDays1979V1981","DobDifferenceInDays1981V1979","DobDifferenceInDays1981V1981", 
  "DobDayIsMissing1979_1", "DobDayIsMissing1979_2", 
  "DobDayIsMissing1981_1", "DobDayIsMissing1981_2",
  "BirthSubjectCountyMissing_1", "BirthSubjectCountyMissing_2", "BirthSubjectCountyEqual",
  "BirthSubjectStateMissing_1", "BirthSubjectStateMissing_2", "BirthSubjectStateEqual",
  "BirthSubjectCountryMissing_1", "BirthSubjectCountryMissing_2", "BirthSubjectCountryEqual",
  "BirthMotherStateMissing_1", "BirthMotherStateMissing_2", "BirthMotherStateEqual",
  "BirthMotherCountryMissing_1", "BirthMotherCountryMissing_2", "BirthMotherCountryEqual",
  "BirthFatherStateMissing_1", "BirthFatherStateMissing_2", "BirthFatherStateEqual",
  "BirthFatherCountryMissing_1", "BirthFatherCountryMissing_2", "BirthFatherCountryEqual"
)

colnames(ds)
#Select only the sanitized variables.
dsSanitized <- ds[, sanitizedColumnNames]
dsSanitized <- colwise(as.integer)(dsSanitized)#Convert the TRUE/FALSE variables to 1/0.

#Save the dataset to a CSV on the CHRR's local workstation (which then will be manually emailed to Joe Rodgers).
write.csv(x=dsSanitized, file=pathOut, row.names=FALSE)