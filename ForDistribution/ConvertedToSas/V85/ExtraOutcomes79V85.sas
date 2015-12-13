* Written by R;
*  foreign::write.foreign(df = ds, datafile = path_output_csv, codefile = path_output_code,  ;

DATA  rdata ;
INFILE  "./ForDistribution/ConvertedToSas/V85/ExtraOutcomes79V85.csv" 
     DSD 
     LRECL= 83 ;
INPUT
 SubjectTag
 SubjectID
 Generation
 HeightZGenderAge
 WeightZGenderAge
 AfqtRescaled2006Gaussified
 Afi
 Afm
 MathStandardized
;
RUN;
