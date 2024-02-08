clear
set more off
cd "/Volumes/T7/State Test Project/New York"

local dofiles "2006-2017.do" "2018.do" "2019.do" "2021.do" "2022.do"

foreach file of local dofiles {
	do "`file'"
}
