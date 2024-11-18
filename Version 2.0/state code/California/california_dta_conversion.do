clear
set more off

cap log close

global original "/Volumes/T7/State Test Project/California/Original Data Files"
global CA_Folder "/Volumes/T7/State Test Project/California"
global data "/Volumes/T7/State Test Project/California/Cleaned DTA"

// File conversion loop 
// Only run this part ONCE!

//NCES Directory
import excel "$CA_Folder/CA_DistSchInfo_2010_2024.xlsx", cellrange(A1) firstrow case(preserve) clear
replace NCESSchoolID = "" if DataLevel != "School"
save "$data/CA_DistSchInfo_2010_2024", replace

//Unmerged 2024
import excel "$CA_Folder/CA_Unmerged_2024", firstrow case(preserve) allstring clear
drop S-AA Notes *Merge
save "$data/CA_Unmerged_2024", replace

//2024 Updates
import excel "$CA_Folder/CA_2024_Updates.xlsx", firstrow case(preserve) allstring clear
drop DataLevel FILE grades nceslink
save "$data/CA_2024_Updates", replace


//2021 2022 2023 2024
global years 2021 2022 2023 2024

foreach a in $years {
	import delimited "${original}/CA_OriginalData_`a'.txt", delimiter("^") case(preserve) clear 
	save California_Original_`a', replace
	
}


global years 2010 2011 2012 2013 2015 2016 2017 2018 2019 

foreach a in $years {
	import delimited "${original}/CA_OriginalData_`a'.txt", delimiter(",") case(preserve) clear 
	save California_Original_`a', replace
}

//2021 2022 2023 2024
global years 2021 2022 2023 2024

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

import delimited "${original}/StudentGroups.txt", delimiter("^") case(preserve) clear
rename DemographicID StudentGroupID
save "California_Student_Group_Names.dta", replace

//Science Data

//2019
import delimited "$original/CA_OriginalData_2019_sci.txt", delimiter(",") case(preserve) clear
save "$original/CA_OriginalData_2019_sci", replace
import delimited "$original/cast_ca2019entities_csv.txt", delimiter(",") case(preserve) clear
save "$original/cast_ca2019entities_csv", replace

//2021-2024
forvalues year = 2024/2024 {
	import delimited "$original/CA_OriginalData_`year'_sci.txt", delimiter("^") case(preserve) clear
	save "$original/CA_OriginalData_`year'_sci", replace
	import delimited "$original/cast_ca`year'entities_csv.txt", delimiter("^") case(preserve) clear
	save "$original/cast_ca`year'entities_csv", replace
}




