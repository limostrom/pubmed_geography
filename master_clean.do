/*
master_dta_clean.do
Called by pmidlist_assemble.do, in `master' section (where it also inherits `Q')
*/

pause on

local all 1
local mesh 0
local date 0
local journals 0
local pub_type 0
local grants 0
local affl 0


*===============================================================================
* Append scraped files
if "`Q'" == "notQA" {

forval i = 1/13 {
	preserve
	if `i' == 1 {
		local start = 1
		local end = 100000
	}
	if inrange(`i', 2, 12) {
		local start = (`i' - 1) * 100000 + 1
		local end = `i'*100000
	}
	if `i' == 13 {
		local start = 1200000 + 1
		local end = _N
	}
	dis "`start' : `end'"
	keep if inrange(_n, `start', `end')
	tempfile sub`i'
	save `sub`i'', replace
	
	restore
}
local maxI = 13

}
else {

forval i = 1/6 {
	preserve
	if `i' == 1 {
		local start = 1
		local end = 30000
	}
	if inrange(`i', 2, 5) {
		local start = (`i' - 1) * 30000 + 1
		local end = `i'*30000
	}
	if `i' == 6 {
		local start = 150000 + 1
		local end = _N
	}
	dis "`start' : `end'"
	keep if inrange(_n, `start', `end')
	tempfile sub`i'
	save `sub`i'', replace
	
	restore
}
local maxI = 6

}
*===============================================================================

*===============================================================================
forval I = 1/`maxI' {
	use `sub`I'', clear
*===============================================================================
* Clean MeSH Terms Field
if `mesh' == 1 | `all' == 1 {
*===============================================================================
gen mesh_na = mesh == "NA"
tab mesh_na

split mesh, p("</MeshHeading>")
ren mesh mesh_raw

egen nterms = noccur(mesh_raw), string("<MeshHeading>")
	egen max_nterms = max(nterms)
	local max_nterms: dis max_nterms
	drop max_nterms

forval x=1/`max_nterms' {
	gen start = strpos(mesh`x', "MajorTopicYN=") + 17
	gen maj = start - 3
	gen end = strpos(mesh`x', "</DescriptorName>")
	gen len = end-start
	gen majortopic = substr(mesh`x', maj, 1)
	replace mesh`x' = substr(mesh`x', start, len)
	replace mesh`x' = "" if majortopic == "N"
	drop start end len maj majortopic
	compress mesh`x', nocoalesce
}

local max_1 = `max_nterms' - 1
forval i = 1/`max_1' {
	local j = `i' + 1
	forval k = `j'/`max_nterms' {
		replace mesh`i' = mesh`k' if mesh`i' == "" & mesh`k' != ""
		replace mesh`k' = "" if mesh`k' == mesh`i'
	}
	compress mesh`i'
}

* Double check pmid 12285838, which supposedly has 26 major mesh topics

*===============================================================================
} // end `mesh'
*===============================================================================

*===============================================================================
* Clean Date Field
if `date' == 1 | `all' == 1 {
*===============================================================================
ren date date_raw
gen start = strpos(date_raw, "<Year>") + 6
gen y = substr(date_raw, start, 4)
	destring y, replace
drop start

gen start = strpos(date_raw, "<Month>") + 7
gen m = substr(date_raw, start, 2)
	destring m, replace
drop start

gen start = strpos(date_raw, "<Day>") + 5
gen d = substr(date_raw, start, 2)
	destring d, replace
drop start

gen date = mdy(m, d, y)
	format date  %td
drop d m y

*===============================================================================
} // end `date'
*===============================================================================

*===============================================================================
* Clean Journals Field
if `journals' == 1 | `all' == 1 {
*===============================================================================
gen journal_na = journal == "NA"
tab journal_na

ren journal journal_raw
gen start = strpos(journal_raw, "<Title>") + 7
gen end = strpos(journal_raw, "</Title>")
gen len = end-start

gen journal = substr(journal_raw, start, len) if start != 7
drop start end len

gen start = strpos(journal_raw, "<ISOAbbreviation>") + 17
gen end = strpos(journal_raw, "</ISOAbbreviation>")
gen len = end-start

gen journal_abbr = substr(journal_raw, start, len) if start != 17
drop start end len

*===============================================================================
} // end `journals'
*===============================================================================

*===============================================================================
* Clean Publication Type Field
if `pub_type' == 1 | `all' == 1 {
*===============================================================================
gen pt_na = pt == "NA"
tab pt_na

ren pt pt_raw
gen start = strpos(pt_raw, "<PublicationType UI=") + 30
gen end = strpos(pt_raw, "</PublicationType>")
gen len = end-start

gen pub_type = substr(pt_raw, start, len)
drop start end len

gen start = strpos(pub_type, ">") + 1
replace pub_type = substr(pub_type, start, .)
drop start
*===============================================================================
} // end `pub_type'
*===============================================================================

*===============================================================================
* Clean Affiliation Field
if `affl' == 1 | `all' == 1 {
*===============================================================================
gen affl_raw = affil
ren affil affl // to work in included do file

include "$repo/pmid_authaffl_clean.do"
*===============================================================================
} // end `affl'
*===============================================================================

	save clean_p`I', replace
	*pause
} // end looping through temp files

*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
use clean_p1, clear
if "`Q'" == "notQA" {
	forval I = 2/13 {
		append using clean_p`I'
	}
}
*br
pause
*===============================================================================
* Saving clean version
*===============================================================================
drop *_raw
order pmid date pub_type pt_na journal journal_abbr journal_na ///
	affl country state_name state_abbr city zip cbsacode alt_cbsacode _merge ///
	nterms mesh*

forval i = 1/42 {
	local j = `i' + 1
	forval k = `j'/42 {
		replace mesh`i' = mesh`k' if mesh`i' == "" & mesh`k' != ""
		replace mesh`k' = "" if mesh`k' == mesh`i'
	}
}

compress *
pause
drop mesh12-mesh42

save "master_`Q'_clean.dta", replace