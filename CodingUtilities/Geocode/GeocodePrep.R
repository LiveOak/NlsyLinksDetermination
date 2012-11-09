rm(list=ls(all=TRUE))
library(NlsyLinks)
library(lubridate)
library(plyr) #Load the package into memory.
require(knitr)
# dsLinksGen1 <- Links79Pair[Links79Pair$RelationshipPath=="Gen1Housemates", ]
pathOut <- "F:/Projects/Nls/Links2011/CodingUtilities/Geocode/FakeGeocode.csv"


dobStart <- ISOdate(1957, 1, 1)
dobStop <- ISOdate(1964, 12, 31)
fipsRangeCountry <- c(1, 50) #?
fipsRangeState <- c(1, 79) #http://en.wikipedia.org/wiki/FIPS_state_code
fipsRangeCounty <- c(1, 840) #http://en.wikipedia.org/wiki/List_of_counties_in_Virginia; #http://en.wikipedia.org/wiki/County_(United_States)#Number_of_county_equivalents_per_state

dsSubjectGen1 <- data.frame(
  CaseID=SubjectDetails79[SubjectDetails79$Generation==1, ]$SubjectTag/100, 
  Dob1979=ISOdate(1900, 1, 1),
  DobYear1979=NA_integer_,
  DobMonth1979=NA_integer_,
  DobDay1979=NA_integer_,
  Dob1981=ISOdate(1900, 1, 1),
  DobYear1981=NA_integer_,
  DobMonth1981=NA_integer_,
  DobDay1981=NA_integer_,
  BirthSubjectCounty=NA_character_,
  BirthSubjectState=NA_character_,
  BirthSubjectCountry=NA_character_,
  BirthMotherState=NA_character_,
  BirthMotherCountry=NA_character_,
  BirthFatherState=NA_character_, 
  BirthFatherCountry=NA_character_
)
n <- nrow(dsSubjectGen1)

# stop("Account for missing days in DOB")

dobDurationInDays <- as.integer(dobStop - dobStart)
dsSubjectGen1$Dob1979 <- dobStart + as.difftime(floor(runif(n=n, min=0, max=dobDurationInDays)), units="days")
dsSubjectGen1$DobYear1979 <- lubridate::year(dsSubjectGen1$Dob1979)
dsSubjectGen1$DobMonth1979 <- lubridate::month(dsSubjectGen1$Dob1979)
dsSubjectGen1$DobDay1979 <- lubridate::day(dsSubjectGen1$Dob1979)
dsSubjectGen1$Dob1981 <- dobStart + as.difftime(floor(runif(n=n, min=0, max=dobDurationInDays)), units="days")
dsSubjectGen1$DobYear1981 <- lubridate::year(dsSubjectGen1$Dob1981)
dsSubjectGen1$DobMonth1981 <- lubridate::month(dsSubjectGen1$Dob1981)
dsSubjectGen1$DobDay1981 <- lubridate::day(dsSubjectGen1$Dob1981)

#potentialStates <- c("Oklahoma", "Maine", "Florida", "New York", "Illinois", "Invalid Skip", "Refused")
# potentialCounties <- c("Cleveland", "Rogers", "Bard", "Hunter", "Meredith")
# dsSubjectGen1$BirthCountySubject <- potentialCounties[floor(runif(n, min=1, max=length(potentialCounties)))]
# dsSubjectGen1$BirthStateSubject <- potentialStates[floor(runif(n, min=1, max=length(potentialStates)))]
# dsSubjectGen1$BirthStateMother <- potentialStates[floor(runif(n, min=1, max=length(potentialStates)))]
# dsSubjectGen1$BirthStateFather <- potentialStates[floor(runif(n, min=1, max=length(potentialStates)))]


potentialCounties <- seq_len(fipsRangeCounty[2])
potentialStates <- seq_len(fipsRangeState[2])
potentialCountries <- seq_len(fipsRangeCountry[2])

dsSubjectGen1$BirthSubjectCounty <- sample(x=potentialCounties, size=n, replace=TRUE)
dsSubjectGen1$BirthSubjectState <- sample(x=potentialStates, size=n, replace=TRUE)
dsSubjectGen1$BirthSubjectCountry <- sample(x=potentialCountries, size=n, replace=TRUE)
dsSubjectGen1$BirthMotherState <- sample(x=potentialStates, size=n, replace=TRUE)
dsSubjectGen1$BirthMotherCountry <- sample(x=potentialCountries, size=n, replace=TRUE)
dsSubjectGen1$BirthFatherState <- sample(x=potentialStates, size=n, replace=TRUE)
dsSubjectGen1$BirthFatherCountry <- sample(x=potentialCountries, size=n, replace=TRUE)

dsSubjectGen1 <- dsSubjectGen1[, !(colnames(dsSubjectGen1) %in% c("Dob1979", "Dob1981"))]

#Simulate missing/skipped day in DOB
dsSubjectGen1$DobDay1979 <- ifelse(runif(n) > .8, sample(x=c(-2, -3), size=n, replace=TRUE), dsSubjectGen1$DobDay1979)
dsSubjectGen1$BirthSubjectCounty <- ifelse(runif(n) > .8, sample(x=c(-1, -2, -3, -4), size=n, replace=TRUE), dsSubjectGen1$BirthSubjectCounty)
dsSubjectGen1$BirthSubjectState <- ifelse(runif(n) > .8, sample(x=c(-1, -2, -3, -4), size=n, replace=TRUE), dsSubjectGen1$BirthSubjectState)
dsSubjectGen1$BirthSubjectCountry <- ifelse(runif(n) > .8, sample(x=c( -3, -4), size=n, replace=TRUE), dsSubjectGen1$BirthSubjectCountry)
dsSubjectGen1$BirthMotherState <- ifelse(runif(n) > .8, sample(x=c(-1, -2, -3, -4), size=n, replace=TRUE), dsSubjectGen1$BirthMotherState)
dsSubjectGen1$BirthMotherCountry <- ifelse(runif(n) > .8, sample(x=c(-2, -3, -4), size=n, replace=TRUE), dsSubjectGen1$BirthMotherCountry)
dsSubjectGen1$BirthFatherState <- ifelse(runif(n) > .8, sample(x=c(-2, -3, -4), size=n, replace=TRUE), dsSubjectGen1$BirthFatherState)
dsSubjectGen1$BirthFatherCountry <- ifelse(runif(n) > .8, sample(x=c(-2, -3, -4), size=n, replace=TRUE), dsSubjectGen1$BirthFatherCountry)

dsSubjectGen1$DobYear1981 <- ifelse(runif(n) > .8, sample(x=c(-5), size=n, replace=TRUE), dsSubjectGen1$DobYear1981)
dsSubjectGen1$DobMonth1981 <- ifelse(runif(n) > .8, sample(x=c(-5), size=n, replace=TRUE), dsSubjectGen1$DobMonth1981)
dsSubjectGen1$DobDay1981 <- ifelse(runif(n) > .8, sample(x=c(-5), size=n, replace=TRUE), dsSubjectGen1$DobDay1981)

replaceColumns <- c("CaseID" = "R0000100",
                    "DobMonth1979" = "R0000300", 
                    "DobDay1979" = "R0000400", 
                    "DobYear1979" = "R0000500",
                    "DobMonth1981" = "R0410100", 
                    "DobDay1981" = "R0410200", 
                    "DobYear1981" = "R0410300",
                    "BirthSubjectCounty" = "R0000900",
                    "BirthSubjectState" = "R0001000",
                    "BirthSubjectCountry" = "R0219114",
                    "BirthMotherState" = "R0006200",
                    "BirthMotherCountry" = "R0006300",
                    "BirthFatherState" = "R0007400",
                    "BirthFatherCountry" = "R0007500"
                    )
dsSubjectGen1 <- plyr::rename(dsSubjectGen1, replace=replaceColumns)

write.csv(dsSubjectGen1, file=pathOut, row.names=FALSE)