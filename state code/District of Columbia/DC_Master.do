clear
set more off
local Original "/Volumes/T7/State Test Project/District of Columbia/Original Data"
local Output "/Volumes/T7/State Test Project/District of Columbia/Output"
local NCES "/Volumes/T7/State Test Project/NCES"
cd "/Volumes/T7/State Test Project/District of Columbia"
local dofiles DC_2015 DC_2016 DC_2017 DC_2018 DC_2019 DC_2022 DC_2023 DC_ParticipationRate_2015_2022

foreach file of local dofiles {
	do `file'
}
/*
forvalues year = 2015/2023 {
if `year' == 2020 | `year' == 2021 continue
use "`Output'DC_AssmtData_`year'"





clear
}
