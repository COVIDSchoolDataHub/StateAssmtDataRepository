// Define file paths

global original_files "/Users/miramehta/Documents/TX State Testing Data/Original"
global NCES_files "/Users/miramehta/Documents/NCES District and School Demographics"
global output_files "/Users/miramehta/Documents/TX State Testing Data/Output"
global temp_files "/Users/miramehta/Documents/TX State Testing Data/Temp"

*Unhide on first run to import .csv files
/*
foreach lev in "School" "District" "State"{
	import delimited "$original_files/TX_OriginalData_2024_`lev'", clear
	gen DataLevel = "`lev'"
	save "$temp_files/TX_OriginalData_2024_`lev'", replace
}

append using "$temp_files/TX_OriginalData_2024_District" "$temp_files/TX_OriginalData_2024_School"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

save "$temp_files/TX_OriginalData_2024", replace
*/
use "$temp_files/TX_OriginalData_2024", clear
duplicates drop

//Identifying Information
rename testedgrade GradeLevel
rename studentgroup StudentSubGroup
drop administration
tostring idcdc, replace
gen StateAssignedDistID = idcdc if DataLevel == 2
replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 5
replace StateAssignedDistID = "00" + StateAssignedDistID if strlen(StateAssignedDistID) == 4
gen StateAssignedSchID = idcdc if DataLevel == 3
replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 8
replace StateAssignedSchID = "00" + StateAssignedSchID if strlen(StateAssignedSchID) == 7
replace StateAssignedDistID = substr(StateAssignedSchID, 1, 6) if DataLevel == 3
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3
gen DistName = organization if DataLevel == 2
gen SchName = organization if DataLevel == 3
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3
drop idcdc organization

//Renaming & Reshaping Performance Information
rename staarmathematicsteststaken StudentSubGroup_TotalTestedE1
rename staarmathematicsaveragescalescor AvgScaleScoreE1
rename staarmathematicsperformancelevel Lev1_countE1
rename v9 Lev1_percentE1
rename v10 Lev2_above_countE1
rename v11 Lev2_above_percentE1
rename v12 ProficientOrAbove_countE1
rename v13 ProficientOrAbove_percentE1
rename v14 Lev4_countE1
rename v15 Lev4_percentE1
rename staarspanishmathematicsteststake StudentSubGroup_TotalTestedS1
rename staarspanishmathematicsaveragesc AvgScaleScoreS1
rename staarspanishmathematicsperforman Lev1_countS1
rename v19 Lev1_percentS1
rename v20 Lev2_above_countS1
rename v21 Lev2_above_percentS1
rename v22 ProficientOrAbove_countS1
rename v23 ProficientOrAbove_percentS1
rename v24 Lev4_countS1
rename v25 Lev4_percentS1
rename staarreadingteststaken StudentSubGroup_TotalTestedE2
rename staarreadingaveragescalescore AvgScaleScoreE2
rename staarreadingperformancelevelsdid Lev1_countE2
rename v29 Lev1_percentE2
rename staarreadingperformancelevelsapp Lev2_above_countE2
rename v31 Lev2_above_percentE2
rename staarreadingperformancelevelsmee ProficientOrAbove_countE2
rename v33 ProficientOrAbove_percentE2
rename staarreadingperformancelevelsmas Lev4_countE2
rename v35 Lev4_percentE2
rename staarspanishreadingteststaken StudentSubGroup_TotalTestedS2
rename staarspanishreadingaveragescales AvgScaleScoreS2
rename staarspanishreadingperformancele Lev1_countS2
rename v39 Lev1_percentS2
rename v40 Lev2_above_countS2
rename v41 Lev2_above_percentS2
rename v42 ProficientOrAbove_countS2
rename v43 ProficientOrAbove_percentS2
rename v44 Lev4_countS2
rename v45 Lev4_percentS2
rename staarscienceteststaken StudentSubGroup_TotalTestedE3
rename staarscienceaveragescalescore AvgScaleScoreE3
rename staarscienceperformancelevelsdid Lev1_countE3
rename v49 Lev1_percentE3
rename staarscienceperformancelevelsapp Lev2_above_countE3
rename v51 Lev2_above_percentE3
rename staarscienceperformancelevelsmee ProficientOrAbove_countE3
rename v53 ProficientOrAbove_percentE3
rename staarscienceperformancelevelsmas Lev4_countE3
rename v55 Lev4_percentE3
rename staarspanishscienceteststaken StudentSubGroup_TotalTestedS3
rename staarspanishscienceaveragescales AvgScaleScoreS3
rename staarspanishscienceperformancele Lev1_countS3
rename v59 Lev1_percentS3
rename v60 Lev2_above_countS3
rename v61 Lev2_above_percentS3
rename v62 ProficientOrAbove_countS3
rename v63 ProficientOrAbove_percentS3
rename v64 Lev4_countS3
rename v65 Lev4_percentS3
rename staarsocialstudiesteststaken StudentSubGroup_TotalTestedE4
rename staarsocialstudiesaveragescalesc AvgScaleScoreE4
rename staarsocialstudiesperformancelev Lev1_countE4
rename v69 Lev1_percentE4
rename v70 Lev2_above_countE4
rename v71 Lev2_above_percentE4
rename v72 ProficientOrAbove_countE4
rename v73 ProficientOrAbove_percentE4
rename v74 Lev4_countE4
rename v75 Lev4_percentE4

replace AvgScaleScoreS2 = subinstr(AvgScaleScoreS2, "S-", "", .)
destring AvgScaleScoreS2, replace

reshape long StudentSubGroup_TotalTested AvgScaleScore Lev1_count Lev1_percent Lev2_above_count Lev2_above_percent ProficientOrAbove_count ProficientOrAbove_percent Lev4_count Lev4_percent, i(DataLevel DistName SchName StateAssignedDistID StateAssignedSchID GradeLevel StudentSubGroup) j(Subject) string

//Assessment Information
gen SchYear = "2023-24"
gen State = "Texas"
gen AssmtType = "Regular"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "N"
gen ParticipationRate = "--"
gen AssmtName = "STAAR - English"
replace AssmtName = "STAAR - Spanish" if strpos(Subject, "S") == 1
replace Subject = "math" if strpos(Subject, "1") == 2
replace Subject = "ela" if strpos(Subject, "2") == 2
replace Subject = "sci" if strpos(Subject, "3") == 2
replace Subject = "soc" if strpos(Subject, "4") == 2
tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel
gen ProficiencyCriteria = "Levels 3-4"

//Removing Empty Observations
drop if Subject == "sci" & !inlist(GradeLevel, "G05", "G08")
drop if Subject == "soc" & GradeLevel != "G08"

//Deriving & Formatting Performance Information
gen Lev2_count = Lev2_above_count - ProficientOrAbove_count
gen Lev2_percent = Lev2_above_percent - ProficientOrAbove_percent
gen Lev3_count = ProficientOrAbove_count - Lev4_count
gen Lev3_percent = ProficientOrAbove_percent - Lev4_percent

forvalues n = 1/4{
	replace Lev`n'_percent = Lev`n'_percent/100
	tostring Lev`n'_percent, replace format("%9.2g") force
	replace Lev`n'_percent = "--" if Lev`n'_percent == "."
	tostring Lev`n'_count, replace
	replace Lev`n'_count = "--" if Lev`n'_count == "."
}

replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
replace Lev2_above_percent = Lev2_above_percent/100
tostring ProficientOrAbove_percent, replace format("%9.2g") force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
tostring Lev2_above_percent, replace format("%9.2g") force
replace Lev2_above_percent = "--" if Lev2_above_percent == "."
tostring ProficientOrAbove_count, replace
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
tostring Lev2_above_count, replace
replace Lev2_above_count = "--" if Lev2_above_count == "."
rename Lev2_above_count ApproachingOrAbove_count
rename Lev2_above_percent ApproachingOrAbove_percent

gen Lev5_count = ""
gen Lev5_percent = ""

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."

//AvgScaleScore
tostring AvgScaleScore, replace
replace AvgScaleScore = "--" if AvgScaleScore == "."

//StudentSubGroup & StudentGroup
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "No Ethnicity Provided"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Special Education"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not Special Education"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Current EB/EL"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Other Non-EB/EL"
replace StudentSubGroup = "EL Monit or Recently Ex" if StudentSubGroup == "Non-EB/EL (Monitored 1st Year)"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not Migrant"
replace StudentSubGroup = "All Students" if StudentSubGroup == "" & inlist(DistName, "WOODVILLE ISD", "WORTHAM ISD", "WYLIE ISD", "YANTIS ISD", "YELLOWSTONE COLLEGE PREPARATORY") & DataLevel == 2
replace StudentSubGroup = "All Students" if StudentSubGroup == "" & inlist(DistName, "YES PREP PUBLIC SCHOOLS INC", "YOAKUM ISD", "YORKTOWN ISD", "YSLETA ISD", "ZAPATA COUNTY ISD", "ZAVALLA ISD", "ZEPHYR ISD") & DataLevel == 2 //adjusting for values that show up oddly from the scraping
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Learner", "English Proficient", "EL Monit or Recently Ex")
replace StudentGroup = "RaceEth" if inlist(StudentSubGroup, "American Indian or Alaska Native", "Asian", "Black or African American", "Hispanic or Latino", "Native Hawaiian or Pacific Islander", "Two or More", "Unknown", "White")
replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Female", "Male", "No Gender Provided")
replace StudentSubGroup = "Unknown" if StudentSubGroup == "No Gender Provided"
replace StudentGroup = "Migrant Status" if inlist(StudentSubGroup, "Migrant", "Non-Migrant")
drop if StudentGroup == ""

//StudentGroup_TotalTested
replace DistName = strtrim(DistName)
replace DistName = stritrim(DistName)
replace SchName = strtrim(SchName)
replace SchName = stritrim(SchName)
sort DataLevel AssmtName StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"

//Remove Null Observations
drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"
gen flag = 1
forvalues n = 1/4 {
	replace flag = 0 if Lev`n'_count != "--"
}
drop if flag == 1 & inlist(StudentSubGroup_TotalTested, "*", "--") & StudentSubGroup != "All Students"
drop flag

//Prepare to Merge with NCES
gen state_leaid = "TX-" + StateAssignedDistID
gen seasch = state_leaid + "-" + StateAssignedSchID
replace seasch = subinstr(seasch, "TX-", "", 1)
save "$temp_files/TX_AssmtData_2024", replace

use "$NCES_files/NCES District Files, Fall 1997-Fall 2022/NCES_2022_District.dta", clear
keep if state_location == "TX"
rename district_agency_type DistType
keep state_location state_fips DistType ncesdistrictid state_leaid DistCharter county_name county_code DistLocale
save "$NCES_files/Cleaned NCES Data/NCES_2022_District_TX.dta", replace

use "$NCES_files/NCES School Files, Fall 1997-Fall 2022/NCES_2022_School.dta", clear
keep if state_location == "TX"
decode district_agency_type, gen(DistType)
drop district_agency_type
keep state_location state_fips lea_name ncesschoolid state_leaid seasch SchLevel SchVirtual school_type
save "$NCES_files/Cleaned NCES Data/NCES_2022_School_TX.dta", replace

//Merge with NCES Data
use "$temp_files/TX_AssmtData_2024", clear
merge m:1 state_leaid using "$NCES_files/Cleaned NCES Data/NCES_2022_District_TX.dta"
drop if _merge == 2
drop _merge

merge m:1 state_leaid seasch using "$NCES_files/Cleaned NCES Data/NCES_2022_School_TX.dta"
drop if _merge == 2
drop _merge

//Cleaning from NCES Info
rename state_location StateAbbrev
rename state_fips_id StateFips
rename ncesdistrictid NCESDistrictID
rename ncesschoolid NCESSchoolID
rename school_type SchType
rename county_name CountyName
rename county_code CountyCode

replace DistName = strtrim(lea_name) if DataLevel == 3
drop lea_name

replace StateAbbrev = "TX"
replace StateFips = 48

//TX New Schools 2024
replace NCESSchoolID = "480007022965" if seasch == "057808-057808104"
replace DistName = "UNIVERSAL ACADEMY" if NCESSchoolID == "480007022965"
replace SchType = 1 if NCESSchoolID == "480007022965"
replace SchLevel = 1 if NCESSchoolID == "480007022965"
replace SchVirtual = 0 if NCESSchoolID == "480007022965"
replace NCESSchoolID = "480146123071" if seasch == "227829-227829005"
replace DistName = "VALOR PUBLIC SCHOOLS" if NCESSchoolID == "480146123071"
replace SchType = 1 if NCESSchoolID == "480146123071"
replace SchLevel = 1 if NCESSchoolID == "480146123071"
replace SchVirtual = 0 if NCESSchoolID == "480146123071"
replace NCESSchoolID = "484272022991" if seasch == "072901-072901072"
replace DistName = "THREE WAY ISD" if NCESSchoolID == "484272022991"
replace SchType = 1 if NCESSchoolID == "484272022991"
replace SchLevel = 1 if NCESSchoolID == "484272022991"
replace SchVirtual = 0 if NCESSchoolID == "484272022991"
replace NCESSchoolID = "480143822937" if seasch == "015834-015834007"
replace DistName = "BASIS TEXAS" if NCESSchoolID == "480143822937"
replace SchType = 1 if NCESSchoolID == "480143822937"
replace SchLevel = 2 if NCESSchoolID == "480143822937"
replace SchVirtual = 0 if NCESSchoolID == "480143822937"
replace NCESSchoolID = "480146023013" if seasch == "101872-101872002"
replace DistName = "ETOILE ACADEMY CHARTER SCHOOL" if NCESSchoolID == "480146023013"
replace SchType = 1 if NCESSchoolID == "480146023013"
replace SchLevel = 1 if NCESSchoolID == "480146023013"
replace SchVirtual = 0 if NCESSchoolID == "480146023013"
replace NCESSchoolID = "480146123070" if seasch == "227829-227829004"
replace DistName = "VALOR PUBLIC SCHOOLS" if NCESSchoolID == "480146123070"
replace SchType = 1 if NCESSchoolID == "480146123070"
replace SchLevel = 1 if NCESSchoolID == "480146123070"
replace SchVirtual = 0 if NCESSchoolID == "480146123070"
replace NCESSchoolID = "480009222966" if seasch == "057813-057813108"
replace DistName = "TRINITY BASIN PREPARATORY" if NCESSchoolID == "480009222966"
replace SchType = 1 if NCESSchoolID == "480009222966"
replace SchLevel = 1 if NCESSchoolID == "480009222966"
replace SchVirtual = 0 if NCESSchoolID == "480009222966"
replace NCESSchoolID = "483398022961" if seasch == "048903-048903011"
replace DistName = "PAINT ROCK ISD" if NCESSchoolID == "483398022961"
replace SchType = 1 if NCESSchoolID == "483398022961"
replace SchLevel = 4 if NCESSchoolID == "483398022961"
replace SchVirtual = 0 if NCESSchoolID == "483398022961"
replace NCESSchoolID = "481965022999" if seasch == "079907-079907163"
replace DistName = "FORT BEND ISD" if NCESSchoolID == "481965022999"
replace SchType = 1 if NCESSchoolID == "481965022999"
replace SchLevel = 1 if NCESSchoolID == "481965022999"
replace SchVirtual = 0 if NCESSchoolID == "481965022999"
replace NCESSchoolID = "480809022943" if seasch == "020901-020901038"
replace DistName = "ALVIN ISD" if NCESSchoolID == "480809022943"
replace SchType = 4 if NCESSchoolID == "480809022943"
replace SchLevel = 4 if NCESSchoolID == "480809022943"
replace SchVirtual = 0 if NCESSchoolID == "480809022943"
replace NCESSchoolID = "480957022926" if seasch == "011901-011901111"
replace DistName = "BASTROP ISD" if NCESSchoolID == "480957022926"
replace SchType = 1 if NCESSchoolID == "480957022926"
replace SchLevel = 1 if NCESSchoolID == "480957022926"
replace SchVirtual = 0 if NCESSchoolID == "480957022926"
replace NCESSchoolID = "480143822938" if seasch == "015834-015834107"
replace DistName = "BASIS TEXAS" if NCESSchoolID == "480143822938"
replace SchType = 1 if NCESSchoolID == "480143822938"
replace SchLevel = 1 if NCESSchoolID == "480143822938"
replace SchVirtual = 0 if NCESSchoolID == "480143822938"
replace NCESSchoolID = "489913022982" if seasch == "066901-066901044"
replace DistName = "BENAVIDES ISD" if NCESSchoolID == "489913022982"
replace SchType = 1 if NCESSchoolID == "489913022982"
replace SchLevel = 4 if NCESSchoolID == "489913022982"
replace SchVirtual = 0 if NCESSchoolID == "489913022982"
replace NCESSchoolID = "483398022962" if seasch == "048903-048903012"
replace DistName = "PAINT ROCK ISD" if NCESSchoolID == "483398022962"
replace SchType = 4 if NCESSchoolID == "483398022962"
replace SchLevel = 4 if NCESSchoolID == "483398022962"
replace SchVirtual = 0 if NCESSchoolID == "483398022962"
replace NCESSchoolID = "481623022969" if seasch == "057905-057905372"
replace DistName = "DALLAS ISD" if NCESSchoolID == "481623022969"
replace SchType = 1 if NCESSchoolID == "481623022969"
replace SchLevel = 2 if NCESSchoolID == "481623022969"
replace SchVirtual = 0 if NCESSchoolID == "481623022969"
replace NCESSchoolID = "480009222967" if seasch == "057813-057813109"
replace DistName = "TRINITY BASIN PREPARATORY" if NCESSchoolID == "480009222967"
replace SchType = 1 if NCESSchoolID == "480009222967"
replace SchLevel = 1 if NCESSchoolID == "480009222967"
replace SchVirtual = 0 if NCESSchoolID == "480009222967"
replace NCESSchoolID = "483398022960" if seasch == "048903-048903004"
replace DistName = "PAINT ROCK ISD" if NCESSchoolID == "483398022960"
replace SchType = 4 if NCESSchoolID == "483398022960"
replace SchLevel = 3 if NCESSchoolID == "483398022960"
replace SchVirtual = 0 if NCESSchoolID == "483398022960"
replace NCESSchoolID = "480140022935" if seasch == "015831-015831008"
replace DistName = "SCHOOL OF SCIENCE AND TECHNOLOGY DISCOVERY" if NCESSchoolID == "480140022935"
replace SchType = 1 if NCESSchoolID == "480140022935"
replace SchLevel = 4 if NCESSchoolID == "480140022935"
replace SchVirtual = 0 if NCESSchoolID == "480140022935"
replace NCESSchoolID = "482019023058" if seasch == "186902-186902698"
replace DistName = "FORT STOCKTON ISD" if NCESSchoolID == "482019023058"
replace SchType = 1 if NCESSchoolID == "482019023058"
replace SchLevel = 1 if NCESSchoolID == "482019023058"
replace SchVirtual = 1 if NCESSchoolID == "482019023058"
replace NCESSchoolID = "484008023007" if seasch == "091906-091906005"
replace DistName = "SHERMAN ISD" if NCESSchoolID == "484008023007"
replace SchType = 4 if NCESSchoolID == "484008023007"
replace SchLevel = 4 if NCESSchoolID == "484008023007"
replace SchVirtual = 0 if NCESSchoolID == "484008023007"
replace NCESSchoolID = "484554023064" if seasch == "220920-220920108"
replace DistName = "WHITE SETTLEMENT ISD" if NCESSchoolID == "484554023064"
replace SchType = 1 if NCESSchoolID == "484554023064"
replace SchLevel = 4 if NCESSchoolID == "484554023064"
replace SchVirtual = 0 if NCESSchoolID == "484554023064"
replace NCESSchoolID = "480009222968" if seasch == "057813-057813110"
replace DistName = "TRINITY BASIN PREPARATORY" if NCESSchoolID == "480009222968"
replace SchType = 1 if NCESSchoolID == "480009222968"
replace SchLevel = 4 if NCESSchoolID == "480009222968"
replace SchVirtual = 0 if NCESSchoolID == "480009222968"
replace NCESSchoolID = "482271023067" if seasch == "225907-225907041"
replace DistName = "HARTS BLUFF ISD" if NCESSchoolID == "482271023067"
replace SchType = 1 if NCESSchoolID == "482271023067"
replace SchLevel = 2 if NCESSchoolID == "482271023067"
replace SchVirtual = 0 if NCESSchoolID == "482271023067"
replace NCESSchoolID = "480957022927" if seasch == "011901-011901112"
replace DistName = "BASTROP ISD" if NCESSchoolID == "480957022927"
replace SchType = 1 if NCESSchoolID == "480957022927"
replace SchLevel = 1 if NCESSchoolID == "480957022927"
replace SchVirtual = 0 if NCESSchoolID == "480957022927"
replace NCESSchoolID = "480005322933" if seasch == "015808-015808017"
replace DistName = "INSPIRE ACADEMIES" if NCESSchoolID == "480005322933"
replace SchType = 1 if NCESSchoolID == "480005322933"
replace SchLevel = 3 if NCESSchoolID == "480005322933"
replace SchVirtual = 0 if NCESSchoolID == "480005322933"
replace NCESSchoolID = "483879022947" if seasch == "031912-031912204"
replace DistName = "SAN BENITO CISD" if NCESSchoolID == "483879022947"
replace SchType = 1 if NCESSchoolID == "483879022947"
replace SchLevel = 2 if NCESSchoolID == "483879022947"
replace SchVirtual = 0 if NCESSchoolID == "483879022947"
replace NCESSchoolID = "480140022936" if seasch == "015831-015831009"
replace DistName = "SCHOOL OF SCIENCE AND TECHNOLOGY DISCOVERY" if NCESSchoolID == "480140022936"
replace SchType = 1 if NCESSchoolID == "480140022936"
replace SchLevel = 3 if NCESSchoolID == "480140022936"
replace SchVirtual = 0 if NCESSchoolID == "480140022936"
replace NCESSchoolID = "482410023084" if seasch == "246906-246906006"
replace DistName = "HUTTO ISD" if NCESSchoolID == "482410023084"
replace SchType = 1 if NCESSchoolID == "482410023084"
replace SchLevel = 3 if NCESSchoolID == "482410023084"
replace SchVirtual = 1 if NCESSchoolID == "482410023084"
replace NCESSchoolID = "481965023000" if StateAssignedSchID == "079907164"
replace DistName = "FORT BEND ISD" if NCESSchoolID == "481965023000"
replace SchType = 1 if NCESSchoolID == "481965023000"
replace SchLevel = 1 if NCESSchoolID == "481965023000"
replace SchVirtual = 0 if NCESSchoolID == "481965023000"
replace NCESSchoolID = "483192023033" if StateAssignedSchID == "167902010"
replace DistName = "MULLIN ISD" if NCESSchoolID == "483192023033"
replace SchType = 4 if NCESSchoolID == "483192023033"
replace SchLevel = 4 if NCESSchoolID == "483192023033"
replace SchVirtual = 0 if NCESSchoolID == "483192023033"
replace NCESSchoolID = "480142123060" if StateAssignedSchID == "220817008"
replace DistName = "NEWMAN INTERNATIONAL ACADEMY OF ARLINGTON" if NCESSchoolID == "480142123060"
replace SchType = 1 if NCESSchoolID == "480142123060"
replace SchLevel = 1 if NCESSchoolID == "480142123060"
replace SchVirtual = 0 if NCESSchoolID == "480142123060"
replace NCESSchoolID = "484411023082" if StateAssignedSchID == "244903103"
replace DistName = "VERNON ISD" if NCESSchoolID == "484411023082"
replace SchType = 4 if NCESSchoolID == "484411023082"
replace SchLevel = 4 if NCESSchoolID == "484411023082"
replace SchVirtual = 0 if NCESSchoolID == "484411023082"

replace SchLevel = 1 if NCESSchoolID == "480009222808"
replace SchLevel = 1 if NCESSchoolID == "480019522865"
replace SchLevel = 3 if NCESSchoolID == "480025913746"
replace SchLevel = 1 if NCESSchoolID == "480144022810"
replace SchLevel = 2 if NCESSchoolID == "480144022811"
replace SchLevel = 1 if NCESSchoolID == "480148222905"
replace SchLevel = 7 if NCESSchoolID == "480771007620"
replace SchLevel = 2 if NCESSchoolID == "480834022797"
replace SchLevel = 2 if NCESSchoolID == "480867012249"
replace SchLevel = 1 if NCESSchoolID == "480920014316"
replace SchLevel = 1 if NCESSchoolID == "480986022776"
replace SchLevel = 1 if NCESSchoolID == "481329022798"
replace SchLevel = 1 if NCESSchoolID == "481473013887"
replace SchLevel = 1 if NCESSchoolID == "481473013896"
replace SchLevel = 2 if NCESSchoolID == "481500014004"
replace SchLevel = 1 if NCESSchoolID == "481500014300"
replace SchLevel = 2 if NCESSchoolID == "481611022857"
replace SchLevel = 1 if NCESSchoolID == "481611022858"
replace SchLevel = 2 if NCESSchoolID == "481707022841"
replace SchLevel = 1 if NCESSchoolID == "481761022893"
replace SchLevel = 1 if NCESSchoolID == "481770022909"
replace SchLevel = 1 if NCESSchoolID == "481830010645"
replace SchLevel = 1 if NCESSchoolID == "481956022876"
replace SchLevel = 2 if NCESSchoolID == "481983014292"
replace SchLevel = 2 if NCESSchoolID == "482001022799"
replace SchLevel = 2 if NCESSchoolID == "482001022800"
replace SchLevel = 7 if NCESSchoolID == "482241008581"
replace SchLevel = 3 if NCESSchoolID == "482460009477"
replace SchLevel = 4 if NCESSchoolID == "482460014110"
replace SchLevel = 1 if NCESSchoolID == "482460022921"
replace SchLevel = 1 if NCESSchoolID == "482478022912"
replace SchLevel = 1 if NCESSchoolID == "482517014259"
replace SchLevel = 1 if NCESSchoolID == "482517022860"
replace SchLevel = 7 if NCESSchoolID == "482526008035"
replace SchLevel = 7 if NCESSchoolID == "482604008718"
replace SchLevel = 1 if NCESSchoolID == "482658022837"
replace SchLevel = 1 if NCESSchoolID == "482742014334"
replace SchLevel = 1 if NCESSchoolID == "482889022918"
replace SchLevel = 4 if NCESSchoolID == "482958014229"
replace SchLevel = 1 if NCESSchoolID == "482985012075"
replace SchLevel = 1 if NCESSchoolID == "483012014190"
replace SchLevel = 1 if NCESSchoolID == "483312013882"
replace SchLevel = 1 if NCESSchoolID == "483318022824"
replace SchLevel = 1 if NCESSchoolID == "483417022843"
replace SchLevel = 1 if NCESSchoolID == "483417022844"
replace SchLevel = 1 if NCESSchoolID == "483483014327"
replace SchLevel = 1 if NCESSchoolID == "483557022900"
replace SchLevel = 1 if NCESSchoolID == "483600022802"
replace SchLevel = 2 if NCESSchoolID == "483873022787"
replace SchLevel = 1 if NCESSchoolID == "483890013968"
replace SchLevel = 2 if NCESSchoolID == "484071013922"
replace SchLevel = 7 if NCESSchoolID == "484107008002"
replace SchLevel = 7 if NCESSchoolID == "484443008402"
replace SchLevel = 2 if NCESSchoolID == "489913122906"
replace SchLevel = 1 if NCESSchoolID == "480809013933"
replace SchLevel = 2 if NCESSchoolID == "483585014191"
replace SchLevel = 1 if NCESSchoolID == "481485022805"
replace SchLevel = 1 if NCESSchoolID == "483318022823"

replace SchVirtual = 0 if missing(SchVirtual) & DataLevel == 3 //manually confirmed that this is correct for each school before adding this code!

drop if inlist(seasch, "025908-025908009", "241902-241902002") //these two schools don't actually open until fall 2024 & don't have any non-missing data

drop if inlist(NCESSchoolID, "481686007857", "481818007651", "481970011016", "482838010527") //these four schools don't have any non-suppressed data and are missing SchLevel

//Final Cleaning
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode ApproachingOrAbove_count ApproachingOrAbove_percent

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode ApproachingOrAbove_count ApproachingOrAbove_percent

sort DataLevel DistName SchName AssmtName Subject GradeLevel StudentGroup StudentSubGroup

save "${output_files}/TX_AssmtData_2024 - HMH.dta", replace
export delimited "${output_files}/TX_AssmtData_2024 - HMH.csv", replace

drop ApproachingOrAbove_count ApproachingOrAbove_percent

save "${output_files}/TX_AssmtData_2024.dta", replace
export delimited "${output_files}/TX_AssmtData_2024.csv", replace
