/*
figures_3-4.do

NOTE: basic science pubs in top 7 journals: 141,696
		basic science pubs in Cell, Nature, and Science: 110,448 (78%)

*/
clear all
cap log close
pause on

use Data/deals_pfcomp_byMSA.dta, clear
replace cbsacode = 41860 if cbsacode == 41940 // Bay Area
gen decade = 10*int(dealyear/10)
	keep if inlist(decade, 2010)
drop deals_raw
collapse (sum) deals_2020USDmn, by(cbsacode decade class)
reshape wide deals_2020USDmn, i(cbsacode decade) j(class) string
tempfile vcdollars
save `vcdollars', replace

use Data/PubMed/pubmed_geo_oldqa.dta, clear

drop if inlist(btc, "healthcare", "trial", "other")	
gen has_affl = affl != ""
gen usa = has_affl & inlist(country, "", "USA")
gen decade = 10*int(year/10)
	keep if inlist(decade, 2010)
keep if usa

replace cbsacode = 41860 if cbsacode == 41940 // Bay Area
replace cbsacode = 19740 if cbsacode == 14500 // Denver-Boulder

collapse (count) pmid, by(cbsacode decade btc)
reshape wide pmid, i(cbsacode decade) j(btc) string
ren pmidtranslational pmidt
ren pmidbasic pmidb
ren pmidclinical pmidc

merge 1:1 cbsacode decade using `vcdollars', keep(3) nogen
	ren deals*y vc_biotech
	ren deals*s vc_pharma
	ren deals*e vc_healthcare
reshape wide pmidb pmidt pmidc vc_*, i(cbsacode) j(decade)

egen msa_pub_tot = rowtotal(pmid*)
drop if cbsacode == .

gsort -msa_pub_tot
g byte sample1 = _n <= 26


gen vc_drugs = vc_biotech + vc_pharma
	egen tot_vc_drugs = total(vc_drugs)
	gen sh_vc_drugs = vc_drugs/tot_vc_drugs*100
	
egen totbas = total(pmidb)
	gen shbas = pmidb/totbas*100
	lab var shbas "Share of Basic Science Publications (%)"

egen tottra = total(pmidt)
	gen shtra = pmidt/tottra*100
	lab var shtra "Share of Translational Science Publications (%)"
	
gen sh_science = (pmidb+pmidt)/(totbas+tottra)*100
	lab var sh_science "Share of Science Publications (%)"

egen totclin = total(pmidc)
	gen shclin = pmidc/totclin*100
	lab var shclin "Share of Clinical Science Publications (%)"

gen deg45y = 0 if _n == 1
gen deg45x = 0 if _n == 1
replace deg45y = 25 if _n == 2
replace deg45x = 25 if _n == 2

gen cbsaname = "Boston" if cbsacode == 14460 // 1
	replace cbsaname = "DC-Bethesda" if cbsacode == 47900 // 3
	replace cbsaname = "Bay Area" if cbsacode == 41860 // 2
	replace cbsaname = "Baltimore" if cbsacode == 12580 // 4
	replace cbsaname = "San Diego" if cbsacode == 41740 // 5
	replace cbsaname = "Los Angeles" if cbsacode == 31080 // 6 
	replace cbsaname = "Chicago" if cbsacode == 16980 // 10
	replace cbsaname = "New Haven" if cbsacode == 35300 // 9
	replace cbsaname = "Durham-Chapel Hill" if cbsacode == 20500 // 7
	replace cbsaname = "Atlanta" if cbsacode == 12060 // 11
	replace cbsaname = "Seattle" if cbsacode == 42660 // 8
	replace cbsaname = "Philadelphia" if cbsacode == 37980 // 12
	replace cbsaname = "Houston" if cbsacode == 26420 // 13
	replace cbsaname = "Dallas" if cbsacode == 19100 // 14
	replace cbsaname = "St. Louis" if cbsacode == 41180 // 15
	replace cbsaname = "Ann Arbor" if cbsacode == 11460 // 16
	replace cbsaname = "Denver-Boulder" if cbsacode == 19740 // 17
	replace cbsaname = "Princeton-Trenton" if cbsacode == 45940 // 18
	replace cbsaname = "Pittsburgh" if cbsacode == 38300 // 19
	replace cbsaname = "Madison" if cbsacode == 31540 // 20
	replace cbsaname = "Cleveland" if cbsacode == 17460 // 21
	replace cbsaname = "Worcester" if cbsacode == 49340 // 22
	replace cbsaname = "Minneapolis-St.Paul" if cbsacode == 33460 // 23
	replace cbsaname = "Nashville" if cbsacode == 34980 // 24
	replace cbsaname = "Ithaca" if cbsacode == 27060 // 25
	replace cbsaname = "New York" if cbsacode == 35620 // 26

#delimit ;
tw (line deg45y deg45x if _n<3, lw(thin) lc(gs10))
   (scatter shtra shbas if sample1 & _n==1, /* Boston */
			msym("o") mc(white) mlabel(cbsaname) mlabp(9) mlabc(black) mlabsize(vsmall) mlabgap(0.5cm))
   (scatter shtra shbas if sample1 & inlist(_n,2), /* Bay */
			msym("o") mc(white) mlabel(cbsaname) mlabp(2) mlabc(black) mlabsize(vsmall) mlabgap(0.5cm))
   (scatter shtra shbas if sample1 & inlist(_n,5), /* SD */
			msym("o") mc(white) mlabel(cbsaname) mlabp(2) mlabc(black) mlabsize(vsmall) mlabgap(0.3cm))
   (scatter shtra shbas if sample1 & inlist(_n,3,6), /*DC & LA */
			msym("o") mc(white) mlabel(cbsaname) mlabp(3) mlabc(black) mlabsize(vsmall))
   (scatter shtra shbas if sample1 & _n==4, /* Baltimore */
			msym("o") mc(white) mlabel(cbsaname) mlabp(2) mlabc(black) mlabsize(vsmall))
   (scatter shtra shbas if sample1 & _n==9, /* New Haven */
			msym("o") mc(white) mlabel(cbsaname) mlabp(1) mlabc(black) mlabsize(vsmall))
   (scatter shtra shbas if sample1 & _n==8, /* Seattle */
			msym("o") mc(white) mlabel(cbsaname) mlabp(3) mlabc(black) mlabsize(vsmall) mlabgap(0.05in))
   (scatter shtra shbas if sample1 & inlist(_n,7), /*Durham*/
			msym("o") mc(white) mlabel(cbsaname) mlabp(5) mlabc(black) mlabsize(vsmall))
   (scatter shtra shbas if sample1 & inlist(_n,10), /*Chicago*/
			msym("o") mc(white) mlabel(cbsaname) mlabp(5) mlabc(black) mlabsize(vsmall) mlabgap(0.1in))
   (scatter shtra shbas if sample1 & inlist(_n,12), /*Philly*/
			msym("o") mc(white) mlabel(cbsaname) mlabp(5) mlabc(black) mlabsize(vsmall) mlabgap(0.07in))
   (scatter shtra shbas if sample1 & inlist(_n,11, 13), /*Altanta & Houston */
			msym("o") mc(white) mlabel(cbsaname) mlabp(12) mlabc(black) mlabsize(vsmall) mlabgap(1.75in))
   (scatter shtra shbas if sample1 & inlist(_n,15), /* St. Louis */
			msym("o") mc(white) mlabel(cbsaname) mlabp(12) mlabc(black) mlabsize(vsmall) mlabgap(1.6in))
   (scatter shtra shbas if sample1 & inlist(_n,14), /* Dallas */
			msym("o") mc(white) mlabel(cbsaname) mlabp(12) mlabc(black) mlabsize(vsmall) mlabgap(1.5in))
   (scatter shtra shbas if sample1 & _n==26,
			msym("o") mc(white) mlabel(cbsaname) mlabp(4) mlabc(black) mlabsize(vsmall))
   (scatter shtra shbas if sample1 [w=vc_drugs], msym("oh") mc(black)),
	legend(off)
	xti("Share of Basic Science Publications (%)", size(small))
	yti("Share of Translational Science Publications (%)" " " " ", size(small))
	ti("Scientific Research, 2010-2019" "Scaled by VC$s in Biotech & Pharma", size(medsmall))
	subti("Top 26 MSAs", size(small)) ylab(0(5)25) xlab(0(5)25)
	note("Lower Left: Ann Arbor, Denver-Boulder, Princeton, Pittsburgh, Madison WI,"
		"Cleveland, Worcester MA, Minneapolis-St. Paul, Nashville, Ithaca NY", size(vsmall));
graph export "Output/fig3-scatter_TvsB_scaledVC.png",
	replace as(png) wid(800) hei(800);

replace deg45y = 30 if _n == 2;
replace deg45x = 30 if _n == 2;
tw (line deg45y deg45x if _n<3, lw(thin) lc(gs10))
   (scatter sh_vc_drugs sh_science if sample1 & inlist(_n,1,2,5,10),
		msym("o") mc(white) mlabel(cbsaname) mlabp(9) mlabc(black) mlabsize(vsmall))
   (scatter sh_vc_drugs sh_science if sample1 & inlist(_n,26,3,6),
		msym("o") mc(white) mlabel(cbsaname) mlabp(3) mlabc(black) mlabsize(vsmall))
   (scatter sh_vc_drugs sh_science if sample1 & inlist(_n,4),
		msym("o") mc(white) mlabel(cbsaname) mlabp(4) mlabc(black) mlabsize(vsmall))
   (scatter sh_vc_drugs sh_science if sample1 & inlist(_n,8,12),
		msym("o") mc(white) mlabel(cbsaname) mlabp(10) mlabc(black) mlabsize(vsmall))
   (scatter sh_vc_drugs sh_science if sample1 & inlist(_n,9),
		msym("o") mc(white) mlabel(cbsaname) mlabp(1) mlabc(black) mlabsize(vsmall) mlabgap(0.35in))
   (scatter sh_vc_drugs`y' sh_science if sample1 & inlist(_n,7),
		msym("o") mc(white) mlabel(cbsaname) mlabp(2) mlabc(black) mlabsize(vsmall) mlabgap(0.3in))
   (scatter sh_vc_drugs sh_science if sample1, msym("oh") mc(black)),
	legend(off)
	xti("Share of Science Publications (%)", size(small)) xlab(0(5)30)
	yti("Share of VC Funding to Drugs (%)" " " " ", size(small)) ylab(0(5)30)
	ti("Scientific Research & VC Investment in Drugs" "2010-2019", size(medsmall))
	subti("Top 26 MSAs", size(small)) /*ylab(0(5)25) xlab(0(5)25)*/
	note("Lower Left: Atlanta, Houston, Dallas, St. Louis, Ann Arbor, Denver-Boulder, Princeton,"
		"Pittsburgh, Madison, Cleveland, Worcester MA, Minneapolis-St. Paul, Nashville, Ithaca NY"
		, size(vsmall));
graph export "Output/fig4-scatter_VCvsSci.png",
	replace as(png) wid(800) hei(800);

#delimit cr
