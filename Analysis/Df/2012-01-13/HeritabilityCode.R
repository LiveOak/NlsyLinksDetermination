#rm(list=ls(all=TRUE)) #Clear all the variables before starting a new run.
require(e1071) #For Skewness function
require(xtable)
#################################################################################################
# Exclude some observations, define some constants and desfine a helper function
#################################################################################################
#pathDoubleEntered <- "F:/Projects/Nls/Links2011/Analysis/Df/2012-01-13/BMI_Sex_Intell_DoubleEntry_Linked.csv"
pathDoubleEntered <- "F:/Projects/Nls/Links2011/Analysis/Df/2012-01-13/DoubleEntered.csv"
dvName <- "HtSt19to25"
#dvName <- "MathStd"
#dvName <- "ReadRecStd"
#dvName <- "Bmi"
#dvName <- "Afi"
#dvName <- "Afm"
#dvName <- "Afd"
dvName_1 <- paste(dvName,"_1", sep="")
dvName_2 <- paste(dvName,"_2", sep="")

#ageFloorInclusive <- 19
ambiguousImplicitSiblingR <- .375
zScoreThreshold <- 20
 
ds <- read.csv(pathDoubleEntered)
ds$Dv_1 <- ds[, dvName_1]
ds$Dv_2 <- ds[, dvName_2]

# v1 <- sort(ds$Dv_1)
# v2 <- sort(ds$Dv_2)
# sum(abs(v1-v2))
# colMeans(cbind(v1, v2))
# (mean(v1) - mean(v2))*1e16
# qqplot(ds$Dv_2 , ds$Dv_1)
# qqplot(ds$Dv_1 , ds$Dv_2, xlab=dvName_1, ylab=dvName_2)
# abline(a=0, b=1, col="tan")

#Cut the youngins
#ds <- subset(ds, AgeHt1>=ageFloorInclusive & AgeHt2>=ageFloorInclusive)
#Set the remaining ambiguous pairs to an fixed constant.
ds[is.na(ds$R), "R"] <- ambiguousImplicitSiblingR
#Cut the ambiguous
#ds <- subset(ds, R!=.375)

ds$RelationshipCategory <- factor(NA, levels=1:6, labels=c("Half", "Ambiguous", "Full", "Dz", "Az", "Mz"), ordered=TRUE)
#ds$RelationshipCategory <- NA
ds$RelationshipCategory[ds$R == .25] <- "Half"
ds$RelationshipCategory[ds$R == ambiguousImplicitSiblingR] <- "Ambiguous"
ds$RelationshipCategory[ds$R == .5 & ds$MultipleBirth==0] <- "Full"
ds$RelationshipCategory[ds$R == .5 & ds$MultipleBirth>0] <- "Dz"
ds$RelationshipCategory[ds$R == .75] <- "Az"
ds$RelationshipCategory[ds$R == 1] <- "Mz"



#Include people if their zScores aren't too high
#ds <- subset(ds, -zScoreThreshold<=Dv_1 & Dv_1<=zScoreThreshold)
#ds <- subset(ds, -zScoreThreshold<=Dv_2 & Dv_2<=zScoreThreshold)

ExtractHeritabilitiesDFMethod1 <- function( dsLm ) {
  #dsLm <- subset(ds, !is.na(Dv_1) & !is.na(Dv_2) & !is.na(R))
  
  brief <- summary(lm(Dv_1 ~ 1 + Dv_2 + R + Dv_2*R, data=dsLm))
  coeficients <- coef(brief)
  nDouble <- length(brief$residuals) 
  #b0 <- coeficients["(Intercept)", "Estimate"]
  b1 <- coeficients["Dv_2", "Estimate"]  
  #b2 <- coeficients["R", "Estimate"]
  b3 <- coeficients["Dv_2:R", "Estimate"]

  return( list(HSquared=b3, CSquared=b1, RowCount=nDouble) )
}
ExtractHeritabilitiesDFMethod2 <- function( dsLm ) {
  #dsLm <- subset(ds, !is.na(Dv_1) & !is.na(Dv_2) & !is.na(R))
  sampleMean <- mean(dsLm$Dv_1, na.rm=T)
  
  brief <- summary(lm(Dv_1 ~ 1 + Dv_2 + R + Dv_2*R, data=dsLm))
  coeficients <- coef(brief)
  nDouble <- length(brief$residuals) 
  b0 <- coeficients["(Intercept)", "Estimate"]
  #b1 <- coeficients["Dv_2", "Estimate"]  
  b2 <- coeficients["R", "Estimate"]
  #b3 <- coeficients["Dv_2:R", "Estimate"]
  
  hSquared <- -b2/sampleMean
  cSquared <- 1 - (b0/sampleMean)
  return( list(HSquared=hSquared, CSquared=cSquared, RowCount=nDouble) )
}
ExtractHeritabilitiesDFMethod3 <- function( dsLm ) {
  #dsLm <- subset(ds, !is.na(Dv_1) & !is.na(Dv_2) & !is.na(R))
  sampleMeanDv_1 <- mean(dsLm$Dv_1, na.rm=T)
  sampleMeanDv_2 <- mean(dsLm$Dv_2, na.rm=T)
  if( abs(sampleMeanDv_1 - sampleMeanDv_2) > 1e10 ) stop(paste("The two variables passed to DFMethod3 do not have the same means:", sampleMeanDv_1, " and ", sampleMeanDv_2))
  
  dsLm$Dv_1Centered <- dsLm$Dv_1 - sampleMeanDv_1
  dsLm$Dv_2Centered <- dsLm$Dv_2 - sampleMeanDv_2
  dsLm$Interaction <- dsLm$Dv_2Centered*dsLm$R
  
  brief <- summary(lm(Dv_1Centered ~ 0 + Dv_2Centered + Interaction, data=dsLm)) #The '0' specifies and intercept-free model.
  coeficients <- coef(brief)
  nDouble <- length(brief$residuals) 
  b1 <- coeficients["Dv_2Centered", "Estimate"]  
  b2 <- coeficients["Interaction", "Estimate"]
  return( list(HSquared=b2, CSquared=b1, RowCount=nDouble) )
}

ExtractResults <- function( dsSubset, subsetTitle ) {
  #dsSubset <- ds
  #subsetTitle <- "TestingEveryone"
  dsLm <- subset(dsSubset, !is.na(Dv_1) & !is.na(Dv_2) & !is.na(R))
  #heritablities <- ExtractHeritabilitiesDFMethod1(dsLm) #Method 1 (original DF that uses b1 & b3)
  #heritablities <- ExtractHeritabilitiesDFMethod2(dsLm) #Method 2 (rescale of b0 & b2)
  #heritablities <- ExtractHeritabilitiesDFMethod3(dsLm) #Method 3 (Simplified DF -Rodgers & Kohler, 2005)
  heritablities <- ExtractHeritabilitiesMxAce(dsLm)
  
  RowCount <- heritablities$RowCount
  hSquared <- heritablities$HSquared
  cSquared <- heritablities$CSquared
  eSquared <- 1 - hSquared - cSquared
  
  countHalf <- sum(dsLm$R == .25)
  countAmbiguousSib <- sum(dsLm$R == .375)
  countFull <- sum(dsLm$R == .5 & dsLm$MultipleBirth==0)
  countDz <- sum(dsLm$R == .5 & dsLm$MultipleBirth>0)
  countAmbiguousTwin <- sum(dsLm$R == .75)
  countMz <- sum(dsLm$R == 1)
  
  corHalf <- cor(dsLm$Dv_1[dsLm$R == .25], dsLm$Dv_2[dsLm$R == .25])
  corAmbiguousSib <- cor(dsLm$Dv_1[dsLm$R == .375], dsLm$Dv_2[dsLm$R == .375])
  corFull <- cor(dsLm$Dv_1[dsLm$R == .5 & dsLm$MultipleBirth==0], dsLm$Dv_2[dsLm$R == .5 & dsLm$MultipleBirth==0])
  corDz <- cor(dsLm$Dv_1[dsLm$R == .5 & dsLm$MultipleBirth>0], dsLm$Dv_2[dsLm$R == .5 & dsLm$MultipleBirth>0])
  #corAmbiguousTwin <- cor(dsLm$Dv_1[dsLm$R == .75], dsLm$Dv_2[dsLm$R == .75])
  corMz <- cor(dsLm$Dv_1[dsLm$R == 1], dsLm$Dv_2[dsLm$R == 1])
  
  dsResult <- data.frame(Subgroup=subsetTitle,NDouble=RowCount, HSq=hSquared, CSq=cSquared, ESq=eSquared,
    M=mean(dsLm$Dv_1, na.rm=T), SD=sd(dsLm$Dv_1, na.rm=T), Skew=skewness(dsLm$Dv_1, na.rm=T),
    Half=countHalf, AS=countAmbiguousSib, Full=countFull, Dz=countDz, Az=countAmbiguousTwin, Mz=countMz,
    CorHalf=corHalf, CorAS=corAmbiguousSib, CorFull=corFull,  CorDz=corDz, CorMz=corMz #CorAT=corAmbiguousTwin,                        
  )  
  return( dsResult )
}
PrintDescriptivesTable <- function( dsResults, title="" ) {
  colnames(dsResults) <- c("Subgroup", "$N$", "$h^2$", "$c^2$", "$e^2$", #17 columns
                       "$\\bar{X}$", "$\\sigma$", "$\\sigma^3$",
                       "$N_{.25}$", "$N_{.375}$", "$N_{Full}$", "$N_{Dz}$", "$N_{.75}$", "$N_{Mz}$",
                       "$r_{.25}$", "$r_{.375}$", "$r_{Full}$", "$r_{Dz}$",              "$r_{Mz}$") #, "$r_{.75}$" 
  
  #Set the formatting for the table
  digitsFormat <- c(0,0,0, 2,2,2, 1,1,1, 0,0,0,0,0,0, 2,2,2,2,2)  #Include an initial dummy for the (suprressed) row names; drop r75.
  textTable <-  xtable(dsResults, label="tab:two", digits=digitsFormat)#, caption="Height Heritability"
  align(textTable) <- "llr|rrr|rrr|rrrrrr|rrrrr"  #Include an initial dummy for the (suprressed) row names; drop r75.
  hLineLocations <- c(1, 4, 7, 10, 13)
  
  print(textTable, hline.after=hLineLocations, include.rownames=F, sanitize.text.function = function(x) {x}, size="footnotesize")  
}

PrintDescriptivesTableFewerColumns <- function( dsResults, title="" ) {
  dsResults <- dsResults[, c(1, 3:5, 9:14, 15:19)]
  colnames(dsResults) <- c("Subgroup",  "$h^2$", "$c^2$", "$e^2$", 
                       "$N_{.25}$", "$N_{.375}$", "$N_{.5}$", "$N_{Dz}$", "$N_{.75}$", "$N_{Mz}$",
                       "$r_{.25}$", "$r_{.375}$", "$r_{.5}$", "$r_{Dz}$",              "$r_{Mz}$")
  textTable <-  xtable(dsResults)#, , digits=digitsFormat)
  align(textTable) <- "ll|rrr|rrrrrr|rrrrr"  #Include an initial dummy for the (suppressed) row names.
  hLineLocations <- c(1)
  #print(textTable,include.rownames=F, sanitize.text.function = function(x) {x})
  print(textTable, hline.after=hLineLocations, include.rownames=F, sanitize.text.function = function(x) {x})  
}

#################################################################################################
# Define the subgroups
#################################################################################################
#By Gender
dsFF <- subset(ds, Gender_1==2 & Gender_2==2)
dsMF <- subset(ds, Gender_1!=Gender_2)
dsMM <- subset(ds, Gender_1==1 & Gender_2==1)

#By Race (1:Hispanic, 2:Black, 3:NBNH)
dsHispanic <- subset(ds, Race_1==1)
dsBlack <- subset(ds, Race_1==2)
dsNBNH <- subset(ds, Race_1==3)

#By Gender for Hispanics
dsHispanicFF <- subset(ds, Race_1==1 & Gender_1==2 & Gender_2==2)
dsHispanicMF <- subset(ds, Race_1==1 & Gender_1!=Gender_2)
dsHispanicMM <- subset(ds, Race_1==1 & Gender_1==1 & Gender_2==1)

#By Gender for Blacks
dsBlackFF <- subset(ds, Race_1==2 & Gender_1==2 & Gender_2==2)
dsBlackMF <- subset(ds, Race_1==2 & Gender_1!=Gender_2)
dsBlackMM <- subset(ds, Race_1==2 & Gender_1==1 & Gender_2==1)

#By Gender for NBNHs
dsNBNHFF <- subset(ds, Race_1==3 & Gender_1==2 & Gender_2==2)
dsNBNHMF <- subset(ds, Race_1==3 & Gender_1!=Gender_2)
dsNBNHMM <- subset(ds, Race_1==3 & Gender_1==1 & Gender_2==1)
 
#################################################################################################
# Get the results for the table
#################################################################################################
resultTotal <- ExtractResults(dsSubset=ds, subsetTitle="Total")
#By Gender
resultFF <- ExtractResults(dsSubset=dsFF, subsetTitle="FF")
resultMF <- ExtractResults(dsSubset=dsMF, subsetTitle="MF")
resultMM <- ExtractResults(dsSubset=dsMM, subsetTitle="MM")

#By Race (1:Hispanic, 2:Black, 3:NBNH)
resultHispanic <- ExtractResults(dsSubset=dsHispanic, subsetTitle="Hispanic")
resultBlack <- ExtractResults(dsSubset=dsBlack, subsetTitle="Black")
resultNBNH <- ExtractResults(dsSubset=dsNBNH, subsetTitle="NBNH")

#By Gender for Hispanics
resultHispanicFF <- ExtractResults(dsSubset=dsHispanicFF, subsetTitle="Hisp FF")
resultHispanicMF <- ExtractResults(dsSubset=dsHispanicMF, subsetTitle="Hisp MF")
resultHispanicMM <- ExtractResults(dsSubset=dsHispanicMM, subsetTitle="Hisp MM")

#By Gender for Blacks
resultBlackFF <- ExtractResults(dsSubset=dsBlackFF, subsetTitle="Black FF")
resultBlackMF <- ExtractResults(dsSubset=dsBlackMF, subsetTitle="Black MF")
resultBlackMM <- ExtractResults(dsSubset=dsBlackMM, subsetTitle="Black MM")

#By Gender for NBNHs
resultNBNHFF <- ExtractResults(dsSubset=dsNBNHFF, subsetTitle="NBNH FF")
resultNBNHMF <- ExtractResults(dsSubset=dsNBNHMF, subsetTitle="NBNH MF")
resultNBNHMM <- ExtractResults(dsSubset=dsNBNHMM, subsetTitle="NBNH MM")

results <- rbind(
  resultTotal,  resultFF, resultMF, resultMM,
  resultHispanic, resultBlack, resultNBNH, 
  resultHispanicFF, resultHispanicMF, resultHispanicMM,
  resultBlackFF, resultBlackMF, resultBlackMM,
  resultNBNHFF, resultNBNHMF, resultNBNHMM
  )


###
### Get the results for the graphs
###
rCategoryCount <- length(unique(ds$R))
PlotSubgroup <- function( dsSubgroup, title, showLoess=T, sectionTitle=""){
   #dsSubgroup=ds; title="testing"
  dvRange <- range(dsSubgroup$Dv_1, na.rm=T)
  gridLineLocations <- pretty(dvRange)
  lmcoef <- coef(lm(Dv_2 ~ Dv_1, dsSubgroup))
  #p <- ggplot(dsSubgroup) #Dv_2 ~ Dv_1 | R, data=
  dsClean <- subset(dsSubgroup, !is.na(Dv_1) & !is.na(Dv_2) & !is.na(R))

  p <- ggplot(dsClean)

  if( showLoess ) {
    p + stat_binhex(aes(x=Dv_1, y=Dv_2), binwidth = c(1, 1) ) +  
      #geom_smooth(aes(x=Dv_1, y=Dv_2), method="loess", size = 1.5, col="green") +
      geom_abline(intercept=lmcoef[1], slope=lmcoef[2], col="tomato") +
      geom_smooth(aes(x=Dv_1, y=Dv_2), method="lm", se=F, col="gold") +
     #facet_grid(.~ R) +
      facet_grid(. ~ RelationshipCategory ) +
      opts(aspect.ratio=1) + 
      scale_x_continuous(name=title, breaks=gridLineLocations, labels=gridLineLocations) +
      scale_y_continuous(name=sectionTitle, breaks=gridLineLocations) + coord_equal(ratio=1) +
      coord_cartesian(xlim=dvRange, ylim=dvRange)
    #+opts(aspect.ratio=1, title=title) +
  }
  else {
    p + stat_binhex(aes(x=Dv_1, y=Dv_2), binwidth = c(1, 1) ) +  
      geom_abline(intercept=lmcoef[1], slope=lmcoef[2], col="tomato") +
      geom_smooth(aes(x=Dv_1, y=Dv_2), method="lm", se=F, col="gold") +
      facet_grid(.~ R) + opts(aspect.ratio=1) + 
      scale_x_continuous(title, breaks=gridLineLocations)+ scale_y_continuous(sectionTitle, breaks=gridLineLocations) + # coord_equal(ratio = 1)
      coord_cartesian(xlim=dvRange, ylim=dvRange)   
  }

  #coord_cartesian(xlim=range(ds$Dv_1), ylim=range(ds$Dv_2))
  #p + geom_density(aes(x=Dv_1, y=Dv_2), data)
}
PlotSubgroup(dsSubgroup=ds, title="Total Sample")
resultTotal


# p + stat_binhex(aes(x=Dv_1, y=Dv_2), binwidth = c(1, 1) ) +  
#   #geom_smooth(aes(x=Dv_1, y=Dv_2), method="loess", size = 1.5, col="green") +
#   geom_abline(intercept=lmcoef[1], slope=lmcoef[2], col="tomato") +
#   geom_smooth(aes(x=Dv_1, y=Dv_2), method="lm", se=F, col="gold") +
#   #facet_grid(.~ R) +
#   facet_grid(. ~ RelationshipCategory ) +
#   opts(aspect.ratio=1) + 
#   scale_x_continuous(name=title, breaks=gridLineLocations, labels=gridLineLocations) +
#   scale_y_continuous(name=sectionTitle, breaks=gridLineLocations) + coord_equal(ratio=1) +
#   coord_cartesian(xlim=dvRange, ylim=dvRange)