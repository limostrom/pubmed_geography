/*
pop_data_clean.do

Run this if you want to population-adjust VC funding or PubMed publications

*/

import excel "Data/Census/list2_2020.xls", clear cellrange(A3:F1271) first case(lower)
	keep cbsacode cbsatitle
	duplicates drop
	replace cbsatitle = lower(cbsatitle)
	tempfile cbsas
	save `cbsas', replace

use if inlist(year, 1990, 2000, 2010) using "Data/Census/usa_00008.dta", clear
	decode sample, gen(newsample)
	drop sample
	ren newsample sample
	keep if inlist(sample, "2010 acs", "2000 5%", "1990 5%")
	collapse (count) pop = pernum [pw = perwt], by(metaread metarea sample) fast

	decode metarea, gen(cbsatitle1)
	decode metaread, gen(cbsatitle2)
	replace cbsatitle1 = subinstr(cbsatitle1, "/", "-", .)
	replace cbsatitle2 = subinstr(cbsatitle2, "/", "-", .)
	
	ren cbsatitle1 cbsatitle
	merge m:1 cbsatitle using `cbsas', nogen keepus(cbsacode)
	ren cbsacode cbsacode1
	ren cbsatitle cbsatitle1
	
	ren cbsatitle2 cbsatitle
	merge m:1 cbsatitle using `cbsas', nogen keepus(cbsacode)
	ren cbsacode cbsacode2
	ren cbsatitle cbsatitle2
	
	replace cbsacode1 = cbsacode2 if cbsacode1 == "" & cbsacode2 != ""
	ren cbsacode1 cbsacode
	replace cbsatitle1 = cbsatitle2 if cbsatitle1 == "" & cbsatitle2 != ""
	ren cbsatitle1 cbsatitle
	
	gen decade = substr(sample, 1, 4)
	destring decade, replace
	
	replace cbsacode = "14460" if cbsacode == "" & strpos(cbsatitle, "boston") > 0 ///
								& strpos(cbsatitle, ", ma") > 0
	replace cbsacode = "41740" if cbsacode == "" & strpos(cbsatitle, "san diego") > 0 ///
								& strpos(cbsatitle, ", ca") > 0
	replace cbsacode = "41860" if cbsacode == "" & (strpos(cbsatitle, "san francisco") > 0 ///
									| strpos(cbsatitle, "oakland") > 0) ///
								& strpos(cbsatitle, ", ca") > 0
	replace cbsacode = "41940" if cbsacode == "" & cbsatitle == "san jose, ca"
	replace cbsacode = "12580" if cbsacode == "" & cbsatitle == "baltimore, md"
	replace cbsacode = "47900" if cbsacode == "" & cbsatitle == "washington, dc-md-va"
	replace cbsacode = "35300" if cbsacode == "" & strpos(cbsatitle, "new haven") > 0 ///
								& strpos(cbsatitle, ", ct") > 0
	replace cbsacode = "20500" if cbsacode == "" & cbsatitle == "raleigh-durham, nc"
	replace cbsacode = "16980" if cbsacode == "" & strpos(cbsatitle, "chicago") > 0 ///
								& strpos(cbsatitle, ", il") > 0
	replace cbsacode = "35620" if cbsacode == "" & strpos(cbsatitle, "new york") > 0 ///
								& strpos(cbsatitle, ", ny") > 0
	replace cbsacode = "42660" if cbsacode == "" ///
								& strpos(cbsatitle, "seattle") > 0 & strpos(cbsatitle, ", wa") > 0
	replace cbsacode = "12060" if cbsacode == "" & cbsatitle == "atlanta, ga"
	replace cbsacode = "31080" if cbsacode == "" ///
		& strpos(cbsatitle, "los angeles") > 0
	replace cbsacode = "37980" if cbsacode == "" ///
		& strpos(cbsatitle, "philadelphia") > 0
	replace cbsacode = "26420" if cbsacode == "" ///
		& strpos(cbsatitle, "houston") > 0
	replace cbsacode = "19100" if cbsacode == "" ///
		& strpos(cbsatitle, "dallas") > 0
	replace cbsacode = "45940" if cbsacode == "" ///
		& strpos(cbsatitle, "trenton") > 0
	replace cbsacode = "17460" if cbsacode == "" ///
		& strpos(cbsatitle, "cleveland") > 0
	replace cbsacode = "49340" if cbsacode == "" ///
		& strpos(cbsatitle, "worcester") > 0
	replace cbsacode = "33460" if cbsacode == "" ///
		& strpos(cbsatitle, "minneapolis") > 0
	replace cbsacode = "34980" if cbsacode == "" ///
		& strpos(cbsatitle, "nashville") > 0
	replace cbsacode = "19740" if cbsacode == "" ///
		& cbsatitle == "denver-boulder, co"
	replace cbsacode = "40900" if cbsacode == "" ///
		& strpos(cbsatitle, "sacramento") > 0
	replace cbsacode = "41620" if cbsacode == "" ///
		& strpos(cbsatitle, "salt lake city") > 0
	replace cbsacode = "38900" if cbsacode == "" ///
		& cbsatitle == "portland, or-wa"
	replace cbsacode = "39300" if cbsacode == "" ///
		& strpos(cbsatitle, "providence") > 0
	replace cbsacode = "16580" if cbsacode == "" ///
		& strpos(cbsatitle, "champaign-urbana") > 0
	replace cbsacode = "32820" if cbsacode == "" ///
		& strpos(cbsatitle, "memphis") > 0
	replace cbsacode = "33100" if cbsacode == "" ///
		& strpos(cbsatitle, "miami") > 0
	replace cbsacode = "12420" if cbsacode == "" ///
		& strpos(cbsatitle, "austin") > 0
	replace cbsacode = "38060" if cbsacode == "" ///
		& strpos(cbsatitle, "phoenix") > 0
	replace cbsacode = "13820" if cbsacode == "" ///
		& strpos(cbsatitle, "birmingham") > 0
	replace cbsacode = "42200" if cbsacode == "" ///
		& strpos(cbsatitle, "santa barbara") > 0
	replace cbsacode = "19820" if cbsacode == "" ///
		& strpos(cbsatitle, "detroit") > 0
	replace cbsacode = "12020" if cbsacode == "" ///
		& strpos(cbsatitle, "athens") > 0
	replace cbsacode = "41700" if cbsacode == "" ///
		& strpos(cbsatitle, "san antonio") > 0
	replace cbsacode = "22660" if cbsacode == "" ///
		& strpos(cbsatitle, "fort collins") > 0
	replace cbsacode = "44300" if cbsacode == "" ///
		& cbsatitle == "state college, pa"
	replace cbsacode = "26900" if cbsacode == "" ///
		& strpos(cbsatitle, "indianapolis") > 0
	replace cbsacode = "46520" if cbsacode == "" ///
		& strpos(cbsatitle, "honolulu") > 0
	replace cbsacode = "42100" if cbsacode == "" ///
		& strpos(cbsatitle, "santa cruz") > 0
	replace cbsacode = "29620" if cbsacode == "" ///
		& strpos(cbsatitle, "lansing") > 0
	replace cbsacode = "26980" if cbsacode == "" ///
		& strpos(cbsatitle, "iowa city") > 0
	replace cbsacode = "29200" if cbsacode == "" ///
		& cbsatitle == "lafayette-w. lafayette, in"
	replace cbsacode = "23540" if cbsacode == "" ///
		& cbsatitle == "gainesville, fl"
	replace cbsacode = "39580" if cbsacode == "" ///
		& strpos(cbsatitle, "raleigh") > 0
	replace cbsacode = "40140" if cbsacode == "" ///
		& cbsatitle == "riverside-san bernardino, ca"
	replace cbsacode = "14020" if cbsacode == "" ///
		& cbsatitle == "bloomington, in"
	replace cbsacode = "40060" if cbsacode == "" ///
		& cbsatitle == "richmond-petersburg, va"
	replace cbsacode = "33340" if cbsacode == "" ///
		& cbsatitle == "milwaukee, wi"
	replace cbsacode = "17780" if cbsacode == "" ///
		& cbsatitle == "bryan-college station, tx"
	replace cbsacode = "31140" if cbsacode == "" ///
		& cbsatitle == "louisville, ky-in"
	replace cbsacode = "45220" if cbsacode == "" ///
		& cbsatitle == "tallahassee, fl"
	replace cbsacode = "15380" if cbsacode == "" ///
		& cbsatitle == "buffalo-niagara falls, ny"
	replace cbsacode = "36540" if cbsacode == "" ///
		& cbsatitle == "omaha, ne-ia"
	replace cbsacode = "25540" if cbsacode == "" ///
		& strpos(cbsatitle, "hartford") > 0
	replace cbsacode = "24340" if cbsacode == "" ///
		& cbsatitle == "grand rapids, mi"
	replace cbsacode = "35380" if cbsacode == "" ///
		& cbsatitle == "new orleans, la"
	replace cbsacode = "16700" if cbsacode == "" ///
		& cbsatitle == "charleston-n. charleston, sc"
	
	collapse (sum) pop, by(cbsacode decade)
	keep if pop > 0 & cbsacode != ""
	destring cbsacode, replace
	save "Data/cbsa_pop_1990-2010.dta", replace