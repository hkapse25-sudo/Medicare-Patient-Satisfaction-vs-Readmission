CREATE TABLE patient_satisfaction (
    Facility_ID VARCHAR(50),
    Facility_Name VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(50),
    ZIP_Code VARCHAR(50),
    County_Parish VARCHAR(100),
    Telephone_Number VARCHAR(50),
    HCAHPS_Measure_ID VARCHAR(50),
    HCAHPS_Question VARCHAR(255),
    HCAHPS_Answer_Description VARCHAR(255),
    Patient_Survey_Star_Rating VARCHAR(50),
    HCAHPS_Answer_Percent VARCHAR(50),
    HCAHPS_Linear_Mean_Value VARCHAR(50),
    Number_of_Completed_Surveys VARCHAR(50),
    Survey_Response_Rate_Percent VARCHAR(50),
    Start_Date VARCHAR(50),
    End_Date VARCHAR(50)
);

DROP TABLE IF EXISTS patient_satisfaction;
---------------------------------------------------------
CREATE TABLE patient_satisfaction (
    Facility_ID VARCHAR(50),
    Facility_Name VARCHAR(255),
    Address VARCHAR(255),
    City_Town VARCHAR(100),
    State VARCHAR(50),
    ZIP_Code VARCHAR(50),
    County_Parish VARCHAR(100),
    Telephone_Number VARCHAR(50),
    HCAHPS_Measure_ID VARCHAR(50),
    HCAHPS_Question VARCHAR(MAX),             -- Changed to MAX for long questions
    HCAHPS_Answer_Description VARCHAR(MAX),   -- Changed to MAX for long answers
    Patient_Survey_Star_Rating VARCHAR(50),
    Patient_Survey_Star_Rating_Footnote VARCHAR(50), -- NEW
    HCAHPS_Answer_Percent VARCHAR(50),
    HCAHPS_Answer_Percent_Footnote VARCHAR(50),      -- NEW
    HCAHPS_Linear_Mean_Value VARCHAR(50),
    Number_of_Completed_Surveys VARCHAR(50),
    Number_of_Completed_Surveys_Footnote VARCHAR(50), -- NEW
    Survey_Response_Rate_Percent VARCHAR(50),
    Survey_Response_Rate_Percent_Footnote VARCHAR(50), -- NEW
    Start_Date VARCHAR(50),
    End_Date VARCHAR(50)
);

BULK INSERT patient_satisfaction -----bulk import
FROM 'C:\Users\harsh\Desktop\SQL\HCAHPS-Hospital.csv'
WITH (
    FORMAT = 'CSV',          
    FIRSTROW = 2,            -- Skips the header row
    FIELDTERMINATOR = ',',   
    ROWTERMINATOR = '0x0a',  -- Handles Excel-style line endings
    maxerrors =100            --Allows  it to keep going if a few  rows  are weird  
);

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'patient_satisfaction';


select  ---- Data type change
Facility_ID,
Facility_Name,
State,
HCAHPS_Measure_ID,
HCAHPS_Question,
Try_cast(HCAHPS_Linear_Mean_Value as int) as satisfaction_linear_score,
Try_cast(Patient_Survey_Star_Rating as int)as satisfaction_star_rating,
try_cast(Number_of_Completed_Surveys as int)as surveys_completed,
Survey_Response_Rate_Percent
into HCAHPS_deep_cleaned
from patient_satisfaction
where 
HCAHPS_Measure_ID='H_COMP_1_LINEAR_SCORE'
and HCAHPS_Linear_Mean_Value is not null
and HCAHPS_Linear_Mean_Value<>''
and HCAHPS_Linear_Mean_Value<>'NA'
and HCAHPS_Answer_Percent_Footnote is null
and Patient_Survey_Star_Rating_Footnote is null

--------------------------------------------------------
DROP TABLE IF EXISTS Unplanned_hospital_visits;
CREATE TABLE Unplanned_hospital_visits (
    Facility_ID VARCHAR(50),
    Facility_Name VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(50),    
    ZIP_Code VARCHAR(50),
    County VARCHAR(100),    
    Telephone_Number VARCHAR(50),    
    Measure_ID VARCHAR(100),    
    Measure_Name VARCHAR(MAX),  
    Compared_to_National VARCHAR(MAX),    
    Denominator VARCHAR(50),    
    Score VARCHAR(50),          
    Lower_Estimate VARCHAR(50),
    Higher_Estimate VARCHAR(50),    
    Number_of_Patients VARCHAR(50),
    Number_of_Patients_Returned VARCHAR(50),    
    Footnote VARCHAR(MAX),    
    Start_Date VARCHAR(50),    
    End_Date VARCHAR(50)
);

BULK INSERT Unplanned_hospital_visits -----------------------------bulk import
FROM 'C:\Users\harsh\Desktop\SQL\Unplanned_Hospital_Visits-Hospital.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',        -- Very important for this file
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    MAXERRORS = 100
);

select * from Unplanned_hospital_visits

select                              -----------data type change 
 Facility_id,
 Facility_name,
 State,
 City,
 Measure_id,
Try_cast(replace(denominator,',','')as int)as total_patient_volume,
try_cast(replace(score,',','')as float)as clinical_score,
try_cast(replace( Number_of_Patients_Returned,',','')as int)as Excess_days_returned
into unplanned_visit_deep_cleaned
from Unplanned_hospital_visits
where
 measure_id in(
 'EDAC_30_HF', 'EDAC_30_PN', 'EDAC_30_AMI')
 and isnumeric(replace(score,',',''))=1
 AND Footnote IS NULL;

DROP TABLE IF EXISTS Final_Capstone_Dataset;

SELECT 
    u.Facility_ID,
    u.Facility_Name,
    u.State,
    u.City,
    u.Measure_ID,
    u.Total_Patient_Volume,
    u.Clinical_Score,
    u.Excess_Days_Returned,
    -- Pivot the HCAHPS scores into separate columns
    MAX(CASE WHEN h.HCAHPS_Measure_ID = 'H_COMP_1_LINEAR_SCORE' THEN h.satisfaction_linear_score END) AS Nurse_Comm_Score,
    MAX(CASE WHEN h.HCAHPS_Measure_ID = 'H_COMP_2_LINEAR_SCORE' THEN h.satisfaction_linear_score END) AS Doctor_Comm_Score
INTO Final_Capstone_Dataset
FROM unplanned_visit_deep_cleaned u
INNER JOIN HCAHPS_deep_cleaned h 
ON u.Facility_ID = h.Facility_ID
GROUP BY 
    u.Facility_ID, u.Facility_Name, u.State, u.City, u.Measure_ID, 
    u.Total_Patient_Volume, u.Clinical_Score, u.Excess_Days_Returned;

    SELECT  ---------------------The "Integrity Check" (Verification)
    Measure_ID,
    AVG(Clinical_Score) as Avg_Excess_Days,
    AVG(Nurse_Comm_Score) as Avg_Nurse_Quality,
    AVG(Doctor_Comm_Score) as Avg_Doctor_Quality
FROM Final_Capstone_Dataset
GROUP BY Measure_ID;

select * from Final_Capstone_Dataset
select * from HCAHPS_deep_cleaned

---------------------------------------------
Drop table if exists Final_Capstone_Dataset

----------------------------------------------------------------------------
SELECT 
    u.Facility_ID,
    u.Facility_Name,
    u.State,
    u.City,
    u.Measure_ID,
    u.Total_Patient_Volume,
    u.Clinical_Score as edac_score,
    u.Excess_Days_Returned,
    MAX(h.satisfaction_linear_score) AS Nurse_Comm_Score
INTO Final_Capstone_Dataset
FROM unplanned_visit_deep_cleaned u
INNER JOIN HCAHPS_deep_cleaned h 
ON u.Facility_ID = h.Facility_ID
where h.HCAHPS_Measure_ID ='H_comp_1_Linear_score'
GROUP BY 
    u.Facility_ID, u.Facility_Name, u.State, u.City, u.Measure_ID, 
    u.Total_Patient_Volume, u.Clinical_Score, u.Excess_Days_Returned;
-----------------------------------------------------------------------------
select * from Final_Capstone_Dataset



