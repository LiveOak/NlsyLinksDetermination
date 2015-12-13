rm(list=ls(all=TRUE))
version_tag <- "V85"
dataset_names <- paste0(c("ExtraOutcomes79", "Links2011", "SubjectDetails", "SurveyTime"), version_tag)

path_input_directory  <- "./ForDistribution"
path_output_directory <-  file.path("./ForDistribution/ConvertedToSas", version_tag)
dataset_directories <- c("Outcomes", "Links", "SubjectDetails", "SurveyTime")

if( !dir.exists(path_output_directory) ) stop("The output directory doesn't exist.")

for( i  in seq_along(dataset_names) ) {
  name <- dataset_names[i]
  path_input       <- file.path(path_input_directory , dataset_directories[i], paste0(name, ".csv"))
  path_output_csv  <- file.path(path_output_directory, paste0(name, ".csv"))
  path_output_code <- file.path(path_output_directory, paste0(name, ".sas"))
  
  ds <- read.csv(path_input, stringsAsFactors=F)

  foreign::write.foreign(
    df       = ds,
    datafile = path_output_csv,
    codefile = path_output_code,
    package  = "SAS"
  )
}
