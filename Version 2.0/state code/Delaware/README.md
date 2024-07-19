
# Delaware Data Cleaning

This is a ReadMe for Delaware's data cleaning process, from Spring 2015 to Spring 2023 

*Has been adapted for the 2024 Zelma 2.0 review.




## Setup

There are four folders you need to create: 
NCESNew, Original Data Files, Output, Excel DCAS Datasets

Download the original .xlsx files and place them into the "Original Data Files" folder. 

(With the exception of the 2015-2017 DCAS files, which should be place separately.

There are 4 .do files. Run them in the following order.

nces_district.do

nces_school.do

DE_2015_2022.do 

(You should not have to run DE_2015_2022_PART2.do separately)

(The NCESOld file should be the most recent available NCES files.)

    
## File Path

The file path setup should be as follows: 

```bash
global original "/Users/minnamgung/Desktop/SADR/Delaware/Original Data Files"
global output "/Users/minnamgung/Desktop/SADR/Delaware/Output"
global nces "/Users/minnamgung/Desktop/SADR/Delaware/NCESNew"
global PART2 "/Users/minnamgung/Documents/GitHub/StateAssmtDataRepository/Version 1.1/state code/Delaware/DE_2015_2022_PART2.do"

global NCESOLD "/Users/minnamgung/Desktop/SADR/NCESOld"
global NCESNEW "/Users/minnamgung/Desktop/SADR/Delaware/NCESNew"

global data "/Users/minnamgung/Desktop/SADR/Delaware/Original Data Files/Excel DCAS Datasets"
global cleaned "/Users/minnamgung/Desktop/SADR/Delaware/Output"
```
## Updates

03/29/2024: Made 2024 updates.
04/12/2024: Responded to 2024 review comments
