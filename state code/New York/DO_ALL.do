clear
set more off
cd "/Users/joshuasilverman/Documents/State Test Project/New York"

local dofiles "2006.do" "2007-2017.do" "2018.do" "2019.do" "2021.do" "2022.do"

foreach file of local dofiles {
	do "`file'"
}
