clear
set more off

local MD "/Volumes/T7/State Test Project/MD R3 Response"
local dofiles MD_R3_2015_2018 2019_new 2021_new 2022_new 2023_new

foreach file of local dofiles {
	do "`MD'/`file'"
}
