clear
set more off

cd "/Users/maggie/Desktop/Mississippi"

** Cleaning ELA & Math **

foreach a in $grade {
	foreach b in $subject2 {
		use "${output}/MS_AssmtData_2019_G`a'`b'.dta", clear
			
			quietly ds
			local school `:word 1 of `r(varlist)''
			foreach var of local school {
				rename `var' SchName
				}
			
			rename TestTakers StudentGroup_TotalTested
			rename AverageScaleScore AvgScaleScore
			
			drop if missing(SchName) & missing(StudentGroup_TotalTested)
			
			generate SchYear = "2018-19"
			
			generate GradeLevel = "G0`a'"
			generate Subject = "`b'"
			replace Subject = lower(Subject)
			gen AssmtName = "MAAP"
			gen AssmtType = "Regular"
			gen StudentGroup = "All students"
			gen StudentSubGroup = "All students"
			
			gen DataLevel = "School"
			
			replace DataLevel = "District" if (strpos(SchName, "District") | strpos(SchName, "Schools") | strpos(SchName, "district") | strpos(SchName, "Midtown Public Charter School") | strpos(SchName, "Joel E. Smilow Prep") | strpos(SchName, "Reimagine Prep") | strpos(SchName, "Blind and Deaf") | strpos(SchName, "Oakley Youth Development Center")) & SchName != "West Bolivar District Middle School" & SchName != "Republic Charter Schools" > 0

			replace DataLevel = "State" if strpos(SchName, "Grand Total") > 0
			
			gen DistName = ""
			replace DistName = SchName if DataLevel == "District"
			replace DistName = "Reimagine Prep" if SchName == "Republic Charter Schools"
			replace DistName = "Joel E. Smillow Prep" if SchName == "Joel E. Smilow Prep"
			replace DistName = "University Of Southern Mississippi" if SchName == "Dubard School for Language Disorders"
			replace DistName = DistName[_n-1] if missing(DistName)
			replace DistName = "" if DataLevel == "State"
			
			replace SchName = "" if DataLevel == "District" | DataLevel == "State"	

			replace DistName = subinstr(DistName,"District","Dist",.)
			replace DistName = upper(DistName)
			
			replace DistName = "BALDWYN SCHOOL DISTRICT" if DistName == "BALDWYN SCHOOL DIST"
			replace DistName = "COAHOMA COUNTY SCHOOL DISTRICT" if DistName == "COAHOMA COUNTY SCHOOL DIST"
			replace DistName = "COLUMBIA SCHOOL DISTRICT" if DistName == "COLUMBIA SCHOOL DIST"
			replace DistName = "FORREST COUNTY SCHOOL DISTRICT" if DistName == "FORREST COUNTY SCHOOL DIST"
			replace DistName = "GREENE COUNTY SCHOOL DISTRICT" if DistName == "GREENE COUNTY SCHOOL DIST"
			replace DistName = "GREENWOOD PUBLIC SCHOOL DISTRICT" if DistName == "GREENWOOD PUBLIC SCHOOL DIST"
			replace DistName = "HAZLEHURST CITY SCHOOL DISTRICT" if DistName == "HAZLEHURST CITY SCHOOL DIST"
			replace DistName = "KOSCIUSKO SCHOOL DISTRICT" if DistName == "KOSCIUSKO SCHOOL DIST"
			replace DistName = "LAMAR COUNTY SCHOOL DISTRICT" if DistName == "LAMAR COUNTY SCHOOL DIST"
			replace DistName = "LAUREL SCHOOL DISTRICT" if DistName == "LAUREL SCHOOL DIST"
			replace DistName = "LEE COUNTY SCHOOL DISTRICT" if DistName == "LEE COUNTY SCHOOL DIST"
			replace DistName = "LUMBERTON PUBLIC SCHOOL DISTRICT" if DistName == "LUMBERTON PUBLIC SCHOOL DIST"
			replace DistName = "MADISON CO SCHOOL DIST" if DistName == "MADISON COUNTY SCHOOL DIST"
			replace DistName = "MCCOMB SCHOOL DISTRICT" if DistName == "MCCOMB SCHOOL DIST"
			replace DistName = "MOSS POINT SEPARATE SCHOOL DIST" if DistName == "MOSS POINT SCHOOL DIST"
			replace DistName = "NESHOBA COUNTY SCHOOL DISTRICT" if DistName == "NESHOBA COUNTY SCHOOL DIST"
			replace DistName = "NEWTON COUNTY SCHOOL DISTRICT" if DistName == "NEWTON COUNTY SCHOOL DIST"
			replace DistName = "NEWTON MUNICIPAL SCHOOL DISTRICT" if DistName == "NEWTON MUNICIPAL SCHOOL DIST"
			replace DistName = "NOXUBEE COUNTY SCHOOL DISTRICT" if DistName == "NOXUBEE COUNTY SCHOOL DIST"
			replace DistName = "OXFORD SCHOOL DISTRICT" if DistName == "OXFORD SCHOOL DIST"
			replace DistName = "PASCAGOULA-GAUTIER SCHOOL DISTRICT" if DistName == "PASCAGOULA-GAUTIER SCHOOL DIST"
			replace DistName = "SIMPSON CO SCHOOL DIST" if DistName == "SIMPSON COUNTY SCHOOL DIST"
			replace DistName = "SOUTH DELTA SCHOOL DISTRICT" if DistName == "SOUTH DELTA SCHOOL DIST"
			replace DistName = "SOUTH PANOLA SCHOOL DISTRICT" if DistName == "SOUTH PANOLA SCHOOL DIST"
			replace DistName = "SUNFLOWER CTY CONS SCHOOL DISTRICT" if DistName == "SUNFLOWER CO CONSOLIDATE SCH DIST"
			replace DistName = "TUNICA COUNTY SCHOOL DISTRICT" if DistName == "TUNICA COUNTY SCHOOL DIST"
			replace DistName = "WATER VALLEY SCHOOL DISTRICT" if DistName == "WATER VALLEY SCHOOL DIST"
			replace DistName = "WEST TALLAHATCHIE SCHOOL DISTRICT" if DistName == "WEST TALLAHATCHIE SCHOOL DIST"
			replace DistName = "WESTERN LINE SCHOOL DISTRICT" if DistName == "WESTERN LINE SCHOOL DIST"
			replace DistName = "NORTH BOLIVAR CONS SCH" if DistName == "NORTH BOLIVAR CONSOLIDATED SCHOOL DIST"
			replace DistName = "STARKVILLE- OKTIBBEHA CONS DIST" if DistName == "STARKVILLE-OKTIBBEHA CONSOLIDATED SCHOOL DIST"
			replace DistName = "WEST BOLIVAR CONS SCHOOL DIST" if DistName == "WEST BOLIVAR CONSOLIDATED SCHOOL DIST"
			replace DistName = "HATTIESBURG PUBLIC SCHOOL DIST" if DistName == "HATTIESBURG PUBLIC SCHOOLDISTRICT"
			replace DistName = "AMITE COUNTY SCHOOL DISTRICT" if DistName == "AMITE CO SCHOOL DIST"
			replace DistName = "ITAWAMBA COUNTY SCHOOL DIST" if DistName == "ITAWAMBA CO SCHOOL DIST"
			replace DistName = "JACKSON PUBLIC SCHOOL DISTRICT" if DistName == "JACKSON PUBLIC SCHOOL DIST"
			replace DistName = "LINCOLN COUNTY SCHOOL DISTRICT" if DistName == "LINCOLN CO SCHOOL DIST"
			replace DistName = "MERIDIAN PUBLIC SCHOOLS" if DistName == "MERIDIAN PUBLIC SCHOOL DIST"
			replace DistName = "NATCHEZ-ADAMS SCHOOL DISTRICT" if DistName == "NATCHEZ-ADAMS SCHOOL DIST"
			replace DistName = "NORTH BOLIVAR CONS SCHOOL DIST" if DistName == "NORTH BOLIVAR CONS SCH"
			replace DistName = "NORTH PANOLA SCHOOL DISTRICT" if DistName == "NORTH PANOLA SCHOOLS"
			replace DistName = "PICAYUNE SCHOOL DISTRICT" if DistName == "PICAYUNE SCHOOL DIST"
			replace DistName = "PEARL PUBLIC SCHOOL DISTRICT" if DistName == "PEARL PUBLIC SCHOOL DIST"
			replace DistName = "COVINGTON COUNTY SCHOOL DISTRICT" if DistName == "COVINGTON CO SCHOOLS"
			replace DistName = "MS SCHS FOR THE BLIND AND DEAF" if DistName == "MS SCHOOLS FOR THE BLIND AND DEAF"
			replace DistName = "WINONA-MONTGOMERY CONSOLIDATED" if DistName == "WINONA-MONTGOMERY CONSOLIDATED SCHOOL DIST"
			replace DistName = "MDHS DIVISION OF YOUTH SERVICES" if DistName == "OAKLEY YOUTH DEVELOPMENT CENTER"
			
			merge m:1 DistName using "${NCES}/NCES_2018_District.dta"

			drop if _merge == 2
			drop _merge
			
			replace NCESDistrictID = "missing" if DistName == "UNIVERSITY OF SOUTHERN MISSISSIPPI"			
			
			rename Level1PCT Lev1_percent
			rename Level2PCT Lev2_percent
			rename Level3PCT Lev3_percent
			rename Level4PCT Lev4_percent
			rename Level5PCT Lev5_percent
						
			gen Lev1_count = ""
			gen Lev2_count = ""
			gen Lev3_count = ""
			gen Lev4_count = ""
			gen Lev5_count = ""
			
			gen ProficiencyCriteria = "Levels 4-5"
			gen ProficientOrAbove_count = ""
			gen ParticipationRate = ""
			
			replace State = 28
			replace StateAbbrev = "MS"
			replace StateFips = 28
			
			gen Flag_AssmtNameChange = "N"
			gen Flag_CutScoreChange_ELA = "N"
			gen Flag_CutScoreChange_math = "N"
			gen Flag_CutScoreChange_read = ""
			gen Flag_CutScoreChange_oth = "N"
			
			sort SchName DistName
			quietly by SchName DistName:  gen dup = cond(_N==1,0,_n)
			drop if dup > 1
			drop dup
			
			replace SchName = strrtrim(SchName)
			
			merge m:1 SchName DistName using "${NCES}/NCES_Schools.dta"
						
			drop if _merge == 2
			drop _merge
			
			replace NCESSchoolID = "missing" if SchName == "Dubard School for Language Disorders"
			
			generate stateid = State_leaid
			replace stateid = subinstr(stateid,"MS-","",.)	
			destring stateid, replace
			replace StateAssignedDistID = stateid if StateAssignedDistID == .			
			replace school_name = SchName if school_name == ""
			replace county_name = CountyName if county_name == ""
			replace county_code = CountyCode if county_code == .
			drop stateid year lea_name SchName CountyCode CountyName school_status No_NCES_id noting_name_change district_agency_type ncesdistrictid
			rename school_name SchName
			rename county_name CountyName
			rename county_code CountyCode

			** Aggregating Proficient Data

			local level 1 2 3 4 5

			foreach c of local level {
				replace Lev`c'_percent = "-1" if Lev`c'_percent == "*"
				destring Lev`c'_percent, replace
			}

			gen ProficientOrAbove_percent = Lev4_percent + Lev5_percent

			foreach c of local level {
				tostring Lev`c'_percent, replace force
				replace Lev`c'_percent = "*" if Lev`c'_percent == "-1"
			}
			
			tostring ProficientOrAbove_percent, replace force
			replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "-2"									
			
			order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
			
			save "${output}/MS_AssmtData_2019_G`a'`b'_Cleaned.dta", replace
	}
}

** Cleaning science **

global gradesci 5 8

	foreach a in $gradesci {
			use "${output}/MS_AssmtData_2019_G`a'sci.dta", clear
			
			quietly ds
			local school `:word 1 of `r(varlist)''
			foreach var of local school {
				rename `var' SchName
			}
			
			rename TestTakers StudentGroup_TotalTested
			rename AverageScaleScore AvgScaleScore
			
			drop if missing(SchName) & missing(StudentGroup_TotalTested)
			
			generate SchYear = "2018-19"
			
			generate GradeLevel = "G0`a'"
			generate Subject = "sci"
			gen AssmtName = "MAAP"
			gen AssmtType = "Regular"
			gen StudentGroup = "All students"
			gen StudentSubGroup = "All students"
			
			gen DataLevel = "School"
			
			replace DataLevel = "District" if (strpos(SchName, "District") | strpos(SchName, "Schools") | strpos(SchName, "Ms Sch For the Blind and Deaf") | strpos(SchName, "district") | strpos(SchName, "Midtown Public Charter School") | strpos(SchName, "Joel E. Smilow Prep") | strpos(SchName, "Reimagine Prep") | strpos(SchName, "Mdhs Division of Youth Services") | strpos(SchName, "North Bolivar Cons Sch") | strpos(SchName, "Starkville- Oktibbeha Cons Sd") | strpos(SchName, "West Bolivar Cons Sch")) & SchName != "West Bolivar District Middle School" & SchName != "Republic Charter Schools" > 0
			replace DataLevel = "State" if strpos(SchName, "Grand Total") > 0
			
			gen DistName = ""
			replace DistName = SchName if DataLevel == "District"
			replace DistName = "Reimagine Prep" if SchName == "Republic Charter Schools"
			replace DistName = "Joel E. Smillow Prep" if SchName == "Joel E. Smilow Prep"
			replace DistName = "University Of Southern Mississippi" if SchName == "Dubard School for Language Disorders"
			replace DistName = DistName[_n-1] if missing(DistName)
			replace DistName = "" if DataLevel == "State"
			
			replace SchName = "" if DataLevel == "District" | DataLevel == "State"	

			replace DistName = subinstr(DistName,"District","Dist",.)
			replace DistName = upper(DistName)
			
			replace DistName = "BALDWYN SCHOOL DISTRICT" if DistName == "BALDWYN SCHOOL DIST"
			replace DistName = "COAHOMA COUNTY SCHOOL DISTRICT" if DistName == "COAHOMA COUNTY SCHOOL DIST"
			replace DistName = "COLUMBIA SCHOOL DISTRICT" if DistName == "COLUMBIA SCHOOL DIST"
			replace DistName = "FORREST COUNTY SCHOOL DISTRICT" if DistName == "FORREST COUNTY SCHOOL DIST"
			replace DistName = "GREENE COUNTY SCHOOL DISTRICT" if DistName == "GREENE COUNTY SCHOOL DIST"
			replace DistName = "GREENWOOD PUBLIC SCHOOL DISTRICT" if DistName == "GREENWOOD PUBLIC SCHOOL DIST"
			replace DistName = "HAZLEHURST CITY SCHOOL DISTRICT" if DistName == "HAZLEHURST CITY SCHOOL DIST"
			replace DistName = "KOSCIUSKO SCHOOL DISTRICT" if DistName == "KOSCIUSKO SCHOOL DIST"
			replace DistName = "LAMAR COUNTY SCHOOL DISTRICT" if DistName == "LAMAR COUNTY SCHOOL DIST"
			replace DistName = "LAUREL SCHOOL DISTRICT" if DistName == "LAUREL SCHOOL DIST"
			replace DistName = "LEE COUNTY SCHOOL DISTRICT" if DistName == "LEE COUNTY SCHOOL DIST"
			replace DistName = "LUMBERTON PUBLIC SCHOOL DISTRICT" if DistName == "LUMBERTON PUBLIC SCHOOL DIST"
			replace DistName = "MADISON CO SCHOOL DIST" if DistName == "MADISON COUNTY SCHOOL DIST"
			replace DistName = "MCCOMB SCHOOL DISTRICT" if DistName == "MCCOMB SCHOOL DIST"
			replace DistName = "MOSS POINT SEPARATE SCHOOL DIST" if DistName == "MOSS POINT SCHOOL DIST"
			replace DistName = "NESHOBA COUNTY SCHOOL DISTRICT" if DistName == "NESHOBA COUNTY SCHOOL DIST"
			replace DistName = "NEWTON COUNTY SCHOOL DISTRICT" if DistName == "NEWTON COUNTY SCHOOL DIST"
			replace DistName = "NEWTON MUNICIPAL SCHOOL DISTRICT" if DistName == "NEWTON MUNICIPAL SCHOOL DIST"
			replace DistName = "NOXUBEE COUNTY SCHOOL DISTRICT" if DistName == "NOXUBEE COUNTY SCHOOL DIST"
			replace DistName = "OXFORD SCHOOL DISTRICT" if DistName == "OXFORD SCHOOL DIST"
			replace DistName = "SIMPSON CO SCHOOL DIST" if DistName == "SIMPSON COUNTY SCHOOL DIST"
			replace DistName = "SOUTH DELTA SCHOOL DISTRICT" if DistName == "SOUTH DELTA SCHOOL DIST"
			replace DistName = "SOUTH PANOLA SCHOOL DISTRICT" if DistName == "SOUTH PANOLA SCHOOL DIST"
			replace DistName = "SUNFLOWER CTY CONS SCHOOL DISTRICT" if DistName == "SUNFLOWER CO CONSOLIDATE SCH DIST"
			replace DistName = "TUNICA COUNTY SCHOOL DISTRICT" if DistName == "TUNICA COUNTY SCHOOL DIST"
			replace DistName = "WATER VALLEY SCHOOL DISTRICT" if DistName == "WATER VALLEY SCHOOL DIST"
			replace DistName = "WEST TALLAHATCHIE SCHOOL DISTRICT" if DistName == "WEST TALLAHATCHIE SCHOOL DIST"
			replace DistName = "WESTERN LINE SCHOOL DISTRICT" if DistName == "WESTERN LINE SCHOOL DIST"
			replace DistName = "NORTH BOLIVAR CONS SCH" if DistName == "NORTH BOLIVAR CONSOLIDATED SCHOOL DIST"
			replace DistName = "STARKVILLE- OKTIBBEHA CONS DIST" if DistName == "STARKVILLE- OKTIBBEHA CONS SD"
			replace DistName = "WEST BOLIVAR CONS SCHOOL DIST" if DistName == "WEST BOLIVAR CONS SCH"
			replace DistName = "HATTIESBURG PUBLIC SCHOOL DIST" if DistName == "HATTIESBURG PUBLIC SCHOOLDISTRICT"
			replace DistName = "AMITE COUNTY SCHOOL DISTRICT" if DistName == "AMITE CO SCHOOL DIST"
			replace DistName = "ITAWAMBA COUNTY SCHOOL DIST" if DistName == "ITAWAMBA CO SCHOOL DIST"
			replace DistName = "MERIDIAN PUBLIC SCHOOLS" if DistName == "MERIDIAN PUBLIC SCHOOL DIST"
			replace DistName = "NATCHEZ-ADAMS SCHOOL DISTRICT" if DistName == "NATCHEZ-ADAMS SCHOOL DIST"
			replace DistName = "NORTH BOLIVAR CONS SCHOOL DIST" if DistName == "NORTH BOLIVAR CONS SCH"
			replace DistName = "NORTH PANOLA SCHOOL DISTRICT" if DistName == "NORTH PANOLA SCHOOLS"
			replace DistName = "PICAYUNE SCHOOL DISTRICT" if DistName == "PICAYUNE SCHOOL DIST"
			replace DistName = "PEARL PUBLIC SCHOOL DISTRICT" if DistName == "PEARL PUBLIC SCHOOL DIST"
			replace DistName = "COVINGTON COUNTY SCHOOL DISTRICT" if DistName == "COVINGTON CO SCHOOLS"
			replace DistName = "MS SCHS FOR THE BLIND AND DEAF" if DistName == "MS SCH FOR THE BLIND AND DEAF"
			replace DistName = "CLINTON PUBLIC SCHOOL DIST" if DistName == "CLINTON PUBLIC SCHOOLS"
			replace DistName = "HOLMES CO CONSOLIDATED SCHOOL DIST" if DistName == "HOLMES CONSOLIDATE SCHOOL DIST"
			replace DistName = "JACKSON PUBLIC SCHOOL DISTRICT" if DistName == "JACKSON PUBLIC SCHOOLS"
			replace DistName = "LINCOLN COUNTY SCHOOL DISTRICT" if DistName == "LINCOLN COUNTY SCHOOLS"
			replace DistName = "MARION CO SCHOOL DIST" if DistName == "MARION COUNTY SCHOOLS"
			replace DistName = "NEW ALBANY PUBLIC SCHOOLS" if DistName == "NEW ALBANY SCHOOLS"
			replace DistName = "PASCAGOULA-GAUTIER SCHOOL DISTRICT" if DistName == "PASCAGOULA GAUTIER SCHOOL DIST"
			replace DistName = "SENATOBIA MUNICIPAL SCHOOL DIST" if DistName == "SENATOBIA CITY SCHOOLS"
			replace DistName = "TUPELO PUBLIC SCHOOL DIST" if DistName == "TUPELO PUBLIC SCHOOLS"
			replace DistName = "WINONA-MONTGOMERY CONSOLIDATED" if DistName == "WINONA-MONTGOMERY CONS DIST"

			merge m:1 DistName using "${NCES}/NCES_2018_District.dta"
		
			drop if _merge == 2
			drop _merge
			
			replace NCESDistrictID = "missing" if DistName == "UNIVERSITY OF SOUTHERN MISSISSIPPI"			
			
			rename Level1PCT Lev1_percent
			rename Level2PCT Lev2_percent
			rename Level3PCT Lev3_percent
			rename Level4PCT Lev4_percent
			rename Level5PCT Lev5_percent
						
			gen Lev1_count = ""
			gen Lev2_count = ""
			gen Lev3_count = ""
			gen Lev4_count = ""
			gen Lev5_count = ""
			
			gen ProficiencyCriteria = "Levels 4-5"
			gen ProficientOrAbove_count = ""
			gen ParticipationRate = ""
			
			replace State = 28
			replace StateAbbrev = "MS"
			replace StateFips = 28
			
			gen Flag_AssmtNameChange = "N"
			gen Flag_CutScoreChange_ELA = "N"
			gen Flag_CutScoreChange_math = "N"
			gen Flag_CutScoreChange_read = ""
			gen Flag_CutScoreChange_oth = "N"
			
			sort SchName DistName
			quietly by SchName DistName:  gen dup = cond(_N==1,0,_n)
			drop if dup > 1
			drop dup

			replace SchName = strrtrim(SchName)
			
			merge m:1 SchName DistName using "${NCES}/NCES_Schools.dta"
			
			drop if _merge == 2
			drop _merge
			
			replace NCESSchoolID = "missing" if SchName == "Dubard School for Language Disorders"
			
			generate stateid = State_leaid
			replace stateid = subinstr(stateid,"MS-","",.)	
			destring stateid, replace
			replace StateAssignedDistID = stateid if StateAssignedDistID == .			
			replace school_name = SchName if school_name == ""
			replace county_name = CountyName if county_name == ""
			replace county_code = CountyCode if county_code == .
			drop stateid year lea_name SchName CountyCode CountyName school_status No_NCES_id noting_name_change district_agency_type ncesdistrictid
			rename school_name SchName
			rename county_name CountyName
			rename county_code CountyCode
			
			** Aggregating Proficient Data

			local level 1 2 3 4 5

			foreach c of local level {
				replace Lev`c'_percent = "-1" if Lev`c'_percent == "*"
				destring Lev`c'_percent, replace
			}

			gen ProficientOrAbove_percent = Lev4_percent + Lev5_percent

			foreach c of local level {
				tostring Lev`c'_percent, replace force
				replace Lev`c'_percent = "*" if Lev`c'_percent == "-1"
			}
			
			tostring ProficientOrAbove_percent, replace force
			replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "-2"						
			
			order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate			
			
			save "${output}/MS_AssmtData_2019_G`a'sci_Cleaned.dta", replace

			}
			

** Appending subjects

	foreach a in $grade {
		use "${output}/MS_AssmtData_2019_G`a'ELA_Cleaned.dta", clear
		append using "${output}/MS_AssmtData_2019_G`a'Math_Cleaned.dta"
		save "${output}/MS_AssmtData_2019_G`a'all.dta", replace
	}
	foreach a in $gradesci {
		use "${output}/MS_AssmtData_2019_G`a'all.dta", clear
		append using "${output}/MS_AssmtData_2019_G`a'sci_Cleaned.dta"
		save "${output}/MS_AssmtData_2019_G`a'all.dta", replace
	}

	use "${output}/MS_AssmtData_2019_G3all.dta", clear
	append using "${output}/MS_AssmtData_2019_G4all.dta"
	append using "${output}/MS_AssmtData_2019_G5all.dta"
	append using "${output}/MS_AssmtData_2019_G6all.dta"
	append using "${output}/MS_AssmtData_2019_G7all.dta"
	append using "${output}/MS_AssmtData_2019_G8all.dta"
	order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
	save "${output}/MS_AssmtData_2019.dta", replace
	export delimited using "${output}/csv/MS_AssmtData_2019.csv", replace
