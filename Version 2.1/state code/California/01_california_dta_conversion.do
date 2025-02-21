*******************************************************
* CALIFORNIA

* File name: 01_california_dta_conversion
* Last update: 2/18/2025

*******************************************************
* Notes

	* This do file imports and converts the following files to *.dta:
	* a) CA_DistSchInfo_2010_2024.xlsx
	* b) CA_Unmerged_2024.xlsx
	* c) CA_2024_Updates.xlsx
	* d) All sb_ca*entities_csv.txt (2013-2024, excluding 2014 and 2020).
	* e) All ca*entities_csv.txt (2010-2019, excluding 2014)
	* f) cast_ca*entities_csv (2019, 2021-2024 only) 
	* g) All original data files (from *.csv or *.txt) for 2010 to 2024 (excluding 2014 and 2020). 
	* 

	* As of the last update 2/18/2025, the latest NCES file is for 2022.
	* This code will need to be updated when newer NCES files are released. 

*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////

clear

// File conversion loop 
// Only run this part ONCE!

//NCES Directory
import excel "$Original/CA_DistSchInfo_2010_2024.xlsx", cellrange(A1) firstrow case(preserve) clear
replace NCESSchoolID = "" if DataLevel != "School"
save "$Original_Cleaned/CA_DistSchInfo_2010_2024", replace

//Unmerged 2024
import excel "$Original/CA_Unmerged_2024", firstrow case(preserve) allstring clear
save "$Original_Cleaned/CA_Unmerged_2024", replace

//2024 Updates
import excel "$Original/CA_2024_Updates.xlsx", firstrow case(preserve) allstring clear
drop DataLevel FILE grades nceslink
save "$Original_Cleaned/CA_2024_Updates", replace


//2021 2022 2023 2024
global years 2021 2022 2023 2024

foreach a in $years {
	import delimited "${Original}/CA_OriginalData_`a'.txt", delimiter("^") case(preserve) clear 
	save "$Original_Cleaned/California_Original_`a'", replace
	
}

global years 2010 2011 2012 2013 2015 2016 2017 2018 2019 

foreach a in $years {
	import delimited "${Original}/CA_OriginalData_`a'.txt", delimiter(",") case(preserve) clear 
	save "$Original_Cleaned/California_Original_`a'", replace
}

//2021 2022 2023 2024
global years 2021 2022 2023 2024

foreach a in $years {
	import delimited "${Original}/sb_ca`a'entities_csv.txt", delimiter("^") case(preserve) clear 
	save "$Original_Cleaned/California_School_District_Names_`a'", replace
}

global years 2013 2015 2016 2017 2018 2019 

foreach a in $years {
	import delimited "${Original}/sb_ca`a'entities_csv.txt", delimiter(",") case(preserve) clear 
	save "$Original_Cleaned/California_School_District_Names_`a'", replace
}

global years 2010 2011 2012

foreach a in $years {
	import delimited "${Original}/ca`a'entities_csv.txt", delimiter(",") case(preserve) clear 
	save "$Original_Cleaned/California_School_District_Names_`a'", replace
}

import delimited "${Original}/StudentGroups.txt", delimiter("^") case(preserve) clear
rename DemographicID StudentGroupID
save "$Original_Cleaned/California_Student_Group_Names.dta", replace

//Science Data

//2019
import delimited "$Original/CA_OriginalData_2019_sci.txt", delimiter(",") case(preserve) clear
save "$Original_Cleaned/CA_OriginalData_2019_sci", replace

import delimited "$Original/cast_ca2019entities_csv.txt", delimiter(",") case(preserve) clear
save "$Original_Cleaned/cast_ca2019entities_csv", replace

//2021-2024
forvalues year = 2021/2024 {
	import delimited "$Original/CA_OriginalData_`year'_sci.txt", delimiter("^") case(preserve) clear
	save "$Original_Cleaned/CA_OriginalData_`year'_sci", replace
	import delimited "$Original/cast_ca`year'entities_csv.txt", delimiter("^") case(preserve) clear
	save "$Original_Cleaned/cast_ca`year'entities_csv", replace
}

* END of 01_california_dta_conversion.do
****************************************************
