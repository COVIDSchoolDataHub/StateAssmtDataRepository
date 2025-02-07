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

*Add newer years in order.*
do "${DoFiles}/01_ID_DataRequest_2016.do" 
do "${DoFiles}/02_ID_DataRequest_2017.do" 
do "${DoFiles}/03_ID_DataRequest_2018.do" 
do "${DoFiles}/04_ID_DataRequest_2019.do" 
do "${DoFiles}/05_ID_DataRequest_2021.do" 
do "${DoFiles}/06_ID_DataRequest_2022.do" 
do "${DoFiles}/07_ID_DataRequest_2023.do" 
do "${DoFiles}/08_ID_DataCleanPublic_2024.do" 
****************************************************
