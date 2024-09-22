In order to scrape Virginia you must follow these steps:

1. Create a localhost chrome browser using these terminal commands
   
    On Mac:
   ```
    USER_DATA_DIR="$HOME/Chrome_Test_Profile"
    cd /Applications/Google\ Chrome.app/Contents/MacOS/
    ./Google\ Chrome --remote-debugging-port=9014 --user-data-dir="$USER_DATA_DIR"
   ```


    On Windows:
   
```
    cd C:\Program Files\Google\Chrome\Application
    chrome.exe -remote-debugging-port=9014 --user-data-dir="C:\test\Chrome_Test_Profile"
```

Change the file names to wherever you want to store Chrome locally.

Change the file path of Google Chrome to the correct path.

2. Run each of the 6 files

3. Both programs require to be run twice - once for "All Grades" and another time to get each individual grade's data

When running All Grades part, comment out all instances of the following code (there are 3)

```
for grade_number in range(3, 9):
    selector(grade, grade_number, False)
```

And uncomment one line close to the end of the file which is
```
selector(grade, 0)
```
Do the reverse when scraping for specific grades

4. Change the file_path_name variable to an existing Excel file path

5. Running each of the four sections all at once is most optimal because it shouldn't
take more than 12 hours to scrape one of the school sections and the districts take no more than 2 hours.

6. Do not leave the window where Chrome is while running the program (only quickly switch back and forth
from your code editor to Chrome if needed)

7. The program will end in an error message regardless of whether it ran correctly or not but if the
only error is one that starts with "Fatal Python error: _enter_buffered_busy:" then the program
finished and all the data was collected.

