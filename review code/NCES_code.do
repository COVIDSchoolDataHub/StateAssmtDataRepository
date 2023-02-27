
forvalues year=2014/2020 {
	
	educationdata using "school ccd directory", sub(year=`year') csv clear
	rename leaid ncesdistrictid
	gen state_fips=fips
	rename fips state_name
	rename county_code county_f
	countyfips, fips(county_f)
	drop if _merge==2
	drop county_code
	rename county_f county_code
	rename ncessch ncesschoolid
	keep state_name state_location state_fips ncesschoolid ncesdistrictid state_leaid lea_name  charter county_code county_name school_type virtual seasch school_level year
	
	save "/Users/becky/Library/CloudStorage/GoogleDrive-rebecca.s.jack@gmail.com/Shared drives/COVID-19 School Data Hub/6. State Assessment Data Repository/_Data Cleaning Materials/NCES 2020-21 District and School Demographics/NCES_`year'_School.dta", replace
	
}


forvalues year=2009/2020 {
	
	educationdata using "district ccd directory", sub(year=`year') csv clear
	rename leaid ncesdistrictid
	gen state_fips=fips
	rename fips state_name
	rename agency_type district_agency_type
	keep state_name state_location state_fips ncesdistrictid state_leaid lea_name district_agency_type county_code county_name year
	
	save "/Users/becky/Library/CloudStorage/GoogleDrive-rebecca.s.jack@gmail.com/Shared drives/COVID-19 School Data Hub/6. State Assessment Data Repository/_Data Cleaning Materials/NCES 2020-21 District and School Demographics/NCES_`year'_District.dta", replace
	
}
