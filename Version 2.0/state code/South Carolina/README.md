
# South Carolina Data Cleaning

This is a ReadMe for South Carolina's data cleaning process, from Spring 2016 to Spring 2023 





## Setup

There are three folders you need to create: 
Original Data Files, Intermediate, Output.

Download the original .xlsx files and place them into the "Original Data Files" folder. 

There is 1 .do file. You can run the entire file at once.

(The NCESOld file should be the most recent available NCES files.)

To include EDFacts Participation data for Version 2.0, run the EDFacts files after fully running the above do-file.

    
## File Path

The file path setup should be as follows: 

```bash
global path "/Users/minnamgung/Desktop/SADR/South Carolina"
global nces "/Users/minnamgung/Desktop/SADR/NCESOld"
```
## Updates

03/29/2024: Made 2024 updates.

06/17/24: Made changes based on state tasks. Changes should be implemented to the main cleaning file in the future, but currently separate for timing reasons.

7/16/24: Incorporated EDFacts Participation Data.

7/26/24: Updated Flags.

8/9/24: Incorporated State Task form 6/17/24 into main do-file
