//Converting from Inequality Symbols to Ranges

forvalues n = 1/5{
replace Lev`n'_percent = subinstr(Lev`n'_percent, "<=", "0-", 1)
replace Lev`n'_percent = subinstr(Lev`n'_percent, "<", "0-", 1)
gen flag = 1 if strpos(Lev`n'_perent, ">") > 0
replace Lev`n'_percent = subinstr(Lev`n'_percent, ">=", "", 1)
replace Lev`n'_percent = subinstr(Lev`n'_percent, ">", "", 1)
replace Lev`n'_percent = Lev`n'_percent + "-1" if flag == 1
drop flag
}

** May need to include ProficientOrAbove_percent or ParticipationRate as well, depending on the structure of the raw data!
