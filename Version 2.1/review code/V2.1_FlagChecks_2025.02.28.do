*****************************************************************************
**	Updated February 28, 2025

** 	ZELMA STATE ASSESSMENT DATA REPOSITORY 
**	ASSESSMENT FLAGS - VERSION 2.1

*****************************************************************************
gen Flag_AssmtNameChange_Chk = "N"
gen Flag_CutScoreChange_ELA_Chk = "N"
gen Flag_CutScoreChange_math_Chk = "N"
gen Flag_CutScoreChange_sci_Chk = "N"
gen Flag_CutScoreChange_soc_Chk = "N"
gen AssmtType_Chk = "Regular"

	
	
//Alabama
if "$StateAbbrev" == "AL" {

	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2018" & (Subject =="ela" | Subject =="math" | Subject =="sci") 
		
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2021" & (Subject =="ela" | Subject =="math" | Subject =="sci") 

	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2018" | FILE == "2021" | FILE == "2023"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2018" | FILE == "2021" // no 2023 flag unlike ELA

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2018" | FILE == "2021"

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
}

//Alaska
if "$StateAbbrev" == "AK" {

	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2017" & (Subject =="ela" | Subject =="math" | Subject =="sci")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2022" & (Subject == "ela" | Subject == "math") // not sci

	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2017" | FILE == "2022" | FILE == "2023"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2017" | FILE == "2022" | FILE == "2023"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2021"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2017" | FILE == "2022"

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
}

//Arizona

if "$StateAbbrev" == "AZ" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject =="ela" | Subject =="math") // not sci
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2021" & (Subject == "ela" | Subject == "math") // not sci
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2022" & (Subject == "ela" | Subject == "math" | Subject == "sci")
	

	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015" | FILE == "2022"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015" | FILE == "2022"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2021"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2022"

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
	*AssmtType
	replace AssmtType_Chk = "Regular and alt" if real(FILE) <= 2019 & (Subject == "ela" | Subject == "math" | Subject == "sci")
	
}

//Arkansas
if "$StateAbbrev" == "AR" {

	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2016" & (Subject == "ela" | Subject == "math" | Subject == "sci")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2024" & (Subject == "ela" | Subject == "math" | Subject == "sci")

	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015" | FILE == "2016" | FILE == "2018"| FILE == "2024"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015" | FILE == "2016" | FILE == "2024" // no 2018 flag

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2016"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2024"

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
	*AssmtType
	replace AssmtType_Chk = "Regular and alt" if real(FILE) >= 2016 & (Subject == "ela" | Subject == "math")
	replace AssmtType_Chk = "Regular and alt" if real(FILE) >= 2016 & (Subject == "eng")
	replace AssmtType_Chk = "Regular and alt" if real(FILE) >= 2016 & (Subject == "read")
	replace AssmtType_Chk = "Regular and alt" if Subject == "sci"
} 

//California
if "$StateAbbrev" == "CA" {

	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & Subject == "sci"


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Not applicable" if FILE == "2014"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Not applicable" if FILE == "2014"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if real(FILE) >= 2014 & real(FILE) <= 2018
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2019"

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable" if real(FILE) > 2013
}

//Colorado
if "$StateAbbrev" == "CO" {

	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2022"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2023" //no name change

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable" if real(FILE) > 2015
}

//Connecticut
if "$StateAbbrev" == "CT" {

	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & Subject == "sci"


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if real(FILE) <=2018
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2019"

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
}

//Delaware
if "$StateAbbrev" == "DE" {

	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & (Subject == "sci" | Subject == "soc")


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2018"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2019"

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable" if FILE == "2017" | FILE == "2018"
	replace Flag_CutScoreChange_soc_Chk = "Y" if FILE == "2019"
	replace Flag_CutScoreChange_soc_Chk = "Y" if FILE == "2023" //no name change
	replace Flag_CutScoreChange_soc_Chk = "Y" if FILE == "2024" & (GradeLevel == "G04" | GradeLevel == "G06") 
}

//District of Columbia
if "$StateAbbrev" == "DC" {

	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & Subject == "sci"
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2024" & (Subject == "ela" | Subject == "math")
	

	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Not applicable" if FILE == "2021"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Not applicable" if FILE == "2021"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if real(FILE) <=2018
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2019"
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2021"

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
}

//Florida
if "$StateAbbrev" == "FL" {

	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math") //not sci
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2023" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2016" & Subject == "sci"


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2023"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2023"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2015"

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
}

//Georgia
if "$StateAbbrev" == "GA" {

	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015"


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2015"

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Y" if FILE == "2015"
}

//Hawaii
if "$StateAbbrev" == "HI" {

	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015"
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2021" & Subject == "sci"


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2021"

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
}

//Idaho
if "$StateAbbrev" == "ID" {

	*AssmtName
	//none


	*ELA
	//none

	*Math
	//none

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2021"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2022" //no name change

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
}

//Illinois
if "$StateAbbrev" == "IL" {

	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2016" & Subject == "sci"
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2021" & Subject == "sci"


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2019"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2019"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2015"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2016"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2021"
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2024"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
}

//Indiana
if "$StateAbbrev" == "IN" {

	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019"


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2019"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2019"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2019"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2024"

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Y" if FILE == "2019"
}

//Iowa
if "$StateAbbrev" == "IA" {

	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2012" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & (Subject == "ela" | Subject == "math" | Subject == "sci")


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2012"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2019"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2012"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2019"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if real(FILE) <= 2014
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2019"

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
	*AssmtType
	replace AssmtType_Chk = "Regular and alt" if real(FILE) <= 2014 & (Subject == "ela" | Subject == "math")
}

//Kansas
if "$StateAbbrev" == "KS" {

	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")

	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if real(FILE) <= 2018

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
}

//Kentucky
if "$StateAbbrev" == "KY" {

	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2012"
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2022"

	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2012"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2022"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2012"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2022"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if real(FILE) > 2014 & real(FILE) < 2018
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2018" // no name change
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2012"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2022"

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Y" if FILE == "2012"
	replace Flag_CutScoreChange_soc_Chk = "Not applicable" if FILE == "2021"
	replace Flag_CutScoreChange_soc_Chk = "Y" if FILE == "2022"
}

//Louisiana
if "$StateAbbrev" == "LA" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2018" & (Subject == "ela" | Subject == "math" | Subject == "soc")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & Subject == "sci"


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2018"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2019"

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable" if FILE == "2016"
	replace Flag_CutScoreChange_soc_Chk = "Y" if FILE == "2017" //no name change
	replace Flag_CutScoreChange_soc_Chk = "Not applicable" if FILE == "2024"
	
}	

//Maine
if "$StateAbbrev" == "ME" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2016" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2021" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2023" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2022" & Subject == "sci"


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2016"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2021"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2023"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2016"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2021"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2023"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2021"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2022"

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
}
//Maryland
if "$StateAbbrev" == "MD" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2018" & Subject == "sci"
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2021" & Subject == "sci"
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2022" & Subject == "sci"
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2021" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2022" & (Subject == "ela" | Subject == "math")


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2021"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2022"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2021"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2022"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2017"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2018"

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
}

//Massachusetts
if "$StateAbbrev" == "MA" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2017" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & Subject == "sci"




	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2017"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2017"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2019"

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
}

//Michigan
if "$StateAbbrev" == "MI" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & (Subject == "ela" | Subject == "math") & GradeLevel == "G08"
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & Subject == "sci"
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & Subject == "soc"




	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2019" & GradeLevel == "G08"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2019" & GradeLevel == "G08"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2021"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2022"
	
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2018"
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2019"
	

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Y" if FILE == "2015"
	
}

//Minnesota
if "$StateAbbrev" == "MN" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "1998" & (Subject == "ela" | Subject == "math" | Subject == "wri")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2006" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2011" & (Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2013" & (Subject == "ela")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2012" & (Subject == "sci")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & (Subject == "ela" | Subject == "math" | Subject == "sci")




	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "1998"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2006"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2013"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "1998"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2006"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2011"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if real(FILE) < 2008
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2012"
	

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
	*AssmtType
	replace AssmtType_Chk = "Regular and alt" if FILE == "2019" | FILE == "2021" | FILE == "2022" | FILE == "2023" | FILE == "2024" & (Subject == "ela" | Subject == "math" | Subject == "sci")
	
}

//Mississippi
if "$StateAbbrev" == "MS" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2016" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & Subject == "sci"




	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2016"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2016"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2019"

	

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
	
}

//Missouri
if "$StateAbbrev" == "MO" {
	
	*AssmtName
	//no name changes




	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2016"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2018"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2016"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2018"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2018"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2019"

	

	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
	
}

//Montana
if "$StateAbbrev" == "MT" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2022" & Subject == "sci"


	*ELA
	//no cut score changes

	*Math
	//no cut score changes

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if real(FILE) < 2022
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2022"

	
	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
	
}

//Nebraska
if "$StateAbbrev" == "NE" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2018" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2018" & Subject == "sci" //no cut change


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2017"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2018"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2023"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2018"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2024"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2021"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2022"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
		
}

//Nevada
if "$StateAbbrev" == "NV" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2016" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2017" & Subject == "sci"


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2016"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2016"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2016"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2017"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
	
}

//New Hampshire
if "$StateAbbrev" == "NH" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2018" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2018" & Subject == "sci"


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2018"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2018"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2014"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2018"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
	
}

//New Jersey
if "$StateAbbrev" == "NJ" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & Subject == "sci"


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_ELA_Chk = "Not applicable" if FILE == "2021"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_math_Chk = "Not applicable" if FILE == "2021"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if real(FILE) < 2019
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2021"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2019"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"	
	
}

//New Mexico

if "$StateAbbrev" == "NM" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2021" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2021" & Subject == "sci"


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2019"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2021"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2019"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2021"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2021"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"	
	
	
	*AssmtType	
	replace AssmtType_Chk = "Reg and Alt" if FILE == "2017" & StudentSubGroup != "All Students"
	replace AssmtType_Chk = "Reg and Alt" if FILE == "2018" & StudentSubGroup != "All Students"
	replace AssmtType_Chk = "Reg and Alt" if FILE == "2019" & StudentSubGroup != "All Students"
	replace AssmtType_Chk = "Reg and Alt" if FILE == "2021" & Subjet == "sci"
	replace AssmtType_Chk = "Reg and Alt" if FILE == "2022"
	replace AssmtType_Chk = "Reg and Alt" if FILE == "2023"
		
}

 

//New York

if "$StateAbbrev" == "NY" {
	
	*AssmtName
	//no name changes


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2013"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2018"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2023"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2013"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2018"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2023"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2024"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable" if real(FILE) > 2010
	
}
	
//North Carolina

if "$StateAbbrev" == "NC" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & (Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2021" & (Subject == "ela" ) & GradeLevel != "G03"
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2022" & (Subject == "ela" ) & GradeLevel == "G03"
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2021" & Subject == "sci"


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2014"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2021" & GradeLevel != "G03"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2022" & GradeLevel == "G03"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2014"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2019"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2014"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2021"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"	
	
}

//North Dakota

if "$StateAbbrev" == "ND" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2018" & (Subject == "ela" | Subject == "math")


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2018"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2018"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2021"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"	
	
}

//Ohio

if "$StateAbbrev" == "OH" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2016" & (Subject == "ela" | Subject == "math")


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2016"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2016"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2021"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable" if real(FILE) > 2017
	
}

//Oklahoma

if "$StateAbbrev" == "OK" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2017" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2017" & (Subject == "sci")


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2017"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2024"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2017"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2024"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2017"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2023"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
}

//Oregon

if "$StateAbbrev" == "OR" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & (Subject == "sci")


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"

	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"

	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2019"



	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
}

//Pennsylvania

if "$StateAbbrev" == "PA" {
	
	*AssmtName
	//no name changes


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"


	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"


	*Sci
	
	//no cut score changes


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
}

//Rhode Island

if "$StateAbbrev" == "RI" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2018" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & (Subject == "sci")


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2018"


	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2018"


	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2018"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2019"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
}

//South Carolina

if "$StateAbbrev" == "SC" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2016" & (Subject == "ela" | Subject == "math")


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2016"


	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2016"


	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2017" //no name change
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2024"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable" if real(FILE) > 2019
	
}

//South Dakota

if "$StateAbbrev" == "SD" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2017" & (Subject == "sci")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2021" & (Subject == "sci")


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Not applicable" if FILE == "2014"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"


	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_math_Chk = "Not applicable" if FILE == "2014"


	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2017"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2021"
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if real(FILE) < 2007


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
	*AssmtType
	replace AssmtType_Chk = "Regular and alt" if FILE == "2015" | FILE == "2016" | FILE == "2017" & (Subject == "ela" | Subject == "math" | Subject == "sci")

	
}

//Tennesse

if "$StateAbbrev" == "TN" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2017" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2017" & (Subject == "sci") //no cut change
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2018" & (Subject == "soc")
	


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Not applicable" if FILE == "2016"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2017"


	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2017"
	replace Flag_CutScoreChange_math_Chk = "Not applicable" if FILE == "2016"


	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2021"
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2016"
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if FILE == "2019"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable" if real(FILE) > 2014 & real(FILE) < 2018
	replace Flag_CutScoreChange_soc_Chk = "Y" if FILE == "2018"
	
}

//Texas

if "$StateAbbrev" == "TX" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2012" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2012" & (Subject == "sci")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2012" & (Subject == "soc")
	


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2012"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2017"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2023"
	


	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2012"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2017"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2023"


	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2012"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2017"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2023"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Y" if FILE == "2012"
	replace Flag_CutScoreChange_soc_Chk = "Y" if FILE == "2017"
	replace Flag_CutScoreChange_soc_Chk = "Y" if FILE == "2023"
	
}

//Utah

if "$StateAbbrev" == "UT" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2014" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & (Subject == "sci") //no cut change
	


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2014"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2019"
	


	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2014"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2019"


	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2018" & real(substr(GradeLevel,-1,1)) >= 6
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2021" & (GradeLevel == "G04" | GradeLevel == "G05")


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
}

//Vermont

if "$StateAbbrev" == "VT" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2023" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2019" & (Subject == "sci")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2023" & (Subject == "sci")
	


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2023"
	


	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2023"


	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if real(FILE) < 2019
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2019"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2023"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
}

//Virginia

if "$StateAbbrev" == "VA" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "1998" 

	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "1998"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2006"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2013"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2021"
	


	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "1998"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2006"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2012"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2019"


	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "1998"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2013"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2023"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Y" if FILE == "1998"
	replace Flag_CutScoreChange_soc_Chk = "Y" if FILE == "2004"
	replace Flag_CutScoreChange_soc_Chk = "Y" if FILE == "2011"
	replace Flag_CutScoreChange_soc_Chk = "Not applicable" if real(FILE) > 2014
	
}

//Washington

if "$StateAbbrev" == "WA" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2018" & (Subject == "sci")
	


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"
	


	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"


	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if real(FILE) < 2018
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2018"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
}

//West Virginia

if "$StateAbbrev" == "WV" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2015" & (Subject == "ela" | Subject == "math")
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2018" & (Subject == "ela" | Subject == "math")
	


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2018"
	


	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2015"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2018"


	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Not applicable" if real(FILE) < 2019


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
}

//Wisconsin

if "$StateAbbrev" == "WI" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2016"
	


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2016"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2024"
	


	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2016"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2024"


	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2016"
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2019"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Y" if FILE == "2016"
	replace Flag_CutScoreChange_soc_Chk = "Y" if FILE == "2022"

	
}

//Wyoming

if "$StateAbbrev" == "WY" {
	
	*AssmtName
	replace Flag_AssmtNameChange_Chk = "Y" if FILE == "2018" & (Subject == "ela" | Subject == "math" | Subject == "sci")
	


	*ELA
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2014"
	replace Flag_CutScoreChange_ELA_Chk = "Y" if FILE == "2018"
	


	*Math
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2014"
	replace Flag_CutScoreChange_math_Chk = "Y" if FILE == "2018"


	*Sci
	replace Flag_CutScoreChange_sci_Chk = "Y" if FILE == "2022"


	*Soc
	replace Flag_CutScoreChange_soc_Chk = "Not applicable"
	
	*AssmtType
	replace AssmtType_Chk = "Regular" if real(FILE) < 2019
	
}

** Summary 
foreach var of varlist *_Chk {
        local flag_var = subinstr("`var'", "_Chk", "", .)

        qui count if `var' != `flag_var'
        local count_result = r(N)

        if `count_result' == 0 {
            di "{error}`flag_var' Correct"
        }
		
        else {
            di "{error}`flag_var' Incorrect in the following years:"
            cap noisily tab FILE `flag_var' if `var' != `flag_var'
        }
    }
