* Written by R;
*  write.foreign(df = dsLinking, datafile = file.path(pathDirectory,  ;

PROC FORMAT;
value RltnshpP 
     1 = "Gen1Housemates" 
     2 = "Gen2Siblings" 
     3 = "Gen2Cousins" 
     4 = "ParentChild" 
     5 = "AuntNiece" 
;

DATA  rdata ;
INFILE  "D:/Projects/BG/Links2011/Nls/NlsyLinksDetermination/ForDistribution/Gen1HousematesLinksForSasV52.csv" 
     DSD 
     LRECL= 95 ;
INPUT
 Subject1Tag
 Subject2Tag
 RelationshipPath
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
FORMAT RelationshipPath RltnshpP. ;
RUN;
