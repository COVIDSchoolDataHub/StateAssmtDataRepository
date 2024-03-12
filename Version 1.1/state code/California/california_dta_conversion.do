clear
set more off

cap log close
log using california_cleaning.log, replace

global original "/Users/minnamgung/Desktop/SADR/California/Original Data Files"

cd "/Users/minnamgung/Desktop/SADR/California/Cleaned DTA"

// File conversion loop 
// Only run this part ONCE! 

global years 2010 2011 2012 2013 2015 2016 2017 2018 2019 2021 2022 2023

foreach a in $years {
	import delimited "${original}/CA_OriginalData_`a'.txt", delimiter("^") case(preserve) clear 
	save California_Original_`a', replace
}

global years 2010 2011 2012 2013 2015 2016 2017 2018 2019 

foreach a in $years {
	import delimited "${original}/CA_OriginalData_`a'.txt", delimiter(",") case(preserve) clear 
	save California_Original_`a', replace
}

global years 2021 2022 2023

foreach a in $years {
	import delimited "${original}/sb_ca`a'entities_csv.txt", delimiter("^") case(preserve) clear 
	save California_School_District_Names_`a', replace
}

global years 2013 2015 2016 2017 2018 2019 

foreach a in $years {
	import delimited "${original}/sb_ca`a'entities_csv.txt", delimiter(",") case(preserve) clear 
	save California_School_District_Names_`a', replace
}

global years 2010 2011 2012

foreach a in $years {
	import delimited "${original}/ca`a'entities_csv.txt", delimiter(",") case(preserve) clear 
	save California_School_District_Names_`a', replace
}
