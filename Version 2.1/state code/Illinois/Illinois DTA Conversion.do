* ILLINOIS

* File name: Illinois DTA Conversion
* Last update: 03/06/2025

*******************************************************
* Notes

	* This do file imports *.csv IL data for 2015-2024 and saves it as *.dta.

*******************************************************

clear

** Converting to dta **

** 2015-17 state-level

import excel "${Original}/IL_OriginalData_2015-2017_all_state.xlsx", sheet("Sheet1") cellrange(A2:T58) firstrow clear
save "${Original_DTA}/IL_AssmtData_2015-2017_all_state.dta", replace

** 2015

import excel "${Original}/IL_OriginalData_2015_all.xlsx", sheet("PARCC performance at 5 levels_s") cellrange(A2:BN4627) firstrow clear
save "${Original_DTA}/IL_AssmtData_2015_all.dta", replace

** 2016

import excel "${Original}/IL_OriginalData_2016_all.xlsx", sheet("PARCC performance at 5 levels_s") cellrange(A2:BN4594) firstrow clear
save "${Original_DTA}/IL_AssmtData_2016_all.dta", replace

import excel "${Original}/IL_OriginalData_2016_sci.xlsx", sheet("gr 5") firstrow clear
save "${Original_DTA}/IL_AssmtData_2016_sci_5.dta", replace

import excel "${Original}/IL_OriginalData_2016_sci.xlsx", sheet("gr8") firstrow clear
save "${Original_DTA}/IL_AssmtData_2016_sci_8.dta", replace

import excel "${Original}/IL_OriginalData_2016_sci_Participation.xlsx", sheet("gr 5") firstrow clear
save "${Original_DTA}/IL_AssmtData_2016_sci_Participation_5.dta", replace

import excel "${Original}/IL_OriginalData_2016_sci_Participation.xlsx", sheet("gr8") firstrow clear
save "${Original_DTA}/IL_AssmtData_2016_sci_Participation_8.dta", replace

import excel "${Original}/IL_OriginalData_2016_sci_AvgScaleScore.xlsx", sheet("gr5 means") firstrow clear
save "${Original_DTA}/IL_AssmtData_2016_sci_AvgScaleScore_5.dta", replace

import excel "${Original}/IL_OriginalData_2016_sci_AvgScaleScore.xlsx", sheet("gr8 means") firstrow clear
save "${Original_DTA}/IL_AssmtData_2016_sci_AvgScaleScore_8.dta", replace

** 2017

import excel "${Original}/IL_OriginalData_2017_all.xlsx", sheet("test at performance levels_s") cellrange(A2:BN4660) firstrow clear
save "${Original_DTA}/IL_AssmtData_2017_all.dta", replace

import excel "${Original}/IL_OriginalData_2017_sci.xlsx", sheet("gr 5") firstrow clear
save "${Original_DTA}/IL_AssmtData_2017_sci_5.dta", replace

import excel "${Original}/IL_OriginalData_2017_sci.xlsx", sheet("gr 8") firstrow clear
save "${Original_DTA}/IL_AssmtData_2017_sci_8.dta", replace

import excel "${Original}/IL_OriginalData_2017_sci_Participation.xlsx", sheet("gr 5") firstrow clear
save "${Original_DTA}/IL_AssmtData_2017_sci_Participation_5.dta", replace

import excel "${Original}/IL_OriginalData_2017_sci_Participation.xlsx", sheet("gr 8") firstrow clear
save "${Original_DTA}/IL_AssmtData_2017_sci_Participation_8.dta", replace

import excel "${Original}/IL_OriginalData_2017_sci_AvgScaleScore.xlsx", sheet("gr 5") firstrow clear
save "${Original_DTA}/IL_AssmtData_2017_sci_AvgScaleScore_5.dta", replace

import excel "${Original}/IL_OriginalData_2017_sci_AvgScaleScore.xlsx", sheet("gr 8") firstrow clear
save "${Original_DTA}/IL_AssmtData_2017_sci_AvgScaleScore_8.dta", replace

** 2018

import excel "${Original}/IL_OriginalData_2018_all.xlsx", sheet("PARCC") cellrange(A1:AHZ4755) firstrow clear
save "${Original_DTA}/IL_AssmtData_2018_all.dta", replace

import excel "${Original}/IL_OriginalData_2018_sci.xlsx", sheet("Grade 5") firstrow clear
save "${Original_DTA}/IL_AssmtData_2018_sci_5.dta", replace

import excel "${Original}/IL_OriginalData_2018_sci.xlsx", sheet("Grade 8") firstrow clear
save "${Original_DTA}/IL_AssmtData_2018_sci_8.dta", replace

import excel "${Original}/IL_OriginalData_2018_sci_Participation.xlsx", sheet("ISA_Grade 5") firstrow clear
save "${Original_DTA}/IL_AssmtData_2018_sci_Participation_5.dta", replace

import excel "${Original}/IL_OriginalData_2018_sci_Participation.xlsx", sheet("ISA_Grade 8") firstrow clear
save "${Original_DTA}/IL_AssmtData_2018_sci_Participation_8.dta", replace

import excel "${Original}/IL_OriginalData_2018_sci_AvgScaleScore.xlsx", sheet("Grade 5") firstrow clear
save "${Original_DTA}/IL_AssmtData_2018_sci_AvgScaleScore_5.dta", replace

import excel "${Original}/IL_OriginalData_2018_sci_AvgScaleScore.xlsx", sheet("Grade 8") firstrow clear
save "${Original_DTA}/IL_AssmtData_2018_sci_AvgScaleScore_8.dta", replace

** 2019

import excel "${Original}/IL_OriginalData_2019_all.xlsx", sheet("IAR") cellrange(A1:AQB4739) firstrow clear
save "${Original_DTA}/IL_AssmtData_2019_all.dta", replace

import excel "${Original}/IL_OriginalData_2019_sci.xlsx", sheet("Grade 5") firstrow clear
save "${Original_DTA}/IL_AssmtData_2019_sci_5.dta", replace

import excel "${Original}/IL_OriginalData_2019_sci.xlsx", sheet("Grade 8") firstrow clear
save "${Original_DTA}/IL_AssmtData_2019_sci_8.dta", replace

import excel "${Original}/IL_OriginalData_2019_sci_Participation.xlsx", sheet("ISA_Grade 5") firstrow clear
save "${Original_DTA}/IL_AssmtData_2019_sci_Participation_5.dta", replace

import excel "${Original}/IL_OriginalData_2019_sci_Participation.xlsx", sheet("ISA_Grade 8") firstrow clear
save "${Original_DTA}/IL_AssmtData_2019_sci_Participation_8.dta", replace

import excel "${Original}/IL_OriginalData_2019_sci_AvgScaleScore.xlsx", sheet("Grade 5") firstrow clear
save "${Original_DTA}/IL_AssmtData_2019_sci_AvgScaleScore_5.dta", replace

import excel "${Original}/IL_OriginalData_2019_sci_AvgScaleScore.xlsx", sheet("Grade 8") firstrow clear
save "${Original_DTA}/IL_AssmtData_2019_sci_AvgScaleScore_8.dta", replace

** 2021

import excel "${Original}/IL_OriginalData_2021_all.xlsx", sheet("IAR") cellrange(A1:AQB4721) firstrow clear
save "${Original_DTA}/IL_AssmtData_2021_all.dta", replace

import excel "${Original}/IL_OriginalData_2021-2023_sci_datarequest_01.28.25.xlsx", sheet ("2021") firstrow clear
save "${Original_DTA}/IL_AssmtData_2021_sci_performance.dta", replace

import excel "${Original}/IL_OriginalData_2021_sci_Participation.xlsx", sheet("Grade 5") firstrow clear
save "${Original_DTA}/IL_AssmtData_2021_sci_Participation_5.dta", replace

import excel "${Original}/IL_OriginalData_2021_sci_Participation.xlsx", sheet("Grade 8") firstrow clear
save "${Original_DTA}/IL_AssmtData_2021_sci_Participation_8.dta", replace

import excel "${Original}/IL_OriginalData_2021_sci_AvgScaleScore.xlsx", sheet("Grade 5") firstrow clear
save "${Original_DTA}/IL_AssmtData_2021_sci_AvgScaleScore_5.dta", replace

import excel "${Original}/IL_OriginalData_2021_sci_AvgScaleScore.xlsx", sheet("Grade 8") firstrow clear
save "${Original_DTA}/IL_AssmtData_2021_sci_AvgScaleScore_8.dta", replace

import excel "${Original}/IL_OriginalData_2021_sci.xlsx", sheet("Grade 5") firstrow clear
save "${Original_DTA}/IL_AssmtData_2021_sci_5.dta", replace

import excel "${Original}/IL_OriginalData_2021_sci.xlsx", sheet("Grade 8") firstrow clear
save "${Original_DTA}/IL_AssmtData_2021_sci_8.dta", replace

** 2022

import excel "${Original}/IL_OriginalData_2022_all.xlsx", sheet("IAR") cellrange(A1:ARZ4708) firstrow clear
save "${Original_DTA}/IL_AssmtData_2022_all.dta", replace

import excel "${Original}/IL_OriginalData_2021-2023_sci_datarequest_01.28.25.xlsx", sheet ("2022") firstrow clear
save "${Original_DTA}/IL_AssmtData_2022_sci_performance.dta", replace

import excel "${Original}/IL_OriginalData_2022_sci_Participation.xlsx", sheet("Grade 5") firstrow clear
save "${Original_DTA}/IL_AssmtData_2022_sci_Participation_5.dta", replace

import excel "${Original}/IL_OriginalData_2022_sci_Participation.xlsx", sheet("Grade 8") firstrow clear
save "${Original_DTA}/IL_AssmtData_2022_sci_Participation_8.dta", replace

import excel "${Original}/IL_OriginalData_2022_sci.xlsx", sheet("Grade 5") firstrow clear
save "${Original_DTA}/IL_AssmtData_2022_sci_5.dta", replace

import excel "${Original}/IL_OriginalData_2022_sci.xlsx", sheet("Grade 8") firstrow clear
save "${Original_DTA}/IL_AssmtData_2022_sci_8.dta", replace

** 2023

import excel "${Original}/IL_OriginalData_2023_all.xlsx", sheet("IAR") cellrange(A1:ATN4706) firstrow clear
save "${Original_DTA}/IL_AssmtData_2023_all.dta", replace

import excel "${Original}/IL_OriginalData_2021-2023_sci_datarequest_01.28.25.xlsx", sheet ("2023") firstrow clear
save "${Original_DTA}/IL_AssmtData_2023_sci_performance.dta", replace

import excel "${Original}/IL_OriginalData_2023_sci_Participation.xlsx", sheet("Grade 5") firstrow clear
save "${Original_DTA}/IL_AssmtData_2023_sci_Participation_5.dta", replace

import excel "${Original}/IL_OriginalData_2023_sci_Participation.xlsx", sheet("Grade 8") firstrow clear
save "${Original_DTA}/IL_AssmtData_2023_sci_Participation_8.dta", replace

import excel "${Original}/IL_OriginalData_2023_sci.xlsx", sheet("Grade 5") firstrow clear
save "${Original_DTA}/IL_AssmtData_2023_sci_5.dta", replace

import excel "${Original}/IL_OriginalData_2023_sci.xlsx", sheet("Grade 8") firstrow clear
save "${Original_DTA}/IL_AssmtData_2023_sci_8.dta", replace

** 2024
import excel "${Original}/IL_OriginalData_2024_ela_mat.xlsx", sheet("IAR") firstrow clear
save "${Original_DTA}/IL_AssmtData_2024_ela_mat.dta", replace

import excel "${Original}/IL_DataRequest_2024_sci.xlsx", clear sheet("Data") firstrow case(preserve)
save "${Original_DTA}/IL_AssmtData_2024_sci.dta", replace
* END of Illinois DTA Conversion.do
****************************************************
