* Written by R;
*  foreign::write.foreign(df = ds, datafile = path_output_csv, codefile = path_output_code,  ;

DATA  rdata ;
INFILE  "./ForDistribution/ConvertedToSas/V85/Links2011V85.csv" 
     DSD 
     LRECL= 132 ;
INPUT
 ExtendedID
 SubjectTag_S1
 SubjectTag_S2
 RelationshipPath
 EverSharedHouse
 R
 RFull
 MultipleBirthIfSameSex
 IsMz
 LastSurvey_S1
 LastSurvey_S2
 RImplicitPass1
 RImplicit
 RImplicit2004
 RImplicitDifference
 RExplicit
 RExplicitPass1
 RPass1
 RExplicitOlderSibVersion
 RExplicitYoungerSibVersion
 RImplicitSubject
 RImplicitMother
 Generation_S1
 Generation_S2
 SubjectID_S1
 SubjectID_S2
;
RUN;
