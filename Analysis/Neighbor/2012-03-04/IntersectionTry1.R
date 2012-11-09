require(rgeos)

data(meuse.grid)
gridded(meuse.grid) = ~x+y
Pt = list(x = c(178274.9,181639.6), y = c(329760.4,333343.7))
sl = SpatialLines(list(Lines(Line(cbind(Pt$x,Pt$y)), "L1")))
image(meuse.grid)
xo = over(sl, geometry(meuse.grid), returnList = TRUE)
image(meuse.grid[xo[[1]], ],col=grey(0.5),add=T)
lines(sl)

sl.agg = aggregate(meuse.grid, sl)
class(sl.agg)
plot(sl.agg)
as.data.frame(sl.agg)