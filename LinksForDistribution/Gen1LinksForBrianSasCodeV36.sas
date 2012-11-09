* Written by R;
*  write.foreign(df = dsLinking, datafile = "F:/Projects/Nls/Links2011/LinksForDistribution/Gen1LinksForBrianToBeSasedV36.csv",  ;

PROC FORMAT;
value RltnshpP 
     1 = "Gen1Housemates" 
     2 = "Gen2Siblings" 
     3 = "Gen2Cousins" 
     4 = "ParentChild" 
     5 = "AuntNiece" 
;

DATA  rdata ;
INFILE  "F:/Projects/Nls/Links2011/LinksForDistribution/Gen1LinksForBrianToBeSasedV36.csv" 
     DSD 
     LRECL= 33 ;
INPUT
 ExtendedID
 Subject1Tag
 Subject2Tag
 R
 RelationshipPath
;
FORMAT RelationshipPath RltnshpP. ;
RUN;
