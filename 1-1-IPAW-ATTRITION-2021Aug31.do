********************************************************************************
********************************************************************************
*** IPAW ESTIMATION: ATTRITION FROM V1 TO V6
********************************************************************************
********************************************************************************

********************************************************************************
********************************************************************************
*** IPAW MICE ESTIMATION: ATTRITION FROM V1 TO V6
********************************************************************************
********************************************************************************

global adjustorsv1															///
	c.agev1	 																/// 
	i.black																	///
	i.female 																///
	i.elevel02																///
	c.bmi01 																///
	i.diabts02																///
	i.hypert05																///
	i.drnkr01


*** NUMERATOR
logit active_v1v6 i.cigt01, vce(robust)

	predict wgt_num
	
*** DENOMINATOR	
logit active_v1v6 i.cigt01 $adjustorsv1, vce(robust)

	predict wgt_den

********************************************************************************
*** STABILIZED WEIGHTS
********************************************************************************

gen wgt_v1v6_mi=wgt_num/wgt_den
	
	su wgt_v1v6 if active_v1v6==1 ,d

graph box wgt_v1v6 if active_v1v6==1 ,									///
	ytitle(Weights)															///
	title("Stabilized IPAW's Distribution" " ")								///
	text(2.7 80 "Mean {it:(SD)} =`: di %2.1f r(mean)' (`: di %2.1f r(sd)')"		///
	"Median {it: (IQR)} = `: di %2.1f r(p50)' (`: di %2.1f r(p25)' - `: di %2.1f r(p75)')" ///
	,just(left) size(small)) 
graph export "Graphs\WGT-MICE-BOX-DISTRIBUTION.png", replace


********************************************************************************
*** UNSTABILIZED WEIGHTS
********************************************************************************

gen uwgt_v1v6=1/wgt_den
	
	su wgt_den if active_v1v6==1
	su uwgt_v1v6,d
	su active_v1v6
	su uwgt_v1v6 if active_v1v6==1 ,d

hist uwgt_v1v6 ,															///
	xtitle(Weights)															///
	title("Unstabilized IPAW's Distribution" " ")										///
	text(.060 125 "Mean {it:(SD)} =`: di %2.1f r(mean)' (`: di %2.1f r(sd)')"		///
	"Median {it: (IQR)} = `: di %2.1f r(p50)' (`: di %2.1f r(p25)' - `: di %2.1f r(p75)')" ///
	,just(left) size(small)) 
graph export "Graphs\UWGT-BOX-DISTRIBUTION.png", replace 
  
  
save "Data\mdf\MDF-WGT-IPAW-SMOKING-2021Aug31", replace



