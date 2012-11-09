#example of openMX ACE model for height
#rm(list=ls(all=TRUE)) #Clear all the variables before starting a new run.
require(OpenMx)

# directory <- "F:/Projects/Nls/Links2011/Analysis/Df/2011-12-18/"
#  pathInput <-  paste(directory, "SingleEntered.csv", sep="")
#  dsSem <- read.csv(pathInput)
# pathInput <-  paste(directory, "DoubleEntered.csv", sep="")
# dsLm <- read.csv(pathInput)
# dvName1 <- "HtSt1"
# dvName2 <- "HtSt2"
# ExtractHeightHeritabilitiesMxAce(read.csv(pathInput))

ExtractHeritabilitiesMxAce <- function( dsLm ) {
  dsSem <- subset(dsLm, Subject1Tag < Subject2Tag)  
  selVars <- c(dvName1, dvName2)
  
  aceVars <- c("A1", "C1", "E1", "A2", "C2", "E2")
  mzData <- as.matrix(subset(dsSem, R==1, selVars))
  fsData <- as.matrix(subset(dsSem, R==.5, selVars))
  asData <- as.matrix(subset(dsSem, R==.375, selVars))
  hsData <- as.matrix(subset(dsSem, R==.25, selVars))
  
  ACEModel <- mxModel("ACE", # Twin ACE Model -- Path Specification
  	type="RAM",
    manifestVars=selVars,
    latentVars=aceVars,
    mxPath(from=aceVars, arrows=2, free=FALSE, values=1),
    mxPath(from="one", to=aceVars, arrows=1, free=FALSE, values=0),
    mxPath(from="one", to=selVars, arrows=1, free=TRUE,  values=0, labels= "mean"),
    mxPath(from=c("A1","C1","E1"), to=selVars[1], arrows=1, free=TRUE, values=.6, label=c("a","c","e")),
    mxPath(from=c("A2","C2","E2"), to=selVars[2], arrows=1, free=TRUE, values=.6, label=c("a","c","e")),
    mxPath(from="C1", to="C2", arrows=2, free=FALSE, values=1)
  )
  mzModel <- mxModel(ACEModel, name="MZ",
  	mxPath(from="A1", to="A2", arrows=2, free=FALSE, values=1),
  	mxData(observed=mzData, type="raw")
  )
  fsModel <- mxModel(ACEModel, name="FS",
    mxPath(from="A1", to="A2", arrows=2, free=FALSE, values=.5),
    mxData(observed=fsData, type="raw")
  )
#   asModel <- mxModel(ACEModel, name="AS",
#     mxPath(from="A1", to="A2", arrows=2, free=FALSE, values=.375),
#     mxData(observed=asData, type="raw")
#   )
  hsModel <- mxModel(ACEModel, name="HS",
    mxPath(from="A1", to="A2", arrows=2, free=FALSE, values=.25),
    mxData(observed=hsData, type="raw")
  )
#   famACEModel <- mxModel("famACE", mzModel, fsModel, asModel, hsModel,
#     mxAlgebra(expression=MZ.objective + FS.objective + AS.objective + HS.objective, name="twin"),
#     mxAlgebraObjective("twin")
#   )
  if( nrow(mzData) > 0 ) {
    famACEModel <- mxModel("famACE", mzModel, fsModel, hsModel,
      mxAlgebra(expression=MZ.objective + FS.objective + HS.objective, name="twin"),
      mxAlgebraObjective("twin")
    )
  }
  else if( nrow(mzData) <= 0 ) {
    famACEModel <- mxModel("famACE", fsModel, hsModel,
      mxAlgebra(expression=FS.objective + HS.objective, name="twin"),
      mxAlgebraObjective("twin")
    )
  }
  
  famACEFit <- mxRun(famACEModel, silent=T)
  # MZc <- famACEFit$MZ.objective@expCov
  # FSc <- famACEFit$FS.objective@expCov
  # ASc <- famACEFit$AS.objective@expCov
  # HSc <- famACEFit$HS.objective@expCov
  # cov(mzData, use="complete")
  # MZc
  # cov(fsData, use="complete")
  # FSc
  # cov(asData, use="complete")
  # ASc
  # cov(hsData, use="complete")
  # HSc
  
  #M <- famACEFit$MZ.objective@expMean
  A <- mxEval(a * a, famACEFit)
  C <- mxEval(c * c, famACEFit)
  E <- mxEval(e * e, famACEFit)
  V <- (A + C + E)
  a2 <- A / V
  c2 <- C / V
  e2 <- E / V
  ACEest <- rbind(cbind(A,C,E),cbind(a2,c2,e2))
  LL_ACE <- mxEval(objective, famACEFit)
  #print(ACEest[2, ])
  
  return( list(HSquared=a2, CSquared=c2, RowCount=nrow(dsSem)) )
}
