rm(list=ls(all=TRUE)) #Clear the memory for any variables set from any previous runs.
library(ggplot2)
library(grid)

inputPath <- "./Publications/2013France/Graphs/Timeline.csv"
outputPath <- "./Publications/2013France/Graphs/Timeline.png"
outputPath <- "./Publications/2013France/Graphs/Timeline.pdf"

ds <- read.csv(inputPath, stringsAsFactors=T)

width <- .2
ds$HeightMin <- ds$Cohort + ds$Offset*width 
ds$HeightMax <- ds$HeightMin + width
ds$Height <- (ds$HeightMax + ds$HeightMin)/2
maxMaxHeight <- max(ds$HeightMax)
# palette <- c("Fertility"="#745a39", "Surveys"="#5a8fc1", "DOB"="#d89f5c") ##1c386a #http://colrd.com/image-dna/42275/
# palette <- c("Fertility"="#5cbddd", "Surveys"="#986a46", "DOB"="#7ebea5") ##1c386a #http://colrd.com/image-dna/23557/
palette <- c("Fertility"="#3c765f", "Surveys"="#986a46", "DOB"="#1c5f83", "tan"="#f3d6a8", "light_blue"="#5cbddd", "explicit"="#7ebea5", "almost_white"="#fefefe") ##1c386a #http://colrd.com/image-dna/23557/

ds$Year <- (ds$StartYear + pmin(ds$StopYear, 2010))/2

# ds <- ds[ds$Cohort <= 1, ]
# ds <- ds[ds$Cohort <= 2, ]

# ds$Cohort <- factor(ds$Cohort, levels=1:2, labels=c("Gen1", "Gen2"))

g <- ggplot(ds, aes(xmin=StartYear, xmax=StopYear, ymin=HeightMin, ymax=HeightMax, fill=Label)) +
  # annotate("rect", xmin=-Inf, xmax=Inf, ymin=c(1, 2, 3)-.3, ymax=c(1, 2, 3)+.3, fill="gray80", alpha=.8) +
  
  annotate("rect", xmin=-Inf, xmax=2010, ymin=c(1, 2, 3)-.3, ymax=c(1, 2, 3)+.3, fill=palette["tan"], alpha=.5) +
  # annotate("rect", xmin=-Inf, xmax=Inf, ymin=c(1, 2)-.3, ymax=c(1, 2)+.3, fill="gray90") +
  # annotate("rect", xmin=-Inf, xmax=Inf, ymin=c(1)-.3, ymax=c(1)+.3, fill="gray90") +
  
  # annotate("rect", xmin=2010, xmax=2014, ymin=-Inf, ymax=Inf, fill="gray80") +
  # annotate("rect", xmin=2010, xmax=2014, ymin=-Inf, ymax=Inf, fill=palette["light_green"], alpha=.25) +
  annotate("rect", xmin=2010, xmax=2014, ymin=-Inf, ymax=Inf, fill=palette["light_blue"], alpha=.25) +
  # annotate("segment", x=2006, xend=2006, y=-Inf, yend=2.5, color=hcl(h=240), size=4) +
  geom_vline(x=2006, color=palette["explicit"], size=4) +
  # annotate("text", x=2006.5, y=3, label="Explicit Items\nFirst Asked\nin 2006", color=hcl(h=240, c=55, l=55), hjust=0.5, size=7, lineheight=.8) +
  
  geom_rect(color=NA) + #The color bars of data
  
  #Arrows showing censored
  annotate("polygon", x=c(2010, 2010, 2012, 2010), y=c(1.1, .9, 1, 1.1),     fill=palette["Surveys"]) +
  annotate("polygon", x=c(2010, 2010, 2012, 2010), y=c(1.1, .9, 1, 1.1)+1,   fill=palette["Surveys"]) +
  annotate("polygon", x=c(2010, 2010, 2012, 2010), y=c(1.1, .9, 1, 1.1)+1.2, fill=palette["Fertility"]) +
  annotate("polygon", x=c(2010, 2010, 2012, 2010), y=c(1.1, .9, 1, 1.1)+2,   fill=palette["Surveys"]) +
  annotate("polygon", x=c(2010, 2010, 2012, 2010), y=c(1.1, .9, 1, 1.1)+2.2, fill=palette["Fertility"]) +
    
  geom_text(aes(x=Year, y=Height, label=Label), hjust=.5, color=palette["almost_white"]) +
  
  # scale_y_discrete(labels=c("", "Nlsy79\n(Generation 1)", "", "", "")) + #, limits=c(1, 4)) +
  # scale_y_discrete(labels=c("", "Nlsy79\n(Generation 1)", "Nlsy79\n(Generation 2)", "", "")) + #, limits=c(1, 4)) +
  # scale_y_discrete(labels=c("", "Nlsy79\n(Generation 1)", "Nlsy79\n(Generation 2)", "Nlsy97", "")) + #, limits=c(1, 4)) +
  scale_y_discrete(labels=c("", "NLSY79\n(Generation 1)", "NLSYC\n(Generation 2)", "NLSY97", "")) + #, limits=c(1, 4)) +
  
  # scale_fill_brewer(palette="Set2", limits=c("Fertility", "Surveys", "DOB")) +
  scale_fill_manual(values=palette) +
  # coord_cartesian(ylim=c(1-2*width, maxMaxHeight + 1*width)) +
  coord_cartesian(xlim=c(1954, 2014), ylim=c(1-1.7*width, maxMaxHeight + .3*width)) +
  labs(y=NULL, fill=NULL, x=NULL) +
  theme_light() +
  theme(plot.margin=unit(c(.1,.2,.2,.1), "cm"), legend.margin = unit(-.5, "cm")) +
  theme(panel.grid.minor.x=element_line(colour=adjustcolor(palette["tan"], alpha=.15), size=1)) +
  theme(panel.grid.major.x=element_line(colour=adjustcolor(palette["tan"], alpha=.25), size=1)) +
  theme(panel.grid.major.y=element_blank()) +
  theme(panel.grid.major.y=element_blank()) +
  theme(axis.text = element_text(colour = palette["DOB"], size = 15)) +

  theme(panel.border = element_blank()) +
  # theme(legend.position=c(0, 1), legend.justification=c(0, 1), legend.background=element_rect(fill="gray90"))
  # theme(legend.position="top") +
  theme(legend.position="none") +
  theme(axis.text.x=element_text(size=14)) +
  theme(axis.text.y=element_text(size=14, hjust=.5)) +
  theme(axis.ticks.length = unit(0, "cm")) 
g
ggsave(filename=outputPath, g, width=10, height=6, dpi=600 )
