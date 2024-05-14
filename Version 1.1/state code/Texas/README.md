# Texas Data Cleaning

This is a ReadMe for Texas's data cleaning process, from 2012 to 2023.

## Setup

Create a folder for Nebraska. Inside that folder, create four more folders: "original_files", "NCES_files", "output_files", and "temp_files"

1.  Download do-files and place them in the folder.
2.  Set file directories at the top of each do file:

```         
global original_files "/Volumes/T7/State Test Project/Texas/Original"
global NCES_files "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global output_files "/Volumes/T7/State Test Project/Texas/Output"
global temp_files "/Volumes/T7/State Test Project/Texas/Temp"
```

-   `original_files` Corresponds to the "Original" data. The folder names don't really matter.
-   `NCES_files` Corresponds to raw NCES .dta files, downloaded from the drive
-   `output_files` Corresponds to the cleaned data
-   `temp_files` should be empty for now.

## Recreate Cleaning

1. Unhide importing code for each year:
```
forvalues i = 3/8
    .
    .
    .
save "$temp_files/TX_Temp_`year'_All_All.dta", replace
```

2. Run the do-files for each year. You will want to hide the importing code again after the first run. 

3. If you run into a problem where stata isn't recognizing the files to import, it's probably because the original data files don't have the ".sas7bdat" suffix. If you're on a mac, you can select all these files and rename them to include the suffix (or run the python code below). If you're on windows, you can run the following python code to automatically rename the files:

```
import os

def rename_files_in_folder(folder_path):
    # Iterate over all files in the specified folder
    for filename in os.listdir(folder_path):
        # Construct full file path
        old_file_path = os.path.join(folder_path, filename)
        
        # Skip if it's not a file
        if not os.path.isfile(old_file_path):
            continue
        
        # New file name with the suffix .sas7bdat
        new_filename = filename + ".sas7bdat"
        new_file_path = os.path.join(folder_path, new_filename)
        
        # Rename the file
        os.rename(old_file_path, new_file_path)
        print(f'Renamed: {old_file_path} to {new_file_path}')

# Specify the folder path
folder_path = '/path/to/your/folder'

# Call the function to rename files
rename_files_in_folder(folder_path)
```


