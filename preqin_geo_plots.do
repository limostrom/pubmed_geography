/*
preqin_geo_plots.do

1. Plots by industry of VC deals with VCs or start-ups from one of the top 10 MSAs
2. Plots related to the VC and start-up being based in the same MSA

*/
clear all
cap log close
pause on

*Keep codes that reshape long VC cities
	* reshape wide states
	* merge with census cbsacodes to figure out which city-state combos make sense
*Keep US investors only
*Reshape long again portfolio cities (almost always only 1 anyway, if not always)
*merge with census cbsacodes on portfolio cities
*collapse (max) on whether same MSA by deal
* collapse (sum) and (count) to determine % deals in same MSA by:
	* (1) top MSAs
	* (2) by industry
	* (3) by funding stage

global repo "C:/Users/17036/OneDrive/Documents/GitHub/pubmed_geography/"
global drop "C:/Users/17036/Dropbox/pubmed_geography/"

cap cd "$drop"

*$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
* Try converting to 2020 USD with both the medical expenses CPI and regular PCE
foreach price in "CPIAUCSL" {
    use "preqin_deals_2000_2019.dta", clear
		replace dealsizeusdmn = dealsizeusdmn_raw*`price'2020/`price'
		local unit_pref "2020 USD in"
*$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
*===============================================================================
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

cap mkdir Output
*===============================================================================
*			 TOP 10 PORTFOLIO & INVESTING MSAs BY INDUSTRY 
*===============================================================================

foreach firm in "Pf" {
	
	if "`firm'" == "Inv" {
		local varname "investor"
		local titleA "Top 10 Investing"
	}
	if "`firm'" == "Pf" {
		local varname "portfoliocompany"
		local titleA "Top 10 Innovating"
	}
	
	local Varname = proper("`varname'")
	
	foreach loc_abbr in "City" {
		
		use `dealset', clear
		drop if stage == "Grants"

		if "`loc_abbr'" == "City" {
			local loc "city"
			local state "`varname'state"
			local titleB "MSAs"
		}
		
		local Loc = proper("`loc'")
		
		preserve
			keep if `varname'`loc' != ""
			if "`loc_abbr'" == "City" keep if strpos(`varname'country, "US") > 0
			collapse (sum) dealsizeusdmn
			local V: dis dealsizeusdmn
		restore
		
		if "`loc_abbr'" == "City" keep if strpos(`varname'country, "US") > 0
		
		egen n_`firm'`loc_abbr' = noccur(`varname'`loc'), string(",")
			replace n_`firm'`loc_abbr' = n_`firm'`loc_abbr' + 1 ///
				if `varname'`loc' != ""
			replace dealsizeusdmn = dealsizeusdmn/n_`firm'`loc_abbr'
		split `varname'`loc', p(", ")
			drop `varname'`loc'
		reshape long `varname'`loc', i(dealid dealsizeusdmn `state') j(`loc'no)
			drop `loc'no
			drop if `varname'`loc' == ""
	
			if "`loc_abbr'" == "City" {
				drop if inlist(`varname'city, "London", "Shanghai", "Basel", "Beijing", ///
					"Hong Kong", "Paris", "Singapore", "Munich", "Toronto")
				* --- By MSA City Groupings ---*
				gen `varname'msa = "Boston" if strpos(`state', "MA") > 0 ///
					& inlist(`varname'city, "Cambridge", "Waltham", "Boston")
				replace `varname'msa = "Boston" if strpos(`state', "MA") > 0 ///
					& strpos(`state', "KY") == 0 & `varname'city == "Lexington"
				replace `varname'msa = "Bay Area" if strpos(`state', "CA") > 0 ///
					& (inlist(`varname'city, "San Francisco", "Menlo Park", "Palo Alto", ///
						"San Mateo", "San Jose", "Santa Clara", "Mountain View") ///
					| inlist(`varname'city, "Redwood City", "South San Francisco", ///
						"Berkeley", "Emeryville", "Sunnyvale", "fremont"))
				replace `varname'msa = "Los Angeles" if strpos(`state', "CA") > 0 ///
					& inlist(`varname'city, "Irvine", "Santa Monica", "Orange", "Pasadena")
				replace `varname'msa = "New York" if strpos(`state', "NJ") > 0 ///
					& inlist(`varname'city, "New Brunswick")
				replace `varname'msa = "San Diego" if strpos(`state', "CA") > 0 ///
					& inlist(`varname'city, "La Jolla")
				replace `varname'msa = "Houston" if strpos(`state', "TX") > 0 ///
					& inlist(`varname'city, "The Woodlands")
				replace `varname'msa = "Washington, DC" if strpos(`state', "DC") > 0 ///
					& inlist(`varname'city, "Washington")
				replace `varname'msa = "Washington, DC" if strpos(`state', "MD") > 0 ///
					& inlist(`varname'city, "Bethesda")
				replace `varname'msa = "Washington, DC" if strpos(`state', "VA") > 0 ///
					& inlist(`varname'city, "Alexandria", "Arlington", "Reston")
				replace `varname'msa = "Lexington, KY" if strpos(`state', "KY") > 0 ///
					& `varname'city == "Lexington"
				replace `varname'msa = "Denver-Boulder" if strpos(`state', "CO") > 0 ///
					& `varname'city == "Denver"
				replace `varname'msa = "Denver-Boulder" if strpos(`state', "CO") > 0 ///
					& `varname'city == "Boulder"
				replace `varname'msa = "Durham" if strpos(`state', "NC") > 0 ///
					& `varname'city == "Chapel Hill"
				replace `varname'msa = `varname'city if `varname'msa == ""
			}
		
		if "`loc_abbr'" == "City" {
			local grpvar "msa"
			local Loc "MSA"
		}
		
		keep dealid dealyear primaryindustry dealsizeusdmn `varname'`grpvar'
		
		preserve
			collapse (sum) vol_deals_`grpvar' = dealsizeusdmn, by(`varname'`grpvar') fast
			egen `grpvar'_rank = rank(vol_deals_`grpvar'), field
			keep if `grpvar'_rank <= 10
			gsort -vol_deals_`grpvar'
			levelsof `varname'`grpvar' , local(list_top10) clean s(", ")

			tempfile top10
			save `top10', replace
		restore
		
		bys `varname'`grpvar': egen vol_deals_`grpvar' = total(dealsizeusdmn)
		bys `varname'`grpvar' dealyear: egen vol_deals_`grpvar'_yr = total(dealsizeusdmn)
		bys `varname'`grpvar' primaryindustry: egen vol_deals_`grpvar'_ind = total(dealsizeusdmn)
		
		merge m:1 `varname'`grpvar' using `top10', gen(top10) assert(1 3)
			replace top10 = 0 if top10 == 1
			replace top10 = 1 if top10 == 3
		
		if "`loc_abbr'" == "City" local sub "(US Only)"
		else local sub ""
		
		* Stacked Bar Plots ----------------------------------------------------------
		preserve
			egen vc_tot_dollars = total(dealsizeusdmn)
			gen drugs = inlist(primaryindustry, "Biotechnology", "Pharmaceuticals")
			bys drugs: egen vc_drugs_dollars = total(dealsizeusdmn)
				replace vc_drugs_dollars = . if drugs == 0
			keep if top10
			/*gen dealdecade = int(dealyear/10)*10
				tostring dealdecade, replace
				replace dealdecade = dealdecade + "s"*/
			replace primaryindustry = subinstr(subinstr(primaryindustry, " ", "", .), "&","",.)
			collapse (sum) deal_vol = dealsizeusdmn (max) vc_tot_dollars vc_drugs_dollars, ///
						by(`varname'`grpvar' primaryindustry /*dealdecade*/) fast
				gen sh_deal_vol = deal_vol/vc_tot_dollars*100
				gen sh_drugs = deal_vol/vc_drugs_dollars*100
				replace deal_vol = deal_vol/1000
				drop vc_drugs_dollars
			replace primaryindustry = "MedicalDevices" if primaryindustry == "MedicalDevicesEquipment"
			reshape wide deal_vol sh_deal_vol sh_drugs, i(`varname'`grpvar' /*dealdecade*/) j(primaryindustry) string
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
			bys `varname'`grpvar': egen tot = total(tot_vol)
			bys `varname'`grpvar': egen tot_drugs = total(drugs_vol)
			
			/* Graph by Share of VC Dollars
			graph bar (asis) sh_deal_volB sh_deal_volP sh_deal_volM sh_deal_volH*,  ///
				stack /*over(dealdecade, sort(dealdecade) lab(angle(60)))*/ ///
					over(`varname'`grpvar',  sort(tot)  descending) ///
				title("Industry Breakdown of VC Funding Recipient Firms") ///
				subtitle("Top MSAs account for `Vpct'% of VC Dollars in US Healthcare") ///
				legend(symx(small) symy(small) r(1)) yti("Share of VC Dollars in Healthcare (%)" " ") ///
				bar(1, col(green)) bar(2, col(cranberry)) bar(3, col(purple)) ///
										bar(4, col(dkorange)) bar(5, col(gs7))
			graph export "Output/`price'/top10_bars_`firm'`loc_abbr'_%_byInd.png", ///
				replace as(png) wid(1800) hei(700) */
				
			egen rowtot_drugs = rowtotal(sh_drugsB sh_drugsP)
			egen drug_totsh = total(rowtot_drugs)
			local Dpct: dis drug_totsh
			local Dpct = round(`Dpct', 1)
			
			* Graph by Share of VC Dollars in Drugs
			graph bar (asis) sh_drugsB sh_drugsP,  ///
				stack over(`varname'`grpvar',  sort(tot_drugs)  descending) ///
				title("Breakdown of VC-Backed Drugs Start-Ups") ///
				subtitle("Top MSAs account for `Dpct'% of VC Dollars in Drugs") ///
				legend(symx(small) symy(small) r(1)) yti("Share of VC Dollars in Drugs (%)" " ") ///
				bar(1, col(green)) bar(2, col(cranberry))
			graph export "Output/`price'/top10_bars_`firm'`loc_abbr'_%_Drugs.png", ///
				replace as(png) wid(1800) hei(700)
		restore // -------------------------------------------------------------------

		

	} // country / city loop
} // investor / portfolio loop

*$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
} // end CPI loop
*$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

