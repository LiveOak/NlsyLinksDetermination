#Run this plot first so that you see what the data in these two shapefiles look like
rm(list=ls(all=TRUE))
library(sp)
library(rgdal)
library(rgeos)

# if( names(dev.cur()) != "null device" ) dev.off()
# deviceWidth <- 8 #20 #10 #6.5
# heightToWidthRatio <- 1.2
# windows(width=deviceWidth, height=deviceWidth*heightToWidthRatio)

directory <- "F:/Projects/Nls/Links2011/Analysis/Neighbor/2012-03-04/Shapefiles"
fileName <- "COL_adm1"
takeLook <- readOGR(dsn=directory, layer=fileName)
plot(takeLook, col="gray70")
title(main="Columbia")
jitterCoord <- coordinates(takeLook)
labelD1 <- takeLook@data$NAME_1
text(jitterCoord, labels=labelD1, cex=.8)
fileName <- "COGE61FL_revised"
takeLook2 <- readOGR(dsn=directory, layer=fileName)
jitterCoord2 <- coordinates(takeLook2)
points(jitterCoord2[,1],jitterCoord2[,2]) #latitude has to come first, then longitude

# takeLook@bbox[1,]
# mask <- owin(xrange=takeLook@bbox[1,], yrange=takeLook@bbox[1,], poly=takeLook)
# str(takeLook)
# str(takeLook@polygons[[1]])
# slotNames(takeLook)
# takeLook@polygons[[1]]
# slot(takeLook@polygons[[1]]
#      
# for( polygonIndex in seq_len(length(slot(takeLook, "polygons"))) ) {
#   
#   sapply(slot(slot(takeLook, "polygons")[[polygonIndex]], "Polygons"), function(x) slot(x, "hole")<- TRUE)
# }
# slot(slot(slot(takeLook, "polygons")[[1]], "Polygons")[[1]], "hole") <- TRUE
# plot(takeLook, col="gray70")
#      
#   plot(mask,add=T)

#shapefile COGE61FL_revised was passed to OpenGeoDa to create a Thiessen Polygon plot of the sampled cluster points.
# OpenGeoDa creates its own rectangular bounding box for these points while it creates the Thiessen Polygons (TP).
#Here is what the TPs look like (requires a newly created shapefile named COGE61FL_revisedTP)
#windows()
fileName <- "COGE61FL_revisedTP"
takeLook4 <- readOGR(dsn=directory, layer=fileName)
proj4string(takeLook4) <- proj4string(takeLook)
plot(takeLook4,lwd=.5,lty=2,col="gray90") #latitude has to come first, then longitude

#x = readWKT("POLYGON ((0 0, 0 10, 10 10, 10 0, 0 0))")
#colorado = readWKT("POLYGON ((-81.841530  -4.228429, -81.841530 15.91247, -66.87033 15.91247, -66.87033  -4.228429, -81.841530 -4.228429))")
colorado = readWKT("POLYGON ((-81.841530  -4.9228429, -81.841530 15.91247, -66.987033 15.91247, -66.987033  -4.9228429, -81.841530 -4.9228429))")
proj4string(colorado) <- proj4string(takeLook)
#plot(colorado)
difference <- gDifference(colorado, takeLook)
slot(slot(slot(difference, "polygons")[[1]], "Polygons")[[1]], "hole") <- F
plot(difference, col="gray", add=T , pbg='transparent')

#plot(d, col="gray", add=T , pbg='red', border='blue')


# xPoints <- seq(from=takeLook@bbox[1,1], to=takeLook@bbox[1,2], length=100)
# yPoints <- seq(from=takeLook@bbox[2,1], to=takeLook@bbox[2,2], length=100)
# dsColombiaGrid <- data.frame(x=rep(xPoints, times=length(yPoints)), y=rep(yPoints, each=length(xPoints))
# o <- over(takeLook, takeLook4)
# plot(o)

# res <-gIntersection(takeLook, takeLook4)
# plot(res)

#now the hard part
#overlay the national and regional boundaries of Columbia
#I want/need to get rid of any polygon areas that exceed the national boundaries (think cookie cutter analogy)
par(new=F)
plot(takeLook,lwd=2)#, col=countyColors)
title(main="Columbia")
