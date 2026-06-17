*==================================
*  Tracking Immigration - Some pre-cleaning of DDP 
*==================================
* Ellie Cox 
* June 5, 2025
*==================================

*==================================
* Cleans ICE arrest data by AOR
*==================================

*==================================
* inputs:
*		2026-ICLI-00005_Arrests_Redacted: ICE arrest data from https://deportationdata.org/data/ice.html (updated through March 10, 2026)
*==================================

*==================================
* Read data
*==================================

forvalues fy = 23/26 { 
	import excel "$data/2026-ICLI-00005_Arrests_Redacted/2026-ICLI-00005_Arrests_FY`fy'_20260311_Redacted", clear cellrange(A7) firstrow
	
	tempfile dat`fy'
	save `dat`fy'', replace
}

use `dat23', clear
forvalues fy = 24/26 {
	append using `dat`fy''
}

* Do some pre cleaning to keep some variables more similar to previous releases
rename ApprehensionDate datetemp
gen year = year(datetemp)
gen mth = month(datetemp)
gen day = day(datetemp)

gen date = dmy(day, mth, year)
format date %td

drop if date > dmy(10, 3, 2026) // keeps the last full day of arrests

rename TOACurrentDutyAOR ApprehensionAOR
rename State ApprehensionState

* Create Date-time variable 
gen double datetime = cofd(datetemp)
format datetime %tcDDmonCCYY_HH:MM:SS

* save as .dta
save "$data/AdminArrests_MidMar.dta", replace
