* Written by R;
*  write.foreign(df = dsLinking, datafile = file.path(pathDirectory,  ;

DATA  rdata ;
INFILE  "F:/Projects/Nls/NlsyLinksDetermination/LinksForDistribution/Gen1HousematesLinksForSasV52.csv" 
     DSD 
     LRECL= 77 ;
INPUT
 Subject1ID
 Subject2ID
 ExtendedID
 R
 RFull
 MathStandardized_1
 HeightZGenderAge_1
 MathStandardized_2
 HeightZGenderAge_2
;
RUN;
