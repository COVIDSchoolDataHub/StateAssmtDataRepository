clear
set more off

global output "/Users/maggie/Desktop/Mississippi/Output"
global NCES "/Users/maggie/Desktop/Mississippi/NCES/Cleaned"

local grade 3 4 5 6 7 8
local gradesci 5 8
local subject ELA MATH

cd "/Users/maggie/Desktop/Mississippi"

** Appending ela & math

foreach grd of local grade {
	foreach sub of local subject {
		use "${output}/MS_AssmtData_2019_G`grd'`sub'.dta", clear

		rename *DistrictSchool SchName
		
		gen Subject = lower("`sub'")
		gen GradeLevel = "G0" + "`grd'"
		
		if (`grd' != 3) | ("`sub'" != "ELA") {
			append using "${output}/MS_AssmtData_2019_elamath.dta"
		}
		save "${output}/MS_AssmtData_2019_elamath.dta", replace
	}
}

foreach grdsci of local gradesci {
	use "${output}/MS_AssmtData_2019_G`grdsci'sci.dta", clear
	
	rename *DistrictSchool SchName
		
	gen Subject = "sci"
	gen GradeLevel = "G0" + "`grdsci'"
	
	if (`grdsci' != 5) {
		append using "${output}/MS_AssmtData_2019_sci.dta"
		}
	save "${output}/MS_AssmtData_2019_sci.dta", replace
}

use "${output}/MS_AssmtData_2019_elamath.dta", clear
append using "${output}/MS_AssmtData_2019_sci.dta"

** Rename existing variables

rename AverageScaleScore AvgScaleScore
rename TestTakers StudentGroup_TotalTested

local level 1 2 3 4 5
foreach a of local level {
	rename Level`a'PCT Lev`a'_percent
}

** Dropping entries

drop if AvgScaleScore == ""

drop if SchName == "School 500"

** Generating new variables

gen SchYear = "2018-19"

gen AssmtName = "MAAP"
gen AssmtType = "Regular"

foreach a of local level {
	gen Lev`a'_count = "--"
}

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested

gen ProficiencyCriteria = "Levels 4-5"
gen ProficientOrAbove_count = "--"

gen ParticipationRate = "--"

gen test = ""
foreach a of local level {
	gen Lev`a'_percent2 = Lev`a'_percent
	destring Lev`a'_percent2, replace force
	replace test = "*" if Lev`a'_percent == "*"
}
gen ProficientOrAbove_percent = Lev4_percent2 + Lev5_percent2
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = test if test != ""
drop test
foreach a of local level {
	drop Lev`a'_percent2
}

replace SchName = strupper(SchName)
gen DataLevel = ""
replace DataLevel = "State" if strpos(SchName, "GRAND TOTAL") > 0
replace DataLevel = "District" if (strpos(SchName, "DIST") | strpos(SchName, "SCHOOLS") | strpos(SchName, "CONSOLIDATED") | strpos(SchName, "MIDTOWN PUBLIC CHARTER SCHOOL") | strpos(SchName, "SMILOW PREP") | strpos(SchName, "BLIND AND DEAF") | strpos(SchName, "MDHS DIVISION OF YOUTH SERVICES") | strpos(SchName, "OAKLEY YOUTH DEVELOPMENT CENTER") | strpos(SchName, "DUBARD SCHOOL FOR LANGUAGE DISORDERS") | strpos(SchName, "CONS ") | strpos(SchName, "REPUBLIC CHARTER SCHOOLS")) & SchName != "WEST BOLIVAR DISTRICT MIDDLE SCHOOL" > 0
replace DataLevel = "School" if DataLevel == ""

gen DistName = ""
replace DistName = SchName if DataLevel == "District"
replace DistName = DistName[_n-1] if missing(DistName)
replace DistName = "MDHS DIVISION OF YOUTH SERVICES" if DistName == "OAKLEY YOUTH DEVELOPMENT CENTER"
replace DistName = "REIMAGINE PREP" if DistName == "REPUBLIC CHARTER SCHOOLS"
replace DistName = "All Districts" if DataLevel == "State"

replace SchName = "All Schools" if DataLevel != "School"

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

merge m:1 DistName using "${NCES}/NCES_2018_District.dta"

drop if _merge == 2
drop _merge

replace DistName = subinstr(DistName, "SCHOOLS", "SCHOOL DISTRICT",.) if CountyName == ""

merge m:1 DistName using "${NCES}/NCES_2018_District.dta", update

drop if _merge == 2
drop _merge

replace DistName = subinstr(DistName,"DISTRICT","DIST",.) if CountyName == ""

merge m:1 DistName using "${NCES}/NCES_2018_District.dta", update

drop if _merge == 2
drop _merge

replace DistName = subinstr(DistName,"COUNTY","CO",.) if CountyName == ""

merge m:1 DistName using "${NCES}/NCES_2018_District.dta", update

drop if _merge == 2
drop _merge

replace DistName = subinstr(DistName,"CO SCHOOL DIST","COUNTY SCHOOL DISTRICT",.) if CountyName == ""

merge m:1 DistName using "${NCES}/NCES_2018_District.dta", update

drop if _merge == 2
drop _merge

replace DistName = "HOLMES CO CONSOLIDATED SCHOOL DIST" if strpos(DistName, "HOLMES") > 0 & NCESDistrictID == ""
replace DistName = "ITAWAMBA COUNTY SCHOOL DIST" if DistName == "ITAWAMBA COUNTY SCHOOL DISTRICT"
replace DistName = "JOEL E. SMILLOW PREP" if strpos(DistName, "SMILOW PREP") > 0 & NCESDistrictID == ""
replace DistName = "MERIDIAN PUBLIC SCHOOLS" if DistName == "MERIDIAN PUBLIC SCHOOL DIST"
replace DistName = "MOSS POINT SEPARATE SCHOOL DIST" if DistName == "MOSS POINT SCHOOL DIST"
replace DistName = "MS SCHS FOR THE BLIND AND DEAF" if strpos(DistName, "DEAF") > 0 & NCESDistrictID == ""
replace DistName = "NEW ALBANY PUBLIC SCHOOLS" if DistName == "NEW ALBANY SCHOOL DIST"
replace DistName = "NORTH BOLIVAR CONS SCHOOL DIST" if strpos(DistName, "NORTH BOLIVAR") > 0 & NCESDistrictID == ""
replace DistName = "PASCAGOULA-GAUTIER SCHOOL DISTRICT" if DistName == "PASCAGOULA GAUTIER SCHOOL DIST"
replace DistName = "SENATOBIA MUNICIPAL SCHOOL DIST" if DistName == "SENATOBIA CITY SCHOOL DIST"
replace DistName = "STARKVILLE- OKTIBBEHA CONS DIST" if strpos(DistName, "STARKVILLE-") > 0 & NCESDistrictID == ""
replace DistName = "SUNFLOWER CTY CONS SCHOOL DISTRICT" if strpos(DistName, "SUNFLOWER") > 0 & NCESDistrictID == ""
replace DistName = "WEST BOLIVAR CONS SCHOOL DIST" if strpos(DistName, "WEST BOLIVAR") > 0 & NCESDistrictID == ""
replace DistName = "WINONA-MONTGOMERY CONSOLIDATED" if strpos(DistName,"WINONA-MONTGOMERY") > 0 & NCESDistrictID == ""

merge m:1 DistName using "${NCES}/NCES_2018_District.dta", update

drop if _merge == 2
drop _merge

replace SchName = strtrim(SchName)
replace SchName = strproper(SchName)

merge m:1 DistName SchName using "${NCES}/NCES_2018_School.dta"

drop if _merge == 2
drop _merge

replace SchName = strupper(SchName)

merge m:1 DistName SchName using "${NCES}/NCES_2018_School.dta", update

drop if _merge == 2
drop _merge

replace SchName = SchName + " SCHOOL" if strpos(SchName, "SCHOOL") == 0 & NCESSchoolID == "" & DataLevel == 3

merge m:1 DistName SchName using "${NCES}/NCES_2018_School.dta", update

drop if _merge == 2
drop _merge

replace SchName = subinstr(SchName,"ELEMENTARY","ELEM",.) if NCESSchoolID == "" & DataLevel == 3
replace SchName = subinstr(SchName, "JR", "JUNIOR",.) if NCESSchoolID == "" & DataLevel == 3

merge m:1 DistName SchName using "${NCES}/NCES_2018_School.dta", update

drop if _merge == 2
drop _merge

replace SchName = subinstr(SchName," SCHOOL","",.) if NCESSchoolID == "" & DataLevel == 3 & DistName != "DUBARD SCHOOL FOR LANGUAGE DISORDERS"

merge m:1 DistName SchName using "${NCES}/NCES_2018_School.dta", update

drop if _merge == 2
drop _merge

replace SchName = subinstr(SchName,"ELEM","ELEMENTARY",.) if NCESSchoolID == "" & DataLevel == 3
replace SchName = subinstr(SchName, "JUNIOR", "JR",.) if NCESSchoolID == "" & DataLevel == 3

merge m:1 DistName SchName using "${NCES}/NCES_2018_School.dta", update

drop if _merge == 2
drop _merge

replace SchName = subinstr(SchName,"ELEMENTARY","ELEM",.) if NCESSchoolID == "" & DataLevel == 3

replace SchName = "ARMSTRONG JUNIOR HIGH SCHOOL" if SchName == "ARMSTRONG MIDDLE"
replace SchName = "A. W. WATSON UPPER ELEMENTARY" if strpos(SchName, "WATSON") > 0 & NCESSchoolID == ""
replace SchName = "ASHLAND MIDDLE-HIGH SCHOOL" if SchName == "ASHLAND HIGH"
replace SchName = "BELL ELEMENTARY SCHOOL" if SchName == "BELL ACADEMY"
replace SchName = "BELMONT SCHOOL" if SchName == "BELMONT HIGH"
replace SchName = "BOLTON-EDWARDS ELEM./MIDDLE SCHOOL" if strpos(SchName, "BOLTON") > 0 & NCESSchoolID == ""
replace SchName = "NORTHSIDE HIGH SCHOOL" if SchName == "BROAD STREET HIGH"
replace SchName = "LILLIE BURNEY STEAM ACADEMY" if SchName == "BURNEY STEAM ACADEMY"
replace SchName = "BYHALIA MIDDLE SCHOOL (6-8)" if SchName == "BYHALIA MIDDLE 6-8"
replace SchName = "BYHALIA ELEMENTARY SCHOOL (K-5)" if SchName == "BYHALIA ELEM K-5"
replace SchName = "COAHOMA COUNTY JR/SR HIGH SCHOOL" if strpos(SchName, "COAHOMA") > 0 & NCESSchoolID == ""
replace SchName = "BARACK H OBAMA ELEMENTARY SCHOOL" if SchName == "DAVIS MAGNET"
replace SchName = "DEXTER ELEMENTARY SCHOOL" if SchName == "DEXTER ATTENDANCE CENTER"
replace SchName = "DURANT ELEMENTARY SCHOOL" if SchName == "DURANT ELEM"
replace SchName = "ENTERPRISE SCHOOL" if SchName == "ENTERPRISE ATTENDANCE CENTER"
replace SchName = "ETHEL ATTENDANCE CENTER" if SchName == "ETHEL HIGH"
replace SchName = "EVA GORDON ELEMENTARY SCHOOL" if SchName == "EVA GORDON LOWER ELEM"
replace SchName = "GALENA ELEMENTARY SCHOOL (K-6)" if SchName == "GALENA ELEM K-8"
replace SchName = "GEO H OLIVER VISUAL/PERF. ARTS" if strpos(SchName, "OLIVER") > 0 & NCESSchoolID == ""
replace SchName = "GOODMAN PICKENS ELEMENTARY SCHOOL" if SchName == "GOODMAN-PICKENS ELEM"
replace SchName = "GREEN HILL INTERMEDIATE" if strpos(SchName, "GREEN") > 0 & NCESSchoolID == ""
replace SchName = "H. W. BYERS HIGH SCHOOL (7-12)" if strpos(SchName, "BYERS HIGH") > 0 & NCESSchoolID == ""
replace SchName = "H. W. BYERS ELEMENTARY (K-6)" if strpos(SchName, "H. W. BYERS ELEM") > 0 & NCESSchoolID == ""
replace SchName = "HAYES COOPER CENTER FOR MATH SC TEC" if strpos(SchName, "HAYES") > 0 & NCESSchoolID == ""
replace SchName = "HEIDELBERG SCHOOL MATH & SCIENCE" if SchName == "HEIDELBERG MATH AND SCIENCE"
replace SchName = "HENDERSON/WARD-STEWART ELEMENTARY" if SchName == "HENDERSON WARD-STEWART ELEM"
replace SchName = "JEFFERSON CO JR HI" if SchName == "JEFFERSON CO JR HIGH"
replace SchName = "KIRKPATRICK  HEALTH /WELLNESS" if SchName == "KIRKPATRICK HEALTH AND WELLNESS"
replace SchName = "LEFLORE COUNTY HIGH SCHOOL" if SchName == "LE FLORE COUNTY HIGH"
replace SchName = "LELAND SCHOOL PARK" if strpos(SchName,"LELAND ELEM") > 0 & NCESSchoolID == ""
replace SchName = "MANTACHIE ATTENDANCE CENTER" if strpos(SchName, "MANTACHIE") > 0 & NCESSchoolID == ""
replace SchName = "MARY REID SCHOOL (K-6)" if SchName == "MARY REID K-6"
replace SchName = "MCADAMS ATTENDANCE CENTER" if SchName == "MCADAMS HIGH"
replace SchName = "MC NEAL ELEMENTARY SCHOOL" if SchName == "MCNEAL ELEM"
replace SchName = "MIDTOWN PUBLIC CHARTER SCHOOL" if SchName == "MIDTOWN PUBLIC"
replace SchName = "MS SCHOOL FOR THE BLIND" if SchName == "MISSISSIPPI FOR THE BLIND"
replace SchName = "MS SCHOOL FOR THE DEAF" if SchName == "MISSISSIPPI FOR THE DEAF"
replace SchName = "MOORHEAD CENTRAL SCHOOL" if strpos(SchName, "MOORHEAD CENTRAL") > 0 & NCESSchoolID == ""
replace SchName = "MORGANTOWN MIDDLE" if SchName == "MORGANTOWN ARTS ACADEMY"
replace SchName = "NANIH WAIYA ATTENDANCE CENTER" if SchName == "NANIH WAIYA"
replace SchName = "NORTH GULFPORT MIDDLE SCHOOL" if strpos(SchName, "GULFPORT") & NCESSchoolID == ""
replace SchName = "NORTH PANOLA MIDDLE SCHOOL" if SchName == "NORTH PANOLA JR HIGH"
replace SchName = "NOXAPATER ATTENDANCE CENTER" if SchName == "NOXAPATER HIGH"
replace SchName = "OBANNON ELEMENTARY SCHOOL" if SchName == "O'BANNON ELEM"
replace SchName = "OBANNON HIGH SCHOOL" if SchName == "O'BANNON HIGH"
replace SchName = "BARACK H OBAMA ELEMENTARY SCHOOL" if SchName == "OBAMA MAGNET"
replace SchName = "PEARL RIVER CENTRAL ELEMENTAR" if SchName == "PEARL RIVER CENTRAL ELEM"
replace SchName = "PECAN PARK ELEMENTARY SCHOOL" if SchName == "PECAN ELEM"
replace SchName = "POTTS CAMP HIGH SCHOOL (7-12)" if strpos(SchName, "POTTS CAMP") > 0 & NCESSchoolID == ""
replace SchName = "REUBEN B. MYERS CANTON SCHOOL OF AR" if strpos(SchName, "REUBEN") > 0 & NCESSchoolID == ""
replace SchName = "S V MARSHALL ELEMENTARY SCHOOL" if SchName == "S.V. MARSHALL ELEM"
replace SchName = "SCOTT CENTRAL ATTENDANCE CENTER" if SchName == "SCOTT CENTRAL ATTENDANCE CTR"
replace SchName = "SHIRLEY D. SIMMONS MIDDLE SCHOOL" if SchName == "SHIRLEY SIMMONS MIDDLE"
replace SchName = "SIMMONS HIGH SCHOOL" if SchName == "SIMMONS JR.SR. HIGH"
replace SchName = "TAYLORSVILLE ATTENDANCE CENTER" if SchName == "TAYLORSVILLE HIGH"
replace SchName = "RANKIN COUNTY LEARNING CENTER" if SchName == "THE LEARNING CENTER"
replace SchName = "THRASHER HIGH SCHOOL" if SchName == "THRASHER"
replace SchName = "TREMONT ATTENDANCE CENTER" if SchName == "TREMONT HIGH"
replace SchName = "UTICA ELEM. / MIDDLE SCHOOL" if strpos(SchName, "UTICA") > 0 & NCESSchoolID == ""
replace SchName = "WAYNE CENTRAL ELEMENTARY SCHOOL" if SchName == "WAYNE CENTRAL"
replace SchName = "WAYNESBORO RIVERVIEW ELE SCHOOL" if strpos(SchName, "RIVERVIEW") > 0 & NCESSchoolID == ""
replace SchName = "WEST JONES HIGH SCHOOL" if SchName == "WEST JONES JR SR HIGH"
replace SchName = "WEST LINCOLN SCHOOL" if SchName == "WEST LINCOLN ATTENDANCE CTR"

merge m:1 DistName SchName using "${NCES}/NCES_2018_School.dta", update

drop if _merge == 2
drop _merge

replace StateAbbrev = "MS"
replace State = 28
replace StateFips = 28

** Generating new variables

replace State_leaid = "Missing/not reported" if DistName == "DUBARD SCHOOL FOR LANGUAGE DISORDERS"
gen StateAssignedDistID = State_leaid
replace seasch = "Missing/not reported" if SchName == "DUBARD SCHOOL FOR LANGUAGE DISORDERS"
gen StateAssignedSchID = seasch

replace NCESDistrictID = "Missing/not reported" if DistName == "DUBARD SCHOOL FOR LANGUAGE DISORDERS"
replace NCESSchoolID = "Missing/not reported" if SchName == "DUBARD SCHOOL FOR LANGUAGE DISORDERS"

replace DistName = strproper(DistName)
replace SchName = strproper(SchName)

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "Y"

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/MS_AssmtData_2019.dta", replace

export delimited using "${output}/csv/MS_AssmtData_2019.csv", replace
