rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# @knitr load_sources ------------------------------
#Load any source files that contain/define functions, but that don't load any other types of variables
#   into memory.  Avoid side effects and don't pollute the global environment.
# source("./SomethingSomething.R")

# @knitr load_packages ------------------------------
library(RODBC, quietly=TRUE)
library(ggplot2, quietly=TRUE)
# library(plyr, quietly=TRUEr)
library(colorspace, quietly=TRUE)

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
  theme(axis.text = element_text(colour="gray40")) +
  theme(axis.title = element_text(colour="gray40")) +
  theme(panel.border = element_rect(colour="gray80")) +
  theme(axis.ticks = element_line(colour="gray80")) + 
  theme(axis.ticks = element_blank()) +
  theme(legend.position = "none") 

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
colorVersion <- sequential_hcl(n=length(versionNumbers), c=c(90,0), l=c(60,0))

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
arrowColor <- "gray50"
dsPublish <- dsRocExplicitImplicit[dsRocExplicitImplicit$Version<=40, ]
g1Publish <- ggplot(dsPublish, aes(y=Good, x=Bad, label=Version, color=Version)) + 
  geom_abline(color=arrowColor, alpha=.5, linetype=2) +
  #   annotate("segment", x=6, xend=34, y=905, yend=2189, arrow=grid::arrow(length=grid::unit(0.3,"cm")), color=arrowColor, alpha=.7) + #58 to 59
  #   annotate("segment", x=78, xend=212, y=2336, yend=2511, arrow=grid::arrow(length=grid::unit(0.3,"cm")), color=arrowColor, alpha=.7) + #69 to 70
  #   annotate("segment", x=212, xend=136, y=1811, yend=1799, arrow=grid::arrow(length=grid::unit(0.3,"cm")), color=arrowColor, alpha=.7) + #70 to 71
  #   annotate("text", x=6, y=905, label="A", color=arrowColor, alpha=.5) + #58 to 59
  #   annotate("text", x=78, y=2336, label="B", color=arrowColor, alpha=.5) + #69 to 70
  #   annotate("text", x=212, y=1811, label="C", color=arrowColor, alpha=.5) + #70 to 71
  geom_path(size=3, alpha=.15) +
  # geom_point(shape=21, size=3, alpha=.7) +
  # geom_text(data=dsRocExplicitImplicitForLabels) +
  geom_text(alpha=.7) +
  scale_colour_gradientn(colours=colorVersion) +#, color=ColorVersion)
  scale_x_continuous(labels=scales::comma) +
  scale_y_continuous(labels=scales::comma) +
  labs(x="Pairs in Disagreement (Implicit vs Explicit)", y="Pairs in Agreement") +
  reportTheme

g1Publish

g1Publish + coord_fixed(xlim=c(0, 7600), ylim=c(0, 7600), ratio=1)

# ggsave(filename="./MicroscopicViews/VersionComparison/RocExplicitVsImplicit.png", plot=g1Publish)

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
print(g1)
# ggsave(filename="./MicroscopicViews/VersionComparison/roc_roster_vs_explicit.png", plot=g1)

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
