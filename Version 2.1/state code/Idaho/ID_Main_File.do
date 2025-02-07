*******************************************************
* IDAHO

* File name: ID_Main_File
* Last update: 2/7/2025

*******************************************************
* Notes

* This file executes all ID files and exports to Output.
*******************************************************
clear 

global original_files "C:\Users\Clare\Desktop\Zelma V2.1\Idaho\Original Data\Idaho data received from data request 11-27-23"
global NCES_files "C:\Users\Clare\Desktop\Zelma V2.0\Iowa - Version 2.0\NCES_full"
global output_files "C:\Users\Clare\Desktop\Zelma V2.1\Idaho\Output"
global temp_files "C:\Users\Clare\Desktop\Zelma V2.1\Idaho\Temp"
global DoFiles "C:\Users\Clare\Desktop\Zelma V2.1\Idaho"

*Run in this order. Add newer years in order.*
do "${DoFiles}/ID_2016_new.do" 
do "${DoFiles}/ID_2017_new.do" 
do "${DoFiles}/ID_2018_new.do" 
do "${DoFiles}/ID_2019_new.do" 
do "${DoFiles}/ID_2021_new.do" 
do "${DoFiles}/ID_2022_new.do" 
do "${DoFiles}/ID_2023_new.do" 
do "${DoFiles}/ID_2024_new.do" 
****************************************************