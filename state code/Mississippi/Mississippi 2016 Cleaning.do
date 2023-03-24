clear
set more off

cd "/Users/maggie/Desktop/Mississippi"

global output "/Users/maggie/Desktop/Mississippi/Output"
global NCES "/Users/maggie/Desktop/Mississippi/NCES/Cleaned"
global MS "/Users/maggie/Desktop/Mississippi"

** Cleaning ELA & Math **

global grade 3 4 5 6 7 8
global sub ELA Math

foreach a in $grade {
	foreach b in $sub {
		use "${output}/MS_AssmtData_2016_G`a'`b'.dta", clear
			
			quietly ds
			local school `:word 1 of `r(varlist)''
			foreach var of local school {
				rename `var' SchName
			}
			
			rename TestTakers StudentGroup_TotalTested

			drop if missing(SchName) & missing(StudentGroup_TotalTested)
			
			generate SchYear = "2015-2016"
			
			generate GradeLevel = "G0`a'"
			generate Subject = "`b'"
			replace Subject = lower(Subject)
			gen AssmtName = "MAAP"
			gen AssmtType = "Regular"
			gen StudentGroup = "All students"
			gen StudentSubGroup = "All students"
			
			gen DataLevel = "School"
			replace DataLevel = "District" if (strpos(SchName, "District") | strpos(SchName, "Schools") | strpos(SchName, "district") | strpos(SchName, "Blind") | strpos(SchName, "Reimagine Prep")) & SchName != "West Bolivar District Middle School" & SchName != "Republic Charter Schools" > 0
			replace DataLevel = "State" if strpos(SchName, "State of Mississippi") > 0
			
			gen DistName = ""
			replace DistName = SchName if DataLevel == "District"
			replace DistName = "Reimagine Prep" if SchName == "Republic Charter Schools"
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
			replace DistName = "STARKVILLE- OKTIBBEHA CONS DIST" if DistName == "STARKVILLE-OKTIBBEHA CONSOLIDATED SCHOOL DIST"
			replace DistName = "SUNFLOWER CONS SCHOOL DIST" if DistName == "SUNFLOWER CO CONSOLIDATE SCH DIST"
			replace DistName = "TUNICA COUNTY SCHOOL DISTRICT" if DistName == "TUNICA COUNTY SCHOOL DIST"
			replace DistName = "WATER VALLEY SCHOOL DISTRICT" if DistName == "WATER VALLEY SCHOOL DIST"
			replace DistName = "WEST BOLIVAR CONS SCHOOL DIST" if DistName == "WEST BOLIVAR CONSOLIDATED SCHOOL DIST"
			replace DistName = "WEST TALLAHATCHIE SCHOOL DISTRICT" if DistName == "WEST TALLAHATCHIE SCHOOL DIST"
			replace DistName = "WESTERN LINE SCHOOL DISTRICT" if DistName == "WESTERN LINE SCHOOL DIST"
			replace DistName = "NORTH BOLIVAR CONS SCH" if DistName == "NORTH BOLIVAR CONSOLIDATED SCHOOL DIST"
			replace DistName = "PASCAGOULA SCHOOL DIST" if DistName == "PASCAGOULA-GAUTIER SCHOOL DISTRICT"
			replace DistName = "STARKVILLE- OKTIBBEHA CONS SD" if DistName == "STARKVILLE- OKTIBBEHA CONS DIST"
			replace DistName = "SUNFLOWER CO CONSOLIDATE SCH DIST" if DistName == "SUNFLOWER CONS SCHOOL DIST"
			replace DistName = "WEST BOLIVAR CONS SCH" if DistName == "WEST BOLIVAR CONS SCHOOL DIST"
			replace DistName = "HATTIESBURG PUBLIC SCHOOL DIST" if DistName == "HATTIESBURG PUBLIC SCHOOLDISTRICT"
			replace DistName = "MS SCH FOR THE BLIND" if DistName == "MISSISSIPPI SCH FOR THE BLIND"
			
			merge m:1 DistName using "${NCES}/NCES_2015_District.dta"
			
			drop if _merge == 2
			drop _merge
			
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
			gen AvgScaleScore = ""
			
			gen ProficiencyCriteria = "Levels 4-5"
			gen ProficientOrAbove_count = ""
			gen ProficientOrAbove_percent = ""
			gen ParticipationRate = ""
			
			replace State = 28
			replace StateAbbrev = "MS"
			replace StateFips = 28
			
			gen Flag_AssmtNameChange = "Y"
			gen Flag_CutScoreChange_ELA = "Y"
			gen Flag_CutScoreChange_math = "Y"
			gen Flag_CutScoreChange_read = ""
			gen Flag_CutScoreChange_oth = "Y"
			
			save "${output}/MS_AssmtData_2016_G`a'`b'.dta", replace
	}
}


** Cleaning science **

global gradesci 5 8

foreach a in $gradesci {
		use "${output}/MS_AssmtData_2016_G`a'sciscale.dta", clear
			quietly ds
			local school `:word 1 of `r(varlist)''
			foreach var of local school {
				rename `var' SchName
			}
			gen DataLevel = "School"
			replace DataLevel = "District" if (strpos(SchName, "District") | strpos(SchName, "Schools") | strpos(SchName, "district") | strpos(SchName, "Blind") | strpos(SchName, "Deaf") |strpos(SchName, "Reimagine Prep")) & SchName != "West Bolivar District Middle School" & SchName != "Republic Charter Schools" > 0
			replace DataLevel = "State" if strpos(SchName, "Grand Total") > 0
			
			gen DistName = ""
			replace DistName = SchName if DataLevel == "District"
			replace DistName = DistName[_n-1] if missing(DistName)
			replace DistName = "" if DataLevel == "State"
			
			replace SchName = "" if DataLevel == "District" | DataLevel == "State"
			
			replace DistName = subinstr(DistName,"District","Dist",.)
			replace DistName = subinstr(DistName,"County","Co",.)
			replace DistName = upper(DistName)
			replace DistName = strrtrim(DistName)
			
			replace DistName = "BALDWYN SCHOOL DISTRICT" if DistName == "BALDWYN SCHOOL DIST"
			replace DistName = "CARROLL COUNTY SCHOOL DIST" if DistName == "CARROLL CO SCHOOL DIST"
			replace DistName = "COAHOMA COUNTY SCHOOL DISTRICT" if DistName == "COAHOMA CO SCHOOL DIST"
			replace DistName = "COLUMBIA SCHOOL DISTRICT" if DistName == "COLUMBIA SCHOOL DIST"
			replace DistName = "FORREST COUNTY SCHOOL DISTRICT" if DistName == "FORREST CO SCHOOL DIST"
			replace DistName = "GREENE COUNTY SCHOOL DISTRICT" if DistName == "GREENE CO SCHOOL DIST"
			replace DistName = "GREENWOOD PUBLIC SCHOOL DISTRICT" if DistName == "GREENWOOD PUBLIC SCHOOL DIST"
			replace DistName = "HAZLEHURST CITY SCHOOL DISTRICT" if DistName == "HAZLEHURST CITY SCHOOL DIST"
			replace DistName = "KOSCIUSKO SCHOOL DISTRICT" if DistName == "KOSCIUSKO SCHOOL DIST"
			replace DistName = "LAMAR COUNTY SCHOOL DISTRICT" if DistName == "LAMAR CO SCHOOL DIST"
			replace DistName = "LAUREL SCHOOL DISTRICT" if DistName == "LAUREL SCHOOL DIST"
			replace DistName = "LEE COUNTY SCHOOL DISTRICT" if DistName == "LEE CO SCHOOL DIST"
			replace DistName = "LUMBERTON PUBLIC SCHOOL DISTRICT" if DistName == "LUMBERTON PUBLIC SCHOOL DIST"
			replace DistName = "MADISON CO SCHOOL DIST" if DistName == "MADISON COUNTY SCHOOL DIST"
			replace DistName = "MCCOMB SCHOOL DISTRICT" if DistName == "MCCOMB SCHOOL DIST"
			replace DistName = "MOSS POINT SEPARATE SCHOOL DIST" if DistName == "MOSS POINT SCHOOL DIST"
			replace DistName = "NESHOBA COUNTY SCHOOL DISTRICT" if DistName == "NESHOBA CO SCHOOL DIST"
			replace DistName = "NEWTON COUNTY SCHOOL DISTRICT" if DistName == "NEWTON CO SCHOOL DIST"
			replace DistName = "NEWTON MUNICIPAL SCHOOL DISTRICT" if DistName == "NEWTON MUNICIPAL SCHOOL DIST"
			replace DistName = "NOXUBEE COUNTY SCHOOL DISTRICT" if DistName == "NOXUBEE CO SCHOOL DIST"
			replace DistName = "OXFORD SCHOOL DISTRICT" if DistName == "OXFORD SCHOOL DIST"
			replace DistName = "PASCAGOULA-GAUTIER SCHOOL DISTRICT" if DistName == "PASCAGOULA-GAUTIER SCHOOL DIST"
			replace DistName = "SIMPSON CO SCHOOL DIST" if DistName == "SIMPSON COUNTY SCHOOL DIST"
			replace DistName = "SOUTH DELTA SCHOOL DISTRICT" if DistName == "SOUTH DELTA SCHOOL DIST"
			replace DistName = "SOUTH PANOLA SCHOOL DISTRICT" if DistName == "SOUTH PANOLA SCHOOL DIST"
			replace DistName = "STARKVILLE- OKTIBBEHA CONS DIST" if DistName == "STARKVILLE- OKTIBBEHA CONSOLIDATED SCHOOL DIST"
			replace DistName = "SUNFLOWER CO CONSOLIDATE SCH DIST" if DistName == "SUNFLOWER CO CONSOLIDATED SCHOOL DIST"
			replace DistName = "TUNICA COUNTY SCHOOL DISTRICT" if DistName == "TUNICA CO SCHOOL DIST"
			replace DistName = "WATER VALLEY SCHOOL DISTRICT" if DistName == "WATER VALLEY SCHOOL DIST"
			replace DistName = "WEST BOLIVAR CONS SCHOOL DIST" if DistName == "WEST BOLIVAR CONSOLIDATED SCHOOL DIST"
			replace DistName = "WEST TALLAHATCHIE SCHOOL DISTRICT" if DistName == "WEST TALLAHATCHIE SCHOOL DIST"
			replace DistName = "WESTERN LINE SCHOOL DISTRICT" if DistName == "WESTERN LINE SCHOOL DIST"
			replace DistName = "NORTH BOLIVAR CONS SCH" if DistName == "NORTH BOLIVAR CONSOLIDATED SCHOOL DIST"
			replace DistName = "PASCAGOULA SCHOOL DIST" if DistName == "PASCAGOULA-GAUTIER SCHOOL DISTRICT"
			replace DistName = "STARKVILLE- OKTIBBEHA CONS SD" if DistName == "STARKVILLE- OKTIBBEHA CONS DIST"
			replace DistName = "SUNFLOWER CO CONSOLIDATE SCH DIST" if DistName == "SUNFLOWER CONS SCHOOL DIST"
			replace DistName = "WEST BOLIVAR CONS SCH" if DistName == "WEST BOLIVAR CONS SCHOOL DIST"
			replace DistName = "HATTIESBURG PUBLIC SCHOOL DIST" if DistName == "HATTIESBURG PUBLIC SCHOOLDISTRICT"
			replace DistName = "MS SCH FOR THE BLIND" if DistName == "MISSISSIPPI SCH FOR THE BLIND"
			replace DistName = "EAST JASPER CONSOLIDATED SCH DIST" if DistName == "EAST JASPER CONSOLIDATED SCHOOL DIST"
			replace DistName = "EAST TALLAHATCHIE CONSOL SCH DIST" if DistName == "EAST TALLAHATCHIE CONSOLIDATED SCHOOL DIST"
			replace DistName = "HOUSTON  SCHOOL DIST" if DistName == "HOUSTON SCHOOL DIST"
			replace DistName = "TISHOMINGO CO SP MUN SCH DIST" if DistName == "TISHOMINGO CO SP MUN SCHOOL DIST"
			replace DistName = "MS SCH FOR THE BLIND" if DistName == "MS SCHOOL FOR THE BLIND"
						
			sort SchName DistName
			quietly by SchName DistName:  gen dup = cond(_N==1,0,_n)
			drop if dup > 1
			
			rename AverageofSS AvgScaleScore
			
			save "${output}/MS_AssmtData_2016_G`a'sciscale.dta", replace
}

	foreach a in $gradesci {
			use "${output}/MS_AssmtData_2016_G`a'sci.dta", clear
			
			quietly ds
			local school `:word 1 of `r(varlist)''
			foreach var of local school {
				rename `var' SchName
			}
			quietly ds
			local total `:word 6 of `r(varlist)''
				foreach var of local total {
					rename `var' StudentGroup_TotalTested
			}	
			
			generate SchYear = "2015-2016"
			
			generate GradeLevel = "G0`a'"
			generate Subject = "sci"
			gen AssmtName = "MST2"
			gen AssmtType = "Regular"
			gen StudentGroup = "All students"
			gen StudentSubGroup = "All students"
			
			gen DataLevel = "School"
			replace DataLevel = "District" if (strpos(SchName, "District") | strpos(SchName, "Schools") | strpos(SchName, "district") | strpos(SchName, "Blind") | strpos(SchName, "Deaf") |strpos(SchName, "Reimagine Prep")) & SchName != "West Bolivar District Middle School" & SchName != "Republic Charter Schools" > 0
			replace DataLevel = "State" if strpos(SchName, "Grand Total") > 0
			
			gen DistName = ""
			replace DistName = SchName if DataLevel == "District"
			replace DistName = DistName[_n-1] if missing(DistName)
			replace DistName = "" if DataLevel == "State"
			
			replace SchName = "" if DataLevel == "District" | DataLevel == "State"	

			replace DistName = subinstr(DistName,"District","Dist",.)
			replace DistName = subinstr(DistName,"County","Co",.)
			replace DistName = upper(DistName)
			replace DistName = strrtrim(DistName)
			
			replace DistName = "BALDWYN SCHOOL DISTRICT" if DistName == "BALDWYN SCHOOL DIST"
			replace DistName = "CARROLL COUNTY SCHOOL DIST" if DistName == "CARROLL CO SCHOOL DIST"
			replace DistName = "COAHOMA COUNTY SCHOOL DISTRICT" if DistName == "COAHOMA CO SCHOOL DIST"
			replace DistName = "COLUMBIA SCHOOL DISTRICT" if DistName == "COLUMBIA SCHOOL DIST"
			replace DistName = "FORREST COUNTY SCHOOL DISTRICT" if DistName == "FORREST CO SCHOOL DIST"
			replace DistName = "GREENE COUNTY SCHOOL DISTRICT" if DistName == "GREENE CO SCHOOL DIST"
			replace DistName = "GREENWOOD PUBLIC SCHOOL DISTRICT" if DistName == "GREENWOOD PUBLIC SCHOOL DIST"
			replace DistName = "HAZLEHURST CITY SCHOOL DISTRICT" if DistName == "HAZLEHURST CITY SCHOOL DIST"
			replace DistName = "KOSCIUSKO SCHOOL DISTRICT" if DistName == "KOSCIUSKO SCHOOL DIST"
			replace DistName = "LAMAR COUNTY SCHOOL DISTRICT" if DistName == "LAMAR CO SCHOOL DIST"
			replace DistName = "LAUREL SCHOOL DISTRICT" if DistName == "LAUREL SCHOOL DIST"
			replace DistName = "LEE COUNTY SCHOOL DISTRICT" if DistName == "LEE CO SCHOOL DIST"
			replace DistName = "LUMBERTON PUBLIC SCHOOL DISTRICT" if DistName == "LUMBERTON PUBLIC SCHOOL DIST"
			replace DistName = "MADISON CO SCHOOL DIST" if DistName == "MADISON COUNTY SCHOOL DIST"
			replace DistName = "MCCOMB SCHOOL DISTRICT" if DistName == "MCCOMB SCHOOL DIST"
			replace DistName = "MOSS POINT SEPARATE SCHOOL DIST" if DistName == "MOSS POINT SCHOOL DIST"
			replace DistName = "NESHOBA COUNTY SCHOOL DISTRICT" if DistName == "NESHOBA CO SCHOOL DIST"
			replace DistName = "NEWTON COUNTY SCHOOL DISTRICT" if DistName == "NEWTON CO SCHOOL DIST"
			replace DistName = "NEWTON MUNICIPAL SCHOOL DISTRICT" if DistName == "NEWTON MUNICIPAL SCHOOL DIST"
			replace DistName = "NOXUBEE COUNTY SCHOOL DISTRICT" if DistName == "NOXUBEE CO SCHOOL DIST"
			replace DistName = "OXFORD SCHOOL DISTRICT" if DistName == "OXFORD SCHOOL DIST"
			replace DistName = "PASCAGOULA-GAUTIER SCHOOL DISTRICT" if DistName == "PASCAGOULA-GAUTIER SCHOOL DIST"
			replace DistName = "SIMPSON CO SCHOOL DIST" if DistName == "SIMPSON COUNTY SCHOOL DIST"
			replace DistName = "SOUTH DELTA SCHOOL DISTRICT" if DistName == "SOUTH DELTA SCHOOL DIST"
			replace DistName = "SOUTH PANOLA SCHOOL DISTRICT" if DistName == "SOUTH PANOLA SCHOOL DIST"
			replace DistName = "STARKVILLE- OKTIBBEHA CONS DIST" if DistName == "STARKVILLE- OKTIBBEHA CONSOLIDATED SCHOOL DIST"
			replace DistName = "SUNFLOWER CO CONSOLIDATE SCH DIST" if DistName == "SUNFLOWER CO CONSOLIDATED SCHOOL DIST"
			replace DistName = "TUNICA COUNTY SCHOOL DISTRICT" if DistName == "TUNICA CO SCHOOL DIST"
			replace DistName = "WATER VALLEY SCHOOL DISTRICT" if DistName == "WATER VALLEY SCHOOL DIST"
			replace DistName = "WEST BOLIVAR CONS SCHOOL DIST" if DistName == "WEST BOLIVAR CONSOLIDATED SCHOOL DIST"
			replace DistName = "WEST TALLAHATCHIE SCHOOL DISTRICT" if DistName == "WEST TALLAHATCHIE SCHOOL DIST"
			replace DistName = "WESTERN LINE SCHOOL DISTRICT" if DistName == "WESTERN LINE SCHOOL DIST"
			replace DistName = "NORTH BOLIVAR CONS SCH" if DistName == "NORTH BOLIVAR CONSOLIDATED SCHOOL DIST"
			replace DistName = "PASCAGOULA SCHOOL DIST" if DistName == "PASCAGOULA-GAUTIER SCHOOL DISTRICT"
			replace DistName = "STARKVILLE- OKTIBBEHA CONS SD" if DistName == "STARKVILLE- OKTIBBEHA CONS DIST"
			replace DistName = "SUNFLOWER CO CONSOLIDATE SCH DIST" if DistName == "SUNFLOWER CONS SCHOOL DIST"
			replace DistName = "WEST BOLIVAR CONS SCH" if DistName == "WEST BOLIVAR CONS SCHOOL DIST"
			replace DistName = "HATTIESBURG PUBLIC SCHOOL DIST" if DistName == "HATTIESBURG PUBLIC SCHOOLDISTRICT"
			replace DistName = "MS SCH FOR THE BLIND" if DistName == "MISSISSIPPI SCH FOR THE BLIND"
			replace DistName = "EAST JASPER CONSOLIDATED SCH DIST" if DistName == "EAST JASPER CONSOLIDATED SCHOOL DIST"
			replace DistName = "EAST TALLAHATCHIE CONSOL SCH DIST" if DistName == "EAST TALLAHATCHIE CONSOLIDATED SCHOOL DIST"
			replace DistName = "HOUSTON  SCHOOL DIST" if DistName == "HOUSTON SCHOOL DIST"
			replace DistName = "TISHOMINGO CO SP MUN SCH DIST" if DistName == "TISHOMINGO CO SP MUN SCHOOL DIST"
			replace DistName = "MS SCH FOR THE BLIND" if DistName == "MS SCHOOL FOR THE BLIND"
			
			merge m:1 DistName using "${NCES}/NCES_2015_District.dta"

			drop if _merge == 2
			drop _merge
			
			rename PL1 Lev1_percent
			rename PL2 Lev2_percent
			rename PL3 Lev3_percent
			rename PL4 Lev4_percent
			gen Lev5_percent = ""
						
			gen Lev1_count = ""
			gen Lev2_count = ""
			gen Lev3_count = ""
			gen Lev4_count = ""
			gen Lev5_count = ""
			
			gen ProficiencyCriteria = "Levels 3-4"
			gen ProficientOrAbove_count = ""
			gen ProficientOrAbove_percent = ""
			gen ParticipationRate = ""
			
			replace State = 28
			replace StateAbbrev = "MS"
			replace StateFips = 28
			
			gen Flag_AssmtNameChange = "Y"
			gen Flag_CutScoreChange_ELA = "Y"
			gen Flag_CutScoreChange_math = "Y"
			gen Flag_CutScoreChange_read = ""
			gen Flag_CutScoreChange_oth = "Y"
						
			sort SchName DistName
			quietly by SchName DistName:  gen dup = cond(_N==1,0,_n)
			drop if dup > 1
						
			save "${output}/MS_AssmtData_2016_G`a'sci.dta", replace
			}
			
			
foreach a in $gradesci {
			use "${output}/MS_AssmtData_2016_G`a'sci.dta", clear
			merge 1:1 DistName SchName using "${output}/MS_AssmtData_2016_G`a'sciscale.dta", keepusing(AvgScaleScore)
			drop _merge dup
			save "${output}/MS_AssmtData_2016_G`a'sci.dta", replace
			}

** Appending subjects

	foreach a in $grade {
		use "${output}/MS_AssmtData_2016_G`a'ELA.dta", clear
		append using "${output}/MS_AssmtData_2016_G`a'Math.dta"
		save "${output}/MS_AssmtData_2016_G`a'all.dta", replace
	}
	foreach a in $gradesci {
		use "${output}/MS_AssmtData_2016_G`a'all.dta", clear
		append using "${output}/MS_AssmtData_2016_G`a'sci.dta"
		save "${output}/MS_AssmtData_2016_G`a'all.dta", replace
	}

	use "${output}/MS_AssmtData_2016_G3all.dta", clear
	append using "${output}/MS_AssmtData_2016_G4all.dta"
	append using "${output}/MS_AssmtData_2016_G5all.dta"
	append using "${output}/MS_AssmtData_2016_G6all.dta"
	append using "${output}/MS_AssmtData_2016_G7all.dta"
	append using "${output}/MS_AssmtData_2016_G8all.dta"
	order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType CountyName CountyCode SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName SchName Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
	drop year
	save "${output}/MS_AssmtData_2016.dta", replace
	export delimited using "/Users/maggie/Desktop/Mississippi/Output/csv/MS_AssmtData_2016.csv", replace




