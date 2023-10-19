clear
set more off

cd "/Users/maggie/Desktop/Oklahoma"

global raw "/Users/maggie/Desktop/Oklahoma/Original Data Files"
global output "/Users/maggie/Desktop/Oklahoma/Output"
global NCES "/Users/maggie/Desktop/Oklahoma/NCES/Cleaned"

global grade 3 4 5 6 7 8

** Converting to dta **

foreach a in $grade {
	import excel "${raw}/OK_OriginalData_2017_G0`a'.xlsx", sheet("Grade `a' Data") firstrow clear
	if (`a' == 3){
		rename MathematicsLimitedKnowledge MathematicsLimitedKnowledgeNo
		rename BH MathematicsLimitedKnowledge
		keep Group OrganizationID Administration ELAValidN MathematicsValidN *MeanOPI *UnsatisfactoryNo *Unsatisfactory *LimitedKnowledgeNo *LimitedKnowledge *ProficientNo *Proficient *AdvancedNo *Advanced 
	}
	if (`a' == 4 | `a' == 6 | `a' == 7){
		rename MathematicsLimitedKnowledge MathematicsLimitedKnowledgeNo
		rename BD MathematicsLimitedKnowledge
		keep Group OrganizationID Administration ELAValidN MathematicsValidN *MeanOPI *UnsatisfactoryNo *Unsatisfactory *LimitedKnowledgeNo *LimitedKnowledge *ProficientNo *Proficient *AdvancedNo *Advanced 
	}
	if (`a' == 5 | `a' == 8){
		rename MathematicsLimitedKnowledge MathematicsLimitedKnowledgeNo
		rename BK MathematicsLimitedKnowledge
		keep Group OrganizationID Administration ELAValidN MathematicsValidN ScienceValidN *MeanOPI *UnsatisfactoryNo *Unsatisfactory *LimitedKnowledgeNo *LimitedKnowledge *ProficientNo *Proficient *AdvancedNo *Advanced 
	}
	save "${raw}/OK_AssmtData_2017_G0`a'.dta", replace
}

foreach a in $grade {
	import excel "${raw}/OK_OriginalData_2018_G0`a'.xlsx", sheet("Grade `a' Data") firstrow clear
	if (`a' == 5 | `a' == 8){
		keep Group OrganizationId Administration ELAValidN MathematicsValidN ScienceValidN *MeanOPI *BelowBasicNo *BelowBasic *BasicNo *Basic *ProficientNo *Proficient *AdvancedNo *Advanced 
	}
	if (`a' != 5 & `a' != 8){
		keep Group OrganizationId Administration ELAValidN MathematicsValidN *MeanOPI *BelowBasicNo *BelowBasic *BasicNo *Basic *ProficientNo *Proficient *AdvancedNo *Advanced
		drop Science*
	}
	save "${raw}/OK_AssmtData_2018_G0`a'.dta", replace
}

import excel "${raw}/OK_OriginalData_2019_all.xlsx", sheet("Sheet1") firstrow clear
keep grade OrganizationId Group Administration ELAValidN MathematicsValidN ScienceValidN *MeanOPI *BelowBasicNo *BelowBasic *BasicNo *Basic *ProficientNo *Proficient *AdvancedNo *Advanced
save "${raw}/OK_AssmtData_2019.dta", replace

import delimited "${raw}/OK_OriginalData_2021_all.csv", case(preserve) clear
keep district_name district subject grade year n_student p_*
drop *_shift *_disab
save "${raw}/OK_AssmtData_2021.dta", replace

import excel "${raw}/OK_OriginalData_2022_all.xlsx", sheet("OK2122MediaRedacted") firstrow clear
keep Grade OrganizationId Group Administration ELAValidN MathematicsValidN ScienceValidN *MeanOPI *BelowBasicNo *BelowBasic *BasicNo *Basic *ProficientNo *Proficient *AdvancedNo *Advanced
drop USHistory*
save "${raw}/OK_AssmtData_2022.dta", replace
