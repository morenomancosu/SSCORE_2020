********************************************************************************
********************************************************************************
**** REPLICATION SYNTAX FOR 
*** “Is it the message or the messenger?” 
*** Conspiracy endorsement and media sources - Social Science Computer Review
*** Moreno Mancosu and Federico Vegetti

set more off, perm
*ssc install blindschemes /*Installs blindschemes if not already installed */
set scheme plotplain,perm

**** Open the file

* cd "Path/to/dir"

use "data_replication",replace

*********************************************************
******************** DATA MANAGEMENT ********************

********************************************
******** sociodemographic variables ********
********************************************

*** ethnicity 

fre dem3

rename dem3 ethn

*** income

fre dem7

recode dem7 (1=10) (2=27) (3=42) (4=62.5) (5=87) (6=120),gen(income)

*** working condition

recode dem6 (1 8=1 "Employed") (2 3= 2 "Self/enterpreneur") ///
 (4 5 6 7=3 "Unemployed/homemaker/student") ///
 (9 10 = 4 "Retired/Unable to work") (11=.),gen(workcond)

encode dem1,gen(gender)
rename dem2 age
recode dem4 (1 2 3=1 "No college") (4 5=2 "Until BA") (6 7 8=3 "More than BA"),gen(educ)

*** conspiracy ideation

recode q21 q22 q23 q24 q25 q26 q27 (8=.),gen(cons1 cons2 cons3 cons4 cons5 cons6 cons7)

alpha cons1 cons2 cons3 cons4 cons5 cons6,item

egen cons = rowmean(cons1 cons2 cons3 cons4 cons5 cons6)

**** trust

recode q91 q92 q93 q94 q95 (12=.),gen(trust1 trust2 trust3 trust4 trust5)

alpha trust1 trust2 trust3 trust5,item

gen trust = (trust1 + trust2 + trust3 + trust5)/4

**** interest in politics

fre q10a q10b

recode q10a (1 2=1) (3 4=0),gen(q10a_r)

gen inter_p = q10a_r
replace inter_p = q10b if q10b!=.

recode inter_p (1=1 "interested") (2=2 "Not interested") (9=.),gen(inter)

**** partisanship

fre q17

recode q17 (1 2 3=1 "Lib.") (4=2 "Indep.") (5 6 7=3 "Cons") (99=.),gen(partyid)

recode q17 (1=1 "Ext. Lib.") (2=2 "Smwt liberal") (3=3 "Slight lib.") (4=4 "Indep.") ///
 (5=5 "Sligth cons.") (6=6 "Smwt cons.") (7=7 "Ext. cons") (99=.),gen(libcons)

****************************
******** Experiment ********
****************************

**** treatments

recode randnumber4 (2 4=1 "Mainstream") (1 3=2 "Alternative"),gen(outlet)
recode randnumber4 (3 4=1 "Debunking") (1 2=2 "Conspiracist"),gen(news)

recode randnumber4 (1=1 "Alternative/Conspiracist") (2=2 "Mainstram/Conspiracist") ///
(3=3 "Alternative/Debunking") (4=4 "Mainstram/Debunking"),gen(outlet_news)

**** heard of?

gen q15 = q15t1
replace q15 = q15t2 if q15t2!=""
replace q15 = q15t3 if q15t3!=""
replace q15 = q15t4 if q15t4!=""

encode q15,gen(heardof_prov)

recode heardof_prov (1=1 "No") (2=2 "Unsure") (3=3 "Yes"),gen(heardof)
drop heardof_prov

recode heardof (1=1 "No") (2 3=2 "Unsure/Yes"),gen(heardof2)

**** believe in it?

gen q16 = q16t1
replace q16 = q16t2 if q16t2!=.
replace q16 = q16t3 if q16t3!=.
replace q16 = q16t4 if q16t4!=.

recode q16 (12=.),gen(believe_2)

************************************************
******************** TABLES ********************

*cd "path_to_dir"

***********************************
******** Model 1 - Table 2 ********
***********************************

reg believe_2 i.outlet##i.news c.cons i.gender c.age i.educ i.ethn i.inter c.trust5

/*outreg2 exports estimates to an excel file - first two columns
 of Figure 2*/
*outreg2 using "Tab1",excel dec(2) side 

***********************************
******** Model 2 - Table 2 ********
***********************************

reg believe_2 i.news##c.cons i.outlet##c.cons i.gender c.age i.educ i.ethn i.inter c.trust5

/*outreg2 exports estimates to an excel file - first two columns
 of Figure 2*/
*outreg2 using "Tab1",excel dec(2) side 

***********************************
******** Model 3 - Table 2 ********
***********************************

reg believe_2 i.outlet##i.news##c.cons i.gender c.age i.educ i.ethn i.inter c.trust5

/*outreg2 exports estimates to an excel file - first two columns
 of Figure 2*/
*outreg2 using "Tab1",excel dec(2) side 

***********************************
**** Appendix 2 - Descriptives ****
***********************************

tab educ, gen(educ_d)
tab ethn, gen(ethn_d)

tabstat believe_2 outlet news cons gender age educ_d2 educ_d3 ethn_d2 ethn_d3 ethn_d4 ///
ethn_d5 ethn_d6 inter trust5 if e(sample),statistics(mean sd min max) columns(statistics) format(%9.2f)

*************************************************
******************** FIGURES ********************

**************************
******** Figure 2 ********
**************************

reg believe_2 i.outlet##i.news c.cons i.gender c.age i.educ i.ethn i.inter c.trust5

margins, at(outlet=(1 2) news=(1 2)) 
marginsplot,recast(bar) xdim(outlet) bydim(news) byopt(title("")) title("News content")  ///
yscale(r(4 7)) ylab(4 (1) 7)  ///
plotopts(barw(.6)) ///
ytitle("Predicted plausibility") ///
xtitle("Outlet type")

**************************
******** Figure 3 ********
**************************

reg believe_2 i.news##c.cons i.outlet##c.cons i.gender c.age i.educ i.ethn i.inter c.trust5
*outreg2 using "Tab1",excel dec(2) side
*** 1
margins,dydx(news) at(cons=(1(1)7)) 
marginsplot,recast(line) xscale(r(0.5 2.5)) ///
title("News type") ///
ylab(2 (1) -7) yscale(r(2 -7))  ///
xsize(7) ysize(6)  name(news, replace) ///
ytitle("AME (Conspiracy-endorsing vs. Debunking news)") xtitle("Conspiracy mentality") yline(0)

*** 2
margins,dydx(outlet) at(cons=(1(1)7)) 
marginsplot,recast(line) xscale(r(0.5 2.5)) ///
title("Outlet type") ///
ylab(2 (1) -7) yscale(r(2 -7))  ///
xsize(7) ysize(6)  name(outlet, replace) ///
ytitle("AME (Alternative vs. Mainstream outlet)") xtitle("Conspiracy mentality") yline(0)
 
graph combine news outlet

*outreg2 using "Tab1",excel dec(2) side
*margins,at(outlet=(1 2) news=(1 2) ) 
*marginsplot, recast(bar) xdim(news outlet)


**************************
******** Figure 4 ********
**************************

reg believe_2 i.outlet##i.news##c.cons i.gender c.age i.educ i.ethn i.inter c.trust5

margins,dydx(news) at(outlet=(1 2) cons=(7)) 
marginsplot,recast(scatter) xscale(r(0.5 2.5)) ///
title("High copnspiracy mentality") ///
yscale(r(.1 3)) ylab(0 (1) 3)  ///
xsize(7) ysize(6)  name(consp, replace) yline(0) ///
ytitle("AME (Conspiracy-endorsing vs. Debunking news)") xtitle("Outlet type")
 

**************************
******** Figure 5 ********
**************************

margins,dydx(news) at(outlet=(1 2) cons=(1)) 
marginsplot,recast(scatter) xscale(r(0.5 2.5)) ///
title("Low conspiracist mentality") ///
ylab(-4 (1) -8) yscale(r(-4 -8))  ///
xsize(7) ysize(6)  name(nonconsp, replace) ///
ytitle("AME (Conspiracy-endorsing vs. Debunking news)") xtitle("Outlet type")


********************************
******** Figure 4 - App ********
********************************

reg believe_2 i.outlet##i.news##c.cons i.gender c.age i.educ i.ethn i.inter c.trust5


margins, at(outlet=(1 2) news=(1 2) cons=(7)) 
marginsplot,recast(bar)  xdim(news ) bydim(outlet) title("") ///
byopts(title("Conspiracists")) ///
yscale(r(0 10)) ylab(0 (1) 10)  ///
plotopts(barw(.6)) ///
ytitle("Predicted evaluation") ///
xtitle("News type") name(consp, replace)
 
********************************
******** Figure 4 - App ********
********************************

margins, at(outlet=(2 1) news=(1 2) cons=(1)) 
marginsplot,recast(bar) title("") xdim(news ) bydim(outlet) ///
byopts(title("Non-conspiracists")) ///
yscale(r(0 10)) ylab(0 (1) 10)  ///
plotopts(barw(.6)) ///
ytitle("Predicted evaluation") ///
xtitle("News type") name(noconsp_app, replace)
 

********* EOF *********
