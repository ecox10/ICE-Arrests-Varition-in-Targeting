*==================================
*  ICE Arrests - Variation in Targeting 
*==================================
* Ellie Cox 
* May 29, 2026
*==================================

*==================================
* This file cleans basic 5-year county level ACS data. This will combine all the ACS data into one file, and save a .dta that can be merged with the ICE data
*==================================

*==================================
* inputs:
*		ACSDT5Y`i'.B05001-Data.csv: ACS county level data for various years in `i'
*==================================

*****
* Read Citizenship data 
*****
forvalues i = 2010/2024 {
	import delimited "$data/ACS_noncit/ACSDT5Y`i'.B05001-Data.csv", clear rowrange(2:3224) varnames(1)
	drop if geo_id == "Geography"
	
	gen year = `i'
	
	tempfile noncit`i'
	save `noncit`i'', replace
}

use `noncit2010', clear
forvalues i = 2011/2024 { 
	append using `noncit`i''
}


* Make non citizen variable
replace b05001_006e = "" if b05001_006e == "null"
rename b05001_006e noncit_count 
replace b05001_001e = "" if b05001_001e == "null"
rename b05001_001e pop_total

gen geofips = substr(geo_id, 10, 5)
destring geofips, replace

destring noncit_count, replace
destring pop_total, replace
gen statefip = substr(geo_id, -5, 2)
destring statefip, replace
gen county_st = substr(geo_id, -5, 5)
destring county_st, replace

*****
* Make at AOR level
*****

gen aor = "New Orleans Area of Responsibility" if statefip == 1
replace aor = "Seattle Area of Responsibility" if statefip == 2
replace aor = "Phoenix Area of Responsibility" if statefip == 4
replace aor = "New Orleans Area of Responsibility" if statefip == 5
replace aor = "Denver Area of Responsibility" if statefip == 8
replace aor = "Boston Area of Responsibility" if statefip == 9
replace aor = "Philadelphia Area of Responsibility" if statefip == 10
replace aor = "Washington Area of Responsibility" if statefip == 11
replace aor = "Miami Area of Responsibility" if statefip == 12
replace aor = "Atlanta Area of Responsibility" if statefip == 13
replace aor = "San Francisco Area of Responsibility" if statefip == 15
replace aor = "Salt Lake City Area of Responsibility" if statefip == 16
replace aor = "Chicago Area of Responsibility" if statefip == 17
replace aor = "Chicago Area of Responsibility" if statefip == 18
replace aor = "St. Paul Area of Responsibility" if statefip == 19
replace aor = "Chicago Area of Responsibility" if statefip == 20
replace aor = "Chicago Area of Responsibility" if statefip == 21
replace aor = "New Orleans Area of Responsibility" if statefip == 22
replace aor = "Boston Area of Responsibility" if statefip == 23
replace aor = "Baltimore Area of Responsibility" if statefip == 24
replace aor = "Boston Area of Responsibility" if statefip == 25
replace aor = "Detroit Area of Responsibility" if statefip == 26
replace aor = "St. Paul Area of Responsibility" if statefip == 27
replace aor = "New Orleans Area of Responsibility" if statefip == 28
replace aor = "Chicago Area of Responsibility" if statefip == 29
replace aor = "Salt Lake City Area of Responsibility" if statefip == 30
replace aor = "St. Paul Area of Responsibility" if statefip == 31
replace aor = "Salt Lake City Area of Responsibility" if statefip == 32
replace aor = "Boston Area of Responsibility" if statefip == 33
replace aor = "Newark Area of Responsibility" if statefip == 34
replace aor = "El Paso Area of Responsibility" if statefip == 35
replace aor = "Atlanta Area of Responsibility" if statefip == 37
replace aor = "St. Paul Area of Responsibility" if statefip == 38
replace aor = "Detroit Area of Responsibility" if statefip == 39
replace aor = "Dallas Area of Responsibility" if statefip == 40
replace aor = "Seattle Area of Responsibility" if statefip == 41
replace aor = "Philadelphia Area of Responsibility" if statefip == 42
replace aor = "Boston Area of Responsibility" if statefip == 44
replace aor = "Atlanta Area of Responsibility" if statefip == 45
replace aor = "St. Paul Area of Responsibility" if statefip == 46
replace aor = "New Orleans Area of Responsibility" if statefip == 47
replace aor = "Salt Lake City Area of Responsibility" if statefip == 49
replace aor = "Boston Area of Responsibility" if statefip == 50
replace aor = "Washington Area of Responsibility" if statefip == 51
replace aor = "Seattle Area of Responsibility" if statefip == 53
replace aor = "Philadelphia Area of Responsibility" if statefip == 54
replace aor = "Chicago Area of Responsibility" if statefip == 55
replace aor = "Denver Area of Responsibility" if statefip == 56

* California
replace aor = "San Diego Area of Responsibility" if county == 6073 | county == 6025 
replace aor = "Los Angeles Area of Responsibility" if county == 6059 | county == 6065 | ///
county == 6071 | county == 6037 | county == 6111 | county == 6083 | county == 6079 
replace aor = "San Francisco Area of Responsibility" if statefip == 6 & ///
aor != "San Diego Area of Responsibility" & aor != "Los Angeles Area of Responsibility" & county != 0

* Texas
replace aor = "El Paso Area of Responsibility" if county == 48141 | county == 48229 | ///
	county == 48109 | county == 48243 | county == 48377 | county == 48371 | ///
	county == 48043 | county == 48443 | ///
	county == 48301 | county == 48495 | county == 48475 | county == 48003 | county == 48317 | ///
	county == 48135 | county == 48329 | county == 48103 | county == 48461 | county == 48389 | county == 48377
	replace aor = "Harlingen Area of Responsibility" if county == 48479 | county == 48505 | ///
	county == 48427 | county == 48131 | county == 48249 | county == 48047 | county == 48215 | ///
	county == 48061 | county == 48489 | county == 48261 | county == 48273 | county == 48355 | ///
	county == 48409 | county == 48505 | county == 48247
	replace aor = "Houston Area of Responsibility" if county == 48007 | county == 48391 | ///
	county == 48297 | county == 48025 | county == 48175 | county == 48057 | county == 48469 | ///
	county == 48123 | county == 48285 | county == 48239 | county == 48149 | county == 48089 | ///
	county == 48481 | county == 48321 | county == 48287 | county == 48477 | county == 48015 | ///
	county == 48331 | county == 48027 | county == 48099 | county == 48193 | county == 48425 | ///
	county == 48035 | county == 48217 | county == 48309 | county == 48145 | county == 48293 | ///
	county == 48161 | county == 48395 | county == 48289 | county == 48225 | county == 48347 | ///
	county == 48419 | county == 48405 | county == 48403 | county == 48005 | county == 48455 | ///
	county == 48313 | county == 48041 | county == 48185 | county == 48471 | county == 48407 | ///
	county == 48373 | county == 48457 | county == 48241 | county == 48351 | county == 48199 | ///
	county == 48291 | county == 48201 | county == 48339 | county == 48473 | county == 48157 | ///
	county == 48039 | county == 48167 | county == 48071 | county == 48245 | county == 48361 | ///
	county == 48051
	replace aor = "San Antonio Area of Responsibility" if county == 48465 | county == 48137 | ///
	county == 48265 | county == 48171 | county == 48319 | county == 48307 | county == 48411 | ///
	county == 48281 | county == 48299 | county == 48053 | county == 48491 | county == 48031 | ///
	county == 48453 | county == 48021 | county == 48209 | county == 48055 | county == 48259 | ///
	county == 48091 | county == 48187 | county == 48177 | county == 48271 | county == 48385 | ///
	county == 48019 | county == 48463 | county == 48325 | county == 48029 | county == 48493 | ///
	county == 48255 | county == 48323 | county == 48507 | county == 48163 | county == 48013 | ///
	county == 48127 | county == 48283 | county == 48311
replace aor = "Dallas Area of Responsibility" if statefip == 48 & aor != "El Paso Area of Responsibility" & ///
aor != "Harlingen Area of Responsibility" & aor != "Houston Area of Responsibility" & ///
aor != "San Antonio Area of Responsibility" & county != 0

* New York
replace aor = "New York City Area of Responsibility" if county == 36105 | county == 36111 | county == 36027 | ///
county == 36071 | county == 36079 | county == 36119 | county == 36087 | county == 36005 | county == 36061 | ///
county == 36047 | county == 36059 | county == 36081 | county == 36103 | county == 36085
replace aor = "Buffalo Area of Responsibility" if statefip == 36 & aor != "New York City Area of Responsibility"

gen temp = 1 
sort year aor county 
by year aor: egen county_count = sum(temp)

collapse (sum) noncit_2023 = noncit_count pop_total, by(aor year)

save "$data/noncit_2023_byaor.dta", replace
export delimited "$data/noncit_2023_byaor.csv", replace

 
