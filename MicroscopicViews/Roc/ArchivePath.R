rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# @knitr load_sources ------------------------------
#Load any source files that contain/define functions, but that don't load any other types of variables
#   into memory.  Avoid side effects and don't pollute the global environment.
# source("./SomethingSomething.R")

# @knitr load_packages ------------------------------
library(RODBC, quietly=TRUE)
library(ggplot2, quietly=TRUE)
requireNamespace("colorspace", quietly=TRUE)
requireNamespace("grid", quietly=TRUE)
requireNamespace("gridExtra", quietly=TRUE)

# @knitr declare_globals ------------------------------
options(show.signif.stars=F) #Turn off the annotations on p-values

# includedRelationshipPaths <- c(1)
includedRelationshipPaths <- c(2)
columnsToConsider <- c("RImplicit", "RExplicit", "RRoster", "RImplicit2004", "RFull", "Count")

archivePath <- "./MicroscopicViews/CrosstabHistoryArchive.csv"
sql <-
  "SELECT Process.tblRelatedStructure.RelationshipPath, Process.tblRelatedValuesArchive.RImplicit, Process.tblRelatedValuesArchive.RExplicit,
    Process.tblRelatedValuesArchive.RRoster, Process.tblRelatedValuesArchive.AlgorithmVersion,
    COUNT(Process.tblRelatedValuesArchive.ID) AS Count, Process.tblRelatedValuesArchive.RImplicit2004, Process.tblRelatedValuesArchive.RFull
  FROM Process.tblRelatedValuesArchive INNER JOIN
    Process.tblRelatedStructure ON Process.tblRelatedValuesArchive.SubjectTag_S1 = Process.tblRelatedStructure.SubjectTag_S1 AND
    Process.tblRelatedValuesArchive.SubjectTag_S2 = Process.tblRelatedStructure.SubjectTag_S2
  GROUP BY Process.tblRelatedStructure.RelationshipPath, Process.tblRelatedValuesArchive.RImplicit, Process.tblRelatedValuesArchive.RExplicit,
    Process.tblRelatedValuesArchive.RRoster, Process.tblRelatedValuesArchive.AlgorithmVersion, Process.tblRelatedValuesArchive.RImplicit2004,
    Process.tblRelatedValuesArchive.RFull"

reportTheme <- theme_light() +
  theme(axis.ticks.length  = grid::unit(0, "cm")) +
  theme(axis.text          = element_text(colour="gray40")) +
  theme(axis.title         = element_text(colour="gray40")) +
  theme(panel.border       = element_rect(colour="gray90")) +
  theme(panel.grid.major   = element_line(colour="gray90")) +
  theme(legend.position    = "none") 

# @knitr load_data ------------------------------
dsArchive <- read.csv(archivePath, stringsAsFactors=F) # 'ds' stands for 'datasets'

channel <- RODBC::odbcDriverConnect("driver={SQL Server};Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")
odbcGetInfo(channel)
dsRaw <- sqlQuery(channel, sql, stringsAsFactors=F)
odbcCloseAll()

# @knitr tweak_data ------------------------------
dsArchive$RFull <- NA_real_

dsRaw <- plyr::rbind.fill(dsRaw, dsArchive)
dsClean <- dsRaw[dsRaw$RelationshipPath %in% includedRelationshipPaths, ]

versionNumbers <- sort(unique(dsClean$AlgorithmVersion))
# colorVersion <- sequential_hcl(n=length(versionNumbers), c=c(130,40), l=c(130,30))
colorVersion <- colorspace::sequential_hcl(n=length(versionNumbers), c=c(90,0), l=c(60,0))

dsRocExplicitImplicit <- data.frame(Version=versionNumbers, Good=NA_integer_, Bad=NA_integer_)
dsRocExplicitRoster <- data.frame(Version=versionNumbers, Good=NA_integer_, Bad=NA_integer_)
dsRocImplicitRoster <- data.frame(Version=versionNumbers, Good=NA_integer_, Bad=NA_integer_)
dsRocImplicit2004RFull <- data.frame(Version=versionNumbers, Good=NA_integer_, Bad=NA_integer_)

desiredLabels <- sort(unique(c(69, 74, 82, range(versionNumbers), seq(from=0, to=max(versionNumbers), by=5))))
dsRocExplicitImplicitForLabels <- dsRocExplicitImplicit[dsRocExplicitImplicit$Version %in% desiredLabels, ]
dsRocExplicitImplicitForPoints <- dsRocExplicitImplicit[!(dsRocExplicitImplicit$Version %in% desiredLabels), ]


# @knitr assemble_comparisons ------------------------------

for( versionNumber in versionNumbers ) {
  dsSliceRaw <- dsRaw[dsClean$AlgorithmVersion==versionNumber, columnsToConsider]  
  dsSliceClean <- dsClean[dsClean$AlgorithmVersion==versionNumber, columnsToConsider]  
  
  goodSumExplicitImplicit <- sum(dsSliceClean[dsSliceClean$RImplicit==dsSliceClean$RExplicit, "Count"], na.rm=T)
  badSumExplicitImplicit <- sum(dsSliceClean[abs(dsSliceClean$RImplicit - dsSliceClean$RExplicit) >= .25, "Count"], na.rm=T)
  dsRocExplicitImplicit[dsRocExplicitImplicit$Version==versionNumber, c("Good", "Bad")] <- c(goodSumExplicitImplicit, badSumExplicitImplicit)
  
  goodSumExplicitRoster <- sum(dsSliceClean[dsSliceClean$RRoster==dsSliceClean$RExplicit, "Count"], na.rm=T)
  badSumExplicitRoster <- sum(dsSliceClean[abs(dsSliceClean$RRoster - dsSliceClean$RExplicit) >= .25, "Count"], na.rm=T)
  dsRocExplicitRoster[dsRocExplicitRoster$Version==versionNumber, c("Good", "Bad")] <- c(goodSumExplicitRoster, badSumExplicitRoster)  
  
  goodSumImplicitRoster <- sum(dsSliceClean[dsSliceClean$RRoster==dsSliceClean$RImplicit, "Count"], na.rm=T)
  badSumImplicitRoster <- sum(dsSliceClean[abs(dsSliceClean$RRoster - dsSliceClean$RImplicit) >= .25, "Count"], na.rm=T)
  dsRocImplicitRoster[dsRocImplicitRoster$Version==versionNumber, c("Good", "Bad")] <- c(goodSumImplicitRoster, badSumImplicitRoster)
  
  goodSumImplicit2004RFull <- sum(dsSliceClean[dsSliceClean$RImplicit2004 ==dsSliceClean$RFull, "Count"], na.rm=T)
  badSumImplicit2004RFull <- sum(dsSliceClean[abs(dsSliceClean$RImplicit2004 - dsSliceClean$RFull) >= .25, "Count"], na.rm=T)
  dsRocImplicit2004RFull[dsRocImplicit2004RFull$Version==versionNumber, c("Good", "Bad")] <- c(goodSumImplicit2004RFull, badSumImplicit2004RFull)
}

# @knitr roc_explicit_vs_implicit ------------------------------
arrowColor <- "gray90"
dsPublish <- dsRocExplicitImplicit[dsRocExplicitImplicit$Version<=40, ]
g1Publish <- ggplot(dsPublish, aes(y=Good, x=Bad, label=Version, color=Version)) + 
  geom_abline(color=arrowColor, linetype="F5") +
  geom_path(size=3, alpha=.15, lineend="round") +
  # geom_point(shape=21, size=3, alpha=.7) +
  # geom_text(data=dsRocExplicitImplicitForLabels) +
  geom_text(alpha=.7) +
  scale_colour_gradientn(colours=colorVersion) +#, color=ColorVersion)
  scale_x_continuous(labels=scales::comma) +
  scale_y_continuous(labels=scales::comma) +
  reportTheme +
  theme(plot.margin = grid::unit(c(0, .2, 0, 0), "lines")) +
  labs(x="Pairs in Disagreement (Implicit vs Explicit)", y="Pairs in Agreement", title=NULL)

x_limit <- c(225, 425)
y_limit <- c(5850, 7550)
xy_max <- 7800

xy_ratio <- (diff(x_limit)/diff(y_limit)) / (xy_max/xy_max)

gridExtra::grid.arrange(
  g1Publish + coord_fixed(xlim=c(0, xy_max), ylim=c(0, xy_max), ratio=1),
  g1Publish + coord_fixed(xlim=x_limit, ylim=y_limit, ratio=xy_ratio) + labs(y=""),
  ncol = 2
)

# @knitr base_graph ------------------------------
g1 <- ggplot(dsRocExplicitImplicit, aes(y=Good, x=Bad, label=Version, color=Version)) +
  geom_path() +
  geom_point(shape=21, size=3, alpha=.7) +
  geom_text() +
  scale_colour_gradientn(colours=colorVersion) +#, color=ColorVersion)
  scale_x_continuous() +#   scale_x_continuous(name="") +
  scale_y_continuous(labels=scales::comma) +
  labs(x="Pairs in Disagreement (Implicit vs Explicit)", y="Pairs in Agreement") +
  reportTheme
# coord_cartesian(xlim=c(0, 8000), ylim=c(0, 8000)) + #coord_equal()
g1

# @knitr roc_roster_vs_explicit ------------------------------
g1 %+% dsRocExplicitRoster + 
  labs(x="Pairs in Disagreement (Roster vs Explicit)")

# @knitr roc_roster_vs_implicit ------------------------------
g1 %+% dsRocImplicitRoster + 
  labs(x="Pairs in Disagreement (Roster vs Implicit)")

# @knitr roc_full_vs_implicit_2004 ------------------------------
g1 %+% dsRocImplicit2004RFull + 
  labs(x="Pairs in Disagreement (RFull vs Implicit2004)") + 
  coord_cartesian(xlim=c(0, 9000), ylim=c(0, 9000))
