* OKLAHOMA

* File name: Oklahoma DTA Conversion
* Last update: 03/11/2025

*******************************************************
* Notes

	* This do file imports *.xlsx 2016-2024 OK data.
	* The files are saved as *.dta.
	* The files are appended and saved as a combined file.
	* The files are used in.
	* a) Oklahoma Cleaning 2017-2023.do
	* b) Oklahoma Cleaning 2024.do
*******************************************************

clear

local subject Math Reading Science
local datatype Participation Performance

** Converting to dta **

foreach a of local subject {
	foreach b of local datatype {
		import excel "${Org_17_23}/`a'_`b'_Redacted.xlsx", sheet("`a'_`b'") firstrow clear
		save "${Original_DTA}/`a' `b'.dta", replace
	}
}

//2017 data
foreach a of numlist 3/8 {
	import excel "${Org_PubAvail}/OK_OriginalData_2017_G0`a'.xlsx", sheet("Grade `a' Data") firstrow clear
	keep OrganizationID *MeanOPI Group
	rename *MeanOPI AvgScaleScore*
	gen GradeLevel = "G0" + "`a'"
	gen StudentSubGroup = "All Students"
	gen State_leaid = "OK-" + substr(OrganizationID, 1, 2) + "-" + substr(OrganizationID, 3, 4) if strlen(OrganizationID) >= 6
	replace State_leaid = "OK-61-E020" if Group == "Carlton Landing Academy" & (strlen(OrganizationID) != 6 | strlen(OrganizationID) != 9)
	replace State_leaid = "OK-55-E005" if Group == "Dove Science Academy Elem" & (strlen(OrganizationID) != 6 | strlen(OrganizationID) != 9)
	replace State_leaid = "OK-55-E020" if Group == "OKC Charter Lighthouse OKC" & (strlen(OrganizationID) != 6 | strlen(OrganizationID) != 9)
	replace State_leaid = "OK-55-E021" if Group == "OKC Charter-Santa Fe South" & (strlen(OrganizationID) != 6 | strlen(OrganizationID) != 9)
	replace State_leaid = "OK-55-E013" if Group == "OKC Charter: Dove Science ES" & (strlen(OrganizationID) != 6 | strlen(OrganizationID) != 9)
	replace State_leaid = "OK-55-E003" if Group == "OKC Charter: Hupfeld/W Village" & (strlen(OrganizationID) != 6 | strlen(OrganizationID) != 9)
	replace State_leaid = "OK-55-E001" if Group == "OKC Charter: Independence MS" & (strlen(OrganizationID) != 6 | strlen(OrganizationID) != 9)
	replace State_leaid = "OK-55-E012" if Group == "OKC Charter: Kipp Reach Coll." & (strlen(OrganizationID) != 6 | strlen(OrganizationID) != 9)
	replace State_leaid = "OK-55-E002" if Group == "OKC Charter: Seeworth Academy" & (strlen(OrganizationID) != 6 | strlen(OrganizationID) != 9)
	replace State_leaid = "OK-72-E019" if Group == "Tulsa Charter: Collegiate Hall" & (strlen(OrganizationID) != 6 | strlen(OrganizationID) != 9)
	replace State_leaid = "OK-72-E018" if Group == "Tulsa Charter: Honor Academy" & (strlen(OrganizationID) != 6 | strlen(OrganizationID) != 9)
	replace State_leaid = "OK-72-E005" if Group == "Tulsa Charter: Kipp Tulsa" & (strlen(OrganizationID) != 6 | strlen(OrganizationID) != 9)
	replace State_leaid = "OK-72-E004" if Group == "Tulsa Charter: Schl Arts/Sci" & (strlen(OrganizationID) != 6 | strlen(OrganizationID) != 9)
	replace State_leaid = "OK-72-E006" if Group == "Tulsa Legacy Charter School" & (strlen(OrganizationID) != 6 | strlen(OrganizationID) != 9)
	gen seasch = substr(OrganizationID, 1, 2) + "-" + substr(OrganizationID, 3, 4) + "-" + substr(OrganizationID, 7, 3) if strlen(OrganizationID) == 9
	drop OrganizationID Group
	reshape long AvgScaleScore, i(State_leaid seasch) j(Subject) string
	replace Subject = "ela" if Subject == "ELA"
	replace Subject = "math" if Subject == "Mathematics"
	replace Subject = "sci" if Subject == "Science"
	save "${Original_DTA}/OK_AssmtData_2017_G0`a'.dta", replace
}

//2018 data
foreach a of numlist 3/8 {
	import excel "${Org_PubAvail}/OK_OriginalData_2018_G0`a'.xlsx", sheet("Grade `a' Data") firstrow clear
	keep OrganizationId *MeanOPI Group
	rename *MeanOPI AvgScaleScore*
	gen GradeLevel = "G0" + "`a'"
	gen StudentSubGroup = "All Students"
	gen State_leaid = "OK-" + substr(OrganizationId, 1, 2) + "-" + substr(OrganizationId, 3, 4) if strlen(OrganizationId) >= 6
	replace State_leaid = "OK-61-E020" if Group == "Carlton Landing Academy" & (strlen(OrganizationId) != 6 | strlen(OrganizationId) != 9)
	replace State_leaid = "OK-55-E021" if Group == "OKC Charter-Santa Fe South" & (strlen(OrganizationId) != 6 | strlen(OrganizationId) != 9)
	replace State_leaid = "OK-55-E024" if Group == "OKC Charter: Dove Science Acad" & (strlen(OrganizationId) != 6 | strlen(OrganizationId) != 9)
	replace State_leaid = "OK-55-E003" if Group == "OKC Charter: Hupfeld/W Village" & strlen(OrganizationId) < 6
	replace State_leaid = "OK-55-E001" if Group == "OKC Charter: Independence MS" & strlen(OrganizationId) < 6
	replace State_leaid = "OK-55-E012" if Group == "OKC Charter: Kipp Reach Coll." & (strlen(OrganizationId) != 6 | strlen(OrganizationId) != 9)
	replace State_leaid = "OK-55-E002" if Group == "OKC Charter: Seeworth Academy" & strlen(OrganizationId) < 6
	replace State_leaid = "OK-72-E019" if Group == "Tulsa Charter: Collegiate Hall" & (strlen(OrganizationId) != 6 | strlen(OrganizationId) != 9)
	replace State_leaid = "OK-72-E018" if Group == "Tulsa Charter: Honor Academy" & (strlen(OrganizationId) != 6 | strlen(OrganizationId) != 9)
	replace State_leaid = "OK-72-E005" if Group == "Tulsa Charter: Kipp Tulsa" & (strlen(OrganizationId) != 6 | strlen(OrganizationId) != 9)
	replace State_leaid = "OK-72-E004" if Group == "Tulsa Charter: Schl Arts/Sci" & (strlen(OrganizationId) != 6 | strlen(OrganizationId) != 9)
	replace State_leaid = "OK-72-E006" if Group == "Tulsa Legacy Charter School" & (strlen(OrganizationId) != 6 | strlen(OrganizationId) != 9)
	gen seasch = substr(OrganizationId, 1, 2) + "-" + substr(OrganizationId, 3, 4) + "-" + substr(OrganizationId, 7, 3) if strlen(OrganizationId) == 9
	drop OrganizationId Group
	reshape long AvgScaleScore, i(State_leaid seasch) j(Subject) string
	replace Subject = "ela" if Subject == "ELA"
	replace Subject = "math" if Subject == "Mathematics"
	replace Subject = "sci" if Subject == "Science"
	save "${Original_DTA}/OK_AssmtData_2018_G0`a'.dta", replace
}

//Combining grade-level data for 2017 and 2018.
foreach b of numlist 2017/2018 {
	use "${Original_DTA}/OK_AssmtData_`b'_G03.dta", clear
	foreach a of numlist 4/8 {
		append using "${Original_DTA}/OK_AssmtData_`b'_G0`a'.dta"
		save "${Original_DTA}/OK_AssmtData_`b'.dta", replace
	}
}

//2019 data
import excel "${Org_PubAvail}/OK_OriginalData_2019_all.xlsx", sheet("Sheet1") firstrow clear
keep grade OrganizationId *MeanOPI
rename *MeanOPI AvgScaleScore*
rename grade GradeLevel
replace GradeLevel = "G" + GradeLevel
gen StudentSubGroup = "All Students"
gen State_leaid = "OK-" + substr(OrganizationId, 1, 2) + "-" + substr(OrganizationId, 3, 4) if strlen(OrganizationId) >= 6
gen seasch = substr(OrganizationId, 1, 2) + "-" + substr(OrganizationId, 3, 4) + "-" + substr(OrganizationId, 7, 3) if strlen(OrganizationId) > 6
drop OrganizationId
reshape long AvgScaleScore, i(State_leaid seasch GradeLevel) j(Subject) string
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
save "${Original_DTA}/OK_AssmtData_2019.dta", replace

//2022 data
import excel "${Org_PubAvail}/OK_OriginalData_2022_all.xlsx", sheet("OK2122MediaRedacted") firstrow clear
keep Grade OrganizationId *MeanOPI
rename *MeanOPI AvgScaleScore*
rename Grade GradeLevel
drop if GradeLevel > 8
tostring GradeLevel, replace force
replace GradeLevel = "G0" + GradeLevel
gen StudentSubGroup = "All Students"
gen State_leaid = "OK-" + substr(OrganizationId, 1, 2) + "-" + substr(OrganizationId, 3, 4) if strlen(OrganizationId) >= 6
gen seasch = substr(OrganizationId, 1, 2) + "-" + substr(OrganizationId, 3, 4) + "-" + substr(OrganizationId, 7, 3) if strlen(OrganizationId) > 6
drop OrganizationId
reshape long AvgScaleScore, i(State_leaid seasch GradeLevel) j(Subject) string
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
save "${Original_DTA}/OK_AssmtData_2022.dta", replace

//2023 data
import excel "${Org_PubAvail}/OK_OriginalData_2023_all.xlsx", sheet("OKOSTP2223MediaRedacted") firstrow clear
keep Grade OrganizationId *MeanOPI
rename *MeanOPI AvgScaleScore*
rename Grade GradeLevel
tostring GradeLevel, replace force
replace GradeLevel = "G0" + GradeLevel
gen StudentSubGroup = "All Students"
gen State_leaid = "OK-" + substr(OrganizationId, 1, 2) + "-" + substr(OrganizationId, 3, 4) if strlen(OrganizationId) >= 6
replace State_leaid = "OK-55-E003" if OrganizationId == "55000"
replace State_leaid = "OK-55-E012" if OrganizationId == "55000000000000"
replace State_leaid = "OK-72-E004" if OrganizationId == "720000"
replace State_leaid = "OK-72-E005" if OrganizationId == "7200000"
replace State_leaid = "OK-72-E006" if OrganizationId == "72000000"
replace State_leaid = "OK-61-E020" if OrganizationId == "6.10000000000e+21"
replace State_leaid = "OK-55-E028" if OrganizationId == "5.50000000000e+29"
replace State_leaid = "OK-55-E030" if OrganizationId == "5.50000000000e+31"
replace State_leaid = "OK-72-E017" if OrganizationId == "7.20000000000e+18"
replace State_leaid = "OK-72-E018" if OrganizationId == "7.20000000000e+19"
replace State_leaid = "OK-72-E019" if OrganizationId == "7.20000000000e+20"
gen seasch = substr(OrganizationId, 1, 2) + "-" + substr(OrganizationId, 3, 4) + "-" + substr(OrganizationId, 7, 3) if strlen(OrganizationId) > 6
drop OrganizationId
reshape long AvgScaleScore, i(State_leaid seasch GradeLevel) j(Subject) string
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
save "${Original_DTA}/OK_AssmtData_2023.dta", replace

//2024 data
import excel "${Org_PubAvail}/OK_OriginalData_2024_all.xlsx", sheet("OKOSTP2324MediaRedacted") firstrow clear
keep Grade OrganizationId *MeanOPI
rename *MeanOPI AvgScaleScore*
rename Grade GradeLevel
tostring GradeLevel, replace force
replace GradeLevel = "G0" + GradeLevel
gen StudentSubGroup = "All Students"
gen State_leaid = "OK-" + substr(OrganizationId, 1, 2) + "-" + substr(OrganizationId, 3, 4) if strlen(OrganizationId) >= 6
replace State_leaid = "OK-55-E003" if OrganizationId == "55000"
replace State_leaid = "OK-55-E012" if OrganizationId == "55000000000000"
replace State_leaid = "OK-72-E004" if OrganizationId == "720000"
replace State_leaid = "OK-72-E005" if OrganizationId == "7200000"
replace State_leaid = "OK-72-E006" if OrganizationId == "72000000"
replace State_leaid = "OK-61-E020" if OrganizationId == "6.10000000000e+21"
replace State_leaid = "OK-55-E026" if OrganizationId == "5.50000000000e+27"
replace State_leaid = "OK-55-E028" if OrganizationId == "5.50000000000e+29"
replace State_leaid = "OK-55-E030" if OrganizationId == "5.50000000000e+31"
replace State_leaid = "OK-72-E017" if OrganizationId == "7.20000000000e+18"
replace State_leaid = "OK-72-E018" if OrganizationId == "7.20000000000e+19"
gen seasch = substr(OrganizationId, 1, 2) + "-" + substr(OrganizationId, 3, 4) + "-" + substr(OrganizationId, 7, 3) if strlen(OrganizationId) > 6
replace seasch = "" if strpos(seasch, ".") > 0 //correcting district level data for values of state_leaid above
replace seasch = "" if seasch == "55-0000-000" & State_leaid == "OK-55-E012"
replace seasch = "" if seasch == "72-0000-00" & State_leaid == "OK-72-E006"
replace seasch = "" if seasch == "72-0000-0" & State_leaid == "OK-72-E005"
drop OrganizationId
reshape long AvgScaleScore, i(State_leaid seasch GradeLevel) j(Subject) string
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
save "${Original_DTA}/OK_AssmtData_2024.dta", replace

foreach b of numlist 2017/2024 {
	if `b' == 2020 | `b' == 2021 {
		continue
	}
	use "${Original_DTA}/OK_AssmtData_`b'.dta", clear
	drop if AvgScaleScore == "N/A"
	replace AvgScaleScore = "*" if AvgScaleScore == "***"
	save "${Original_DTA}/OK_AssmtData_`b'.dta", replace
}
*End of Oklahoma DTA Conversion.do
****************************************************
