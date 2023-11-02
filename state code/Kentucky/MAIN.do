clear
set more off
global raw "C:\Users\philb\Downloads\Kentucky\raw\"
global clean "C:\Users\philb\Downloads\Kentucky\clean\"
global nces "C:\Users\philb\Downloads\NCES School Files, Fall 1997-Fall 2021\"
global code "C:\Users\philb\Documents\GitHub\StateAssmtDataRepository\state code\Kentucky\"

do "${code}KY_2012-2017.do"
do "${code}KY_2018-2019.do"
do "${code}KY_2021.do"
do "${code}KY_2022.do"
do "${code}nces_merge.do"