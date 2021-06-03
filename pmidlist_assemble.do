/*
pmidlist_assemble.do



*/

cd "Data/PubMed/"

local notqa 0 // appends the 5% sample of 1980-2018 PMIDs with
					// the 5% sample of 2019 PMIDs
local btc 0 // imports the BTC CSVs and appends them together
local master 1 // imports the full article metadata files and prepares
					// master dataset
	local master_clean 1
local merge 1 // merges PMID lists to assemble final dataset

*===============================================================================
*						IMPORT & APPEND
*===============================================================================
*--- NOT QA 5% SAMPLE ----------------------------------------------------------
if `notqa' == 1 {
	import delimited pmid using "raw/PMIDs_master_2019.csv", clear rowr(2:)
	tempfile pmids2019
	save `pmids2019', replace

	import delimited pmid using "raw/PMIDs_master_samp5pct.csv", clear rowr(2:)
	* This file is a random 5% sample by year of journal articles in PubMed published
	*	in any journal between 1980-2018
	append using `pmids2019' // Adding a random 5% of journal articles published in 2019
	duplicates drop
	export delimited "raw/notQA_pmids.csv", replace
}

*--- BASIC, TRANSLATIONAL, AND CLINICAL SCIENCE PUBS ---------------------------
if `btc' == 1 {
	local filelist: dir "raw/BTC/" files "BTC_*.csv"

	local i = 1
	foreach file of local filelist {
		dis "`file'"
		import delimited pmid query_name using "raw/BTC/`file'", rowr(2:) clear
		if _N > 0 {
			tostring pmid, replace
			drop if pmid == "NA"
			destring pmid, replace

			if `i' == 1 {
				tempfile full_pmids
				save `full_pmids', replace 
			}
			if `i' > 1 {
				append using `full_pmids'
				save `full_pmids', replace
			}
			local ++i
		}
	}

	use `full_pmids', clear

	split query_name, p("_")
	ren query_name1 btc
	gen nih = query_name2 == "NIH"
	ren query_name3 year
	destring year, replace
	drop query_name query_name2

	replace pmid = pmid*10000 if inlist(btc, "total", "totalCTs")
	duplicates tag pmid, gen(dup)
	gen nothc = btc != "healthcare" if dup > 0
		bys pmid: egen tot_nothc = total(nothc)
		drop if dup & btc == "healthcare" & tot_nothc > 0
		drop dup
	duplicates tag pmid, gen(dup)
	gen clin = btc == "clinical" if dup > 0
		bys pmid: egen tot_clin = total(clin)
		drop if btc == "translational" & tot_clin > 0 & dup
		drop dup tot_clin clin tot_nothc nothc
	bys pmid btc: egen minyr = min(year)
		drop if year > minyr
	isid pmid
	replace pmid = pmid/10000 if inlist(btc, "total", "totalCTs")
	duplicates tag pmid, gen(dup)
	drop if dup & inlist(btc, "total", "totalCTs")
	replace btc = "other" if btc == "total"
	isid pmid
	drop dup minyr

	save "BTC_pmids.dta", replace
}
*--- ARTICLE METADATA ----------------------------------------------------------
if `master' == 1 {
	if `master_clean' == 1 include $repo/clean_msa_codes2.do
	
foreach Q in /*"QA"*/ "oldqa" /*"notQA"*/ { // --- Top 7 Journals or All Journals --- //
	local filelist: dir "raw\Article_Metadata" files "`Q'_*"

	cd "raw/Article_Metadata"
	local i = 1
	foreach file of local filelist {
		import delimited pmid date mesh journal affil pt gr using "`file'", clear
		dis "`file'"

		if _N > 0 {
			tostring pmid, replace
			drop if inlist(pmid, "pmid", "v1", "NA")
			destring pmid, replace

				if `i' == 1 {
					tempfile full_pmids
					save `full_pmids', replace 
				}
				if `i' > 1 {
					append using `full_pmids'
					save `full_pmids', replace
				}
		} // _N > 0

		local ++i
	} // file loop
	cd "../../"
	save "master_`Q'_appended.dta", replace
	if `master_clean' == 1 include "$repo/master_clean.do"
}
}

*===============================================================================
*						MERGE
if `merge' == 1 {
*===============================================================================

import delimited "raw/QA_pmids.csv", clear varn(1)
drop if pmid == "NA"
destring pmid, replace
tempfile qa
save `qa', replace

use master_oldqa_clean.dta
merge 1:1 pmid using BTC_pmids.dta, keep(3) nogen
merge 1:1 pmid using `qa', keep(3) nogen

save "pubmed_geo_oldqa.dta", replace

*===============================================================================
}
*===============================================================================
cd ../../