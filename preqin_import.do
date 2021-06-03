/*
prequin_import.do
Dataset acquired from Prequin (see readme.txt)
*/


*=========================================================================
*							IMPORT
*=========================================================================
local filelist: dir "Data/Preqin" files "Preqin_deals_export*.xlsx"

cd Data/Preqin
local ii 1
foreach file of local filelist {
	import excel "`file'", clear first case(lower)
	    if `ii' == 1 {
			tempfile deals
			save `deals', replace
		}
		if `ii' > 1 {
		    append using `deals'
			save `deals', replace
		}
	local ++ii
}
cd ../../
isid dealid // unique

gen dealyear = year(dealdate)
gen dealmonth = month(dealdate)
gen datem = ym(dealyear, dealmonth)

* Convert Deal Sizes to 2020 USD
preserve
	import delimited "Data/CPIAUCSL.csv", clear varn(1) case(upper)
		gen year = substr(DATE, 1, 4)
			destring year, replace
		gen month = substr(DATE, 6, 2)
			destring month, replace
		gen datem = ym(year, month)
			format %tm datem
			drop year month DATE
			
		gen CPIAUCSL2020 = CPIAUCSL if datem == tm(2020m1)
			ereplace CPIAUCSL2020 = max(CPIAUCSL2020)
		tempfile cpiaucsl
		save `cpiaucsl', replace
restore

merge m:1 datem using `cpiaucsl', nogen keep(1 3)

gen dealsizeusdmn_raw = dealsizeusdmn

save "Data/Preqin/preqin_deals_2000_2019.dta", replace
*=========================================================================



*=========================================================================
*						SAVING MSA DATASET
*=========================================================================
use dealid dealyear dealsizeusdmn CPIAUCSL2020 CPIAUCSL ///
	industryclassification primaryindustry ///
	portfoliocompanycountry portfoliocompanystate portfoliocompanycity ///
	using "Data/Preqin/preqin_deals_2000_2019.dta", clear
keep if industryclassification == "Healthcare"

replace primaryindustry = "Biotechnology" if primaryindustry == "Biopolymers"
replace primaryindustry = "Healthcare" if primaryindustry == "Healthcare Specialists"

keep if strpos(portfoliocompanycountry, "US") > 0

ren portfoliocompanycity city
*reshape long city, i(dealid dealsizeusdmn portfoliocompanystate) j(cityno)
	*drop if city == ""
	replace city = "Ann Arbor" if city == "Ann Arbour"
	replace city = "Palo Alto" if city == "Menlo Park"
	replace city = "San Diego" if city == "La Jolla"
	replace city = "San Mateo" if city == "Portola Valley"
	replace city = "Philadelphia" if city == "Conshohocken"
ren portfoliocompanystate state_abbr
	replace city = "Boston" if city == "Lexington" & state == "MA"

	merge m:1 city state_abbr using "Data/MSA_city_state_clean.dta", ///
			keep(1 3) keepus(cbsacode) nogen
	destring cbsacode, replace
	*replace msa = cbsacode if msa == .


bys cbsacode: egen mode_city = mode(city), minmode
	replace mode_city = "Boston" if mode_city == "Cambridge" & state == "MA"
	replace mode_city = "Los Angeles" if mode_city == "Irvine" & state == "CA"
	replace mode_city = "San Jose" if mode_city == "Palo Alto" & state == "CA"
bys cbsacode: egen mode_state = mode(state_abbr), minmode
replace mode_city = "" if cbsacode == .
replace mode_state = "" if cbsacode == .

gen dealsize_na = dealsizeusdmn == .
tab dealsize_na

replace dealsizeusdmn = 0 if dealsizeusdmn == .

gen dealsizeusdmn_raw = dealsizeusdmn
	drop dealsizeusdmn
gen dealsizeusdmn_2020 = dealsizeusdmn_raw*CPIAUCSL2020/CPIAUCSL

			
foreach dollars in /*"raw"*/ "2020" {
	bys dealyear industryclass cbsacode: egen deals_`dollars'USDmnHealthcare = total(dealsizeusdmn_`dollars')
	foreach ind in "Biotechnology" "Pharmaceuticals" {
		bys dealyear primaryindustry cbsacode: ///
			egen deals_`dollars'USDmn`ind' = total(dealsizeusdmn_`dollars') ///
				if primaryindustry == "`ind'"
		bys dealyear cbsacode: ereplace deals_`dollars'USDmn`ind' = max(deals_`dollars'USDmn`ind')
		replace deals_`dollars'USDmn`ind' = 0 if deals_`dollars'USDmn`ind' == .
	}
}

sort dealyear cbsacode primaryindustry

collapse (last) deals_*USDmn* city = mode_city state = mode_state, by(cbsacode dealyear)

reshape long deals_rawUSDmn deals_2020USDmn, i(cbsacode city state dealyear) j(class) string
sort dealyear city state
order dealyear cbsacode city state
save "Data/deals_pfcomp_byMSA.dta", replace
outsheet using "Data/deals_pfcomp_byMSA.csv", comma replace