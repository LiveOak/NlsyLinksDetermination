* Written by R;
*  write.foreign(df = Links79PairExpanded[Links79PairExpanded$RelationshipPath ==  ;

PROC FORMAT;
value RltnshpP 
     1 = "Gen1Housemates" 
     2 = "Gen2Siblings" 
     3 = "Gen2Cousins" 
     4 = "ParentChild" 
     5 = "AuntNiece" 
;

value IsMz 
     1 = "No" 
     2 = "Yes" 
     3 = "DoNotKnow" 
;

DATA  OnlyGen2Siblings_V85 ;
INFILE  "./ForDistribution/LinksForSas/SasLinksOnlyGen2Siblings.csv" 
     DSD 
     LRECL= 156 ;
INPUT
 SubjectTag_S1
 SubjectTag_S2
 ExtendedID
 RelationshipPath
 EverSharedHouse
 R
 RFull
 IsMz
 LastSurvey_S1
 LastSurvey_S2
 RImplicitPass1
 RImplicit
 RImplicit2004
 RExplicit
 RExplicitPass1
 RPass1
 RExplicitOlderSibVersion
 RExplicitYoungerSibVersion
 Generation_S1
 Generation_S2
 SubjectID_S1
 SubjectID_S2
 MathStandardized_S1
 HeightZGenderAge_S1
 MathStandardized_S2
 HeightZGenderAge_S2
;
FORMAT RelationshipPath RltnshpP. ;
FORMAT IsMz IsMz. ;
RUN;
