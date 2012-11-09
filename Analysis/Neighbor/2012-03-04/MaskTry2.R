
shear <- matrix(c(1,0,0.6,1),ncol=2)
X <- affine(owin(), shear)
## Not run:
plot(X)


 data(letterR)
poly <- letterR
summary(poly)
str(poly)

#plot(affine(as.mask(letterR), shear, c(0, 0.5)))
plot(poly)
plot(as.mask(poly))

reversedPoly <- poly
reversedPoly$bdry[[1]]$hole <- TRUE
reversedPoly$bdry[[2]]$hole <- FALSE
str(reversedPoly)

plot(reversedPoly)

plot(as.mask(revmasersedPoly))
