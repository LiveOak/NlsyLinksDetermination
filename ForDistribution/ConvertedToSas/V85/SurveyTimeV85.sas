* Written by R;
*  foreign::write.foreign(df = ds, datafile = path_output_csv, codefile = path_output_code,  ;

DATA  rdata ;
LENGTH
 SurveyDate $ 10
;

INFILE  "./ForDistribution/ConvertedToSas/V85/SurveyTimeV85.csv" 
     DSD 
     LRECL= 43 ;
INPUT
 SubjectTag
 SurveySource
 SurveyYear
 SurveyDate
 AgeSelfReportYears
 AgeCalculateYears
;
RUN;
