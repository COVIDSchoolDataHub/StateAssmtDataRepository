clear
set more off

//Set NY folder directory
cd "/Volumes/T7/State Test Project/New York"

//SET FILE DIRECTORIES FOR ALL DO-FILES HERE

global original "/Volumes/T7/State Test Project/New York/Original"
global output "/Volumes/T7/State Test Project/New York/Output"
global nces_school "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global nces_district "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"

local dofiles "2006-2017.do" "2018.do"  "2019.do" "2021.do" "2022.do" "2023.do"

foreach file of local dofiles {
	do "`file'"
}
