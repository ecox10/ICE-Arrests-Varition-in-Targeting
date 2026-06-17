*==================================
*  ICE Arrests - Variation in Targeting 
*==================================
* Ellie Cox and Caitlin Patler
* June 17, 2026
*==================================

*==================================
* Does national analysis 
*==================================

*==================================
* inputs:
* 		unsmoothed_arrests_criminality_method_fy15_25_corrected.csv: Appended Hernandez, and DDP data 
*		Appended_Garcia.dta: Garcia Hernandez data
* 		AdminArrests_MidOct.dta: DDP data covering 2023+
*==================================

*==================================
* Outputs: 
* 		Figure 1 panels (a) and (b): arrests_ddp_2015_2025(OCT)_noncit.pdf and arrests_2015_2025_bymethod_noncit.pdf
* 		Figure 3: meandecomp_byaor.pdf
*==================================

*==================================
* Some lite data prep
*==================================

import delimited "$data/unsmoothed_arrests_criminality_method_fy15_26.csv", clear varnames(1)

rename apprehensiondate date_st
gen date = date(date_st, "YMD")
format date %td
drop if date > dmy(10, 3, 2026)

* Collapse for total arrests 
preserve 
collapse (sum) arrests , by(date)
tempfile arrests 
save `arrests', replace
restore 

collapse (sum) pct if criminality == "Convicted", by(date)
merge 1:1 date using `arrests'
drop _merge

gen year = year(date)

* Moving average
tsset date  
tssmooth ma ma_arrests = arrests, window(7 1 7)
tssmooth ma ma_conv = pct, window(7 1 7)

**** Calculates # of arrests (listed in appendix) 
* Hernandez 
preserve 
collapse (sum) arrests if inrange(date, dmy(1,10,2015), dmy(31, 8, 2023))
sum arrests
restore 
* DDP 
preserve 
collapse (sum) arrests if inrange(date, dmy(1,9,2023), dmy(10, 3, 2026))
sum arrests
restore 
* 2015-2025
preserve 
collapse (sum) arrests if inrange(date, dmy(1,10,2015), dmy(10, 3, 2026))
sum arrests
restore 

* Average # arrests for certain time periods 
sum arrests if inrange(date, dmy(21, 1, 2025), dmy(10, 3, 2026))
sum arrests if inrange(date, dmy(1,10,2015), dmy(19, 1, 2025))
sum pct if inrange(date, dmy(21, 1, 2025), dmy(10, 3, 2026))

* Add non-citizen count from ACS 
preserve 
use "$data/noncit_2023_byaor.dta", clear
rename year datayear 
gen year = datayear + 1
keep ApprehensionAOR year noncit_2023
collapse (sum) noncit = noncit_2023, by(year)
tempfile noncit 
save `noncit', replace
restore 

merge m:1 year using `noncit'

* Calculate arrests per 100k noncit 
gen ma_arrests_noncit = (ma_arrests/noncit) * 100000

*****
* Figure 1 (a)
*****
twoway (line ma_arrests_noncit date if date >= dmy(1,10,2015), lcolor(black) yaxis(1)) ///lcolor("79 56 62 49")
(line ma_conv date if date >= dmy(1,10,2015), lcolor("0 153 0") yaxis(2)), ///80 14 48 0
xline(20839, lcolor(red)) ///
xline(23762, lcolor(red)) ///
xline(22300, lcolor(red)) ///
text(2.25 21075 "Trump's First", size(small)) ///
text(2 21075 "Inauguration", size(small)) ///
text(3.75 22500 "Biden's", size(small)) ///
text(3.5 22590 "Inauguration", size(small)) ///
text(3 23470 "Trump's Second", size(small)) ///
text(2.75 23530 "Inauguration", size(small)) ///
scheme(plotplainblind) ///
xtitle("") ///
ytitle("Number of Arrests per 100k Non-Citizens", axis(1) margin(0 0 0 12)) ///
ytitle("Percent Convicted of a Crime", axis(2) margin(0 0 0 22)) ///
xlabel(#20, ang(90) format(%tdMon_CCYY) labgap(vhuge)) ///
ylabel(0(0.5)4, labgap(large) labcolor("41 64 62")) ///
ylabel(0(10)90, axis(2) labgap(small) labcolor("82 106 57")) ///
xlabel(20355(365)24175) ///
yscale(titlegap(2)) ///
xsize(8) ///
yscale(axis(2) titlegap(3)) ///
legend(pos(6) rows(1) order(1 "Total Arrests" 2 "Percent of Arrested People with Criminal Convictions"))
graph export "$figs/arrests_ddp_2015_2025(OCT)_noncit.pdf", replace width(20)

*==================================
* Prep data by apprehension method
*==================================


import delimited "$data/unsmoothed_arrests_criminality_method_fy15_26.csv", clear varnames(1)

rename apprehensiondate date_st
gen date = date(date_st, "YMD")
format date %td

* Code up LEA/community arrests
gen appmethod = 1 if (apprehensionmethod == "287(g) Program" | apprehensionmethod == "Anti-Smuggling" | ///
apprehensionmethod == "CAP Federal Incarceration" | apprehensionmethod == "CAP Local Incarceration" | ///
apprehensionmethod == "CAP State Incarceration" | apprehensionmethod == "Criminal Alien Program" | ///
apprehensionmethod == "ERO Reprocessed Arrest" | apprehensionmethod == "Law Enforcement Agency Response Unit" | ///
apprehensionmethod == "Organized Crime Drug Enforcement Tas" | apprehensionmethod == "Other Agency (turned over to INS)" | ///
apprehensionmethod == "Other Task Force" | apprehensionmethod == "Probation and Parole" | ///
apprehensionmethod == "Custodial Arrest" | apprehensionmethod == "Patrol Border" | apprehensionmethod == "Patrol Interior") 
replace appmethod = 2 if (apprehensionmethod == "Located" | apprehensionmethod == "Non-Custodial Arrest" | ///
apprehensionmethod == "Worksite Enforcement")
replace appmethod = 3 if apprehensionmethod == "Boat Patrol" | apprehensionmethod == "Crewman/Stowaway" | ///
apprehensionmethod == "Inspections" | apprehensionmethod == "Other efforts" | apprehensionmethod == "Traffic Check" | apprehensionmethod == "Transportation Check Aircraft" | ///
apprehensionmethod == "Transportation Check Bus" | apprehensionmethod == "Transportation Check Freight Train" | ///
apprehensionmethod == "Transportation Check Passenger Train" | apprehensionmethod == "Presented During Inspection"


* Collapse for total arrests 
preserve 
collapse (sum) arrests pconv_tot = pct, by(date appmethod)
tempfile arrests 
save `arrests', replace
restore 

collapse (sum) pconv = pct if criminality == "Convicted", by(date appmethod)
merge 1:1 date appmethod using `arrests'
drop _merge

gen year = year(date)

gen pconv_appmethod = (pconv/pconv_tot)*100 

* Calculate moving average
xtset appmethod date 
tssmooth ma ma_arrests = arrests, window(7 1 7)
tssmooth ma ma_pconv = pconv_appmethod, window(7 1 7)

* Add non-citizen count from ACS 
preserve 
use "$data/noncit_2023_byaor.dta", clear
rename year datayear 
gen year = datayear + 1
keep ApprehensionAOR year noncit_2023
collapse (sum) noncit = noncit_2023, by(year)
tempfile noncit 
save `noncit', replace
restore 

merge m:1 year using `noncit'

* Calculate arrests per 100k noncit 
gen ma_arrests_noncit = (ma_arrests/noncit) * 100000
sort appmethod date 

*****
* Figure 1 (b)
*****
twoway (line ma_arrests_noncit date if appmethod == 1 & date >= dmy(1,10,2015), lcolor("204 0 0")  lpattern(solid) yaxis(1)) ///
(line ma_pconv date if appmethod == 1 & date >= dmy(1,10,2015), lcolor("255 138 138") yaxis(2) lpattern(dash)) ///
(line ma_arrests_noncit date if appmethod == 2 & date >= dmy(1,10,2015), lcolor("0 153 255") lpattern(solid) yaxis(1)) ///
(line ma_pconv date if appmethod == 2 & date >= dmy(1,10,2015), lcolor("184 226 255") yaxis(2) lpattern(dash)), ///
xline(20839, lcolor(red)) ///
xline(23762, lcolor(red)) ///
xline(22300, lcolor(red)) /// 
text(1.5 21075 "Trump's First", size(small)) ///
text(1.25 21075 "Inauguration", size(small)) ///
text(3.75 22500 "Biden's", size(small)) ///
text(3.5 22590 "Inauguration", size(small)) ///
text(3 23470 "Trump's Second", size(small)) ///
text(2.75 23530 "Inauguration", size(small)) ///
scheme(plotplainblind) ///
xtitle("") ///
ytitle("Number of Arrests per 100k Non-Citizens", axis(1) margin(0 0 0 12)) ///
ytitle("Percent with a Criminal Conviction", axis(2) margin(0 0 0 12)) ///
xlabel(#20, ang(90) format(%tdMon_CCYY) labgap(vhuge)) ///
ylabel(0(0.5)4, labgap(large) labcolor("41 64 62")) ///
ylabel(0(10)100, axis(2) labgap(large)) ///
xlabel(20355(365)24175) ///
yscale(titlegap(2)) ///
xsize(8) ///
legend(pos(6) rows(2) order(1 "# LEA Arrests" 2 "# Community Arrests" 3 "% LEA with Conviction" 4 "% Community Arrests with Conviction")) // 
graph export "$figs/arrests_2015_2025_bymethod_noncit.pdf", replace width(20)


*==================================
* Mean Decomposition Figure
*==================================


/* ===== SECTION 1: LOAD DATA AND PREP for term 1 ======= */
use "$data/Appended_Garcia.dta", clear

gen arrest_date_temp = date(apprehensiondate, "20YMD")
format arrest_date_temp %td
rename arrest_date_temp date

replace apprehensionaor = "San Antonio Area of Responsibility" if apprehensionaor == "Houston Area of Responsibility"
drop if apprehensionaor == "" | apprehensionaor == "HQ Area of Responsibility" | apprehensionaor == "NA"
rename apprehensionaor ApprehensionAOR

keep if inrange(date, mdy(1,20,2017) - 414, mdy(1,20,2017) + 414)

gen method = 1 if apprehensionmethod == "287(g) Program" | apprehensionmethod == "Anti-Smuggling" | ///
apprehensionmethod == "CAP Federal Incarceration" | apprehensionmethod == "CAP Local Incarceration" | ///
apprehensionmethod == "CAP State Incarceration" | apprehensionmethod == "Criminal Alien Program" | ///
apprehensionmethod == "ERO Reprocessed Arrest" | apprehensionmethod == "Law Enforcement Agency Response Unit" | ///
apprehensionmethod == "Organized Crime Drug Enforcement Tas" | apprehensionmethod == "Other Agency (turned over to INS)" | ///
apprehensionmethod == "Other Task Force" | apprehensionmethod == "Probation and Parole" | ///
apprehensionmethod == "Custodial Arrest" | apprehensionmethod == "Patrol Border" | apprehensionmethod == "Patrol Interior"
replace method = 2 if apprehensionmethod == "Located" | apprehensionmethod == "Non-Custodial Arrest" | ///
apprehensionmethod == "Worksite Enforcement"
replace method = 3 if apprehensionmethod == "Boat Patrol" | apprehensionmethod == "Crewman/Stowaway" | ///
apprehensionmethod == "Inspections" | apprehensionmethod == "Other efforts" | apprehensionmethod == "Traffic Check" | apprehensionmethod == "Transportation Check Aircraft" | ///
apprehensionmethod == "Transportation Check Bus" | apprehensionmethod == "Transportation Check Freight Train" | ///
apprehensionmethod == "Transportation Check Passenger Train" | apprehensionmethod == "Presented During Inspection"

gen convicted = 1 if mostseriouscriminalchargestatus == "Convicted"

gen byte post = (date >= mdy(1,20,2017))

tempfile term1 
save `term1', replace


/* ===== SECTION 2: LOAD DATA AND PREP for term 2 ======= */
use "$data/AdminArrests_MidMar.dta", clear 
replace ApprehensionAOR = "San Antonio Area of Responsibility" ///
    if inlist(ApprehensionAOR, "Harlingen Area of Responsibility", "Houston Area of Responsibility")
	drop if ApprehensionAOR == "" | ApprehensionAOR == "HQ Area of Responsibility"
	
gen method = 1 if ApprehensionMethod == "287(g) Program" | ApprehensionMethod == "Anti-Smuggling" | ///
ApprehensionMethod == "CAP Federal Incarceration" | ApprehensionMethod == "CAP Local Incarceration" | ///
ApprehensionMethod == "CAP State Incarceration" | ApprehensionMethod == "Criminal Alien Program" | ///
ApprehensionMethod == "ERO Reprocessed Arrest" | ApprehensionMethod == "Law Enforcement Agency Response Unit" | ///
ApprehensionMethod == "Organized Crime Drug Enforcement Task Force" | ApprehensionMethod == "Other Agency (turned over to INS)" | ///
ApprehensionMethod == "Other Task Force" | ApprehensionMethod == "Probation and Parole" | ///
ApprehensionMethod == "Custodial Arrest" | ApprehensionMethod == "Patrol Border" | ApprehensionMethod == "Patrol Interior"
replace method = 2 if ApprehensionMethod == "Located" | ApprehensionMethod == "Non-Custodial Arrest" | ///
ApprehensionMethod == "Worksite Enforcement"
replace method = 3 if ApprehensionMethod == "Boat Patrol" | ApprehensionMethod == "Crewman/Stowaway" | ///
ApprehensionMethod == "Inspections" | ApprehensionMethod == "Other efforts" | ApprehensionMethod == "Traffic Check" | ApprehensionMethod == "Transportation Check Aircraft" | ///
ApprehensionMethod == "Transportation Check Bus" | ApprehensionMethod == "Transportation Check Freight Train" | ///
ApprehensionMethod == "Transportation Check Passenger Train" | ApprehensionMethod == "Presented During Inspection"

label define methodlbl 1 "LEA" 2 "CA" 3 "Other"
label values method methodlbl

gen byte convicted = (ApprehensionCriminality == "1 Convicted Criminal")

keep if  inrange(date, mdy(1,20,2025) - 414, mdy(1,20,2025) + 414)
gen byte post = (date >= mdy(1,20,2025))

tempfile term2 
save `term2', replace


/* ===== SECTION 3: Loop to do a national calculation for each term ======== */

foreach t in term1 term2 {
	use ``t'', clear
	gen ones = 1
	collapse (sum) n=ones c=convicted, by( method post)

	reshape wide n c, i(method) j(post)

	rename n0 n_pre
	rename n1 n_post
	rename c0 c_pre
	rename c1 c_post

	recode n_pre n_post c_pre c_post (.=0)

	/* ===== Pre-decomp calculations ======== */
	egen N_pre  = total(n_pre)
	egen N_post = total(n_post)

	gen s_pre      = n_pre  / N_pre
	gen s_post     = n_post / N_post

	gen c_rate_pre  = cond(n_pre>0,  c_pre /n_pre,  0)
	gen c_rate_post = cond(n_post>0, c_post/n_post, 0)

	gen ds = s_post - s_pre        // change in method share
	gen dc = c_rate_post - c_rate_pre  // change in conviction rate within method

	/* ===== Decomp calculations by method ======== */
	gen comp_m   = ds * (c_rate_pre + c_rate_post) / 2
	gen within_m = (s_pre + s_post) / 2 * dc

	/* ===== Aggregate and calculate overall pchanges ======== */
	collapse (sum) method=comp_m targeting=within_m                                ///
    (sum) tot_n_pre=n_pre tot_n_post=n_post tot_c_pre=c_pre tot_c_post=c_post
	
	gen pre_conv  = tot_c_pre /tot_n_pre
	gen post_conv = tot_c_post/tot_n_post

	gen observed  = post_conv - pre_conv

	gen check_sum = method + targeting

	keep pre_conv post_conv observed method targeting check_sum tot_n_pre tot_n_post

	foreach v in pre_conv post_conv observed method targeting check_sum {
		replace `v' = `v' * 100
	}

	gen method_pct    = round(method   /observed*100)
	gen targeting_pct = round(targeting/observed*100)
	
	gen aor = "National"
	gen term = "`t'"
	gen order = 1
	
	tempfile national`t'
	save `national`t'', replace
}

/* ===== SECTION 4: Loop to do a by AOR calculation for each term ======== */

foreach t in term1 term2 {
	use ``t'', clear
	gen ones = 1
	collapse (sum) n=ones c=convicted, by(ApprehensionAOR method post)

	reshape wide n c, i(ApprehensionAOR method) j(post)

	rename n0 n_pre
	rename n1 n_post
	rename c0 c_pre
	rename c1 c_post

	recode n_pre n_post c_pre c_post (.=0)

	/* ===== Pre-decomp calculations ======== */
	bys ApprehensionAOR: egen N_pre  = total(n_pre)
	bys ApprehensionAOR: egen N_post = total(n_post)

	gen s_pre      = n_pre  / N_pre
	gen s_post     = n_post / N_post

	gen c_rate_pre  = cond(n_pre>0,  c_pre /n_pre,  0)
	gen c_rate_post = cond(n_post>0, c_post/n_post, 0)

	gen ds = s_post - s_pre        // change in method share
	gen dc = c_rate_post - c_rate_pre  // change in conviction rate within method

	/* ===== Decomp calculations by method ======== */
	gen comp_m   = ds * (c_rate_pre + c_rate_post) / 2
	gen within_m = (s_pre + s_post) / 2 * dc

	/* ===== Aggregate and calculate overall pchanges  */
	collapse (sum) method=comp_m targeting=within_m                                ///
    (sum) tot_n_pre=n_pre tot_n_post=n_post tot_c_pre=c_pre tot_c_post=c_post, by(ApprehensionAOR)
	
	gen pre_conv  = tot_c_pre /tot_n_pre
	gen post_conv = tot_c_post/tot_n_post

	gen observed  = post_conv - pre_conv

	gen check_sum = method + targeting
	
	gen aor       = subinstr(ApprehensionAOR, " Area of Responsibility", "", .)

	keep aor pre_conv post_conv observed method targeting check_sum tot_n_pre tot_n_post

	foreach v in pre_conv post_conv observed method targeting check_sum {
		replace `v' = `v' * 100
	}

	gen method_pct    = round(method   /observed*100)
	gen targeting_pct = round(targeting/observed*100)
	
	gen term = "`t'"
	gsort aor
	gen order = _n+1
	
	tempfile byaor`t'
	save `byaor`t'', replace
}

* Put this all together 
use `nationalterm1', clear
append using `nationalterm2'
append using `byaorterm1'
append using `byaorterm2'



/* ===== SECTION 5: Plot ======== */
sort order term
gen pos = _N - _n + 1

local mylabels
forvalues i = 1(3)`=_N' {
    local aname = aor[`i']
    local pnum  = pos[`i']
    local mylabels `mylabels' `pnum' `"`aname'"'
}

gen method_start    = 0
gen method_end      = method
gen targeting_start = method
gen targeting_end   = method + targeting

* Text label e.g. "25% / 75%" — share of total Δ from method vs targeting.
gen str20 pct_label = string(method_pct) + "% / " + string(targeting_pct) + "%"

*****
* Figure 3
*****
twoway ///                             ///
    (rbar targeting_start targeting_end pos if term == "term1", horizontal barwidth(0.7)            ///
        fcolor("240 228 66")  lcolor("240 228 66"))                                ///
	(rbar method_start    method_end    pos if term == "term1", horizontal barwidth(0.7)            ///
        fcolor("86 180 233")  lcolor("86 180 233"))   ///
     (rbar targeting_start targeting_end pos if term == "term2", horizontal barwidth(0.7)            ///
        fcolor("213 94 0")  lcolor("213 94 0"))                                ///
	(rbar method_start    method_end    pos if term == "term2", horizontal barwidth(0.7)            ///
        fcolor("0 114 178")  lcolor("0 114 178"))                                ///
    (scatter pos observed, msymbol(Oh) mcolor(black) msize(medsmall) mlwidth(medthick)), ///
    ylabel(`mylabels', angle(0) labsize(small) grid)          ///
    xlabel(-50(10)10, format(%4.0f))     ///
    xline(0, lpattern(solid) lcolor(gs10) lwidth(thin))                          ///
    xtitle("Percentage Point Change in Percent with a Conviction", size(small))                 ///
    ytitle("")                                                                    ///
    legend(order(1 "Term 1: Within-Method"                                 ///
                 2 "Term 1: Method"                 ///
                 3 "Term 2: Within-Method" ///
				 4 "Term 2: Method"  ///
				 5 "Total Percentage Point Change")                                            ///
           rows(3) position(6) size(vsmall) region(lcolor(white)))                ///
    graphregion(color(white)) plotregion(margin(small)) ///
	ysize(7) 
	graph export "$figs/meandecomp_byaor.pdf", replace height(20) 

