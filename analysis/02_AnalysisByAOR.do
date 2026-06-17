*==================================
*  ICE Arrests - Variation in Targeting 
*==================================
* Ellie Cox 
* June 17, 2026
*==================================

*==================================
* Cleans and preps data for plotting by area of responsibility (AOR)
*==================================

*==================================
* inputs:
*		Appended_Garcia.dta: Garcia Hernandez data 
* 		AdminArrests_MidMar.dta: DDP data covering 2023+
*==================================

*==================================
* Get Arrests by method for each time period
*==================================

**** 2016-2017 Data 
use "$data/Appended_Garcia.dta", clear

gen arrest_date_temp = date(apprehensiondate, "20YMD")
format arrest_date_temp %td
rename arrest_date_temp date

keep if inrange(date, mdy(1,20,2017) - 414, mdy(1,20,2017) + 414)

gen lea = 1 if apprehensionmethod == "287(g) Program" | apprehensionmethod == "Anti-Smuggling" | ///
apprehensionmethod == "CAP Federal Incarceration" | apprehensionmethod == "CAP Local Incarceration" | ///
apprehensionmethod == "CAP State Incarceration" | apprehensionmethod == "Criminal Alien Program" | ///
apprehensionmethod == "ERO Reprocessed Arrest" | apprehensionmethod == "Law Enforcement Agency Response Unit" | ///
apprehensionmethod == "Organized Crime Drug Enforcement Tas" | apprehensionmethod == "Other Agency (turned over to INS)" | ///
apprehensionmethod == "Other Task Force" | apprehensionmethod == "Probation and Parole" | ///
apprehensionmethod == "Custodial Arrest" | apprehensionmethod == "Patrol Border" | apprehensionmethod == "Patrol Interior"
gen communityarrest = 1 if apprehensionmethod == "Located" | apprehensionmethod == "Non-Custodial Arrest" | ///
apprehensionmethod == "Worksite Enforcement"
gen othmethod = 1 if apprehensionmethod == "Boat Patrol" | apprehensionmethod == "Crewman/Stowaway" | ///
apprehensionmethod == "Inspections" | apprehensionmethod == "Other efforts" | apprehensionmethod == "Traffic Check" | apprehensionmethod == "Transportation Check Aircraft" | ///
apprehensionmethod == "Transportation Check Bus" | apprehensionmethod == "Transportation Check Freight Train" | ///
apprehensionmethod == "Transportation Check Passenger Train" | apprehensionmethod == "Presented During Inspection"

gen ones = 1

gen convicted = 1 if mostseriouscriminalchargestatus == "Convicted"

* Make date relative to inauguration 
gen date_rel_inaug = date - daily("20jan2017", "DMY")

* Add national
preserve 
collapse (sum) arrests_tot = ones arrests_conv = convicted lea communityarrest if inrange(date, mdy(1,20,2017) - 414, mdy(1,20,2017) + 414), by(date_rel_inaug)

gen ApprehensionAOR = "National"

* calculate moving average 
sort date 
gen ma_arrests_oldat = (arrests_tot[_n-7] + arrests_tot[_n-6] + arrests_tot[_n-5] + ///
arrests_tot[_n-4] + arrests_tot[_n-3] + arrests_tot[_n-2] + arrests_tot[_n-1] + arrests_tot[_n] + arrests_tot[_n+1] + arrests_tot[_n+2] + arrests_tot[_n+3] + arrests_tot[_n+4] + arrests_tot[_n+5] + arrests_tot[_n+6] + arrests_tot[_n+7])/15
gen ma_lea = (lea[_n-7] + lea[_n-6] + lea[_n-5] + ///
lea[_n-4] + lea[_n-3] + lea[_n-2] + lea[_n-1] + lea[_n] + lea[_n+1] + lea[_n+2] + lea[_n+3] + lea[_n+4] + lea[_n+5] + lea[_n+6] + lea[_n+7])/15
gen ma_commarr = (communityarrest[_n-7] + communityarrest[_n-6] + communityarrest[_n-5] + ///
communityarrest[_n-4] + communityarrest[_n-3] + communityarrest[_n-2] + communityarrest[_n-1] + communityarrest[_n] + communityarrest[_n+1] + communityarrest[_n+2] + communityarrest[_n+3] + communityarrest[_n+4] + communityarrest[_n+5] + communityarrest[_n+6] + communityarrest[_n+7])/15

tempfile nationalterm1 
save `nationalterm1', replace
restore 

* AOR Level
collapse (sum) arrests_tot = ones arrests_conv = convicted lea communityarrest if inrange(date, mdy(1,20,2017) - 414, mdy(1,20,2017) + 414), by(date_rel_inaug apprehensionaor)

rename apprehensionaor ApprehensionAOR

* calculate moving average (doing this manually since tsset doesn't allow us to do this over multiple groups)
sort ApprehensionAOR date 
by ApprehensionAOR: gen ma_arrests_oldat = (arrests_tot[_n-7] + arrests_tot[_n-6] + arrests_tot[_n-5] + ///
arrests_tot[_n-4] + arrests_tot[_n-3] + arrests_tot[_n-2] + arrests_tot[_n-1] + arrests_tot[_n] + arrests_tot[_n+1] + arrests_tot[_n+2] + arrests_tot[_n+3] + arrests_tot[_n+4] + arrests_tot[_n+5] + arrests_tot[_n+6] + arrests_tot[_n+7])/15
by ApprehensionAOR: gen ma_lea = (lea[_n-7] + lea[_n-6] + lea[_n-5] + ///
lea[_n-4] + lea[_n-3] + lea[_n-2] + lea[_n-1] + lea[_n] + lea[_n+1] + lea[_n+2] + lea[_n+3] + lea[_n+4] + lea[_n+5] + lea[_n+6] + lea[_n+7])/15
by ApprehensionAOR: gen ma_commarr = (communityarrest[_n-7] + communityarrest[_n-6] + communityarrest[_n-5] + ///
communityarrest[_n-4] + communityarrest[_n-3] + communityarrest[_n-2] + communityarrest[_n-1] + communityarrest[_n] + communityarrest[_n+1] + communityarrest[_n+2] + communityarrest[_n+3] + communityarrest[_n+4] + communityarrest[_n+5] + communityarrest[_n+6] + communityarrest[_n+7])/15

append using `nationalterm1'

tempfile aorfigdat1 
save `aorfigdat1', replace

**** 2024-2025 Data
use "$data/AdminArrests_MidMar.dta", clear

* Remap Harlingen, San Antonio, and Houston to one AOR called San Antonio
replace ApprehensionAOR = "San Antonio Area of Responsibility" if ApprehensionAOR == "Harlingen Area of Responsibility" | ApprehensionAOR == "Houston Area of Responsibility"

gen ones = 1
gen lea = (ApprehensionMethod == "287(g) Program" | ApprehensionMethod == "Anti-Smuggling" | ///
ApprehensionMethod == "CAP Federal Incarceration" | ApprehensionMethod == "CAP Local Incarceration" | ///
ApprehensionMethod == "CAP State Incarceration" | ApprehensionMethod == "Criminal Alien Program" | ///
ApprehensionMethod == "ERO Reprocessed Arrest" | ApprehensionMethod == "Law Enforcement Agency Response Unit" | ///
ApprehensionMethod == "Organized Crime Drug Enforcement Task Force" | ApprehensionMethod == "Other Agency (turned over to INS)" | ///
ApprehensionMethod == "Other Task Force" | ApprehensionMethod == "Probation and Parole" | ///
ApprehensionMethod == "Custodial Arrest") | ApprehensionMethod == "Patrol Border" | ApprehensionMethod == "Patrol Interior"
gen communityarrest = (ApprehensionMethod == "Located" | ApprehensionMethod == "Non-Custodial Arrest" | ///
ApprehensionMethod == "Worksite Enforcement")

* Make date relative to inauguration 
gen date_rel_inaug = date - daily("20jan2025", "DMY")

* National 
preserve 
collapse (sum) arrests_new = ones lea_new = lea commarr_nes = communityarrest if inrange(date, mdy(1,20,2025) - 414, mdy(1,20,2025) + 414), by(date_rel_inaug)
gen ApprehensionAOR = "National"

sort date 
gen ma_new_lea = (lea_new[_n-7] + lea_new[_n-6] + lea_new[_n-5] + ///
lea_new[_n-4] + lea_new[_n-3] + lea_new[_n-2] + lea_new[_n-1] + lea_new[_n] + lea_new[_n+1] + lea_new[_n+2] + lea_new[_n+3] + lea_new[_n+4] + lea_new[_n+5] + lea_new[_n+6] + lea_new[_n+7])/15
gen ma_new_commarr = (commarr_nes[_n-7] + commarr_nes[_n-6] + commarr_nes[_n-5] + ///
commarr_nes[_n-4] + commarr_nes[_n-3] + commarr_nes[_n-2] + commarr_nes[_n-1] + commarr_nes[_n] + commarr_nes[_n+1] + commarr_nes[_n+2] + commarr_nes[_n+3] + commarr_nes[_n+4] + commarr_nes[_n+5] + commarr_nes[_n+6] + commarr_nes[_n+7])/15
tempfile nationalterm2 
save `nationalterm2', replace
restore

* AOR Level 
collapse (sum) arrests_new = ones lea_new = lea commarr_nes = communityarrest if  inrange(date, mdy(1,20,2025) - 414, mdy(1,20,2025) + 414), by(date_rel_inaug ApprehensionAOR)

sort ApprehensionAOR date 
by ApprehensionAOR: gen ma_new_lea = (lea_new[_n-7] + lea_new[_n-6] + lea_new[_n-5] + ///
lea_new[_n-4] + lea_new[_n-3] + lea_new[_n-2] + lea_new[_n-1] + lea_new[_n] + lea_new[_n+1] + lea_new[_n+2] + lea_new[_n+3] + lea_new[_n+4] + lea_new[_n+5] + lea_new[_n+6] + lea_new[_n+7])/15
by ApprehensionAOR: gen ma_new_commarr = (commarr_nes[_n-7] + commarr_nes[_n-6] + commarr_nes[_n-5] + ///
commarr_nes[_n-4] + commarr_nes[_n-3] + commarr_nes[_n-2] + commarr_nes[_n-1] + commarr_nes[_n] + commarr_nes[_n+1] + commarr_nes[_n+2] + commarr_nes[_n+3] + commarr_nes[_n+4] + commarr_nes[_n+5] + commarr_nes[_n+6] + commarr_nes[_n+7])/15


append using `nationalterm2'

tempfile aorfigdat2
save `aorfigdat2', replace

***** 
* Put this all together
*****

use `aorfigdat1', clear 

merge 1:1 ApprehensionAOR date_rel_inaug using `aorfigdat2', keep(3)
drop _merge

replace ApprehensionAOR = subinstr(ApprehensionAOR, " Area of Responsibility", " AOR", .)

***** 
* Save 
*****
drop if ApprehensionAOR == "HQ"
export delimited "$data/arrests_relinaug_v2.csv", replace
