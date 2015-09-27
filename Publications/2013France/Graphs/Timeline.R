rm(list=ls(all=TRUE)) #Clear the memory for any variables set from any previous runs.
library(ggplot2)
requireNamespace("grid", quietly=T)

inputPath <- "./Publications/2013France/Graphs/Timeline.csv"
outputPath <- "./Publications/2013France/Graphs/Timeline.png"
# outputPath <- "./Publications/2013France/Graphs/Timeline.pdf"

ds <- read.csv(inputPath, stringsAsFactors=F)

radius <- .2
ds$HeightMin <- ds$Cohort + ds$Offset*radius 
ds$HeightMax <- ds$HeightMin + radius
ds$Height <- (ds$HeightMax + ds$HeightMin)/2
maxMaxHeight <- max(ds$HeightMax)
# palette <- c("Fertility"="#745a39", "Surveys"="#5a8fc1", "DOB"="#d89f5c") ##1c386a #http://colrd.com/image-dna/42275/
# palette <- c("Fertility"="#5cbddd", "Surveys"="#986a46", "DOB"="#7ebea5") ##1c386a #http://colrd.com/image-dna/23557/
palette <- c("Fertility"="#3c765f", "Surveys"="#986a46", "DOB"="#1c5f83", "tan"="#f3d6a8", "light_blue"="#5cbddd", "explicit"="#7ebea5", "almost_white"="#fefefe") ##1c386a #http://colrd.com/image-dna/23557/

ds$Year <- (ds$StartYear + pmin(ds$StopYear, 2014))/2

# ds <- ds[ds$Cohort <= 1, ]
# ds <- ds[ds$Cohort <= 2, ]

g <- ggplot(ds, aes(xmin=StartYear, xmax=StopYear, ymin=HeightMin, ymax=HeightMax, fill=Label)) +
  annotate("rect", xmin=-Inf, xmax=2014, ymin=c(1, 2, 3)-.3, ymax=c(1, 2, 3)+.3, fill=palette["tan"], alpha=.5) +
  # annotate("rect", xmin=-Inf, xmax=Inf, ymin=c(1, 2)-.3, ymax=c(1, 2)+.3, fill=palette["tan"]) +
  # annotate("rect", xmin=-Inf, xmax=Inf, ymin=c(1)-.3, ymax=c(1)+.3, fill=palette["tan"]) +
  
  annotate("rect", xmin=2014, xmax=2016, ymin=-Inf, ymax=Inf, fill=palette["light_blue"], alpha=.5) +
  annotate("segment", x=2006, xend=2006, y=-Inf, yend=2.5, color=palette["explicit"], size=4, alpha=.5) +
  annotate("text", x=2006.8, y=1.5, label="explicit items\nfirst asked\nin 2006", color=palette["explicit"], hjust=0, size=4, lineheight=.8) +
  
  geom_rect(color=NA) + #The colored bars of data
  
  #Arrows showing censored
  annotate("polygon", x=c(2014, 2014, 2015, 2014), y=c(1.1, .9, 1, 1.1),       fill=palette["Surveys"])   +
  annotate("polygon", x=c(2014, 2014, 2015, 2014), y=c(1.1, .9, 1, 1.1) + 1  , fill=palette["Surveys"])   +
  annotate("polygon", x=c(2014, 2014, 2015, 2014), y=c(1.1, .9, 1, 1.1) + 1.2, fill=palette["Fertility"]) +
  annotate("polygon", x=c(2014, 2014, 2015, 2014), y=c(1.1, .9, 1, 1.1) + 2  , fill=palette["Surveys"])   +
  annotate("polygon", x=c(2014, 2014, 2015, 2014), y=c(1.1, .9, 1, 1.1) + 2.2, fill=palette["Fertility"]) +
    
  geom_text(aes(x=Year, y=Height, label=Label), hjust=.5, color=palette["almost_white"]) +
  
  scale_x_continuous(breaks=seq(1960,2010,10)) +
  scale_y_discrete(labels=c("", "NLSY79\n(Generation 1)", "NLSYC\n(Generation 2)", "NLSY97", "")) + #, limits=c(1, 4)) +
  scale_fill_manual(values=palette) +
  # scale_y_discrete(labels=c("", "Nlsy79\n(Generation 1)", "", "", "")) + #, limits=c(1, 4)) +
  # scale_y_discrete(labels=c("", "Nlsy79\n(Generation 1)", "Nlsy79\n(Generation 2)", "", "")) + #, limits=c(1, 4)) +
  # scale_y_discrete(labels=c("", "Nlsy79\n(Generation 1)", "Nlsy79\n(Generation 2)", "Nlsy97", "")) + #, limits=c(1, 4)) +
  
  coord_cartesian(xlim=c(1954, 2016), ylim=c(1-1.7*radius, maxMaxHeight + .3*radius)) +
  
  theme_light() +
  theme(plot.margin        = grid::unit(c(.1,.1,.1,.1), "cm")) +
  theme(panel.border       = element_blank()) +
  theme(panel.grid.minor.x = element_line(colour=adjustcolor(palette["tan"], alpha=.1), size=1)) +
  theme(panel.grid.major.x = element_line(colour=adjustcolor(palette["tan"], alpha=.25), size=1)) +
  theme(panel.grid.major.y = element_blank()) +
  theme(panel.grid.major.y = element_blank()) +
  theme(axis.text          = element_text(colour = palette["DOB"], size = 14)) +
  theme(axis.text.y        = element_text(hjust=.5)) +
  theme(axis.ticks.length  = grid::unit(0, "cm")) +
  theme(legend.position    = "none") +
  labs(x=NULL, y=NULL) 
g
ggsave(filename=outputPath, g, width=10, height=6, dpi=600 )
