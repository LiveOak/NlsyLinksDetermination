data standardized; set 'C:\Users\Kelly Bear\Documents\- NLSY Grant\NLSY_Grant\standardized';
title 'Linking Standardized DVs with Links2011V28';

data NLSYPairs; set 'C:\Users\Kelly Bear\Documents\- NLSY Grant\Links2011V28\Links2011V28';
id_1=Subject1Tag;
id_2=Subject2Tag;
run;
title2 'Merge by ID1';
data height14; set standardized;
keep cid mid crace cgender age_ht htst height age_wt wtst weight;
rename cid=id_1 mid=mid_1 crace=race_1 cgender=gender_1 age_ht=ageht_1 htst=htst_1 height=height_1 age_wt=agewt_1 wtst=wtst_1 weight=weight_1;
proc sort; by id_1;
proc sort data=NLSYPairs; by id_1;
data together; merge NLSYPairs height14; by id_1;
/*data mergecheck1; set together; if _n_ le 25; proc print; run;*/

title2 'Merge by ID2';
data height15; set standardized;
keep cid mid crace cgender age_ht htst height age_wt wtst weight;
rename cid=id_2 mid=mid_2 crace=race_2 cgender=gender_2 age_ht=ageht_2 htst=htst_2 height=height_2 age_wt=agewt_2 wtst=wtst_2 weight=weight_2;
proc sort; by id_2;
proc sort data=together; by id_2;
data togetheragain; merge together height15; by id_2;
proc freq; tables r;
/*data mergecheck2; set togetheragain; if _n_ le 25; proc print; */
run;

title2 'keeping necessary variables for doubling';
data doubling; set togetheragain;
keep id_1 mid_1 race_1 gender_1 ageht_1 htst_1 height_1 agewt_1 wtst_1 weight_1 
     id_2 mid_2 race_2 gender_2 ageht_2 htst_2 height_2 agewt_2 wtst_2 weight_2
	 r rimplicit rexplicit _;
if _=. then delete;
proc freq; tables r rimplicit rexplicit;
run;

title2 'double entered';
data Reverse; set doubling;
rename id_1=id_2 mid_1=mid_2 race_1=race_2 gender_1=gender_2 ageht_1=ageht_2 htst_1=htst_2 height_1=height_2 agewt_1=agewt_2 wtst_1=wtst_2 weight_1=weight_2
id_2=id_1 mid_2=mid_1 race_2=race_1 gender_2=gender_1 ageht_2=ageht_1 htst_2=htst_1 height_2=height_1 agewt_2=agewt_1 wtst_2=wtst_1 weight_2=weight_1
;
run;
data doubleentered; set doubling reverse;
proc freq; tables r rimplicit rexplicit;
run;

*Prepping Data;
Title 'Prepping Data: Sex Typing, removing those w/o sibs';
data linked1; set doubleentered;
if gender_1=1 and gender_2=1 then sextype='mm';
if gender_1=2 and gender_2=2 then sextype='ff';
if gender_1=1 and gender_2=2 then sextype='mf';
if gender_1=2 and gender_2=1 then sextype='mf';
proc freq; tables r sextype;
run;

data 'C:\Users\Kelly Bear\Documents\- NLSY Grant\Links2011V28\Links2011V28Check'; set linked1; run;

*******Running DF Analyses For those 19+ to Test changes to .375 and . for Ambigous Sibs*************;
Title1 'Validity Checks 19+ With Implicit+Explicit Combined Links';
Title2 'R=.375';
data vc19plus; set linked1;
if ageht_1 < 19 then delete;
if ageht_2 < 19 then delete;
if r=. then r=.375;
proc sort; by r; proc means; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r sextype race_1; 
run;


Title3 'Total Sample';
data vc19plus1; set vc19plus;
proc glm; model htst_1 = htst_2 r htst_2*r;
proc glm; model wtst_1 = wtst_2 r wtst_2*r;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r race_1 race_2 sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r;
run;

Title3 'By Sextype';
data vc19plus2; set vc19plus;
proc sort; by sextype;
proc glm; model htst_1 = htst_2 r htst_2*r; by sextype;
proc glm; model wtst_1 = wtst_2 r wtst_2*r; by sextype;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2; by sextype;
proc freq; tables r race_1 race_2 sextype; by sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2; by sextype;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r sextype;
run;

Title3 'By Race';
data vc19plus3; set vc19plus;
proc sort; by race_1;
proc glm; model htst_1 = htst_2 r htst_2*r; by race_1;
proc glm; model wtst_1 = wtst_2 r wtst_2*r; by race_1;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2; by race_1;
proc freq; tables r race_1 race_2 sextype; by race_1;
proc corr; var htst_1 htst_2 wtst_1 wtst_2; by race_1;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r race_1;
run;

Title3 'By Race and Gender';
data vc19plus4; set vc19plus;
proc sort; by race_1 sextype;
proc glm; model htst_1 = htst_2 r htst_2*r; by race_1 sextype;
proc glm; model wtst_1 = wtst_2 r wtst_2*r; by race_1 sextype;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2; by race_1 sextype;
proc freq; tables r race_1 race_2 sextype; by race_1 sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2; by race_1 sextype;
proc sort; by r race_1 sextype; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r race_1 sextype;
run;

*_________________________________________________________________________________________;
*For R = .25;
Title1 'Validity Checks 19+ With Implicit+Explicit Links';
Title2 'For R=.25';
data vc19plus25Ambig; set vc19plus;
if r=.375 then r=.25;
if r=. then r=.25;
proc sort; by r; proc means; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r; 
run;


Title3 'Total Sample';
data vc19plus25Ambig1; set vc19plus25Ambig;
proc glm; model htst_1 = htst_2 r htst_2*r;
proc glm; model wtst_1 = wtst_2 r wtst_2*r;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r race_1 race_2 sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r;
run;

Title3 'By Sextype';
data vc19plus25Ambig2; set vc19plus25Ambig;
proc sort; by sextype;
proc glm; model htst_1 = htst_2 r htst_2*r; by sextype;
proc glm; model wtst_1 = wtst_2 r wtst_2*r; by sextype;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2; by sextype;
proc freq; tables r race_1 race_2 sextype; by sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2; by sextype;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r sextype;
run;

Title3 'By Race';
data vc19plus25Ambig3; set vc19plus25Ambig;
proc sort; by race_1;
proc glm; model htst_1 = htst_2 r htst_2*r; by race_1;
proc glm; model wtst_1 = wtst_2 r wtst_2*r; by race_1;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2; by race_1;
proc freq; tables r race_1 race_2 sextype; by race_1;
proc corr; var htst_1 htst_2 wtst_1 wtst_2; by race_1;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r race_1;
run;

Title3 'By Race and Gender';
data vc19plus25Ambig4; set vc19plus25Ambig;
proc sort; by race_1 sextype;
proc glm; model htst_1 = htst_2 r htst_2*r; by race_1 sextype;
proc glm; model wtst_1 = wtst_2 r wtst_2*r; by race_1 sextype;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2; by race_1 sextype;
proc freq; tables r race_1 race_2 sextype; by race_1 sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2; by race_1 sextype;
proc sort; by r race_1 sextype; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r race_1 sextype;
run;


*_________________________________________________________________________________________;
*For R = .5;
Title1 'Validity Checks 19+ With Implicit+Explicit Links';
Title2 'For R=.5';
data vc19plus5Ambig; set vc19plus;
if r=.375 then r=.5;
if r=. then r=.5;
proc sort; by r; proc means; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r ; 
run;


Title3 'Total Sample';
data vc19plus5Ambig1; set vc19plus5Ambig;
proc glm; model htst_1 = htst_2 r htst_2*r;
proc glm; model wtst_1 = wtst_2 r wtst_2*r;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r race_1 race_2 sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r;
run;

Title3 'By Sextype';
data vc19plus5Ambig2; set vc19plus5Ambig;
proc sort; by sextype;
proc glm; model htst_1 = htst_2 r htst_2*r; by sextype;
proc glm; model wtst_1 = wtst_2 r wtst_2*r; by sextype;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2; by sextype;
proc freq; tables r race_1 race_2 sextype; by sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2; by sextype;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r sextype;
run;

Title3 'By Race';
data vc19plus5Ambig3; set vc19plus5Ambig;
proc sort; by race_1;
proc glm; model htst_1 = htst_2 r htst_2*r; by race_1;
proc glm; model wtst_1 = wtst_2 r wtst_2*r; by race_1;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2; by race_1;
proc freq; tables r race_1 race_2 sextype; by race_1;
proc corr; var htst_1 htst_2 wtst_1 wtst_2; by race_1;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r race_1;
run;

Title3 'By Race and Gender';
data vc19plus5Ambig4; set vc19plus5Ambig;
proc sort; by race_1 sextype;
proc glm; model htst_1 = htst_2 r htst_2*r; by race_1 sextype;
proc glm; model wtst_1 = wtst_2 r wtst_2*r; by race_1 sextype;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2; by race_1 sextype;
proc freq; tables r race_1 race_2 sextype; by race_1 sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2; by race_1 sextype;
proc sort; by r race_1 sextype; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r race_1 sextype;
run;


***************************************************************************************************
***************************************************************************************************;

*******Running DF Analyses For those 19+ to Test changes to .375 and . for Ambigous Sibs*************;
Title1 'Validity Checks 19+ With Implicit+Explicit Combined Links';
Title2 'R=.375, With Blank Nulls';
data vc19plusBlankNull; set linked1;
if ageht_1 < 19 then delete;
if ageht_2 < 19 then delete;
proc sort; by r; proc means; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r sextype race_1; 
run;


Title3 'Total Sample';
data vc19plus1BlankNull; set vc19plusBlankNull;
proc glm; model htst_1 = htst_2 r htst_2*r;
proc glm; model wtst_1 = wtst_2 r wtst_2*r;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r race_1 race_2 sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r;
run;

Title3 'By Sextype';
data vc19plus2BlankNull; set vc19plusBlankNull;
proc sort; by sextype;
proc glm; model htst_1 = htst_2 r htst_2*r; by sextype;
proc glm; model wtst_1 = wtst_2 r wtst_2*r; by sextype;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2; by sextype;
proc freq; tables r race_1 race_2 sextype; by sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2; by sextype;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r sextype;
run;

Title3 'By Race';
data vc19plus3BlankNull; set vc19plusBlankNull;
proc sort; by race_1;
proc glm; model htst_1 = htst_2 r htst_2*r; by race_1;
proc glm; model wtst_1 = wtst_2 r wtst_2*r; by race_1;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2; by race_1;
proc freq; tables r race_1 race_2 sextype; by race_1;
proc corr; var htst_1 htst_2 wtst_1 wtst_2; by race_1;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r race_1;
run;

Title3 'By Race and Gender';
data vc19plus4BlankNull; set vc19plusBlankNull;
proc sort; by race_1 sextype;
proc glm; model htst_1 = htst_2 r htst_2*r; by race_1 sextype;
proc glm; model wtst_1 = wtst_2 r wtst_2*r; by race_1 sextype;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2; by race_1 sextype;
proc freq; tables r race_1 race_2 sextype; by race_1 sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2; by race_1 sextype;
proc sort; by r race_1 sextype; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r race_1 sextype;
run;

*_________________________________________________________________________________________;
*For R = .25;
Title1 'Validity Checks 19+ With Implicit+Explicit Links';
Title2 'For R=.25 With Blank Nulls';
data vc19plus25AmbigBlankNull; set vc19plus;
if r=.375 then r=.25;
proc sort; by r; proc means; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r; 
run;


Title3 'Total Sample';
data vc19plus25Ambig1BlankNull; set vc19plus25AmbigBlankNull;
proc glm; model htst_1 = htst_2 r htst_2*r;
proc glm; model wtst_1 = wtst_2 r wtst_2*r;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r race_1 race_2 sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r;
run;

Title3 'By Sextype';
data vc19plus25Ambig2BlankNull; set vc19plus25AmbigBlankNull;
proc sort; by sextype;
proc glm; model htst_1 = htst_2 r htst_2*r; by sextype;
proc glm; model wtst_1 = wtst_2 r wtst_2*r; by sextype;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2; by sextype;
proc freq; tables r race_1 race_2 sextype; by sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2; by sextype;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r sextype;
run;

Title3 'By Race';
data vc19plus25Ambig3BlankNull; set vc19plus25AmbigBlankNull;
proc sort; by race_1;
proc glm; model htst_1 = htst_2 r htst_2*r; by race_1;
proc glm; model wtst_1 = wtst_2 r wtst_2*r; by race_1;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2; by race_1;
proc freq; tables r race_1 race_2 sextype; by race_1;
proc corr; var htst_1 htst_2 wtst_1 wtst_2; by race_1;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r race_1;
run;

Title3 'By Race and Gender';
data vc19plus25Ambig4BlankNull; set vc19plus25AmbigBlankNull;
proc sort; by race_1 sextype;
proc glm; model htst_1 = htst_2 r htst_2*r; by race_1 sextype;
proc glm; model wtst_1 = wtst_2 r wtst_2*r; by race_1 sextype;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2; by race_1 sextype;
proc freq; tables r race_1 race_2 sextype; by race_1 sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2; by race_1 sextype;
proc sort; by r race_1 sextype; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r race_1 sextype;
run;


*_________________________________________________________________________________________;
*For R = .5;
Title1 'Validity Checks 19+ With Implicit+Explicit Links';
Title2 'For R=.5 Blank Nulls';
data vc19plus5AmbigBlankNull; set vc19plus;
if r=.375 then r=.5;
proc sort; by r; proc means; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r ; 
run;


Title3 'Total Sample';
data vc19plus5Ambig1BlankNull; set vc19plus5AmbigBlankNull;
proc glm; model htst_1 = htst_2 r htst_2*r;
proc glm; model wtst_1 = wtst_2 r wtst_2*r;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r race_1 race_2 sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r;
run;

Title3 'By Sextype';
data vc19plus5Ambig2BlankNull; set vc19plus5AmbigBlankNull;
proc sort; by sextype;
proc glm; model htst_1 = htst_2 r htst_2*r; by sextype;
proc glm; model wtst_1 = wtst_2 r wtst_2*r; by sextype;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2; by sextype;
proc freq; tables r race_1 race_2 sextype; by sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2; by sextype;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r sextype;
run;

Title3 'By Race';
data vc19plus5Ambig3BlankNull; set vc19plus5AmbigBlankNull;
proc sort; by race_1;
proc glm; model htst_1 = htst_2 r htst_2*r; by race_1;
proc glm; model wtst_1 = wtst_2 r wtst_2*r; by race_1;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2; by race_1;
proc freq; tables r race_1 race_2 sextype; by race_1;
proc corr; var htst_1 htst_2 wtst_1 wtst_2; by race_1;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r race_1;
run;

Title3 'By Race and Gender';
data vc19plus5Ambig4BlankNull; set vc19plus5AmbigBlankNull;
proc sort; by race_1 sextype;
proc glm; model htst_1 = htst_2 r htst_2*r; by race_1 sextype;
proc glm; model wtst_1 = wtst_2 r wtst_2*r; by race_1 sextype;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2; by race_1 sextype;
proc freq; tables r race_1 race_2 sextype; by race_1 sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2; by race_1 sextype;
proc sort; by r race_1 sextype; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r race_1 sextype;
run;


************************************************************************************************
/* Trying with all ages 5+/*;
************************************************************************************************

*******Running DF Analyses For those 5+ to Test changes to .375 and . for Ambigous Sibs*************;
*________________________________________________________________________________________;
*For R = .375;
Title1 'Validity Checks 19+ With Implicit+Explicit Combined Links';
Title2 'R=.375 On Ambig and Null For Ages 5+';
data vc5plus; set linked1;
if ageht_1 < 5 then delete;
if ageht_2 < 5 then delete;
if r=. then r=.375;
proc sort; by r; proc means; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r sextype race_1; 
run;


Title3 'Total Sample';
data vc5plus1; set vc5plus;
proc glm; model htst_1 = htst_2 r htst_2*r;
proc glm; model wtst_1 = wtst_2 r wtst_2*r;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r race_1 race_2 sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r;
run;


*_________________________________________________________________________________________;
*For R = .25;
Title1 'Validity Checks 19+ With Implicit+Explicit Links';
Title2 'For R=.25 on Ambig and Null For Ages 5+';
data vc5plus25Ambig; set vc5plus;
if r=.375 then r=.25;
if r=. then r=.25;
proc sort; by r; proc means; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r; 
run;


Title3 'Total Sample';
data vc5plus25Ambig1; set vc5plus25Ambig;
proc glm; model htst_1 = htst_2 r htst_2*r;
proc glm; model wtst_1 = wtst_2 r wtst_2*r;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r race_1 race_2 sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r;
run;


*_________________________________________________________________________________________;
*For R = .5;
Title1 'Validity Checks 5+ With Implicit+Explicit Links';
Title2 'For R=.5 On Ambig and Null For Ages 5+';
data vc5plus5Ambig; set vc5plus;
if r=.375 then r=.5;
if r=. then r=.5;
proc sort; by r; proc means; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r ; 
run;


Title3 'Total Sample';
data vc5plus5Ambig1; set vc5plus5Ambig;
proc glm; model htst_1 = htst_2 r htst_2*r;
proc glm; model wtst_1 = wtst_2 r wtst_2*r;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r race_1 race_2 sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r;
run;


*******Running DF Analyses For those 5+ to Test changes to .375 Ambigous Sibs, No Changes to Nulls*************;
*________________________________________________________________________________________;
*For R = .375;
Title1 'Validity Checks 19+ With Implicit+Explicit Combined Links';
Title2 'R=.375 On Ambig (Null as Null) For Ages 5+';
data vc5plusBLANKNULL; set linked1;
if ageht_1 < 5 then delete;
if ageht_2 < 5 then delete;
proc sort; by r; proc means; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r sextype race_1; 
run;


Title3 'Total Sample';
data vc5plus1BLANKNULL; set vc5plusBLANKNULL;
proc glm; model htst_1 = htst_2 r htst_2*r;
proc glm; model wtst_1 = wtst_2 r wtst_2*r;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r race_1 race_2 sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r;
run;


*_________________________________________________________________________________________;
*For R = .25;
Title1 'Validity Checks 19+ With Implicit+Explicit Links';
Title2 'For R=.25 on Ambig (Null as Null) For Ages 5+';
data vc5plus25AmbigBLANKNULL; set vc5plusBLANKNULL;
if r=.375 then r=.25;
proc sort; by r; proc means; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r; 
run;


Title3 'Total Sample';
data vc5plus25Ambig1BLANKNULL; set vc5plus25AmbigBLANKNULL;
proc glm; model htst_1 = htst_2 r htst_2*r;
proc glm; model wtst_1 = wtst_2 r wtst_2*r;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r race_1 race_2 sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r;
run;


*_________________________________________________________________________________________;
*For R = .5;
Title1 'Validity Checks 5+ With Implicit+Explicit Links';
Title2 'For R=.5 On Ambig (Null as Null) For Ages 5+';
data vc5plus5AmbigBLANKNULL; set vc5plusBLANKNULL;
if r=.375 then r=.5;
proc sort; by r; proc means; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r ; 
run;


Title3 'Total Sample';
data vc5plus5Ambig1BLANKNULL; set vc5plus5AmbigBLANKNULL;
proc glm; model htst_1 = htst_2 r htst_2*r;
proc glm; model wtst_1 = wtst_2 r wtst_2*r;
proc univariate; var htst_1 htst_2 wtst_1 wtst_2;
proc freq; tables r race_1 race_2 sextype;
proc corr; var htst_1 htst_2 wtst_1 wtst_2;
proc sort; by r; proc corr; var htst_1 htst_2 wtst_1 wtst_2; by r;
run;
