rm(list=ls(all=TRUE))
library(RODBC)

channel <- RODBC::odbcDriverConnect("driver={SQL Server}; Server=Bee\\Bass; Database=NlsLinks; Uid=NlsyReadWrite; Pwd=nophi")
ds <- sqlQuery(channel, "SELECT * FROM NlsLinks.Process.tblSurveyTime ORDER BY SubjectTag, SurveyYear")
algorithmVersion <- max(sqlQuery(channel, "SELECT MAX(AlgorithmVersion) as AlgorithmVersion  FROM [NlsLinks].[Process].[tblRelatedValuesArchive]"))
odbcClose(channel)

fileName <- sprintf("./ForDistribution/SurveyTime/SurveyTimeV%d.csv", algorithmVersion)

ds$ID <- NULL
ds$AgeSelfReportYears <- base::round(ds$AgeSelfReportYears, 2)
ds$AgeCalculateYears <- base::round(ds$AgeCalculateYears, 2)

write.csv(ds, file=fileName, row.names=FALSE)
summary(ds)

# Summarize each year & source ---------------------------------------------------
library(magrittr)
requireNamespace("dplyr")

ds_source_year <- ds %>% 
  dplyr::group_by_("SurveySource", "SurveyYear") %>%
  dplyr::summarise(Count = length(SurveySource))

dplyr:::print.tbl_dt(ds_source_year, n=100)
