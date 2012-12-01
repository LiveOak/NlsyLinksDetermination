#Fresh R Studio Session
remove.packages(c("devtools", "plyr", "gtable", "scales", "ggplot2"))

#Fresh R Studio Session again
install.packages("plyr")
install.packages("devtools")
library(devtools)
# devtools::unload(inst("plyr"))
# detach("package:plyr")
remove.packages("plyr")
install_github("plyr", ref = "plyr-1.8-rc")

#Restart R Session
require(plyr)
sessionInfo() #Verify the plyr_1.8 is attached (not 1.7)
library(devtools)
install_github("gtable", ref = "gtable-0.1.2-rc")
install_github("scales", ref = "scales-0.2.3-rc")
install_github("ggplot2", ref = "ggplot2-0.9.3-rc")

#Fresh R Studio Session again
rm(list=ls(all=TRUE))
library(plyr)
library(ggplot2)

dsRoc <- data.frame(
  Version=c(51, 50),
  Agree=c(7492, 7494),
  Disagree=c(355,356)
)
ggplot(dsRoc, aes(y=Agree, x=Disagree, label=Version)) + layer(geom="path") 

split_indices(c(1L, 2L), 2L)

#These three variations produce the same error too:
# ggplot(dsRoc, aes(y=Agree, x=Disagree, label=Version)) + geom_path() 
# ggplot(dsRoc, aes(y=Agree, x=Disagree, label=Version)) + geom_line() 
# ggplot(dsRoc, aes(y=Agree, x=Disagree, label=Version)) + geom_text() 

#To provide more information about Issue #3.  
#   It won't work with Issue #2, because that crashes at the R (or RStudio) process.
traceback()
# 6: rename(x, .base_to_ggplot, warn_missing = FALSE) at aes.r#68
# 5: rename_aes(aes) at aes.r#50
# 4: aes(y = Agree, x = Disagree, label = Version)
# 3: inherits(mapping, "uneval") at plot.r#97
# 2: ggplot.data.frame(dsRoc, aes(y = Agree, x = Disagree, label = Version)) at plot.r#74
# 1: ggplot(dsRoc, aes(y = Agree, x = Disagree, label = Version))

sessionInfo() #with all the RC versions.
# R version 2.15.2 (2012-10-26)
# Platform: x86_64-w64-mingw32/x64 (64-bit)
# 
# locale:
#   [1] LC_COLLATE=English_United States.1252  LC_CTYPE=English_United States.1252   
# [3] LC_MONETARY=English_United States.1252 LC_NUMERIC=C                          
# [5] LC_TIME=English_United States.1252    
# 
# attached base packages:
#   [1] stats     graphics  grDevices utils     datasets  methods   base     
# 
# other attached packages:
#   [1] ggplot2_0.9.3 plyr_1.8     
# 
# loaded via a namespace (and not attached):
#   [1] colorspace_1.2-0   dichromat_1.2-4    digest_0.6.0       grid_2.15.2       
# [5] gtable_0.1.2       labeling_0.1       MASS_7.3-22        munsell_0.4       
# [9] proto_0.3-9.2      RColorBrewer_1.0-5 reshape2_1.2.1     scales_0.2.3      
# [13] stringr_0.6.1      tools_2.15.2   
