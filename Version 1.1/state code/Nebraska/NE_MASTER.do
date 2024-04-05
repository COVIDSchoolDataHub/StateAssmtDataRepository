clear

//Set directory below
global dir "/Volumes/T7/State Test Project/Nebraska"

do "$dir/NE Student Counts 2016 + 17_12.1.23.do"
do "$dir/NE Student Counts 2018_12.1.23.do" 

forvalues year = 2016/2023 {
	if `year' == 2020 continue
	do "$dir/NE Cleaning `year'.do"
}

