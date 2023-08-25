clear
set more off

global output "/Users/maggie/Desktop/Mississippi/Output"
global NCES "/Users/maggie/Desktop/Mississippi/NCES/Cleaned"

local grade 3 4 5 6 7 8
local gradesci 5 8
local subject ELA MATH
local level 1 2 3 4 5
local levelsci 1 2 3 4

cd "/Users/maggie/Desktop/Mississippi"

** Appending ela & math

foreach grd of local grade {
	foreach sub of local subject {
		use "${output}/MS_AssmtData_2017_G`grd'`sub'.dta", clear

		rename Grade* SchName
		foreach a of local level {
			rename Level`a'PCT Lev`a'_percent
		}
		rename TestTakers StudentGroup_TotalTested
		
		gen Subject = lower("`sub'")
		gen GradeLevel = "G0`grd'"
		gen AssmtName = "MAAP"
		
		if (`grd' != 3) | ("`sub'" != "ELA") {
			append using "${output}/MS_AssmtData_2017_elamath.dta"
		}
		save "${output}/MS_AssmtData_2017_elamath.dta", replace
	}
}	
	
foreach grdsci of local gradesci {
	use "${output}/MS_AssmtData_2017_G`grdsci'sci.dta", clear
	
	rename Grade* SchName
	foreach a of local levelsci {
			rename PL`a' Lev`a'_percent
		}
	rename TotalTestTakers StudentGroup_TotalTested
		
	gen Subject = "sci"
	gen GradeLevel = "G0`grdsci'"
	gen AssmtName = "MST2"
	gen row = _n
	
	merge 1:1 SchName row using "${output}/MS_AssmtData_2017_G`grdsci'sciscale.dta", keepusing(AvgScaleScore)
	
	sort row
	drop row _merge
	
	if (`grdsci' != 5) {
		append using "${output}/MS_AssmtData_2017_sci.dta"
		}
	save "${output}/MS_AssmtData_2017_sci.dta", replace
}

use "${output}/MS_AssmtData_2017_elamath.dta", clear
append using "${output}/MS_AssmtData_2017_sci.dta"

** Replace existing variables

replace AvgScaleScore = "--" if AvgScaleScore == ""

** Dropping entries

drop if SchName == ""

drop if SchName == "School 500"

** Generating new variables

gen SchYear = "2016-17"

gen AssmtType = "Regular"

foreach a of local level {
	gen Lev`a'_count = "--"
}

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested

gen ProficiencyCriteria = "Levels 3-4" if Subject == "sci"
replace ProficiencyCriteria = "Levels 4-5" if Subject != "sci"

gen ProficientOrAbove_count = "--"

gen ParticipationRate = "--"

gen test = ""
foreach a of local level {
	gen Lev`a'_percent2 = Lev`a'_percent
	destring Lev`a'_percent2, replace force
	replace test = "*" if Lev`a'_percent == "*"
}
gen ProficientOrAbove_percent = Lev4_percent2 + Lev5_percent2 if Subject != "sci"
replace ProficientOrAbove_percent = Lev3_percent2 + Lev4_percent2 if Subject == "sci"
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = test if test != ""
drop test
foreach a of local level {
	drop Lev`a'_percent2
}

replace SchName = strupper(SchName)
gen DataLevel = ""
replace DataLevel = "State" if strpos(SchName, "GRAND TOTAL") | strpos(SchName, "STATE OF MISSISSIPPI") > 0
replace DataLevel = "District" if (strpos(SchName, "DIST") | strpos(SchName, "SCHOOLS") | strpos(SchName, "CONSOLIDATED") | strpos(SchName, "MIDTOWN PUBLIC CHARTER SCHOOL") | strpos(SchName, "SMILOW PREP") | strpos(SchName, "MS SCH FOR THE BLIND") | strpos(SchName, "MS SCHOOL FOR THE DEAF") | strpos(SchName, "MDHS DIVISION OF YOUTH SERVICES") | strpos(SchName, "OAKLEY YOUTH DEVELOPMENT CENTER") | strpos(SchName, "DUBARD SCHOOL FOR LANGUAGE DISORDERS") | strpos(SchName, "CONS ") | strpos(SchName, "REPUBLIC CHARTER SCHOOLS") | strpos(SchName, "REIMAGINE PREP")) & SchName != "WEST BOLIVAR DISTRICT MIDDLE SCHOOL" > 0
replace DataLevel = "School" if DataLevel == ""

gen DistName = ""
replace DistName = SchName if DataLevel == "District"
replace DistName = DistName[_n-1] if missing(DistName)
replace DistName = "MDHS DIVISION OF YOUTH SERVICES" if DistName == "OAKLEY YOUTH DEVELOPMENT CENTER"
replace DistName = "REIMAGINE PREP" if DistName == "REPUBLIC CHARTER SCHOOLS"
//replace DistName = "GREENWOOD-LEFLORE CONS SCH DISTRICT" if DistName == "GREENWOOD-LEFLORE CONSOLIDATED SD"
replace DistName = "All Districts" if DataLevel == "State"

replace SchName = "All Schools" if DataLevel != "School"

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

merge m:1 DistName using "${NCES}/NCES_2016_District.dta"

drop if _merge == 2
drop _merge

replace DistName = subinstr(DistName, "SCHOOLS", "SCHOOL DISTRICT",.) if CountyName == ""

merge m:1 DistName using "${NCES}/NCES_2016_District.dta", update

drop if _merge == 2
drop _merge

replace DistName = subinstr(DistName,"DISTRICT","DIST",.) if CountyName == ""

merge m:1 DistName using "${NCES}/NCES_2016_District.dta", update

drop if _merge == 2
drop _merge

replace DistName = subinstr(DistName,"COUNTY","CO",.) if CountyName == ""

merge m:1 DistName using "${NCES}/NCES_2016_District.dta", update

drop if _merge == 2
drop _merge

replace DistName = subinstr(DistName,"CO SCHOOL","COUNTY SCHOOL",.) if CountyName == ""

merge m:1 DistName using "${NCES}/NCES_2016_District.dta", update

drop if _merge == 2
drop _merge

replace DistName = "COVINGTON CO SCHOOLS" if DistName == "COVINGTON COUNTY SCHOOL DIST"
replace DistName = "JOEL E. SMILOW PREP" if DistName == "SMILOW PREP"
replace DistName = "MOSS POINT SEPARATE SCHOOL DIST" if DistName == "MOSS POINT SCHOOL DIST"
replace DistName = "NORTH BOLIVAR CONS SCH" if strpos(DistName, "NORTH BOLIVAR") > 0 & NCESDistrictID == ""
replace DistName = "PASCAGOULA GAUTIER SCHOOL DIST" if DistName == "PASCAGOULA-GAUTIER SCHOOL DIST"
replace DistName = "STARKVILLE- OKTIBBEHA CONS SD" if strpos(DistName, "STARKVILLE-") > 0 & NCESDistrictID == ""
replace DistName = "WEST BOLIVAR CONS SCH" if strpos(DistName, "WEST BOLIVAR") > 0 & NCESDistrictID == ""

merge m:1 DistName using "${NCES}/NCES_2016_District.dta", update

drop if _merge == 2
drop _merge

replace SchName = strtrim(SchName)
replace SchName = strproper(SchName)

merge m:1 DistName SchName using "${NCES}/NCES_2016_School.dta"

drop if _merge == 2
drop _merge

replace SchName = strupper(SchName)

merge m:1 DistName SchName using "${NCES}/NCES_2016_School.dta", update

drop if _merge == 2
drop _merge

replace SchName = SchName + " SCHOOL" if strpos(SchName, "SCHOOL") == 0 & NCESSchoolID == "" & DataLevel == 3

merge m:1 DistName SchName using "${NCES}/NCES_2016_School.dta", update

drop if _merge == 2
drop _merge

replace SchName = subinstr(SchName,"ELEMENTARY","ELEM",.) if NCESSchoolID == "" & DataLevel == 3
replace SchName = subinstr(SchName, "JR", "JUNIOR",.) if NCESSchoolID == "" & DataLevel == 3

merge m:1 DistName SchName using "${NCES}/NCES_2016_School.dta", update

drop if _merge == 2
drop _merge

replace SchName = subinstr(SchName," SCHOOL","",.) if NCESSchoolID == "" & DataLevel == 3 & DistName != "DUBARD SCHOOL FOR LANGUAGE DISORDERS"

merge m:1 DistName SchName using "${NCES}/NCES_2016_School.dta", update

drop if _merge == 2
drop _merge

replace SchName = subinstr(SchName,"ELEM","ELEMENTARY",.) if NCESSchoolID == "" & DataLevel == 3
replace SchName = subinstr(SchName, "JUNIOR", "JR",.) if NCESSchoolID == "" & DataLevel == 3

merge m:1 DistName SchName using "${NCES}/NCES_2016_School.dta", update

drop if _merge == 2
drop _merge

replace SchName = subinstr(SchName,"ELEMENTARY","ELEM",.) if NCESSchoolID == "" & DataLevel == 3

replace SchName = "BASSFIELD HIGH SCHOOL" if SchName == "BASSFIELD JR SR HIGH"
replace SchName = "BELMONT SCHOOL" if SchName == "BELMONT HIGH"
replace SchName = "BOLTON-EDWARDS ELEM./MIDDLE SCHOOL" if strpos(SchName, "BOLTON") > 0 & NCESSchoolID == ""
replace SchName = "LILLIE BURNEY STEAM ACADEMY" if SchName == "BURNEY STEAM ACADEMY"
replace SchName = "BYHALIA MIDDLE SCHOOL (6-8)" if SchName == "BYHALIA MIDDLE, 6-8"
replace SchName = "BYHALIA ELEMENTARY SCHOOL (K-5)" if SchName == "BYHALIA ELEM, K-5"
replace SchName = "COAHOMA COUNTY JR/SR HIGH SCHOOL" if strpos(SchName, "COAHOMA") > 0 & NCESSchoolID == ""
replace SchName = "COLDWATER ATTENDANCE CENTER" if SchName == "COLDWATER HIGH"
replace SchName = "DEXTER ATTENDANCE CENTER" if strpos(SchName, "DEXTER") & NCESSchoolID == ""
replace SchName = "D. M. SMITH MIDDLE" if SchName == "DM SMITH MIDDLE"
replace SchName = "DURANT PUBLIC SCHOOL" if SchName == "DURANT HIGH"
replace SchName = "KEYS VOC CENTER" if SchName == "ELIZABETH H KEYS ALTERNATIVE EDUCATION CENTER"
replace SchName = "ENTERPRISE SCHOOL" if SchName == "ENTERPRISE ATTENDANCE CENTER"
replace SchName = "ETHEL ATTENDANCE CENTER" if SchName == "ETHEL HIGH"
replace SchName = "EVA GORDON ELEMENTARY SCHOOL" if SchName == "EVA GORDON LOWER ELEM"
replace SchName = "FIFTH STREET SCHOOL" if SchName == "FIFTH STREET JR. HIGH"
replace SchName = "GALENA ELEMENTARY SCHOOL (K-8)" if strpos(SchName, "GALENA") > 0 & NCESSchoolID == ""
replace SchName = "GEO H OLIVER VISUAL/PERF. ARTS" if strpos(SchName, "OLIVER") > 0 & NCESSchoolID == ""
replace SchName = "H. W. BYERS MIDDLE SCHOOL (6-8)" if SchName == "H. W. BYERS MIDDLE, 6-8"
replace SchName = "H. W. BYERS ELEMENTARY (K-5)" if strpos(SchName, "H. W. BYERS ELEM") > 0 & NCESSchoolID == ""
replace SchName = "HAYES COOPER CENTER FOR MATH SC TEC" if strpos(SchName, "HAYES") > 0 & NCESSchoolID == ""
replace SchName = "HEIDELBERG SCHOOL MATH & SCIENCE" if SchName == "HEIDELBERG MATH AND SCIENCE"
replace SchName = "HENDERSON/WARD-STEWART ELEMENTARY" if SchName == "HENDERSON WARD-STEWART ELEM"
replace SchName = "JOHN F KENNEDY MEMORIAL HI SCHOOL" if SchName == "JOHN F KENNEDY MEML HIGH SCH"
replace SchName = "KIRKPATRICK  HEALTH /WELLNESS" if SchName == "KIRKPATRICK HEALTH AND WELLNESS"
replace SchName = "LEFLORE COUNTY HIGH SCHOOL" if SchName == "LE FLORE COUNTY HIGH"
replace SchName = "LELAND SCHOOL PARK" if strpos(SchName,"LELAND ELEM") > 0 & NCESSchoolID == ""
replace SchName = "MANTACHIE ATTENDANCE CENTER" if strpos(SchName, "MANTACHIE") > 0 & NCESSchoolID == ""
replace SchName = "MARY REID SCHOOL (K-3)" if SchName == "MARY REID, K-3"
replace SchName = "MCADAMS ATTENDANCE CENTER" if SchName == "MCADAMS HIGH"
replace SchName = "MIDTOWN PUBLIC CHARTER SCHOOL" if SchName == "MIDTOWN PUBLIC"
replace SchName = "MS SCHOOL FOR THE BLIND HS" if strpos(SchName, "BLIND") > 0 & NCESSchoolID == ""
replace SchName = "MS SCHOOL FOR THE DEAF ELEMENTARY" if SchName == "MISSISSIPPI FOR THE DEAF ELEM"
replace SchName = "NORTH GULFPORT MIDDLE SCHOOL" if strpos(SchName, "GULFPORT") & NCESSchoolID == ""
replace SchName = "NANIH WAIYA ATTENDANCE CENTER" if SchName == "NANIH WAIYA"
replace SchName = "NOXAPATER ATTENDANCE CENTER" if SchName == "NOXAPATER HIGH"
replace SchName = "OBANNON ELEMENTARY SCHOOL" if SchName == "O'BANNON ELEM"
replace SchName = "OBANNON HIGH SCHOOL" if SchName == "O'BANNON HIGH"
replace SchName = "PICAYUNE JUNIOR HIGH SCHOOL" if SchName == "PICAYUNE ITINERATE CENTER"
replace SchName = "PRENTISS SENIOR HIGH SCHOOL" if SchName == "PRENTISS HIGH"
replace SchName = "POTTS CAMP MIDDLE SCHOOL (4-8)" if strpos(SchName, "POTTS CAMP") > 0 & NCESSchoolID == ""
replace SchName = "SCOTT CENTRAL ATTENDANCE CENTER" if SchName == "SCOTT CENTRAL ATTENDANCE CTR"
replace SchName = "SENATOBIA MIDDLE SCHOOL" if SchName == "SENATOBIA HIGH"
replace SchName = "SHIRLEY D. SIMMONS MIDDLE SCHOOL" if SchName == "SHIRLEY SIMMONS MIDDLE"
replace SchName = "SIMMONS HIGH SCHOOL" if SchName == "SIMMONS JR./SR. HIGH"
replace SchName ="SOUTH PIKE SENIOR HIGH SCHOOL" if SchName == "SOUTH PIKE HIGH"
replace SchName = "TAYLORSVILLE ATTENDANCE CENTER" if SchName == "TAYLORSVILLE HIGH"
replace SchName = "RANKIN COUNTY LEARNING CENTER" if SchName == "THE LEARNING CENTER"
replace SchName = "THRASHER HIGH SCHOOL" if SchName == "THRASHER"
replace SchName = "TREMONT ATTENDANCE CENTER" if SchName == "TREMONT HIGH"
replace SchName = "UTICA ELEM. / MIDDLE SCHOOL" if strpos(SchName, "UTICA") > 0 & NCESSchoolID == ""
replace SchName = "VIRGIL JONES JR. ELEMENTARY SCHOOL" if SchName == "VIRGIL JONES, JR. ELEM"
replace SchName = "WAYNESBORO ELEMENTARY SCH" if strpos(SchName, "WAYNESBORO") > 0 & NCESSchoolID == ""
replace SchName = "WEST JONES HIGH SCHOOL" if SchName == "WEST JONES JR SR HIGH"
replace SchName = "WEST LINCOLN SCHOOL" if SchName == "WEST LINCOLN ATTENDANCE CTR"
replace SchName = "WINONA SECONDARY SCHOOL" if SchName == "WINONA HIGH"

merge m:1 DistName SchName using "${NCES}/NCES_2016_School.dta", update

drop if _merge == 2
drop _merge

//replace SchName = "Boyd Elementary School" if SchName == "BOYD ELEM"
//replace SchName = "Carver Middle School" if SchName == "CARVER MIDDLE"
//replace SchName = "Carver Elementary School" if SchName == "CARVER ELEM"
//replace SchName = "Central Elementary School" if strpos(SchName, "CENTRAL") > 0 & NCESSchoolID == ""
//replace SchName = "Davis Magnet School" if SchName == "DAVIS MAGNET"
//replace SchName = "Lake Elementary School" if SchName == "LAKE ELEM"
//replace SchName = "Magnolia Middle School" if SchName == "MAGNOLIA MIDDLE"
//replace SchName = "Marshall Elementary School" if SchName == "MARSHALL ELEM"
//replace SchName = "North Bay Elementary School" if SchName == "NORTH BAY ELEM"
//replace SchName = "Oak Park Elementary School" if SchName == "OAK PARK ELEM"
//replace SchName = "South Side Elementary School" if SchName == "SOUTH SIDE ELEM"
//replace SchName = "West Elementary School" if SchName == "WEST ELEM"
//replace SchName = "William Dean Jr. Elementary School" if SchName == "WILLIAM DEAN JR. ELEM"
//replace SchName = "Williams-Sullivan Elementary School" if SchName == "WILLIAMS-SULLIVAN ELEM"
//replace SchName = "Winona Elementary School" if SchName == "WINONA ELEM"
//replace SchName = "Winona Secondary School" if SchName == "WINONA SECONDARY"

//merge m:1 DistName SchName using "${NCES}/NCES_Schools.dta", keepusing(NCESSchoolID seasch Virtual SchoolLevel SchoolType) update

//drop if _merge == 2
//drop _merge

replace StateAbbrev = "MS"
replace State = 28
replace StateFips = 28

** Generating new variables

replace State_leaid = "Missing/not reported" if SchName == "DUBARD SCHOOL FOR LANGUAGE DISORDERS"
gen StateAssignedDistID = State_leaid
replace seasch = "Missing/not reported" if SchName == "DUBARD SCHOOL FOR LANGUAGE DISORDERS"
gen StateAssignedSchID = seasch

replace NCESDistrictID = "Missing/not reported" if SchName == "DUBARD SCHOOL FOR LANGUAGE DISORDERS"
replace NCESSchoolID = "Missing/not reported" if SchName == "DUBARD SCHOOL FOR LANGUAGE DISORDERS"

replace DistName = strproper(DistName)
replace SchName = strproper(SchName)

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/MS_AssmtData_2017.dta", replace

export delimited using "${output}/csv/MS_AssmtData_2017.csv", replace
