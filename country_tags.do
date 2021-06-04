/*
Extract other country names

*/
pause on


#delimit ;
local countries zzz "Afghanistan" "Algeria" "Andorra" "Angola" "Argentina" "Buenos Aires"
			"Armenia" "Yerevan" "Aruba"
			"Australia" "Adelaide" "Brisbane" "Camperdown" "Canberra" "Melbourne" "Perth" "Sydney"
			"Austria" "Wien" "Azerbaijan" "Bangladesh"
			"Belgium" "Belgique" "Brussels" "Leuven" "Bruxelles"
			"Belarus" "Benin"
			"Bermuda" "Botswana" "Brazil" "Brasil" "Rio " "SÃ£o Paulo" "Bulgaria" "Burkina Faso" "Cameroon" 
			"Canada" "British Columbia" "Calgary" "Edmonton" "Manitoba" "Montreal" "MontrÃ©al" "Nova Scotia"
				"Ontario" "Ottawa" "Quebec" "QuÃ©bec" "Toronto" "Vancouver" "Winnipeg" "Canadian"
			"Chile" "Cambodia" "Phnom Penh" "Cameroon" "Cameroun" "Chad"
			"China" "Chinese" "Beijing" "Changsha" "Guangdong" "Guangzhou" "Shanghai" "Urumchi" "Urumqi"
			"Colombia" "BogotÃ¡" "BogatÃ¡" "Congo" "Costa Rica"
			"Croatia" "Cuba" "Cyprus" "Czech Republic" "Prague" "Brno"
			"Denmark" "Danish" "Aarhus" "Copenhagen" "Faroe Islands" "Lyngby"
			"Dominican Republic"
			"Ecuador" "Egypt" "Cairo" "Ethiopia" "Addis Ababa" "England" "Estonia"
			"Helsinki" "Turku" "Finland"
			"France" "French Guiana" "Guadeloupe" "New Caledonia" 
				"Angers" "Beaujon" "Bordeaux" "Boulogne" "Dijon" "Lille" "Limoges" "Lyon"
				"Marseille" "Nantes" "Nice" "Nogent" "Paris" "Rouen" "Strasbourg" "Toulouse"
				"Villejuif" "Vitry Sur Seine"
			"Fiji" "French Polynesia" "Gaza," "Gaza "
			"German" "Deutschland" "FRG" "FGR" "DDR"
				"Berlin" "Bochum" "Bremen" "DÃ¼sseldorf" "Essen" "Frankfurt" "Grosshansdorf"
				"Halle" "Hamburg" "Hannover" "Heidelberg" "Homburg"
				"Kiel" "Mainz" "Munich" "MÃ¼nchen" "Regensburg" "Tuebingen" "TÃ¼bingen" "Ulm," "Ulm " ".de."
			"Gambia" "Banjul" "Gabon" "Ghana" "GHANA" "Greece" "Thessaloniki"
			"Guatemala" "Haiti" "Port-au-Prince"
			"Honduras" "Hong Kong" "Hungary" "Budapest" "Iceland" 
			"India" "Bangalore" "Bombay" "Calcutta" "Gujarat" "Kolkata" "Maharashtra"
				"Mumbai" "New Delhi" "Tamilnadu" "Tamil Nadu"
			"Indonesia" "Iran" "Ireland" "Dublin" "Iraq" "Baghdad"
			"Israel" "Jerusalem" "Haifa" "Tel Aviv" "Tel Hashomer"
			"Italy" "Italia" "Basilicata" "Bologna" "Brescia" "Catania" "Genoa" "Genova" "Milan"
				"Modena" "Napoli" "Pavia" "Padova" "Pescara" "Pisa" "Rome" "Roma" "Torino"
			"Ivory Coast" "Abidjan" "CÃ´te d'Ivoire"
			"Jamaica" "Jordan" 
			"Japan" "Aichi" "Amagasaki" "Aomori" "Chiba" "Fukui" "Fukuoka" "Fukushima" "Gifu" "Gunma"
				"Hamamatsu" "Hirakata" "Hirosaki" "Hiroshima" "Hokkaido" "Iwate" "Jichi" "Jikei" "Juntendo" 
				"Kagoshima" "Kanagawa" "Kanazawa" "Kanto " "Kashihara" "Kawasaki" "Kinki" "Kitasato"
				"Kumamoto" "Kurashiki" "Kurume" "Kyoto" "Meiji Seika" "Nagoya" "Nihon" "Nippon" "Osaka"
				"Showa" "Tohoku" "Tokyo" "Yokohama" ".jp."
			"Kazakhstan" "Kenya" "Kilifi" "Nairobi" "Korea" "Seoul" "Kuwait"
			"Lao " "Laos" "Latvia" "Lebanon" "Liberia" "Libya" "Lithuania" "Luxembourg" "Macdeonia"
			"Madagascar" "Antananarivo" "Malawi" "Chilumba" "Malaysia" "Mali"
			"Mauritius" "Mexico" "MÃ©xico" "Guanajuato"
			"Moldova" "Mongolia" "Monaco" "Morocco" "Mozambique"
			"Myanmar" "Nepal" "Nicaragua" "Nigeria"
			"Netherland" "Amsterdam" "Breda" "Leiden" "Nijmegen" "Rijswijk" "Rotterdam"
			"New Zealand" "Auckland" 
			"Norway" "Norwegian" "Oslo" "Bergen" "Trondheim" "Oman" "Pakistan" "Rawalpindi"
			"Northern Marianas" "Papua New Guinea" "Guinea" "Panama" "PanamÃ" 
			"Paraguay" "Peru" "Philippines"
			"Poland" "P oland" "Warszawa" "Portugal" "Qatar" "Romania"
			"Russia" "USSR" "Tatarstan" "Moscow" "Rwanda" "Samoa" "Saudi Arabia"
			"Scotland" "Edinburgh" "Dundee" "Senegal" "Dakar" "Serbia" "Sierra Leone"
			"Singapore" "Slovenia" "Slovakia" "Bratislava" "Solomon Islands" "Somaliland"
			"Spain" "EspaÃ±a" "Barcelona" "CÃ³rdoba" "Jaen" "Madrid" "Navarra"
					"Pamplona" "Santander" "Sevill"
			"South Africa" "Cape Town" "Johannesburg" "KwaZulu-Natal" "Medunsa"
			"Sri Lanka" "Sudan" "Khartoum" "Swaziland"
			"Sweden" "Stockholm" "Swedish" "AlbaNova" "Gothenburg" "Goteborg" "Solna" "Uppsala"
			"Switzerland" "Switerland" "Basel" "Berne" "Epalinges" "Geneva"
				"Kantonsspital" "Lausanne" "Zurich" "Swiss"
			"Syria" "Taiwan" "Taipei" "Chang Gung" "Tanzania" "Dar es Salaam"
			"Thailand" "Bangkok" "Mahidol" "Tibet" "Timor-Leste"
			"Togo" "Tonga" "Trinidad and Tobago" "Tunisia" "Turkey" "Uganda" "Entebbe" "Kampala" 
			"United Arab Emirates" "Ukraine" "Uruguay"
			"UK" "Alverstoke" "Belfast" "Buckinghamshire" "Cheshire" "Glasgow" "Harrow"
					"Hertfordshire" "Kent" "Leeds" "Leicester" "Liverpool" "London"
					"Newcastle" "Nottingham" "Salford" "Sheffield"
					"Staffordshire" "Surrey" "Swansea" "Whitchurch" "U.K." "United Kingdom"
			"Uzbekistan" "Venezuela" "Caracas" "Viet Nam" "Vietnam" "Veitnam"
			"West Indies" "Wales" "Cardiff"
			"West Bank" "Nablus" "Birzeit" "Ramallah" "Yemen" "Yugoslavia" "Zaire" "Zambia" 
			"Zimbabwe" "Harare";
#delimit cr

foreach c of local countries {
		dis "`c'"
		replace country = "`c'" if strpos(affl, "`c'") > 0 & country == ""
		replace country = "`c'" if country != "" & strpos(affl, "`c'") > 0 & ///
							strpos(affl, "`c'") < strpos(affl, country)
	}

	replace country = "USA" if strpos(affl, "USA") > 0 & ///
						(country == "" | strpos(affl, country) > strpos(affl, "USA"))
	replace country = "USA" if strpos(affl, "U.S.") > 0 & country == ""
	replace country = "USA" if strpos(affl, "United States") > 0 & country == ""
	replace country = "USA" if strpos(affl, "National Science Foundation") > 0 & country == ""
	replace country = "USA" if strpos(affl, "Guam") > 0 & country == ""

	replace country = "Argentina" if inlist(country, "Argentina", "Buenos Aires")
	replace country = "Armenia" if inlist(country, "Armenia", "Yerevan")
	replace country = "Australia" if inlist(country, "Adelaide", "Brisbane", ///
									"Camperdown", "Canberra", "Melbourne", "Perth", "Sydney")
	replace country = "Austria" if inlist(country, "Wien")
	replace country = "Belgium" if inlist(country, "Belgique", "Brussels", "Bruxelles", "Leuven")
	replace country = "Brazil" if inlist(country, "Brazil", "Brasil", "Rio ", "SÃ£o Paulo")
	replace country = "Cambodia" if inlist(country, "Cambodia", "Phnom Penh")
	replace country = "Cameroon" if inlist(country, "Cameroon", "Cameroun")
	replace country = "Canada" if inlist(country, "Calgary", "Edmonton", "Manitoba", "Montreal", ///
											"MontrÃ©al", "Nova Scotia") ///
								| inlist(country, "Ontario", "Ottawa", "Quebec", "QuÃ©bec", "Toronto", ///
											"Vancouver", "Winnipeg", "Canadian")
	replace country = "China" if inlist(country, "Chinese", "Beijing", "Changsha", "Guangdong", ///
										"Guangzhou", "Shanghai", "Urumchi", "Urumqi")
	replace country = "Colombia" if inlist(country, "Colombia", "BogotÃ¡", "BogatÃ¡")
	replace country = "Czech Republic" if inlist(country, "Czech Republic", "Prague", "Brno")
	replace country = "Denmark" if inlist(country, "Denmark", "Danish", "Aarhus", ///
									"Copenhagen", "Faroe Islands", "Lyngby")
	replace country = "Egypt" if inlist(country, "Egypt", "Cairo")
	replace country = "Ethiopia" if inlist(country, "Ethiopia", "Addis Ababa")
	replace country = "Finland" if inlist(country, "Finland", "Helsinki", "Turku")
	replace country = "France" if inlist(country, "French Guiana", "Guadeloupe", "New Caledonia") ///
								| inlist(country, "Angers", "Beaujon", "Bordeaux", "Boulogne", "Dijon", ///
										"Lille", "Limoges", "Lyon", "Marseille") ///
								| inlist(country, "Nantes", "Nice", "Nogent", "Paris", "Rennes", "Rouen", ///
										"Strasbourg", "Toulouse") ///
								| inlist(country, "Villejuif", "Vitry Sur Seine")
	replace country = "The Gambia" if inlist(country, "Gambia", "Banjul")
	replace country = "Gaza Strip" if inlist(country, "Gaza,", "Gaza ")
	replace country = "Germany" if inlist(country, "German", "Deutschland", "FRG", "FGR", "DDR") ///
									| inlist(country, "Berlin", "Bochum", "Bremen", "DÃ¼sseldorf", ///
											"Essen", "Frankfurt", "Grosshansdorf") ///
									| inlist(country, "Halle", "Hamburg", "Hannover", "Heidelberg", ///
											"Homburg", "Kiel", "Mainz") ///
									| inlist(country, "Munich", "MÃ¼nchen", "Regensburg", ///
											"Tuebingen", "TÃ¼bingen", "Ulm,", "Ulm ", ".de.")
	replace country = "Ghana" if inlist(country, "Ghana", "GHANA")
	replace country = "Greece" if inlist(country, "Greece", "Thessaloniki")
	replace country = "Haiti" if inlist(country, "Haiti", "Port-au-Prince")
	replace country = "Hungary" if inlist(country, "Hungary", "Budapest")
	replace country = "Italy" if inlist(country, "Italia", "Basilicata", "Bologna", "Brescia", ///
											"Catania", "Genoa", "Genova") ///
								| inlist(country, "Milan", "Modena", "Napoli", "Pavia", "Padova", ///
											"Pescara", "Pisa") ///
								| inlist(country, "Rome", "Roma", "Torino")
	replace country = "India" if inlist(country, "Bangalore", "Bombay", "Calcutta", "Gujarat", "Kolkata") ///
								| inlist(country, "Maharashtra", "Mumbai", "New Delhi", "Tamilnadu", "Tamil Nadu")
	replace country = "Iraq" if inlist(country, "Iraq", "Baghdad")
	replace country = "Ireland" if inlist(country, "Ireland", "Dublin")
	replace country = "Israel" if inlist(country, "Israel", "Jerusalem", "Haifa", "Tel Aviv", "Tel Hashomer") ///
								| (country == "" & strpos(affl, "Petah") > 0 & strpos(affl, "Tiqva") > 0)
	replace country = "Ivory Coast" if inlist(country, "Ivory Coast", "Abidjan", "CÃ´te d'Ivoire")
	replace country = "Japan" if inlist(country, "Aichi", "Amagasaki", "Aomori", "Chiba", "Fukui", ///
											"Fukushima", "Fukuoka", "Gunma") ///
								| inlist(country, "Hamamatsu", "Hirakata", "Hirosaki", "Hiroshima", ///
											"Hokkaido", "Iwate", "Jichi", "Jikei", "Juntendo") ///
								| inlist(country, "Kagoshima", "Kanagawa", "Kanazawa", "Kanto ", ///
											"Kashihara", "Kawasaki", "Kinki", "Kitasato") ///
								| inlist(country, "Kurashiki", "Kurume", "Kyoto", "Kyushu", ///
											"Meiji Seika", "Nagoya", "Nihon", "Nippon") ///
								| inlist(country, "Osaka", "Showa", "Tohoku", "Tokyo", ".jp.")
	replace country = "Kenya" if inlist(country, "Kenya", "Nairobi", "Kilifi")
	replace country = "Laos" if inlist(country, "Laos", "Lao ")
	replace country = "Madagascar" if inlist(country, "Madagascar", "Antananarivo")
	replace country = "Malawi" if inlist(country, "Malawi", "Chilumba")
	replace country = "Mexico" if inlist(country, "Mexico", "MÃ©xico", "Guanajuato")
	replace country = "Netherlands" if inlist(country, "Netherland", "Amsterdam", "Breda", ///
											"Leiden", "Nijmegen", "Rijswijk", "Rotterdam")
	replace country = "New Zealand" if inlist(country, "New Zealand", "Auckland")
	replace country = "Niger" if country == "" & strpos(affl, "Niger") > 0 // separate because Nigeria
	replace country = "Norway" if inlist(country, "Norway", "Norwegian", "Oslo", "Bergen", "Trondheim")
	replace country = "Pakistan" if inlist(country, "Rawalpindi")
	replace country = "Panama" if inlist(country, "Panama", "PanamÃ")
	replace country = "Poland" if inlist(country, "Poland", "P oland")
	replace country = "Russia" if inlist(country, "Russia", "USSR", "Tatarstan", "Moscow")
	replace country = "Senegal" if inlist(country, "Senegal", "Dakar")
	replace country = "Slovakia" if inlist(country, "Bratislava")
	replace country = "South Africa" if inlist(country, "South Africa", "Cape Town", "Johannesburg", ///
													"KwaZulu-Natal", "Medunsa")
	replace country = "South Korea" if inlist(country, "Korea", "Seoul")
	replace country = "Spain" if inlist(country, "EspaÃ±a", "Barcelona", "CÃ³rdoba", "Jaen", ///
										"Madrid", "Navarra", "Pamplona") ///
								| inlist(country, "Santander", "Sevill")
	replace country = "Sudan" if inlist(country, "Sudan", "Khartoum")
	replace country = "Sweden" if inlist(country,"Stockholm", "Swedish", "AlbaNova", ///
												"Gothenburg", "Goteborg", "Solna", "Uppsala")
	replace country = "Switzerland" if inlist(country, "Switzerland", "Switerland", "Swiss") ///
									| inlist(country, "Basel", "Berne", "Epalinges", ///
											"Geneva", "Kantonsspital", "Lausanne", "Zurich")
	replace country = "Taiwan" if inlist(country, "Taipei", "Chang Gung")
	replace country = "Tanzania" if inlist(country, "Tanzania", "Dar es Salaam")
	replace country = "Thailand" if inlist(country, "Thailand", "Bangkok", "Mahidol")
	replace country = "Uganda" if inlist(country, "Uganda", "Entebbe", "Kampala")
	replace country = "United Kingdom" if inlist(country, "UK", "U.K.", "England", "Scotland", ///
										"Edinburgh", "Dundee", "Wales", "Cardiff", "Bermuda") ///
										| inlist(country, "Alverstoke", "Belfast", "Buckinghamshire", ///
										"Cheshire", "Glasgow", "Harrow", "Hertfordshire", "Kent", "Leeds") ///
										| inlist(country, "Leicester", "Liverpool", "London", "Newcastle", ///
										"Nottingham", "Sheffield", "Staffordshire", "Surrey") ///
										| inlist(country, "Swansea", "Whitchurch")
	replace country = "Vietnam" if inlist(country, "Vietnam", "Viet Nam", "Veitnam")
	replace country = "West Bank" if inlist(country, "West Bank", "Nablus", "Birzeit", "Ramallah")
	replace country = "Zimbabwe" if inlist(country, "Zimbabwe", "Harare")

