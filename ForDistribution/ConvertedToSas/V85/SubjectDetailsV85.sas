* Written by R;
*  foreign::write.foreign(df = ds, datafile = path_output_csv, codefile = path_output_code,  ;

DATA  rdata ;
LENGTH
 Mob $ 10
;

INFILE  "./ForDistribution/ConvertedToSas/V85/SubjectDetailsV85.csv" 
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
