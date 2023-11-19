clear
set more off

global raw "/Users/miramehta/Documents/NM State Testing Data"
global output "/Users/miramehta/Documents/NM State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

cd "/Users/miramehta/Documents/NM State Testing Data"

** Converting to dta **

import excel "${raw}/NM_OriginalData_2017_elamath.xlsx", sheet(PARCC 2017) cellrange(A4) firstrow clear
drop J-N
drop if Code == .
save "${raw}/NM_AssmtData_2017_PARCC.dta", replace
import excel "${raw}/NM_OriginalData_2017_sci.xlsx", sheet(Webfiles SBASCI 2016) cellrange(A3) firstrow clear
drop I-M
save "${raw}/NM_AssmtData_2017_SBA.dta", replace

import excel "${raw}/NM_OriginalData_2018_elamath.xlsx", sheet(PARCC 2018) cellrange(A4) firstrow clear
save "${raw}/NM_AssmtData_2018_PARCC.dta", replace
import excel "${raw}/NM_OriginalData_2018_sci.xlsx", sheet(SBA Science by Grade 2018 MASKE) cellrange(A3) firstrow clear
drop I-K
save "${raw}/NM_AssmtData_2018_SBA.dta", replace	

import excel "${raw}/NM_OriginalData_2019_elamath.xlsx", sheet(TAMELA Proficiencies 2019 MASKE) cellrange(A4) firstrow clear
save "${raw}/NM_AssmtData_2019_TAMELA.dta", replace
import excel "${raw}/NM_OriginalData_2019_sci.xlsx", sheet(SBA_Science_by_Grade_2019) cellrange(A3) firstrow clear
drop I-K
drop if Code == ""
save "${raw}/NM_AssmtData_2019_SBA.dta", replace	
