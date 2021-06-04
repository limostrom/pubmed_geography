/*
figure_2.do
*/

use Data/PubMed/pubmed_geo_oldqa.dta, clear

drop if inlist(btc, "healthcare", "trial", "other")	
gen has_affl = affl != ""
gen usa = has_affl & inlist(country, "", "USA")

gen MSAgroup = "Boston" if cbsacode == 14460 // 1
	replace MSAgroup = "DC-Bethesda" if cbsacode == 47900 // 2
	replace MSAgroup = "Bay Area" if inlist(cbsacode, 41860, 41940) // 3 & 6
	replace MSAgroup = "Baltimore" if cbsacode == 12580 // 4
	replace MSAgroup = "San Diego" if cbsacode == 41740 // 5
	replace MSAgroup = "Los Angeles" if cbsacode == 31080 // 7 
	replace MSAgroup = "Chicago" if cbsacode == 16980 // 8
	replace MSAgroup = "New Haven" if cbsacode == 35300 // 9
	replace MSAgroup = "Durham" if cbsacode == 20500 // 10
	*replace MSAgroup = "Atlanta" if cbsacode == 12060 // 11
	*replace MSAgroup = "Seattle" if cbsacode == 42660 // 12
	*replace MSAgroup = "New York" if cbsacode == 35620 // 28

	replace MSAgroup = "Other" if cbsacode != . & MSAgroup == ""

keep if usa

gen decade = 10*int(year/10)
keep if inlist(btc, "basic", "translational")

collapse (count) pmid, by(cbsacode MSAgroup decade)
collapse (sum) pmid, by(MSAgroup decade)
	bys MSAgroup: egen sort_tot = total(pmid)
	bys decade: egen decade_pubs = total(pmid)
		gen sh_dec_pubs = pmid/decade_pubs * 100
	
	* -- Calculating N to show what % in these top MSAs -- *	
	preserve
		keep if decade == 2010
		collapse (sum) pmid
		local N: dis pmid
	restore
	preserve
		keep if !inlist(MSAgroup, "", "Other") & decade == 2010
		collapse (sum) pmid
		local n: dis pmid
		local pctN = round(`n'/`N'*100, 1)
	restore
		
	#delimit ;
	graph bar (asis) sh_dec_pubs if inlist(decade, 2010) 
		& !inlist(MSAgroup, "", "Other"), 
		bar(1, col(edkblue)) over(MSAgroup, sort(sort_tot) descending)
	yti("Share of Science Publications (%)")
	title("Top 10 MSAs for Academic Science")
	subtitle("Top MSAs account for `pctN'% of Science Publications") legend(off);
	graph export "Output/fig2-bars_BT_bymsa_%.png",
		replace as(png) wid(1600) hei(700);
	#delimit cr