w <- owin()
w <- owin(c(0,1), c(0,1))
# the unit square

w <- owin(c(10,20), c(10,30), unitname=c("foot","feet"))
# a rectangle of dimensions 10 x 20 feet
# with lower left corner at (10,10)

# polygon (diamond shape)
w <- owin(poly=list(x=c(0.5,1,0.5,0),y=c(0,1,2,1)))
w <- owin(c(0,1), c(0,2), poly=list(x=c(0.5,1,0.5,0),y=c(0,1,2,1)))

# polygon with hole
ho <- owin(poly=list(list(x=c(0,1,1,0), y=c(0,0,1,1)),
                     list(x=c(0.6,0.4,0.4,0.6), y=c(0.2,0.2,0.4,0.4))))

w <- owin(c(-1,1), c(-1,1), mask=matrix(TRUE, 100,100))
# 100 x 100 image, all TRUE
X <- raster.x(w)
Y <- raster.y(w)
wm <- owin(w$xrange, w$yrange, mask=(X^2 + Y^2 <= 1))
# discrete approximation to the unit disc

## Not run: 
plot(c(0,1),c(0,1),type="n")
bdry <- locator()
# click the vertices of a polygon (anticlockwise)

## End(Not run)

w <- owin(poly=bdry)
## Not run: plot(w)

## Not run: 
im <- as.logical(matrix(scan("myfile"), nrow=128, ncol=128))
# read in an arbitrary 128 x 128 digital image from text file
rim <- im[, 128:1]
# Assuming it was given in row-major order in the file
# i.e. scanning left-to-right in rows from top-to-bottom,
# the use of matrix() has effectively transposed rows & columns,
# so to convert it to our format just reverse the column order.
w <- owin(mask=rim)
plot(w)
# display it to check!

## End(Not run)