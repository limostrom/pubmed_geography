/*
figure_1.do
A stacked bar chart of biotechnology + pharmaceuticals share of VC invested in
	drugs startups, for the top 10 MSAs
*/


*-------------------------------------------------------------------------------
use "Data/Preqin/preqin_deals_2000_2019.dta", clear

replace dealsizeusdmn = dealsizeusdmn_raw*CPIAUCSL2020/CPIAUCSL

keep if industryclassification == "Healthcare"

replace primaryindustry = "Biotechnology" if primaryindustry == "Biopolymers"
replace primaryindustry = "Healthcare" if primaryindustry == "Healthcare Specialists"

gen stagegrp = "Seed & Angel" if inlist(stage, "Angel", "Seed")
	replace stagegrp = "Series A & B" if ///
						inlist(stage, "Series A/Round 1", "Series B/Round 2")
	replace stagegrp = "Expansion" if inlist(stage, "Venture Debt", "Add-on", ///
			"Series C/Round 3", "Series D/Round 4", "Growth Capital/Expansion")
	replace stagegrp = "Late Stage" if inlist(stage, "Merger", "PIPE", ///
			"Pre-IPO", "Secondary Stock Purchase") | ///
			inlist(stage, "Series E/Round 5", "Series F/Round 6", "Series G/Round 7", ///
						"Series H/Round 8", "Series I/Round 9", "Series J/Round 10")
	replace stagegrp = "Unspecified" if stage == "Unspecified Round"

gen stagesort = 1 if stagegrp == "Seed & Angel"
	replace stagesort = 2 if stagegrp == "Series A & B"
	replace stagesort = 3 if stagegrp == "Expansion"
	replace stagesort = 4 if stagegrp == "Late Stage"
	
gen venture_id = dealid
	drop dealid
	egen dealid = group(venture_id)

tempfile dealset
save `dealset', replace
*-------------------------------------------------------------------------------

ren portfoliocompany* pf*
	
preserve
	keep if pfcity != ""
	keep if strpos(pfcountry, "US") > 0
	collapse (sum) dealsizeusdmn
	local V: dis dealsizeusdmn
restore
	
keep if strpos(pfcountry, "US") > 0
	
egen n_pfcity = noccur(pfcity), string(",")
	replace n_pfcity = n_pfcity + 1 ///
		if pfcity != ""
	replace dealsizeusdmn = dealsizeusdmn/n_pfcity
split pfcity, p(", ")
	drop pfcity
reshape long pfcity, i(dealid dealsizeusdmn pfstate) j(cityno)
	drop cityno
	drop if pfcity == ""

	drop if inlist(pfcity, "London", "Shanghai", "Basel", "Beijing", ///
		"Hong Kong", "Paris", "Singapore", "Munich", "Toronto")
* --- By MSA City Groupings ---*
gen pfmsa = "Boston" if strpos(pfstate, "MA") > 0 ///
	& inlist(pfcity, "Cambridge", "Waltham", "Boston", "Watertown")
replace pfmsa = "Boston" if strpos(pfstate, "MA") > 0 ///
	& strpos(pfstate, "KY") == 0 & pfcity == "Lexington"
replace pfmsa = "Bay Area" if strpos(pfstate, "CA") > 0 ///
	& (inlist(pfcity, "San Francisco", "Menlo Park", "Palo Alto", ///
		"San Mateo", "San Jose", "Santa Clara", "Mountain View") ///
	| inlist(pfcity, "Redwood City", "South San Francisco", ///
		"Berkeley", "Emeryville", "Sunnyvale", "fremont"))
replace pfmsa = "Los Angeles" if strpos(pfstate, "CA") > 0 ///
	& inlist(pfcity, "Irvine", "Santa Monica", "Orange", "Pasadena", "El Segundo")
replace pfmsa = "New York" if strpos(pfstate, "NJ") > 0 & inlist(pfcity, "New Brunswick")
replace pfmsa = "San Diego" if strpos(pfstate, "CA") > 0 & inlist(pfcity, "La Jolla")
replace pfmsa = "Houston" if strpos(pfstate, "TX") > 0 & inlist(pfcity, "The Woodlands")
replace pfmsa = "Washington, DC" if strpos(pfstate, "DC") > 0 & inlist(pfcity, "Washington")
replace pfmsa = "Washington, DC" if strpos(pfstate, "MD") > 0 & inlist(pfcity, "Bethesda")
replace pfmsa = "Washington, DC" if strpos(pfstate, "VA") > 0 ///
	& inlist(pfcity, "Alexandria", "Arlington", "Reston")
replace pfmsa = "Lexington, KY" if strpos(pfstate, "KY") > 0 & pfcity == "Lexington"
replace pfmsa = "Denver-Boulder" if strpos(pfstate, "CO") > 0 & pfcity == "Denver"
replace pfmsa = "Denver-Boulder" if strpos(pfstate, "CO") > 0 & pfcity == "Boulder"
replace pfmsa = "Durham" if strpos(pfstate, "NC") > 0 & pfcity == "Chapel Hill"
replace pfmsa = pfcity if pfmsa == ""
	
keep dealid dealyear primaryindustry dealsizeusdmn pfmsa

preserve
	collapse (sum) vol_deals_msa = dealsizeusdmn, by(pfmsa) fast
	egen msa_rank = rank(vol_deals_msa), field
	keep if msa_rank <= 10
	gsort -vol_deals_msa
	levelsof pfmsa , local(list_top10) clean s(", ")

	tempfile top10
	save `top10', replace
restore
	
bys pfmsa: egen vol_deals_msa = total(dealsizeusdmn)
bys pfmsa dealyear: egen vol_deals_msa_yr = total(dealsizeusdmn)
bys pfmsa primaryindustry: egen vol_deals_msa_ind = total(dealsizeusdmn)

merge m:1 pfmsa using `top10', gen(top10) assert(1 3)
	replace top10 = 0 if top10 == 1
	replace top10 = 1 if top10 == 3
	
* Stacked Bar Plots ----------------------------------------------------------
egen vc_tot_dollars = total(dealsizeusdmn)
gen drugs = inlist(primaryindustry, "Biotechnology", "Pharmaceuticals")
bys drugs: egen vc_drugs_dollars = total(dealsizeusdmn)
	replace vc_drugs_dollars = . if drugs == 0
keep if top10
gen dealdecade = int(dealyear/10)*10
	keep if dealdecade == 2010
replace primaryindustry = subinstr(subinstr(primaryindustry, " ", "", .), "&","",.)
collapse (sum) deal_vol = dealsizeusdmn (max) vc_tot_dollars vc_drugs_dollars, ///
			by(pfmsa primaryindustry) fast
	gen sh_deal_vol = deal_vol/vc_tot_dollars*100
	gen sh_drugs = deal_vol/vc_drugs_dollars*100
	replace deal_vol = deal_vol/1000
	drop vc_drugs_dollars
replace primaryindustry = "MedicalDevices" if primaryindustry == "MedicalDevicesEquipment"
reshape wide deal_vol sh_deal_vol sh_drugs, i(pfmsa) j(primaryindustry) string
	lab var deal_volBiotech "Biotechnology"
	lab var deal_volHealthcare "Healthcare"
	lab var deal_volHealthcareIT "Healthcare IT"
	lab var deal_volMedicalDev "Medical Devices"
	lab var deal_volPharma "Pharmaceuticals"
	lab var sh_deal_volBiotech "Biotechnology"
	lab var sh_drugsBiotech "Biotechnology"
	lab var sh_deal_volHealthcare "Healthcare"
	lab var sh_deal_volHealthcareIT "Healthcare IT"
	lab var sh_deal_volMedicalDev "Medical Devices"
	lab var sh_deal_volPharma "Pharmaceuticals"
	lab var sh_drugsPharma "Pharmaceuticals"
egen tot_vol = rowtotal(deal_vol*)
egen drugs_vol = rowtotal(deal_volB deal_volP)
bys pfmsa: egen tot = total(tot_vol)
bys pfmsa: egen tot_drugs = total(drugs_vol)
	
egen rowtot_drugs = rowtotal(sh_drugsB sh_drugsP)
egen drug_totsh = total(rowtot_drugs)
local Dpct: dis drug_totsh
local Dpct = round(`Dpct', 1)

* Graph by Share of VC Dollars in Drugs
graph bar (asis) sh_drugsB sh_drugsP,  ///
	stack over(pfmsa,  sort(tot_drugs)  descending) ///
	title("Breakdown of VC-Backed Drugs Start-Ups") ///
	subtitle("Top MSAs account for `Dpct'% of VC Dollars in Drugs") ///
	legend(symx(small) symy(small) r(1)) ///
	yti("Share of VC Dollars in Drugs (%)" " ") ///
	bar(1, col(green)) bar(2, col(cranberry))
graph export "Output/fig1-top10_bars_pfcity_%_Drugs.png", ///
	replace as(png) wid(1800) hei(700)