#rm(list=ls(all=TRUE))
require(NlsyLinks) 
if( names(dev.cur()) != "null device" ) dev.off()
deviceWidth <- 4#6.5#10#20
heightToWidthRatio <- .75
windows(width=deviceWidth, height=deviceWidth*heightToWidthRatio)

if( names(dev.cur()) != "null device" ) dev.off()
deviceWidth <-6.5*1 #20 #10 #6.5
deviceHeight <- 4.9*1 #deviceWidth * aspectRatio
windows(width=deviceWidth, height=deviceHeight)

#
#Step 3: Load the linking dataset and filter for the Gen2 subjects
#data(Links79Pair)
dsLinking <- subset(Links79Pair, RelationshipPath=="Gen2Siblings")
#
#Step 4: Load the outcomes dataset from the hard drive and then examine the summary.
#   Your path might be: filePathOutcomes <- 'C:/BGResearch/NlsExtracts/Gen2Birth.csv'
filePathOutcomes <- file.path(path.package("NlsyLinks"), "extdata", "Gen2Birth.csv")
dsOutcomes <- ReadCsvNlsy79Gen2(filePathOutcomes)
summary(dsOutcomes)
head(dsOutcomes)
head(dsOutcomes, 8)
#
#Step 5: Verify and rename an existing column.
VerifyColumnExists(dsOutcomes,  "C0328600") #Should return '11' in this example.
dsOutcomes <- RenameNlsyColumn(dsOutcomes, "C0328600", "BirthWeightInOunces")

#Step 6: Manipulate & groom
dsOutcomes$BirthWeightInOunces[dsOutcomes$BirthWeightInOunces < 0] <- NA
#dsOutcomes$BirthWeightInOunces <- pmin(dsOutcomes$BirthWeightInOunces, 300)
head(dsOutcomes[-9])

#Step 7: Merge outcome & linking dataset
dsSingle <- CreatePairLinksSingleEntered(outcomeDataset=dsOutcomes, linksPairDataset=dsLinking, outcomeNames=c('BirthWeightInOunces'))
head(dsSingle)

#Step 8: Declare outcome variable names
oName_1 <- "BirthWeightInOunces_1" 
oName_2 <- "BirthWeightInOunces_2" 

#Step 9: GroupSummary
dsGroupSummary <- RGroupSummary(dsSingle, oName_1, oName_2)
dsGroupSummary

#Step 10: Create Cleaned dataset
dsClean <- CleanSemAceDataset(dsDirty=dsSingle, dsGroupSummary, oName_1, oName_2)

#Step 11: Run the model
ace <- AceLavaanGroup(dsClean)
ace

#Step 12: Inspect the output further
require(lavaan) #Load the package to access methods of the lavaan class.
GetDetails(ace)

hist(dsOutcomes$BirthWeightInOunces)
length(dsOutcomes$BirthWeightInOunces)



hist(dsOutcomes$BirthWeightInOunces, breaks=500, border="NA", col="blue")
require(ggplot2)
qplot(dsOutcomes$BirthWeightInOunces, fill=I("blue"), xlab="Birth Weight (in ounces)", ylab="Frequency", binwidth=2) #color=I("blue"),

head(sort(dsOutcomes$BirthWeightInOunces, decreasing=T))
sum(!is.na(dsOutcomes$BirthWeightInOunces))

head(dsOutcomes[order(dsOutcomes$BirthWeightInOunces, decreasing=T), ])
head(dsOutcomes[order(dsOutcomes$C0328800, decreasing=T), ])

head(dsLinking)