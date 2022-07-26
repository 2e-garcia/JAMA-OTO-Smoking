* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* ARIC 
* FOR USE IN PROJECT:
* * * SMOKING AND HEARING
* * * * JANUARY 2020
* * * * * 1. DATA SET UP
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

clear
clear matrix
set more off
set scheme s1color, permanently
ssc install estout
ssc install table1_mc

net from https://www.andrew.cmu.edu/user/bjones/traj/
net install traj, force

cd "S:\CCHPH_ARIC_3313_Smoking_Hearing"

use "Data\mdf\mdf_2021Aug24.dta"

/*Setting and study population
The Atherosclerosis Risk in Communities (ARIC) study is a population-based 
prospective cohort study of 15,792 men and women ages 45-64 years recruited
in 1987 – 1989 form 4 US communities. At Visit 6, 3737 participants underwent
pure-tone audiometry and N=3628 had complete audiometric data for the speech
frequencies, and who have smoking history recorded at V1, V4 and V6.*/

********************************************************************************
********************************************************************************
*** DEFINING THE ANALYTIC SAMPLE	
********************************************************************************
********************************************************************************

gen analyticsample=1
	
	replace analyticsample=0 if missing(v6date61)							//	Dropped=11,789
		tab analyticsample	
	
	replace analyticsample=0 if cmpltheardata==0							//	D=375
		tab analyticsample	
	
	replace analyticsample=0 if missing(racecenter)							//	D=20
		tab analyticsample			
		
		// N=3,607
		
gen asample=analyticsample
		
	replace asample=0 if missing(ocupnoise)									//	M=20
		tab asample		

	replace asample=0 if missing(elevel02)									//	M=20
		tab asample
		
	replace asample=0 if missing(bmi01)										//	M=20
		tab asample

	replace asample=0 if missing(diabts02)									//	M=20
		tab asample
		
	replace asample=0 if missing(hypert05)									//	M=20
		tab asample
		
	replace asample=0 if missing(drnkr01)									//	M=20
		tab asample

	replace asample=0 if missing(drnkr61)									//	M=20
		tab asample

	replace asample=0 if missing(bmi_catv6)									//	M=20
		tab asample
		
global model1																///
	c.agev6																	///
	i.female																///
	i.racecenter															///
	i.elevel02																///
	i.bmi_catv6																///
	i.hypert65																///
	i.diabts64																///
	i.drnkr61																///
	i.ocupnoise	
		
*** MISSING COVARIATES
egen complete6=rowmiss(														///
	bptacat bpta															///
	agev1 agev4 															///
	female black elevel02 													///
	ocupnoise																///
	bmi_catv6 hypert65 diabts64 drnkr61 smoker_catv6)
	
********************************************************************************
********************************************************************************
*** INVERSE PROBABILITY OF ATTRITION WEIGHTS
********************************************************************************
********************************************************************************

********************************************************************************
*** MISSING INFO AT V1
********************************************************************************
codebook						///
	agev1	 					/// Missing = 0
	cigt01						/// Missing = 0
	black						/// Missing = 0
	female 						/// Missing = 0
	elevel02					/// Missing = 5	
	bmi01 						/// Missing = 2
	diabts02					/// Missing = 26	
	hypert05					/// Missing = 20
	drnkr01						/// Missing = 8
		if analyticsample==1

egen miss_cov=rowmiss(														///
	agev1												 					/// 
	cigt01												 					/// 
	black												 					/// 
	female 												 					/// 
	elevel02											 					/// 
	bmi01 												 					/// 
	diabts02											 					/// 
	hypert05											 					/// 
	drnkr01)																///
		if analyticsample==1
		
	replace miss_cov=1														///
		if miss_cov>0 & analyticsample==1
		
********************************************************************************
********************************************************************************
*** SUMMARY STATISTICS
********************************************************************************
********************************************************************************

/*** Summary Statistics Analytic Sample		
table1_mc, by(analyticsample)														///
	vars(																	///			
	bpta			conts %4.2f \											///
	cigt01			cat %4.2f \ 											///
	agev1 			conts %4.2f \											///
	racecenter		cat %4.2f \												///
	female 			bin %4.2f \												///
	elevel02		cat %4.2f \							 					///	
	bmi01 			contn %4.2f \ 											///
	diabts02		bin %4.2f \												///	
	hypert05		bin %4.2f \												///
	drnkr01 		cat %4.2f)												///
	nospace onecol missing total(before) 							///
	saving("Tables\TABLE0-1-SUMSTATS-MISSING-COVARIATES.xls", replace)		
*/
		
*** Creating variable to check if patient is available at V6
gen active_v1v6=1 
	
	replace active_v1v6=0													///
		if missing(v6date61)

*** Summary Statistics Available at V6		
table1_mc, by(active_v1v6)													///
	vars(cigt01		cat %4.2f \ 											///
	agev1 			conts %4.2f \											///
	racecenter		cat %4.2f \												///
	black			bin %4.2f \												///
	female 			bin %4.2f \												///
	elevel02		cat %4.2f \							 					///	
	bmi01 			contn %4.2f \ 											///
	diabts02		bin %4.2f \												///	
	hypert05		bin %4.2f \												///
	drnkr01 		cat %4.2f)												///
	nospace onecol missing total(before) 							///
	saving("Tables\TABLE0-1-SUMSTATS-ATTRITION-v1v6-Aug24.xls", replace)
			
		
		
********************************************************************************
********************************************************************************
*** IPAW ESTIMATION: ATTRITION FROM V4 TO V6
********************************************************************************
********************************************************************************

do "Dofiles\1-1-IPAW-ATTRITION-2021Aug31.do"
		
********************************************************************************
********************************************************************************
*** GBTM ANALYSIS
********************************************************************************
********************************************************************************
 
clear

use "Data\mdf\MDF-WGT-IPAW-SMOKING-2021Aug31.dta"

*** V1
gen smoking_t1=(cigt01==2)													///
	if cigt01!=.

gen sm_time_1=0
	
*** V2
gen smoking_t2=(cigt21==2)													///
	if cigt21!=.

gen sm_time_2=3

*** V3
gen smoking_t3=(cigt31==2)													///
	if cigt31!=.

gen sm_time_3=5

*** V4
gen smoking_t4=(cigt41==2)													///
	if cigt41!=.

gen sm_time_4=9

*** V5
gen smoking_t5=(cigt52==2)													///
	if cigt52!=.

gen sm_time_5=23

*** V6
gen smoking_t6=(cigt62==2)													///
	if cigt62!=.

gen sm_time_6=27

keep if asample==1 & wgt_v1v6!=.

traj , var(smoking_t*) indep(sm_time_*) 											///
	model(logit) order (3 2 2)

egen smoking_con=concat(smoking_t1 smoking_t2 smoking_t3 smoking_t4 	///
	smoking_t5 smoking_t6)	

tab smoking_con

/*
program summary_table_procTraj
    preserve
    *now lets look at the average posterior probability
	gen Mp = 0
	foreach i of varlist _traj_ProbG* {
	    replace Mp = `i' if `i' > Mp 
	}
    sort _traj_Group
    *and the odds of correct classification
    by _traj_Group: gen countG = _N
    by _traj_Group: egen groupAPP = mean(Mp)
    by _traj_Group: gen counter = _n
    gen n = groupAPP/(1 - groupAPP)
    gen p = countG/ _N
    gen d = p/(1-p)
    gen occ = n/d
    *Estimated proportion for each group
    scalar c = 0
    gen TotProb = 0
    foreach i of varlist _traj_ProbG* {
       scalar c = c + 1
       quietly summarize `i'
       replace TotProb = r(sum)/ _N if _traj_Group == c 
    }
	gen d_pp = TotProb/(1 - TotProb)
	gen occ_pp = n/d_pp
    *This displays the group number [_traj_~p], 
    *the count per group (based on the max post prob), [countG]
    *the average posterior probability for each group, [groupAPP]
    *the odds of correct classification (based on the max post prob group assignment), [occ] 
    *the odds of correct classification (based on the weighted post. prob), [occ_pp]
    *and the observed probability of groups versus the probability [p]
    *based on the posterior probabilities [TotProb]
    list _traj_Group countG groupAPP occ occ_pp p TotProb if counter == 1
    restore
end
*/

summary_table_procTraj

*** GRAPH
	
trajplot, ytitle("Current smoker") ylabel(0 1)								///
	xtitle("Years after visit 1 ") xlabel(0 3 5 9 23 27)
graph export "Graphs\Graph-traj-GBTM-5V-2021Aug24.png", replace


tab _traj_Group, gen(group_)

********************************************************************************
*** COMPLETE SAMPLE - TABLE 1
********************************************************************************

mi extract 0, clear	

table1_mc 																	///
	if asample==1 & wgt_v1v6!=.										///
	, by(_traj_Group)														///
	vars(																	///
	agev6 			conts %4.1f \											///
	black			bin %4.1f \												///
	female 			bin %4.1f \												///
	elevel02		cat %4.1f \							 					///	
	bmi_catv6 		cat %4.1f \ 											///
	diabts64		bin %4.1f \												///	
	hypert65		bin %4.1f \												///
	drnkr61 		cat %4.1f \												///
	ocupnoise 		bin %4.1f \												///
	bpta			contn %4.1f \ 											///
	bptacat4		cat %4.1f \							 					///	
	lowf_bpta		contn %4.1f \ 											///
	highf_bpta		contn %4.1f	\											///
	QSavg_v6		contn %4.1f \ _traj_Group cat %4.1f)											///
	nospace onecol missing total(before)		 							///
	saving("Tables\TABLE1-BASELINE-SUMSTATS-SMOKER-TRAJ-Aug24.xls", replace)	

preserve

keep if asample==1 & wgt_v1v6!=.

anova agev6 i._traj_Group

estat esize
	
*******************************************************************************
********************************************************************************
*** WEIGHTED MAIN DATA SET
********************************************************************************
********************************************************************************

merge 1:1 id																///
	using "Data\mdf\mdf_2021Aug31.dta", keepusing(cancer_ever)

save "Data\mdf\MDF-WGT-TRAJ-SMOKING-2021Aug31.dta", replace
