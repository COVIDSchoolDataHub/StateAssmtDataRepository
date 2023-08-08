clear
set more off

cd "G:\Test Score Repository Project\NY\TXT Format Original"

local subjects "ELA" "MATH" "SCIENCE" "SOC"
local allgrades "G03" "G04" "G05" "G06" "G07" "G08"
local sciencegrades "G04" "G08"
local socgrades "G05" "G08"

foreach year in 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 {
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
            local filename "`subject'`grade'_`year'.txt"

            di "`filename'"
            capture confirm file "`filename'"
            if _rc == 0 {
                di "`filename' exists, opening file"
                import delimited using "`filename'", clear
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
    save "Combined_`year'.dta", replace
}
