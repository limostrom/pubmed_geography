/*
main.do




*/

set scheme s1color
pause on

local wd: pwd
if substr("`wd'",10,8) == "lmostrom" {
	global repo "C:\Users\lmostrom\Documents\GitHub\pubmed_geography"
	global drop "C:\Users\lmostrom\Dropbox\pubmed_geography\"
}
if substr("`wd'",10,5) == "17036" {
	global repo "C:\Users\17036\OneDrive\Documents\GitHub\pubmed_geography"
	global drop "C:\Users\17036\Dropbox\pubmed_geography"
}

cd $drop

*=== PUBMED DATA ===*
/*--- Imports and appends lists of PMIDs for the basic, translational, and clinical
	science publication groups, the PMID list for the 5% sample of publications
	in all journals, and the dataset of publication metadata including MeSH terms
	and author affiliations --------------------------------------------------*/
include $repo/pmidlist_assemble.do
	// this do file calls master_clean.do, pmid_authaffl_clean.do,
	// clean_msa_codes2.do, and country_tags.do

*=== PREQIN DATA ===*
*--- Imports, appends, and cleans the data on VC deals from Preqin -------------
*include $repo/preqin_import.do

*=== FIGURES ===*
include $repo/figure_1.do // bar chart, VC invested in biotech & drugs for top 10 MSAs
include $repo/figure_2.do // bar chart, basic and translational science pubs for top 10 MSAs
include $repo/figures_3-4.do // scatter, translational vs basic science, scaled by VC
							// scatter, VC vs basic + translational
	