clear all
set more off

cd "/Volumes/T7/State Test Project/West Virginia"
global data "/Volumes/T7/State Test Project/West Virginia/Original Data Files"
global NCES "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_clean "/Volumes/T7/State Test Project/West Virginia/NCES_Clean"
global edfacts "/Volumes/T7/State Test Project/EDFACTS"
global counts "/Volumes/T7/State Test Project/West Virginia/Counts"

forvalues year = 2015/2024 {
	if `year' == 2020 continue
	do WV_`year'
}
do WV_edfacts_participation_2015_2021
