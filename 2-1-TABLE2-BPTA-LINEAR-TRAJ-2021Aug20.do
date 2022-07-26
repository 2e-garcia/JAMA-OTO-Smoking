********************************************************************************
********************************************************************************
*** ASSOCIATION BETWEEN V1 SMOKING STATUS AND HEARING LOSS
********************************************************************************
********************************************************************************

global model1																///
	c.agev6																	///
	i.female																///
	i.racecenter															///
	i.elevel02																///
	c.bmi61																///
	i.hypert65																///
	i.diabts64																///
	i.drnkr61																///
	i.ocupnoise

su wgt_v1v6_mi, d

reg bpta group_2 group_3 $model1 												///
	if asample==1 & wgt_v1v6_mi!=.
eststo m1

reg wpta group_2 group_3 $model1 [aw=wgt_v1v6_mi]								///
	if analyticsample==1 
eststo m2

reg QSavg_v6 group_2 group_3 $model1 												///
	if analyticsample==1 & wgt_v1v6_mi!=.
eststo m3

reg QSavg_v6 group_2 group_3 $model1 [aw=wgt_v1v6_mi]								///
	if analyticsample==1 
eststo m4

#delimit ;

cap n esttab * using Tables/TABLE2-MICE-LINEAR-TRAJ.csv,
			style(tab) label notype replace
			stats(N, fmt(0))
			cells("b( fmt(%10.2fc)) ci_l(fmt(%10.2fc)) ci_u(fmt(%10.2fc)) p(fmt(%10.3fc))")
			title(Linear regression model for the relationship between smoking status at V6 and better-ear pure tone average at V6)   
			drop(_cons 0.female 0.racecenter 0.elevel02 0.bmi_catv6 
			0.hypert65 0.diabts64 1.drnkr61 0.ocupnoise)
			collabels(none) eqlabels(none) mlabels(none) mgroups(none);

#delimit cr
cap n estimates clear
