cd "/Volumes/T7/State Test Project/New York/Original/2006-2017"

local subjects "ELA MATH SCIENCE"

foreach year in 2018 {
    local firstfile = 1
    foreach subject of local subjects {
        local filename "`subject'`year'.txt"
        
        di "`filename'"
        capture confirm file "`filename'"
        if _rc == 0 {
            di "`filename' exists, opening file"
            import delimited using "`filename'", clear stringcols(1)
			gen subject = "`subject'"
            
            
            // Loop over each variable in the dataset
            foreach var of varlist _all {
                // Exclude the newly created 'subject' variable
                if "`var'" != "subject" {
                    // Convert numeric variables to string
                    capture confirm numeric variable `var'
                    if _rc == 0 {
                        tostring `var', replace
                    }
                }
            }

            if `firstfile' == 1 {
                tempfile thisyear
                save "`thisyear'"
                local firstfile = 0
            }
            else {
                append using "`thisyear'"
                save "`thisyear'", replace
            }
        }
        else {
            di "`filename' does not exist or could not be opened"
        }
    }
    use "`thisyear'", clear
    save "Combined_`year'.dta", replace
}
