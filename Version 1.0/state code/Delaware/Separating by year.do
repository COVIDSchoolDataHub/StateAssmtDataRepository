clear
//TO RECREATE SPLITTING, DEFINE DIRECTORY BELOW

cd "G:\Test Score Repository Project\Delaware\Original"

local original "G:\Test Score Repository Project\Delaware\Original"


//IMPORTING
import delimited "`original'/Student_Assessment_Performance.csv", case(preserve)
save "`original'/Student_Assessment_Performance"

//SPLITTING BY YEAR

foreach year of numlist 2015 2016 2017 2018 2019 2020 2021 2022 {
use "`original'/Student_Assessment_Performance", replace
drop if `year' != SchoolYear

//EXPORTING TO EXCEL
export excel using "DE_OriginalData_`year'_all.xlsx", firstrow(variables) replace
clear
}