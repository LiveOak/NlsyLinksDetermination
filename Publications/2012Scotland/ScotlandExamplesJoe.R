rm(list=ls(all=TRUE)) #Clear all the variables before starting a new run.
require(ggplot2)
require(colorspace)
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


# deviceWidth <-10 #20 #10 #6.5
# if( names(dev.cur()) != "null device" ) dev.off()
# aspectRatio <- .5
# deviceHeight <- deviceWidth * aspectRatio
# windows(width=deviceWidth, height=deviceHeight)

#ageFloorInclusive <- 19
ambiguousImplicitSiblingR <- .375
zScoreThreshold <- 20

ds <- read.csv(pathDoubleEntered)
ds$Dv_1 <- ds[, dvName_1]
ds$Dv_2 <- ds[, dvName_2]

ds[is.na(ds$R), "R"] <- ambiguousImplicitSiblingR
#Cut the ambiguous
#ds <- subset(ds, R!=.375)

ds$RelationshipCategory <- factor(NA, levels=1:6, labels=c("Half", "Ambiguous", "Full", "DZ", "AZ", "MZ"), ordered=TRUE)
#ds$RelationshipCategory <- NA
ds$RelationshipCategory[ds$R == .25] <- "Half"
#ds$RelationshipCategory[ds$R == ambiguousImplicitSiblingR] <- "Ambiguous"
ds$RelationshipCategory[ds$R == ambiguousImplicitSiblingR] <- NA
#ds$RelationshipCategory[ds$R == .5] <- "Full"
ds$RelationshipCategory[ds$R == .5 & ds$MultipleBirth==0] <- "Full"
ds$RelationshipCategory[ds$R == .5 & ds$MultipleBirth>0] <- "DZ"
ds$RelationshipCategory[ds$R == .75] <- "AZ"
ds$RelationshipCategory[ds$R == 1] <- "MZ"



dvRange <- range(ds$Dv_1, na.rm=T)
gridLineLocations <- pretty(dvRange)
lmcoef <- coef(lm(Dv_2 ~ Dv_1, ds))
#p <- ggplot(dsSubgroup) #Dv_2 ~ Dv_1 | R, data=
dsClean <- subset(ds, !is.na(Dv_1) & !is.na(Dv_2) & !is.na(R) & !is.na(ds$RelationshipCategory))

#colorPalette <- heat_hcl(12, h = c(-50, -100), c = c(40, 60), l = c(90, 60), power=c(1, 5))
colorPalette <- heat_hcl(12, h=c(160, 260), c = c(15, 70), l = c(90, 60), power=c(1.5, 3))
#colorPalette <- rev(colorPalette)

p <- ggplot(dsClean, aes(x=Dv_1, y=Dv_2))
p <- p +# stat_binhex(aes(x=Dv_1, y=Dv_2), binwidth = c(1, 1) ) +  
  #scale_fill_gradient( low="red", high="blue", trans="log") +
  #scale_fill_manual(colorPalette) +
  #scale_fill_gradientn(colours=colorPalette, trans="log") +
  scale_fill_gradientn("Frequency", colours=colorPalette) +
  #scale_fill_continuous(low = "grey80", high = "black") +
  #scale_colour_gradientn(colour = rainbow(7)) +
  stat_binhex(binwidth = c(1, 1) ) +
  
  #layer(geom="hex", stat_params=list(binwidth=c(10,10))) + #, stat="bin"
  #layer(geom="hex", mapping=aes(x=Dv_1, y=Dv_2), stat_params=list(binwidth=c(1, 1)))
  
  #geom_smooth(method="loess", lwd=2, col=rgb(.2,1,.2)) +
  #geom_smooth(method="loess", lwd=2, col=rgb(.2,1,1)) +
  #geom_smooth(method="loess", lwd=2, col=rgb(.5,.2,1)) +
  #geom_abline(intercept=lmcoef[1], slope=lmcoef[2], col="purple") +
  geom_abline(intercept=lmcoef[1], slope=lmcoef[2], col="tomato", lwd=2) +
  geom_smooth(method="lm", se=F, col="gold", lwd=2) +
  #geom_smooth(aes(x=Dv_1, y=Dv_2), method="lm", se=F, col="purple") +
  #geom_smooth(aes(x=Dv_1, y=Dv_2), method="lm", se=F, col="") +
  
  #facet_grid(.~ R) +
  facet_grid(. ~ RelationshipCategory ) +
  opts(aspect.ratio=1) + 
  #scale_x_continuous(name=dvName)#, breaks=gridLineLocations, labels=gridLineLocations) +
  scale_x_continuous(name="Adult Height (Standardized)") +
  scale_y_continuous(name="") +#, breaks=gridLineLocations) + 
  coord_equal(ratio=1) +
  coord_cartesian(xlim=dvRange, ylim=dvRange) + 
  opts(legend.position = "top")

print(p)
summary(p)

#stat_binhex(aes(x=Dv_1, y=Dv_2), binwidth = c(1, 1) )
#layer(geom="hex", stat_params=list(binwidth=c(1, 1))) 