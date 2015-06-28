#rm(list=ls(all=TRUE)) #Clear all the variables before starting a new run.
library(e1071) #For Skewness function
library(xtable)
#################################################################################################
# Exclude some observations, define some constants and desfine a helper function
#################################################################################################
pathDoubleEntered <- "F:/Projects/Nls/Links2011/Analysis/Df/2012-01-07/BMI_Sex_Intell_DoubleEntry_Linked.csv"
# dvName1 <- "MathRaw_1"
# dvName2 <- "MathRaw_2"
dvName1 <- "BMI_1"
dvName2 <- "BMI_2"
# dvName1 <- "AFI_1"
# dvName2 <- "AFI_2"
# dvName1 <- "AFM_1"
# dvName2 <- "AFM_2"
#dvName1 <- "HtSt19to25_1"
#dvName2 <- "HtSt19to25_2"

ageFloorInclusive <- 19
ambiguousImplicitSiblingR <- .375
zScoreThreshold <- 10
 
ds <- read.csv(pathDoubleEntered)
ds$Dv1 <- ds[, dvName1]
ds$Dv2 <- ds[, dvName2]

v1 <- sort(ds$Dv1)
v2 <- sort(ds$Dv2)
sum(abs(v1-v2))
colMeans(cbind(v1, v2))
(mean(v1) - mean(v2))*1e16
qqplot(ds$Dv2 , ds$Dv1)
abline(a=0, b=1, col="tan")

#Cut the youngins
#ds <- subset(ds, AgeHt1>=ageFloorInclusive & AgeHt2>=ageFloorInclusive)
#Set the remaining ambiguous pairs to an fixed constant.
ds[is.na(ds$R), "R"] <- ambiguousImplicitSiblingR
#Cut the ambiguous
ds <- subset(ds, R!=.375)

#Include people if their zScores aren't too high
#ds <- subset(ds, -zScoreThreshold<=Dv1 & Dv1<=zScoreThreshold)
#ds <- subset(ds, -zScoreThreshold<=Dv2 & Dv2<=zScoreThreshold)

ExtractHeightHeritabilitiesDFMethod1 <- function( dsLm ) {
  #dsLm <- subset(ds, !is.na(Dv1) & !is.na(Dv2) & !is.na(R))
  
  brief <- summary(lm(Dv1 ~ 1 + Dv2 + R + Dv2*R, data=dsLm))
  coeficients <- coef(brief)
  nDouble <- length(brief$residuals) 
  #b0 <- coeficients["(Intercept)", "Estimate"]
  b1 <- coeficients["Dv2", "Estimate"]  
  #b2 <- coeficients["R", "Estimate"]
  b3 <- coeficients["Dv2:R", "Estimate"]

  return( list(HSquared=b3, CSquared=b1, RowCount=nDouble) )
}
ExtractHeightHeritabilitiesDFMethod2 <- function( dsLm ) {
  #dsLm <- subset(ds, !is.na(Dv1) & !is.na(Dv2) & !is.na(R))
  sampleMean <- mean(dsLm$Dv1, na.rm=T)
  
  brief <- summary(lm(Dv1 ~ 1 + Dv2 + R + Dv2*R, data=dsLm))
  coeficients <- coef(brief)
  nDouble <- length(brief$residuals) 
  b0 <- coeficients["(Intercept)", "Estimate"]
  #b1 <- coeficients["Dv2", "Estimate"]  
  b2 <- coeficients["R", "Estimate"]
  #b3 <- coeficients["Dv2:R", "Estimate"]
  
  hSquared <- -b2/sampleMean
  cSquared <- 1 - (b0/sampleMean)
  return( list(HSquared=hSquared, CSquared=cSquared, RowCount=nDouble) )
}
ExtractHeightHeritabilitiesDFMethod3 <- function( dsLm ) {
  #dsLm <- subset(ds, !is.na(Dv1) & !is.na(Dv2) & !is.na(R))
  meanDV1 <- mean(dsLm$Dv1, na.rm=T)
  meanDV2 <- mean(dsLm$Dv2, na.rm=T)
  dsLm$Dv1Centered <- dsLm$Dv1 - meanDV1
  dsLm$Dv2Centered <- dsLm$Dv2 - meanDV2
  dsLm$Interaction <- dsLm$Dv2Centered*dsLm$R
  
  brief <- summary(lm(Dv1Centered ~ 0 + Dv2Centered + Interaction, data=dsLm)) #The '0' specifies and intercept-free model.
  coeficients <- coef(brief)
  nDouble <- length(brief$residuals) 
  b1 <- coeficients["Dv2Centered", "Estimate"]  
  b2 <- coeficients["Interaction", "Estimate"]
  return( list(HSquared=b2, CSquared=b1, RowCount=nDouble) )
}

ExtractHeightResults <- function( dsSubset, subsetTitle ) {
  #dsSubset <- ds
  #subsetTitle <- "TestingEveryone"
  dsLm <- subset(dsSubset, !is.na(Dv1) & !is.na(Dv2) & !is.na(R))
  #heritablities <- ExtractHeightHeritabilitiesDFMethod1(dsLm) #Method 1 (original DF that uses b1 & b3)
  #heritablities <- ExtractHeightHeritabilitiesDFMethod2(dsLm) #Method 2 (rescale of b0 & b2)
  heritablities <- ExtractHeightHeritabilitiesDFMethod3(dsLm) #Method 3 (Simplified DF -Rodgers & Kohler, 2005)
  #heritablities <- ExtractHeightHeritabilitiesMxAce(dsLm)
  
  RowCount <- heritablities$RowCount
  hSquared <- heritablities$HSquared
  cSquared <- heritablities$CSquared
  eSquared <- 1 - hSquared - cSquared
  
  countHalf <- sum(dsLm$R == .25)
  countAmbiguousSib <- sum(dsLm$R == .375)
  countFull <- sum(dsLm$R == .5)
  countAmbiguousTwin <- sum(dsLm$R == .75)
  countMz <- sum(dsLm$R == 1)
  
  corHalf <- cor(dsLm$Dv1[dsLm$R == .25], dsLm$Dv2[dsLm$R == .25])
  corAmbiguousSib <- cor(dsLm$Dv1[dsLm$R == .375], dsLm$Dv2[dsLm$R == .375])
  corFull <- cor(dsLm$Dv1[dsLm$R == .5], dsLm$Dv2[dsLm$R == .5])
  #corAmbiguousTwin <- cor(dsLm$Dv1[dsLm$R == .75], dsLm$Dv2[dsLm$R == .75])
  corMz <- cor(dsLm$Dv1[dsLm$R == 1], dsLm$Dv2[dsLm$R == 1])
  
  dsResult <- data.frame(Subgroup=subsetTitle,NDouble=RowCount, HSq=hSquared, CSq=cSquared, ESq=eSquared,
    M=mean(dsLm$Dv1, na.rm=T), SD=sd(dsLm$Dv1, na.rm=T), Skew=skewness(dsLm$Dv1, na.rm=T),
    Half=countHalf, AS=countAmbiguousSib, Full=countFull, AT=countAmbiguousTwin, Mz=countMz,
    CorHalf=corHalf, CorAS=corAmbiguousSib, CorFull=corFull, CorMz=corMz #CorAT=corAmbiguousTwin,                         
  )  
  return( dsResult )
}
PrintDescriptivesTable <- function( dsResults, title="" ) {
  colnames(dsResults) <- c("Subgroup", "$N$", "$h^2$", "$c^2$", "$e^2$", #17 columns
                       "$\\bar{X}$", "$\\sigma$", "$\\sigma^3$",
                       "$N_{.25}$", "$N_{.375}$", "$N_{.5}$", "$N_{.75}$", "$N_{Mz}$",
                       "$r_{.25}$", "$r_{.375}$", "$r_{.5}$",              "$r_{Mz}$") #, "$r_{.75}$" 
  
  #Set the formatting for the table
  digitsFormat <- c(0,0,0, 2,2,2, 2,2,2, 0,0,0,0,0, 2,2,2,2)  #Include an initial dummy for the (suprressed) row names; drop r75.
  textTable <-  xtable(dsResults, caption="Height Heritability", label="tab:two", digits=digitsFormat)
  align(textTable) <- "llr|rrr|rrr|rrrrr|rrrr"  #Include an initial dummy for the (suprressed) row names; drop r75.
  hLineLocations <- c(1, 4, 7, 10, 13)
  
  print(textTable, hline.after=hLineLocations, include.rownames=F, sanitize.text.function = function(x) {x})  
}

PrintDescriptivesTableFewerColumns <- function( dsResults, title="" ) {
  dsResults <- dsResults[, c(1, 3:5, 9:13, 14:17)]
  colnames(dsResults) <- c("Subgroup",  "$h^2$", "$c^2$", "$e^2$", 
                       "$N_{.25}$", "$N_{.375}$", "$N_{.5}$", "$N_{.75}$", "$N_{Mz}$",
                       "$r_{.25}$", "$r_{.375}$", "$r_{.5}$", "$r_{Mz}$")
  textTable <-  xtable(dsResults)#, , digits=digitsFormat)
  align(textTable) <- "ll|rrr|rrrrr|rrrr"  #Include an initial dummy for the (suprressed) row names.
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
resultTotal <- ExtractHeightResults(dsSubset=ds, subsetTitle="Total")
#By Gender
resultFF <- ExtractHeightResults(dsSubset=dsFF, subsetTitle="FF")
resultMF <- ExtractHeightResults(dsSubset=dsMF, subsetTitle="MF")
resultMM <- ExtractHeightResults(dsSubset=dsMM, subsetTitle="MM")

#By Race (1:Hispanic, 2:Black, 3:NBNH)
resultHispanic <- ExtractHeightResults(dsSubset=dsHispanic, subsetTitle="Hispanic")
resultBlack <- ExtractHeightResults(dsSubset=dsBlack, subsetTitle="Black")
resultNBNH <- ExtractHeightResults(dsSubset=dsNBNH, subsetTitle="NBNH")

#By Gender for Hispanics
resultHispanicFF <- ExtractHeightResults(dsSubset=dsHispanicFF, subsetTitle="Hisp FF")
resultHispanicMF <- ExtractHeightResults(dsSubset=dsHispanicMF, subsetTitle="Hisp MF")
resultHispanicMM <- ExtractHeightResults(dsSubset=dsHispanicMM, subsetTitle="Hisp MM")

#By Gender for Blacks
resultBlackFF <- ExtractHeightResults(dsSubset=dsBlackFF, subsetTitle="Black FF")
resultBlackMF <- ExtractHeightResults(dsSubset=dsBlackMF, subsetTitle="Black MF")
resultBlackMM <- ExtractHeightResults(dsSubset=dsBlackMM, subsetTitle="Black MM")

#By Gender for NBNHs
resultNBNHFF <- ExtractHeightResults(dsSubset=dsNBNHFF, subsetTitle="NBNH FF")
resultNBNHMF <- ExtractHeightResults(dsSubset=dsNBNHMF, subsetTitle="NBNH MF")
resultNBNHMM <- ExtractHeightResults(dsSubset=dsNBNHMM, subsetTitle="NBNH MM")

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
  lmcoef <- coef(lm(Dv2 ~ Dv1, dsSubgroup))
  dvRange <- c(-6.5, 4.5)
  gridLineLocations <- pretty(dvRange)
  p <- ggplot(dsSubgroup) #Dv2 ~ Dv1 | R, data=

  if( showLoess ) {
    p + stat_binhex(aes(x=Dv1, y=Dv2), binwidth = c(1, 1) ) +  
      geom_smooth(aes(x=Dv1, y=Dv2), method="loess", size = 1.5, col="green") +
      geom_abline(intercept=lmcoef[1], slope=lmcoef[2], col="tomato") +
      geom_smooth(aes(x=Dv1, y=Dv2), method="lm", se=F, col="gold") +
      facet_grid(.~ R) + opts(aspect.ratio=1) + 
      scale_x_continuous(title, breaks=gridLineLocations)+ scale_y_continuous(sectionTitle, breaks=gridLineLocations) + # coord_equal(ratio = 1)
      coord_cartesian(xlim=dvRange, ylim=dvRange) 
      #coord_cartesian(xlim=dvRange), ylim=dvRange)
    #+opts(aspect.ratio=1, title=title) +
  }
  else {
    p + stat_binhex(aes(x=Dv1, y=Dv2), binwidth = c(1, 1) ) +  
      geom_abline(intercept=lmcoef[1], slope=lmcoef[2], col="tomato") +
      geom_smooth(aes(x=Dv1, y=Dv2), method="lm", se=F, col="gold") +
      facet_grid(.~ R) + opts(aspect.ratio=1) + 
      scale_x_continuous(title, breaks=gridLineLocations)+ scale_y_continuous(sectionTitle, breaks=gridLineLocations) + # coord_equal(ratio = 1)
      coord_cartesian(xlim=dvRange, ylim=dvRange)   
  }

  #coord_cartesian(xlim=range(ds$Dv1), ylim=range(ds$Dv2))
  #p + geom_density(aes(x=Dv1, y=Dv2), data)
}



#resultTotal
