rm(list=ls(all=TRUE)) #Clear the memory for any variables set from any previous runs.
library(ggplot2)
library(grid)

inputPath <- "./Publications/2013France/Graphs/Timeline.csv"
outputPath <- "./Publications/2013France/Graphs/Timeline.png"
# outputPath <- "./Publications/2013France/Graphs/Timeline.emf"
ds <- read.csv(inputPath, stringsAsFactors=T)

width <- .2
ds$HeightMin <- ds$Cohort + ds$Offset*width 
ds$HeightMax <- ds$HeightMin + width
ds$Height <- (ds$HeightMax + ds$HeightMin)/2
maxMaxHeight <- max(ds$HeightMax)

ds$Year <- (ds$StartYear + pmin(ds$StopYear, 2010))/2

# ds <- ds[ds$Cohort <= 1, ]
# ds <- ds[ds$Cohort <= 2, ]

# ds$Cohort <- factor(ds$Cohort, levels=1:2, labels=c("Gen1", "Gen2"))

g <- ggplot(ds, aes(xmin=StartYear, xmax=StopYear, ymin=HeightMin, ymax=HeightMax, fill=Label)) +
  annotate("rect", xmin=-Inf, xmax=Inf, ymin=c(1, 2, 3)-.3, ymax=c(1, 2, 3)+.3, fill="gray90") +
#   annotate("rect", xmin=-Inf, xmax=Inf, ymin=c(1, 2)-.3, ymax=c(1, 2)+.3, fill="gray90") +
#   annotate("rect", xmin=-Inf, xmax=Inf, ymin=c(1)-.3, ymax=c(1)+.3, fill="gray90") +
  
  annotate("rect", xmin=2010, xmax=2014, ymin=-Inf, ymax=Inf, fill="gray80") +
#   annotate("segment", x=2006, xend=2006, y=-Inf, yend=2.5, color=hcl(h=240), size=4) +
#   geom_vline(x=2006, color=hcl(h=240), size=4) +
#   annotate("text", x=2006.5, y=3, label="Explicit Items\nFirst Asked\nin 2006", color=hcl(h=240, c=55, l=55), hjust=0.5, size=7, lineheight=.8) +
  
  geom_rect(color=NA) + #The color bars of data
  
  #Arrows showing censored
  annotate("polygon", x=c(2010, 2010, 2012, 2010), y=c(1.1, .9, 1, 1.1)) +
  annotate("polygon", x=c(2010, 2010, 2012, 2010), y=c(1.1, .9, 1, 1.1)+1) +
  annotate("polygon", x=c(2010, 2010, 2012, 2010), y=c(1.1, .9, 1, 1.1)+1.2) +
  annotate("polygon", x=c(2010, 2010, 2012, 2010), y=c(1.1, .9, 1, 1.1)+2) +
  annotate("polygon", x=c(2010, 2010, 2012, 2010), y=c(1.1, .9, 1, 1.1)+2.2) +
    
  geom_text(aes(x=Year, y=Height, label=Label), hjust=.5) +
  
#   scale_y_discrete(labels=c("", "Nlsy79\n(Generation 1)", "", "", "")) + #, limits=c(1, 4)) +
#   scale_y_discrete(labels=c("", "Nlsy79\n(Generation 1)", "Nlsy79\n(Generation 2)", "", "")) + #, limits=c(1, 4)) +
#   scale_y_discrete(labels=c("", "Nlsy79\n(Generation 1)", "Nlsy79\n(Generation 2)", "Nlsy97", "")) + #, limits=c(1, 4)) +
  scale_y_discrete(labels=c("", "NLSY79\n(Generation 1)", "NLSYC\n(Generation 2)", "NLSY97", "")) + #, limits=c(1, 4)) +
  
  scale_fill_brewer(palette="Set2", limits=c("Fertility", "Surveys", "DOB")) +
  #coord_cartesian(ylim=c(1-2*width, maxMaxHeight + 1*width)) +
  coord_cartesian(xlim=c(1954, 2014), ylim=c(1-2*width, maxMaxHeight + 1*width)) +
  labs(y=NULL, fill=NULL, x=NULL) +
  theme_bw() +
  theme(plot.margin=unit(c(.1,.2,.2,.1), "cm"), legend.margin = unit(-.5, "cm"))+
  theme(panel.grid.minor.x=element_line(colour="gray90", size=1), panel.grid.major.x=element_line(colour="gray90", size=1)) +
#   theme(panel.grid.major.y=element_blank())+
#   theme(legend.position=c(0, 1), legend.justification=c(0, 1), legend.background=element_rect(fill="gray90"))
#   theme(legend.position="top") +
  theme(legend.position="none") +
  theme(axis.text.x=element_text(size=14)) +
  theme(axis.text.y=element_text(size=14, hjust=.5)) +
  theme(axis.ticks.length = unit(0, "cm")) 

ggsave(filename=outputPath, g, width=10, height=6, dpi=600 )
