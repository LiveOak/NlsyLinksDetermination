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
INFILE  "F:/Projects/Nls/NlsyLinksDetermination/LinksForDistribution/LinksForSasV52.csv" 
     DSD 
     LRECL= 34 ;
INPUT
 ExtendedID
 Subject1Tag
 Subject2Tag
 R
 RelationshipPath
;
FORMAT RelationshipPath RltnshpP. ;
RUN;
