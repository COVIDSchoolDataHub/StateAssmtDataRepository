clear
set more off
//Make sure to download all dofiles first and save to a directory, specified below. 
cd "/Volumes/T7/State Test Project/South Dakota"
local dofiles SD_2003_2013.do SD_2014_2017.do SD_2018.do SD_2021_2022.do
local years 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2021 2022
local Output "/Volumes/T7/State Test Project/South Dakota/Output"
foreach file of local dofiles { //Doing all files
	do `file'
}

foreach year of local years { //Additional Cleaning for each year
	use "`Output'/SD_AssmtData_`year'.dta", clear
	
	
	
	
	
	
	
	
	
	
	
	
	save "`Output'/SD_AssmtData_`year'.dta" , replace
	export delimited "`Output'/SD_AssmtData_`year'", replace	
}
