/*
Cleaning PMID author affiliations

pmid_authaffl_clean.do

*/


replace affl = "" if affl_raw == "NA" ///
				| substr(affl_raw, 1, 3) == " . " ///
				| substr(affl_raw, 1, 21) == "Nature Communications" ///
				| substr(affl_raw, 1, 15) == " Nature Reviews" ///
				| substr(affl_raw, 1, 8) == " Nature," ///
				| substr(affl_raw, 1, 5) == "Cell." ///
				| substr(affl_raw, 1, 10) == "The Lancet" ///
				| affl == "["

replace affl = subinstr(affl, "Saint Louis", "St. Louis", .)
replace affl = subinstr(affl, "St Louis", "St. Louis", .)

*First check country
gen country = ""
include "$repo/country_tags.do"

	*Common points of confusion
	replace country = "USA" if strpos(affl, "Beth Israel") > 0 & country == "Israel"
	replace country = "USA" if strpos(affl, "New London") > 0 & country == "United Kingdom"
	replace country = "USA" if strpos(affl, "New England") > 0 & country == "United Kingdom" & ///
				strpos(affl, "University of New England") == 0
		replace country = "Australia" if strpos(affl, "University of New England") > 0
	replace country = "USA" if strpos(affl, "Dartmouth") > 0 & country == "Lebanon"
	replace country = "USA" if strpos(affl, "Indiana") > 0 & country == "India"

*Then find zipcodes
gen zip = regexs(0) if regexm(affl, "[0-9][0-9][0-9][0-9][0-9]") & inlist(country, "USA", "")

*Then search strings for state names
gen state_name = ""

foreach sn of local state_names {
	dis "`sn'"
	replace state_name = "`sn'" if strpos(affl, "`sn'") > 0 & state_name == "" & inlist(country, "USA", "")
	replace state_name = "`sn'" if strpos(affl, "`sn'") > 0 & state_name != "" & ///
									strpos(affl, "`sn'") < strpos(affl, state_name) & inlist(country, "USA", "")
}

*Then search strings for state abbreviations
gen state_abbr = ""

foreach SA of local state_abbrs {
	dis "`SA'"
	local Sa = upper(substr("`SA'",1,1)) + lower(substr("`SA'",2,1))
	replace state_abbr = "`SA'" if strpos(affl, "`SA'") > 0 & state_abbr == "" & inlist(country, "USA", "")
	replace state_abbr = "`SA'" if state_abbr != "" & strpos(affl, "`SA'") > 0 & ///
									strpos(affl, "`SA'") < strpos(affl, state_abbr) & inlist(country, "USA", "")
	replace state_abbr = "`SA'" if (strpos(affl, "`Sa' ") > 0 | strpos(affl, "`Sa',") > 0 | strpos(affl, "`Sa'.") > 0) ///
								& state_abbr == "" & state_name == "" & inlist(country, "USA", "")
}

*Then search strings for city names
gen city = ""
foreach c of local city_names {
	if "`c'" != "California" {
		replace city = "`c'" if strpos(affl, "`c'") > 0 & city == "" & inlist(country, "USA", "")
		replace city = "`c'" if strpos(affl, "`c'") > 0 & city != "" & ///
									strpos(affl, "`c'") > strpos(affl, city) & inlist(country, "USA", "")
	}
		/* take city that appears later in the string because that's a more likely place for a city;
			"city names" found earlier more likely to be names of institutions or streets */
}

*Common points of confusion & specific places that need to be clarified:
replace country = "Greece" if city == "Athens" & state_abbr == "" & state_name == "" & country == ""

replace state_name = "" if strpos(affl, "Washington") > 0 & strpos(affl, "DC") > 0
	// streets named after states
replace state_abbr = "MO" if strpos(affl, "Washington University") > 0 & ///
			strpos(affl, "Western Washington University") == 0 & ///
			strpos(affl, "George Washington University") == 0
	replace state_name = "Missouri" if strpos(affl, "Washington University") > 0 & ///
			strpos(affl, "Western Washington University") == 0 & ///
			strpos(affl, "George Washington University") == 0
replace state_abbr = "NY" if strpos(affl, "Columbia University") > 0 & state_abbr == ""
	replace city = "New York" if strpos(affl, "Columbia University") > 0 & city == "Columbia"
replace state_abbr = "CT" if strpos(affl, "Yale") > 0 & state_abbr == ""
	replace city = "New Haven" if strpos(affl, "Yale") > 0 & city == ""
replace state_abbr = "FL" if strpos(affl, "University of Miami") > 0
replace state_abbr = "OH" if strpos(affl, "Miami Univ") > 0
	replace city = "Oxford" if strpos(affl, "Miami Univ") > 0
replace city = "San Diego" if strpos(affl, "La Jolla") > 0 & ///
					(city == "" | strpos(affl, "La Jolla") > strpos(affl, city))

replace state_abbr = "DC" if strpos(affl, "D.C.") > 0 & ///
			state_abbr == "" & state_name == ""
replace state_abbr = "NY" if strpos(affl, "N.Y.") > 0 & ///
			inlist(country, "USA", "") & state_abbr == "" & state_name == ""
egen noccur_newyork = noccur(affl), s("New York")
	replace city = "New York" if noccur_newyork == 2 | (noccur_newyork == 1 & state_abbr == "NY")
	drop noccur_newyork
replace state_abbr = "NC" if strpos(affl, "N.C.") > 0 & ///
			inlist(country, "USA", "") & state_abbr == "" & state_name == ""
replace state_abbr = "NH" if strpos(affl, "N.H.") > 0 & ///
			inlist(country, "USA", "") & state_abbr == "" & state_name == ""

replace state_name = "Arizona" if strpos(affl, "Ariz") > 0 ///
					& state_name == "" & state_abbr == ""
replace state_name = "California" if strpos(affl, "Calif") > 0 ///
					& state_name == "" & state_abbr == ""
replace state_name = "Connecticut" if strpos(affl, "Conn") > 0 ///
					& state_name == "" & state_abbr == ""
replace state_name = "Florida" if strpos(affl, "Fla.") > 0 ///
					& state_name == "" & state_abbr == ""
replace state_name = "Illinois" if strpos(affl, "Ill") > 0 ///
					& state_name == "" & state_abbr == ""
replace state_name = "Massachusetts" if strpos(affl, "Mass") > 0 ///
					& state_name == "" & state_abbr == ""
replace state_name = "Minnesota" if strpos(affl, "Minn") > 0 ///
					& state_name == "" & state_abbr == ""
replace state_name = "Nebraska" if strpos(affl, "Nebr.") > 0 ///
					& state_name == "" & state_abbr == ""
replace state_name = "Oklahoma" if strpos(affl, "Okla.") > 0 ///
					& state_name == "" & state_abbr == ""
replace state_name = "Colorado" if strpos(affl, "Colo") > 0 ///
					& state_name == "" & state_abbr == ""

replace city = "Atlanta" if pmid == 27222919
replace city = "Baltimore" if pmid == 25140953
replace city = "Cleveland" if inlist(pmid, 28199805, 24283197)
	replace state_abbr = "OH" if pmid == 28199805
replace city = "Stanford" if inlist(pmid, 28402244, 24720680)
	replace state_abbr = "CA" if pmid == 28402244
replace city = "New Haven" if inlist(pmid, 29466161, 28902587, 26028131, 27959694)
replace city = "Nashville" if pmid == 27806233
	replace state_abbr = "TN" if pmid == 27806233
replace city = "St. Louis" if inlist(pmid, 27959731, 30207916, 30380364)
replace city = "Pittsburgh" if pmid == 28538133
	replace state_abbr = "PA" if pmid == 28538133
replace city = "Arlington" if pmid == 28636834
replace city = "Wallingford" if pmid == 3175622
	replace state_abbr = "CT" if pmid == 3175622
replace city = "Washington" if inlist(pmid, 24855260, 30230961, 24521104)
replace city = "Providence" if pmid == 25946281
replace city = "Durham" if inlist(pmid, 29298160, 25651252)
replace city = "Boston" if inlist(pmid, 29694825, 26200979, 26083120, 29171811)
replace city = "Washington" if pmid == 29365296
replace city = "Rochester" if pmid == 28614683
replace city = "Huntsville" if pmid == 11749284
	replace state_abbr = "AL" if pmid == 11749284
replace city = "Pendleton" if pmid == 9794751
replace city = "Tarrytown" if pmid == 26933753
replace city = "Bethesda" if inlist(pmid, 25124429, 26360241, 16399157, 28728919)
replace city = "Chicago" if inlist(pmid, 26530619, 24429156)
replace city = "Philadelphia" if pmid == 25317870
	replace state_abbr = "PA" if pmid == 25317870
replace city = "White River Junction" if pmid == 24645801
replace city = "Dallas" if pmid == 28402745
replace city = "Pasadena" if inlist(pmid, 8035840, 7739682)
replace city = "Los Angeles" if inlist(pmid, 25651247, 30021096, 28877011)
	replace state_abbr = "CA" if pmid == 25651247
replace city = "Cleveland" if pmid == 30157388
replace city = "Bar Harbor" if pmid == 23723228
replace city = "Cleveland" if pmid == 26457558
replace city = "Los Alamos" if inlist(pmid, 9727972, 9727971)
	replace state_abbr = "NM" if inlist(pmid, 9727972, 9727971)
replace city = "Bethesda" if inlist(pmid, 23112322, 14963313, 27653382)
replace city = "San Diego" if pmid == 26196502
	replace state_abbr = "CA" if pmid == 26196502
replace city = "New York" if inlist(pmid, 27602661, 24450857)
	replace state_abbr = "NY" if inlist(pmid, 27602661, 27641143, 28121514, ///
								10381876, 26535512, 25891304, 24337287, 27040324, 24450857)
replace state_abbr = "" if pmid == 9014911
	replace country = "United Kingdom" if pmid == 9014911
replace city = "Bronx" if inlist(pmid, 15333840, 21680833)
replace city = "San Francisco" if inlist(pmid, 19679812, 12920282)
replace city = "Pittsburgh" if pmid == 30044935
	replace state_abbr = "PA" if pmid == 30044935
replace city = "Baton Rouge" if pmid == 28877013
replace city = "New Brunswick" if pmid == 28467732
replace city = "Buffalo" if pmid == 27509100
replace city = "Sacramento" if pmid == 10741966
replace city = "Pontiac" if pmid == 16738268
	replace state_abbr = "MI" if pmid == 16738268
replace city = "Cambridge" if inlist(pmid, 29949491, 28402238, 25689017, 26039524)
replace city = "Boston" if pmid == 28402772
replace city = "Hollywood" if pmid == 24311660
replace city = "University Park" if pmid == 9624047
replace city = "College Park" if pmid == 26250658
replace city = "St. Louis" if inlist(pmid, 30462938, 26844840)
replace city = "Duarte" if pmid == 28029927
replace city = "Silver Spring" if inlist(pmid, 29949489, 28423289, 26244879)
replace city = "Gaithersburg" if pmid == 30049853
replace city = "Rochester" if pmid == 28402767
replace city = "Hampton" if pmid == 9497278
replace city = "Fort Washington" if pmid == 26444746



replace state_abbr = "OH" if city == "Akron" & state_abbr == "" & ///
				strpos(affl, "University of Akron") > 0				
replace state_abbr = "CA" if city == "Albany" & substr(zip, 1, 2) == "94"
replace state_abbr = "NY" if city == "Albany" & substr(zip, 1, 1) == "1"
replace state_abbr = "NM" if city == "Albuquerque"
replace state_abbr = "MI" if city == "Ann Arbor"
replace state_abbr = "GA" if city == "Atlanta" & (state_abbr == "" | ///
				(state_abbr == "DC" & strpos(affl, "CDC") > 0)     | ///
				(state_abbr == "HI" & strpos(affl, "HIV") > 0)     | ///
				inlist(state_abbr, "ID", "MD", "MO", "MS", "NC", "NE", "VA"))
replace state_abbr = "GA" if city == "Augusta" & state_abbr == ""
replace state_abbr = "CO" if city == "Aurora" & (state_abbr == "" | ///
				(state_abbr == "MS" & zip == "80045"))
replace state_abbr = "UT" if pmid == 28834469
	replace city = "Salt Lake City" if pmid == 28834469
replace state_abbr = "TX" if city == "Austin" & ///
		(state_abbr == "" | substr(zip, 1, 2) == "78")
	replace state_abbr = "MN" if city == "Austin" & zip == "55912"
replace state_abbr = "MD" if city == "Baltimore" & !inlist(state_abbr, "DC", "VA")
	replace city = "Washington" if state_abbr == "DC" & city == "Baltimore"
	replace city = "Silver Spring" if pmid == 27974039
	replace city = "San Francisco" if pmid == 30575451
		replace state_abbr = "CA" if pmid == 30575451
replace state_abbr = "ME" if city == "Bangor" & strpos(affl, "Joseph Hospital") > 0
replace state_abbr = "LA" if inlist(city, "Baton Rouge", "New Orleans")
replace state_abbr = "CA" if city == "Berkeley" & inlist(state_abbr, "", "MS", "ND")
replace state_abbr = "MD" if city == "Bethesda"
replace state_abbr = "PA" if city == "Bethlehem" & strpos(affl, "Lehigh") > 0
replace state_abbr = "AL" if city == "Birmingham" & ///
			(country == "USA" | strpos(affl, "Birmingham, Ala") > 0 )
	replace country = "United Kingdom" if city == "Birmingham" & ///
			state_abbr == "" & state_name == "" & country == ""
replace state_abbr = "VA" if city == "Blacksburg"
replace state_abbr = "IN" if city == "Bloomington" & substr(zip, 1, 2) == "47"
replace state_abbr = "IL" if city == "Bloomington" & substr(zip, 1, 2) == "61"
replace city = "Durham" if city == "Boston" & state_abbr == "NC"
replace state_abbr = "MA" if city == "Boston" & ///
				(inlist(state_abbr, "", "CO", "FL", "HI", "ID", "KS", "MD", "MI") ///
				| inlist(state_abbr, "OR", "SD", "VA", "WA", "NH"))
replace state_abbr = "CO" if city == "Boulder" & inlist(state_abbr, "", "AL", "MS", "NC", "SD")
replace state_abbr = "NY" if city == "Buffalo" & inlist(state_abbr, "", "MT")
replace state_abbr = "VT" if city == "Burlington" & state_abbr == "" & substr(zip, 1, 2) == "05"
	replace state_abbr = "MA" if city == "Burlington" & state_abbr == "" & substr(zip, 1, 2) == "01"
replace state_abbr = "MA" if city == "Cambridge" & ///
		((strpos(affl, "Harvard") + strpos(affl, "MIT") + strpos(affl, "M.I.T.") > 0) | ///
		(country == "USA" & state_abbr == "" & state_name == "" & substr(zip, 1, 2) == "02") | ///
		(country == "USA" & state_abbr == "" & state_name == "" & zip == "") | ///
		inlist(pmid, 15731449, 25908816, 22086544))
	replace state_abbr = "MD" if city == "Cambridge" & state_abbr == "" & substr(zip, 1, 1) == "2"
	replace state_abbr = "" if pmid == 17196512 // UK
replace state_abbr = "IL" if (city == "Champaign" & strpos(affl, "Urbana-Champaign")) | city == "Urbana"
replace state_abbr = "NC" if city == "Chapel Hill" & state_abbr == ""
replace state_abbr = "SC" if city == "Charleston" & state_abbr == ""
replace city = "Charlottesville" if city == "Charlotte" & ///
			strpos(affl, "Charlottesville") + strpos(affl, "Charlotteville") > 0
	replace state_abbr = "VA" if city == "Charlottesville"
replace state_abbr = "IL" if city == "Chicago"
replace state_abbr = "OH" if (city == "Cincinnati" & state_abbr == "") | ///
							 (city == "Cleveland" & inlist(state_abbr, "", "MS", "VA", "NE", "TN"))
replace state_abbr = "TX" if city == "College Station" & state_abbr == ""
replace state_abbr = "SC" if city == "Columbia" & substr(zip, 1, 2) == "29"
replace state_abbr = "OH" if city == "Columbus" & ///
						((state_abbr == "" & substr(zip, 1, 2) == "43") | pmid == 29091557)
replace state_abbr = "OR" if city == "Corvallis"
replace state_abbr = "TX" if city == "Dallas" & inlist(state_abbr, "", "MD", "MI", "UT", "VA")
replace city = "Madison" if state_abbr == "WI" & city == "Dayton"
replace state_abbr = "MI" if city == "Dearborn"
replace state_abbr = "CO" if city == "Denver" & inlist(state_abbr, "", "MS", "SC", "VA")
replace state_abbr = "MI" if city == "Detroit" & state_abbr == ""
replace state_abbr = "NC" if city == "Durham"
replace state_abbr = "TX" if city == "El Paso" & state_abbr == ""
replace state_abbr = "OR" if city == "Eugene" & state_abbr == ""
replace state_abbr = "AK" if city == "Fairbanks"  & state_abbr == ""
replace state_abbr = "ND" if city == "Fargo"
replace state_abbr = "CT" if city == "Farmington" & substr(zip, 1, 2) == "06"
replace state_abbr = "MI" if city == "Flint"
replace state_abbr = "CO" if city == "Fort Collins" & substr(zip, 1, 2) == "80"
replace state_abbr = "FL" if city == "Gainesville" & state_abbr == ""
replace state_abbr = "MI" if city == "Grand Rapids" & substr(zip, 1, 2) == "49"
replace state_abbr = "NC" if city == "Greenville" & substr(zip, 1, 2) == "27"
replace city = "Palo Alto" if city == "Hanover" & state_abbr == "CA" & substr(zip, 1, 2) == "94"
replace state_abbr = "CT" if city == "Hartford" & state_abbr == ""
replace state_abbr = "MS" if city == "Hattiesburg"  & state_abbr == ""
replace city = "Honolulu" if city == "" & inlist(state_abbr, "", "HI") & strpos(affl, "Manoa") > 0
replace state_abbr = "HI" if city == "Honolulu" & state_abbr == ""
replace city = "Stanford" if city == "Hoover" & state_abbr == "CA"
replace state_abbr = "TX" if city == "Houston" & ///
				(inlist(state_abbr, "", "UT", "VA") | ///
				 (state_abbr == "MD" & strpos(affl, "MD Anderson") > 0) | ///
				 (state_abbr == "MS" & substr(zip, 1, 2) == "77"))
replace state_abbr = "AL" if city == "Huntsville"
replace state_abbr = "TN" if city == "Johnson City" & state_abbr == ""
replace state_abbr = "NY" if city == "Kettering" & strpos(affl, "Kettering Cancer Center") > 0
	replace city = "New York" if city == "Kettering" & strpos(affl, "Kettering Cancer Center") > 0
replace state_abbr = "TN" if city == "Knoxville" & inlist(state_abbr, "", "UT")
replace state_abbr = "WI" if city == "La Crosse"
replace city = "St. Louis" if city == "Lafayette" & state_abbr == "MO"
replace state_abbr = "MI" if city == "Lansing" & state_abbr == ""
replace state_abbr = "KS" if city == "Lawrence" & substr(zip, 1, 2) == "66"
replace city = "Livermore" if city == "Lawrence" & state_abbr == "CA" & ///
				strpos(affl, "Lawrence Livermore") > 0
replace city = "Berkeley" if city == "Lawrence" & state_abbr == "CA" & ///
				strpos(affl, "Lawrence Berkeley") > 0
replace state_abbr = "KY" if city == "Lexington" & substr(zip, 1, 2) == "40"
replace state_abbr = "AR" if city == "Little Rock" & state_abbr == ""
replace state_abbr = "CA" if (city == "Long Beach" & inlist(state_abbr, "", "VA")) | ///
					(city == "Los Angeles" & ///
						(inlist(state_abbr, "", "HI", "LA", "SC", "VA") | substr(zip, 1, 2) == "90"))
replace state_abbr = "WI" if city == "Madison" & inlist(state_abbr, "", "MD", "MI", "MS", "SC", "SD")
replace state_abbr = "TN" if city == "Memphis" & state_abbr == ""
replace state_abbr = "FL" if city == "Miami" & (state_abbr == "" | substr(zip, 1, 2) == "33")
replace state_abbr = "WI" if city == "Milwaukee"
replace state_abbr = "MT" if city == "Missoula"
replace state_abbr = "WV" if city == "Morgantown"
replace state_abbr = "NJ" if city == "Morristown"
replace state_abbr = "TN" if city == "Nashville"
replace state_abbr = "CT" if inlist(city, "New Haven", "New London")
replace state_abbr = "LA" if city == "New Orleans"
replace city = "New Brunswick" if city == "" & inlist(state_abbr, "", "NJ") & strpos(lower(affl), "rutgers") > 0
replace state_abbr = "NJ" if city == "New Brunswick" & state_abbr == ""
replace state_abbr = "NJ" if city == "Newark" & substr(zip, 1, 2) == "07"
	replace state_abbr = "DE" if city == "Newark" & substr(zip, 1, 2) == "19"
replace state_abbr = "VA" if city == "Norfolk"
replace state_abbr = "CA" if city == "Oakland" & state_abbr == ""
replace state_abbr = "OK" if city == "Oklahoma City"
replace state_abbr = "NE" if city == "Omaha"
replace state_abbr = "FL" if city == "Orlando"
replace state_abbr = "PA" if inlist(city, "Philadelphia", "Pittsburgh")
replace state_abbr = "AZ" if city == "Phoenix"
replace state_abbr = "OR" if city == "Portland" & (zip == "" | substr(zip,1,2) == "97")
replace state_abbr = "NJ" if city == "Princeton" & (substr(zip,1,2) == "08" | state_abbr == "")
replace state_abbr = "RI" if city == "Providence"
replace city = "Stanford" if city == "Pueblo" & state_abbr == "CA" & ///
				strpos(affl, "Stanford") > 0
replace state_abbr = "NC" if city == "Raleigh"
replace state_abbr = "NV" if city == "Reno"
replace state_abbr = "WA" if city == "Richland"
replace state_abbr = "VA" if city == "Richmond" & substr(zip,1,2) == "23"
replace state_abbr = "CA" if city == "Richmond" & substr(zip,1,2) == "94"
replace state_abbr = "MN" if city == "Rochester" & (substr(zip,1,2) == "55" | strpos(affl, "Mayo Clinic") > 0)
replace state_abbr = "NY" if city == "Rochester" & (substr(zip,1,2) == "14" | ///
										strpos(affl, "University of Rochester") > 0)
replace city = "Hamilton" if city == "Rocky Mount" & strpos(affl, "Rocky Mountain Lab") > 0
	replace state_abbr = "MT" if city == "Rocky Mount" & strpos(affl, "Rocky Mountain Lab") > 0
replace city = "Sacramento" if strpos(affl, "Davis") > 0 & city == "" & state_abbr == "" ///
		& inlist(country, "", "USA")
replace state_abbr = "UT" if city == "Salt Lake City"
replace state_abbr = "TX" if city == "San Antonio"
replace state_abbr = "CA" if inlist(city, "San Diego", "San Francisco", "San Jose", "Santa Barbara", ///
									"Santa Cruz", "Santa Monica", "Sacramento", "Irvine")
	replace state_abbr = "CA" if city == "Orange" & state_abbr == ""
replace state_abbr = "WA" if inlist(city, "Seattle", "Spokane")
replace city = "Stanford" if city == "Sherman" & state_abbr == "CA"
replace state_abbr = "IL" if city == "Springfield" & substr(zip,1,2) == "62"
	replace state_abbr = "MA" if city == "Springfield" & strpos(affl, "Baystate Health") > 0
replace state_abbr = "MO" if city == "St. Louis"
replace state_abbr = "MN" if city == "St. Paul"
replace state_abbr = "WA" if city == "Tacoma"
replace state_abbr = "FL" if city == "Tampa"
replace state_abbr = "AZ" if city == "Tempe"
replace state_abbr = "KS" if city == "Topeka"
replace state_abbr = "AZ" if city == "Tucson"
replace state_abbr = "AL" if city == "Tuscaloosa"
replace city = "Bethesda" if city == "Warren" & state_abbr == "MD"
replace city = "Stanford" if city == "Washington" & state_abbr == "CA"
replace state_abbr = "DC" if city == "Washington" & ///
			inlist(state_abbr, "HI", "ID", "NE", "NH", "PA", "PR", "SC") // HIV/AIDS orgs, NE quadrant
replace city = "St. Louis" if city == "Washington" & state_abbr == "MO" & ///
				(strpos(affl, "St Louis") + strpos(affl, "Saint Louis") > 0 | substr(zip,1,3) == "631" | ///
					(strpos(affl, "Washington University") > 0 & ///
						strpos(affl, "George Washington University") + strpos(affl, "Western Washington University") == 0))
replace city = "Ellensburg" if zip == "98926"
	replace state_abbr = "WA" if zip == "98926"
	replace city = "Seattle" if city == "Washington" & state_abbr == "WA" & strpos(affl, "Seattle") > 0
replace state_abbr = "DE" if city == "Wilmington" & state_abbr == "CO" & substr(zip, 1, 3) == "198"
replace state_abbr = "MA" if city == "Worcester" & country == "USA"
replace state_abbr = "CA" if strpos(affl, "Burnham Institute") > 0 & city == "" & state_abbr == ""
	replace city = "San Diego" if strpos(affl, "Burnham Institute") > 0 & city == "" & state_abbr == ""
replace state_abbr = "CA" if strpos(affl, "Caltech") > 0 & city == "" & state_abbr == ""
	replace city = "Pasadena" if strpos(affl, "Caltech") > 0 & city == "" & state_abbr == ""
replace state_abbr = "OH" if city == "Youngstown"
replace city = "Hanover" if city == "" & strpos(affl, "Dartmouth") > 0 & inlist(state_abbr, "", "NH")
	replace state_abbr = "NH" if strpos(affl, "Dartmouth") > 0 & city == "Hanover" & state_abbr == ""
replace city = "Washington" if city == "" & strpos(affl, "Urban Institute") > 0 & inlist(state_abbr, "", "DC")
	replace state_abbr = "DC" if strpos(affl, "Urban Institute") > 0 & city == "Washington" & state_abbr == ""
replace city = "Washington" if city == "" & strpos(affl, "Georgetown University") > 0 & city == "Georgetown"
	replace state_abbr = "DC" if strpos(affl, "Georgetown University") > 0 & city == "Washington" & state_abbr == ""
replace city = "Washington" if city == "" & strpos(affl, "House of Representatives") > 0 & country == "USA"
	replace state_abbr = "DC" if strpos(affl, "House of Representatives") > 0 & city == "Washington" & state_abbr == ""
replace city = "Washington" if city == "" & strpos(affl, "Congress") > 0 & country == "USA"
	replace state_abbr = "DC" if strpos(affl, "Congress") > 0 & city == "Washington" & state_abbr == ""

replace city = "Washington" if state_abbr == "DC" & city == ""

replace city = "Jacksonville" if city == "Jackson" & strpos(affl, "Jacksonville")
	replace state_abbr = "FL" if city == "Jacksonville"
	replace state_abbr = "MS" if city == "Jackson" & state_abbr == ""
replace city = "Boston" if city == "Albany" & strpos(affl, "Boston University") > 0
replace city = "Berkeley" if city == "Albany" & ///
					(state_abbr == "CA" | state_name == "California")
replace city = "Smithville" if strpos(affl, "Anderson Cancer Center") > 0 & city == "Anderson"
	replace state_abbr = "TX" if strpos(affl, "Anderson Cancer Center") > 0 & city == "Anderson"
replace city = "Chicago" if zip == "60607"
replace city = "Royal Oak" if city == "Beaumont" & zip == "48073"
	replace state_abbr = "MI" if city == "Beaumont" & zip == "48073"
replace city = "South Bend" if city == "Bend" & strpos(affl, "South Bend") > 0
	replace state_abbr = "IN" if city == "South Bend"
replace city = "New Brunswick" if city == "Brunswick" & strpos(affl, "New Brunswick") > 0
	replace state_abbr = "NJ" if city == "New Brunswick" & inlist(state_abbr, "", "MD")
replace city = "Daytona Beach" if city == "Dayton" & strpos(affl, "Daytona Beach") > 0
replace city = "Fayetteville" if city == "Fayette" & strpos(affl, "Fayetteville") > 0
replace city = "Hendersonville" if city == "Henderson" & strpos(affl, "Hendersonville") > 0
replace city = "Madisonville" if city == "Madison" & strpos(affl, "Madisonville") > 0

replace city = "Boston" if city == "" & inlist(state_abbr, "", "MA") & ///
		strpos(affl, "Harvard") + strpos(affl, "Dana Farber") + strpos(affl, "Dana-Farber") + ///
				strpos(affl, "Brigham and Women") + strpos(affl, "Massachusetts General Hospital") > 0
		replace state_abbr = "MA" if city == "Boston" & state_abbr == ""
replace city = "Durham" if city == "" & inlist(state_abbr, "", "NC") & ///
		strpos(affl, "Duke University") + strpos(affl, "Duke Medical") > 0
		replace state_abbr = "NC" if city == "Durham" & state_abbr == ""
replace city = "Washington" if city == "" & inlist(state_abbr, "", "DC") & ///
		strpos(affl, "Smithsonian") > 0 | strpos(affl, "Brookings Institution") > 0
		replace state_abbr = "DC" if city == "Washington" & strpos(affl, "Smithsonian") > 0
replace city = "Baltimore" if city == "" & inlist(state_abbr, "", "MD") & ///
		strpos(affl, "Johns Hopkins") > 0
		replace state_abbr = "MD" if city == "Baltimore" & state_abbr == ""
replace city = "Providence" if city == "" & inlist(state_abbr, "", "RI") & ///
		strpos(affl, "Brown University") > 0
		replace state_abbr = "RI" if city == "Providence" & state_abbr == ""
replace city = "Evanston" if city == "" & inlist(state_abbr, "", "IL") & ///
		strpos(affl, "Northwestern University") > 0
		replace state_abbr = "IL" if city == "Evanston" & state_abbr == ""
replace city = "Waltham" if city == "" & inlist(state_abbr, "", "MA") & ///
		strpos(affl, "Brandeis University") > 0
		replace state_abbr = "MA" if city == "Waltham" & state_abbr == ""
replace city = "New York" if city == "" & inlist(state_abbr, "", "NY") & ///
		(strpos(affl, "Mount Sinai") > 0 | strpos(affl, "Yeshiva University") > 0)
		replace state_abbr = "NY" if city == "New York" & state_abbr == ""
replace city = "Stanford" if strpos(affl, "Stanford") > 0 & city == "" & inlist(state_abbr, "", "CA")
	replace state_abbr = "CA" if city == "Stanford" & state_abbr == ""
replace city = "Santa Clara" if city == "Stanford" & state_abbr == "CA"
replace city = "New York" if (inlist(state_abbr, "NY", "") | state_name == "New York") & ///
		city == "" & strpos(affl, "Brooklyn") + strpos(affl, "Bronx") + strpos(affl, "Queens") > 0
replace city = "New York" if (city == "York" & state_abbr == "NY") | ///
				(inlist(substr(zip,1,3), "100", "112") & strpos(affl, "Brooklyn") > 0)
	replace state_abbr = "New York" if city == "New York"
replace city = "Atlanta" if (strpos(affl, "Centers for Disease Control") > 0 ///
							| strpos(affl, "Emory University") > 0) ///
				& city == "" & inlist(state_abbr, "", "GA")
	replace state_abbr = "GA" if (strpos(affl, "Centers for Disease Control") > 0 ///
								| strpos(affl, "Emory University") > 0) ///
				& inlist(city, "", "Atlanta") & state_abbr == ""

replace country = "Austria" if city == "Vienna" & state_name == "" & state_abbr == "" & country == ""
replace country = "Canada" if city == "Kingston" & country == "" & state_abbr == ""
	replace country = "Canada" if city == "Victoria" & strpos(affl, "East Geelong") > 0
replace country = "Peru" if city == "Lima" & state_abbr == "" & state_name == ""
replace country = "United Kingdom" if inlist(city, "Bristol", "Cambridge", "Manchester", ///
											"Norwich", "Salisbury", "Warwick", "Oxford")  & ///
			state_name == "" & state_abbr == "" & country == ""
replace country = "United Kingdom" if city == "Victoria" & strpos(affl, "Victoria Infirmary") > 0
replace country = "United Kingdom" if (strpos(affl, "Ackton Hospital") > 0 | ///
			strpos(affl, "Addenbrooke's Hospital") > 0 | ///
			strpos(affl, "Brunel University") > 0 | ///
			strpos(affl, "Aberdeen Royal Infirmary") > 0 | ///
			strpos(affl, "University of Oxford") > 0 | ///
			(strpos(affl, "Ipswich Hospital") > 0 & strpos(affl, "Suffolk") > 0)) ///
			& state_name == "" & state_abbr == "" & country == ""
replace country = "Canada" if strpos(affl, "Hamilton") > 0 & ///
			(strpos(affl, "ON") + strpos(affl, "Ont.") > 0)
replace country = "Canada" if (strpos(affl, "McGill University") > 0 | ///
			strpos(affl, "University of Alberta")) & ///
			state_name == "" & state_abbr == "" & country == ""
replace country = "France" if strpos(affl, "Institut de Chimie") > 0 & ///
			state_name == "" & state_abbr == "" & country == ""
replace country = "Italy" if strpos(affl, "University of Florence") > 0 & ///
			state_name == "" & state_abbr == "" & country == ""

	


*In case of conflicts / multiple author affiliations
replace state_name = "" if state_name != "" & state_abbr != "" & ///
							strpos(affl, state_abbr) > strpos(affl, state_name)
replace state_abbr = "" if state_name != "" & state_abbr != "" & ///
							strpos(affl, state_name) > strpos(affl, state_abbr)
replace zip = "" if !inlist(country, "", "USA") // 5-digit address probably
replace country = "USA" if (strpos(affl, "USA") > 0 | state_name != "" | state_abbr != "") ///
					& country == ""

merge m:1 state_name using "../state_names_abbrs.dta", nogen keep(1 3) keepus(state_abbr) update

*========================================

merge m:1 city state_abbr using "../MSA_city_state_clean.dta", keep(1 3) keepus(cbsacode)
destring cbsacode, replace
replace cbsacode = . if country != "USA"

bys zip: egen alt_cbsacode = mode(cbsacode)
	replace cbsacode = alt_cbsacode if (city == "" | state_abbr == "" | country == "USA") ///
								& zip != ""



