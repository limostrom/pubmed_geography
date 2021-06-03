/*
Clean another set of MSA Codes to see if it matches cities better
*/

*Load in list of states w/ FIPS codes
import excel "../Census/all-geocodes-v2019.xlsx", clear cellrange(A5:G43851) first

ren *, lower
keep if summarylevel == "040"
keep statecodefips areaname

ren statecodefips state_fips
ren areaname state_name

merge m:1 state_name using "../state_names_abbrs.dta", nogen keep(1 3) keepus(state_abbr)

tempfile state_fips
save `state_fips', replace

*Load in 
import excel "../Census/list2_2020.xls", clear cellrange(A3:F1271) first

ren *, lower

ren fipsstatecode state_fips
ren principalcityname city
drop cbsatitle fipsplacecode

keep if metropolitanmicropolitan == "Metropolitan Statistical Area"
	drop metropolitan*

expand 2 if city == "Athens-Clarke County unified government (balance)", gen(dup)
	replace city = "Athens" if city == "Athens-Clarke County unified government (balance)" & dup == 0
	replace city = "Clarke County" if city == "Athens-Clarke County unified government (balance)" & dup == 1
	drop dup
expand 2 if city == "Augusta-Richmond County consolidated government (balance)", gen(dup)
	replace city = "Augusta" if city == "Augusta-Richmond County consolidated government (balance)" & dup == 0
	replace city = "Richmond County" if city == "Augusta-Richmond County consolidated government (balance)" & dup == 1
	drop dup
expand 2 if city == "Butte-Silver Bow (balance)", gen(dup)
	replace city = "Butte" if city == "Butte-Silver Bow (balance)" & dup == 0
	replace city = "Silver Bow" if city == "Butte-Silver Bow (balance)" & dup == 1
	drop dup
expand 2 if city == "Louisville/Jefferson County metro government (balance)", gen(dup)
	replace city = "Louisville" if city == "Louisville/Jefferson County metro government (balance)" & dup == 0
	replace city = "Jefferson County" if city == "Louisville/Jefferson County metro government (balance)" & dup == 1
	drop dup
expand 2 if city == "Nashville-Davidson metropolitan government (balance)", gen(dup)
	replace city = "Nashville" if city == "Nashville-Davidson metropolitan government (balance)" & dup == 0
	replace city = "Davidson" if city == "Nashville-Davidson metropolitan government (balance)" & dup == 1
	drop dup
expand 2 if city == "San Buenaventura (Ventura)", gen(dup)
	replace city = "San Buenaventura" if city == "San Buenaventura (Ventura)" & dup == 0
	replace city = "Ventura" if city == "San Buenaventura (Ventura)" & dup == 1
	drop dup
expand 2 if city == "El Paso de Robles (Paso Robles)", gen(dup)
	replace city = "El Paso de Robles" if city == "El Paso de Robles (Paso Robles)" & dup == 0
	replace city = "Paso Robles" if city == "El Paso de Robles (Paso Robles)" & dup == 1
	drop dup
expand 2 if city == "Minneapolis", gen(dup)
	replace city = "Twin Cities" if city == "Minneapolis" & dup == 1
	drop dup
expand 2 if city == "Chicago", gen(dup)
	replace city = "Argonne" if city == "Chicago" & dup == 1
	drop dup

replace city = "Milford" if city == "Milford city (balance)"
replace city = "Indianapolis" if city == "Indianapolis city (balance)"
replace city = "Honolulu" if city == "Urban Honolulu"



merge m:1 state_fips using `state_fips', nogen keepus(state_name state_abbr)

local state_names zzz "Alabama" "Alaska" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" ///
						"Delaware" "Florida" "Georgia" "Hawaii" "Hawai'i" "Idaho" "Illinois" "Indiana" "Iowa" ///
						"Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" ///
						"Minnesota" "Mississippi" "Missouri" "Montana" "Nebraska" "Nevada" ///
						"New Hampshire" "New Jersey" "New Mexico" "New York" "North Carolina" ///
						"North Dakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania" "Rhode Island" ///
						"South Carolina" "South Dakota" "Tennessee" "Texas" "Utah" "Vermont" ///
						"Virginia" "Washington" "West Virginia" "Wisconsin" "Wyoming" "Puerto Rico"

levelsof state_abbr, local(state_abbrs)
levelsof city, local(city_names)

save ../MSA_city_state_clean.dta, replace