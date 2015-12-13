LIBNAME repo 'C:\Users\wbeasley\Documents\GitHub\NlsyLinksDetermination\ForDistribution\ConvertedToSas\V85';

DATA  repo.ExtraOutcomes79V85;
INFILE  "C:\Users\wbeasley\Documents\GitHub\NlsyLinksDetermination\ForDistribution\ConvertedToSas\V85\ExtraOutcomes79V85.csv"
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

DATA repo.Links2011V85;
INFILE  "C:\Users\wbeasley\Documents\GitHub\NlsyLinksDetermination\ForDistribution\ConvertedToSas\V85\Links2011V85.csv" 
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
FORMAT RelationshipPath RltnshpP. ;
FORMAT IsMz IsMz. ;
RUN;

DATA repo.SubjectDetailsV85 ;
LENGTH
 Mob $ 10
;

INFILE  "C:\Users\wbeasley\Documents\GitHub\NlsyLinksDetermination\ForDistribution\ConvertedToSas\V85\SubjectDetailsV85.csv" 
     DSD 
     LRECL= 74 ;
INPUT
 SubjectTag
 ExtendedID
 Generation
 Gender
 RaceCohort
 SiblingCountInNls
 BirthOrderInNls
 SimilarAgeCount
 HasMzPossibly
 KidCountBio
 KidCountInNls
 Mob
 LastSurveyYearCompleted
 AgeAtLastSurvey
 IsDead
 DeathDate
;
RUN;

DATA repo.SurveyTime ;
LENGTH
 SurveyDate $ 10
;

INFILE  "C:\Users\wbeasley\Documents\GitHub\NlsyLinksDetermination\ForDistribution\ConvertedToSas\V85\SurveyTimeV85.csv"
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
