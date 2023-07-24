clear
set more off
set trace on

//NOTE: IF YOU'RE RECREATING CLEANING PROCESS, RUN DE_2015_2022 CODE FIRST

local data "/Volumes/T7 1/State Test Project/Delaware/Original/Combined .dta by DataLevel & Year"

foreach year in 2015 2016 2017 {
	di as error "`year'"
//State
	use "`data'/State_`year'_DCAS.dta", clear
	if `year' == 2017 {
		rename PercentProficient PercentProficiency
	}
	//Converting to Percents
		destring PL*, replace i(<>=)
		foreach n in 1 2 3 4 {
			replace PL`n' = PL`n'/100
		}
		destring ParticipationRate, replace i(<>=)
		replace ParticipationRate = ParticipationRate/100
		replace PercentProficiency = PercentProficiency/100
		
	//Fixing Grade and Subject
		gen Grade = "G0" + substr(Subject, strpos(Subject, "Grade")+6,1)
		gen Subject1 = substr(Subject, strpos(Subject, "Grade")+7,10)
		drop Subject
		rename Subject1 Subject
	//Generating empty variables
		gen District = ""
		gen SchoolName = ""
	//Variables: Group NumberTested MeanScaleScore PercentProficiency ParticipationRate PL1-4 Subject Grade District SchoolName
	tostring MeanScaleScore, replace
	tostring NumberTested, replace
	tempfile State_`year'
	save "`State_`year''"
	
	
//District 
	use "`data'/District_`year'_DCAS.dta", clear
	if `year' != 2017 {
	drop G PercentProficient I
	}
	else if `year' == 2017 {
		drop G H I
		rename PercentProficient PercentProficiency
	}
	//Fixing District for 2016 & 2017
	if `year' !=2015 {
	gen District1 = subinstr(District," Performance and Participation","", .)
	drop District
	rename District1 District
	}
	//Converting to Percents
	destring PercentProficiency, replace i(<>=%*)
	replace PercentProficiency = PercentProficiency/100
	destring ParticipationRate, replace i(<>%*)
	replace ParticipationRate = ParticipationRate/100
	
	//Fixing Grade and Subject
	rename Data Subject
	gen Grade = "G0" + substr(Subject, strpos(Subject, "Grade")+6,1)
	gen Subject1 = substr(Subject, strpos(Subject, "Grade")+7,10)
	drop Subject
	rename Subject1 Subject
	//Generating empty variables
	foreach s in 1 2 3 4 {
		gen PL`s'=.
	}
	gen SchoolName = ""
	gen NumberTested =.
	//Variables: District Group MeanScaleScore PercentProficiency ParticipationRate PL1-4 Subject Grade SchoolName NumberTested
	tostring MeanScaleScore, replace
	tostring NumberTested, replace
	tempfile District_`year'
	save "`District_`year''"

//School
	use "`data'/School_`year'_DCAS.dta", clear
	if `year' != 2017 {
	drop G PercentProficient I
	}
	else if `year' == 2017 {
		drop F G H
		rename PercentProficient PercentProficiency
	}
	//Converting to Percents
	destring PercentProficiency, replace i(<>=%*)
	replace PercentProficiency = PercentProficiency/100
	destring ParticipationRate, replace i(<>%*)
	replace ParticipationRate = ParticipationRate/100
	
	//Fixing Grade and Subject
	gen Subject1 ="" 
	replace Subject1 = substr(Subject, strpos(Subject, "-")+2,10) if strpos(Subject,"-") !=0
	replace Subject1 = Subject if strpos(Subject,"-") !=0
	drop Subject
	capture noisily rename Subject1 Subject
	capture drop if Subject = "The Wallace Wallin School"
	tostring Grade, replace
	gen Grade1 = "G0" + Grade
	drop Grade
	rename Grade1 Grade
	//Generating Empty Variables
	foreach s in 1 2 3 4 {
		gen PL`s'=.
	}
	gen District = ""
	gen NumberTested =.
	gen Group = "All Students"
	//Variables: Subject SchoolName Grade MeanScaleScore PercentProficiency ParticipationRate PL1-4 District NumberTested Group
	tostring MeanScaleScore, replace
	tostring NumberTested, replace
	tempfile School_`year'
	save "`School_`year''"
//Charter (for 2016 & 17)
	if `year' != 2015 {
	use "`data'/Charter_`year'_DCAS.dta"
	rename School SchoolName
	if `year' != 2017 {
	drop G H I
	rename PercentProficient PercentProficiency
	}
	else if `year' == 2017 {
		drop F G H
		rename PercentProficient PercentProficiency
	}
	//Converting to Percents
	destring PercentProficiency, replace i(<>=%*)
	replace PercentProficiency = PercentProficiency/100
	destring ParticipationRate, replace i(<>%*)
	replace ParticipationRate = ParticipationRate/100
	
	//Fixing Grade and Subject
	gen Subject1 ="" 
	replace Subject1 = substr(Subject, strpos(Subject, "-")+2,10) if strpos(Subject,"-") !=0
	replace Subject1 = Subject if strpos(Subject,"-") !=0
	drop Subject
	rename Subject1 Subject
	capture drop if Subject = "The Wallace Wallin School"
	tostring Grade, replace
	gen Grade1 = "G0" + Grade
	drop Grade
	rename Grade1 Grade
	//Generating Empty Variables
	foreach s in 1 2 3 4 {
		gen PL`s'=.
	}
	gen District = ""
	gen NumberTested =.
	gen Group = "All Students"
	//Variables: Subject SchoolName Grade MeanScaleScore PercentProficiency ParticipationRate PL1-4 District NumberTested Group
	tostring MeanScaleScore, replace
	tostring NumberTested, replace
	tempfile Charter_`year'
	save "`Charter_`year''"
	clear
	}
	if `year' == 2015 {
	append using "`State_`year''" "`District_`year''" "`School_`year''"
	save "`data'/Combined_`year'", replace
	}
	else {
	append using "`State_`year''" "`District_`year''"  "`School_`year''" "`Charter_`year''"
	save "`data'/Combined_`year'", replace
	}
	
	clear
	
	
	}


local data "/Volumes/T7/State Test Project/Delaware/Original/Combined .dta by DataLevel & Year"
	foreach year in 2015 2016 2017 {
		use "`data'/Combined_`year'"
		keep if Grade == "G04" | Grade == "G05" | Grade == "G07" | Grade == "G08"
		replace Subject = "sci" if Grade== "G05" | Grade == "G08"
		replace Subject = "soc" if Grade== "G04" | Grade == "G07"
		capture replace SchoolName = School if missing(SchoolName)
		replace SchoolName = SchoolName[_n-1] if missing(SchoolName)
		rename Group StudentSubGroup
		rename NumberTested StudentSubGroup_TotalTested
		rename MeanScaleScore AvgScaleScore
		rename PercentProficiency ProficientOrAbove_percent
		rename PL1 Lev1_percent
		rename PL2 Lev2_percent
		rename PL3 Lev3_percent
		rename PL4 Lev4_percent
		rename Grade GradeLevel
		rename SchoolName School
		replace District = "All Districts" if !missing(Lev1_percent) | !missing(Lev3_percent)
		replace School = "All Schools" if School= ""
		save "`data'/Combined_`year'", replace
		
	}
	