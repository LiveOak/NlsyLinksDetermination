library(gpclib)

set.seed(100)
a <- cbind(rnorm(100), rnorm(100))
a <- a[chull(a), ]
## Convert 'a' from matrix to "gpc.poly"
a <- as(a, "gpc.poly")
b <- cbind(rnorm(100), rnorm(100))
b <- as(b[chull(b), ], "gpc.poly")
## More complex polygons with an intersection
p1 <- read.polyfile(system.file("poly-ex/ex-poly1.txt", package = "gpclib"))
p2 <- read.polyfile(system.file("poly-ex/ex-poly2.txt", package = "gpclib"))
## Plot both polygons and highlight their intersection in red
plot(append.poly(p1, p2))
plot(intersect(p1, p2), poly.args = list(col = 2), add = TRUE)
## Highlight the difference p1 \ p2 in green
plot(setdiff(p1, p2), poly.args = list(col = 3), add = TRUE)
## Highlight the difference p2 \ p1 in blue
plot(setdiff(p2, p1), poly.args = list(col = 4), add = TRUE)
## Plot the union of the two polygons
plot(union(p1, p2))
## Take the non-intersect portions and create a new polygon
## combining the two contours
p.comb <- append.poly(setdiff(p1, p2), setdiff(p2, p1))
plot(p.comb, poly.args = list(col = 2, border = 0))