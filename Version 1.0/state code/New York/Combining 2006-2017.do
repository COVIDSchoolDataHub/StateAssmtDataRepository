clear
set more off
set trace off

cd "/Volumes/T7/State Test Project/New York/Original/2006-2017"

local subjects ela mat sci soc
local allgrades G03 G04 G05 G06 G07 G08
local sciencegrades G04 G08
local socgrades G05 G08

forvalues year = 2006/2017 {
    local firstfile = 1
    foreach subject of local subjects {
        // If the subject is SOC and the year is after 2010, skip the rest of the loop
        if "`subject'" == "SOC" & `year' > 2010 {
            continue
        }
        local grades
        if "`subject'" == "SCIENCE" {
            local grades "`sciencegrades'"
        }
        else if "`subject'" == "SOC" {
            local grades "`socgrades'"
        }
        else {
            local grades "`allgrades'"
        }
        foreach grade of local grades {
            local filename "NY_OriginalData_`subject'_`grade'_`year'.txt"

            di "`filename'"
            capture confirm file "`filename'"
            if _rc == 0 {
                di "`filename' exists, opening file"
                import delimited using "`filename'", clear stringcols(1)
                gen subject = "`subject'"
                gen grade = "`grade'"
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
    }
    use "`thisyear'", clear
    save "/Volumes/T7/State Test Project/New York/Original/Combined_`year'.dta", replace
}
