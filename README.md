# 🏥 Medicare Patient Experience & Clinical Outcomes Analysis

**Author:** Harsha Sharad Kapse  
**Context:** Capstone Project — Master of Science in Healthcare Informatics, Sacred Heart University  

---

## 📊 Interactive Dashboard
*Click the image below to view the interactive dashboard on Tableau Public:*

[![Medicare Patient Experience Dashboard](dashboard_preview.png)](https://public.tableau.com/views/Medicarereadmissiontableudashboard/Dashboard1?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

---

## 🎯 Executive Summary & Business Problem
In the era of value-based healthcare, patient satisfaction scores (HCAHPS) are heavily scrutinized, but their direct relationship to tangible clinical outcomes is often debated. High hospital readmissions and "Excess Days in Acute Care" (EDAC) cost hospitals millions in Medicare penalties. 

**The Objective:** This project investigates a critical question for hospital administrators and quality improvement teams: *Does better communication from nursing staff directly correlate with lower hospital return days for acute cardiac and respiratory patients?*

## 🗄️ Data Architecture
The analysis utilizes two massive public datasets from the **CMS Hospital Compare Archive**:
1. **Patient Survey (HCAHPS) - Hospital:** Standardized patient perspectives of care, specifically extracting the linear mean scores for Nurse Communication (`H_COMP_1_LINEAR_SCORE`).
2. **Unplanned Hospital Visits - Hospital:** Clinical outcome data tracking hospital return days (EDAC) for Heart Failure (`EDAC_30_HF`), Acute Myocardial Infarction (`EDAC_30_AMI`), and Pneumonia (`EDAC_30_PN`).

## 🛠️ Technical Workflow
The data pipeline was constructed using **SQL Server (T-SQL)** for data engineering and **Tableau** for data visualization.

### 1. Data Engineering (SQL)
* **Ingestion:** Utilized `BULK INSERT` to load raw, large-scale CSV files into staging tables, resolving anomalies like Excel-style line endings and text qualifiers.
* **Cleaning & Type Casting:** Filtered out suppressed or unavailable data (e.g., removing rows with insufficient sample sizes) and cast text-based metrics into functional numeric types (`INT`, `FLOAT`) for aggregation.
* **Transformation & Joining:** Isolated the `H_COMP_1_LINEAR_SCORE` measure and joined the clinical outcomes table with the patient satisfaction table using `Facility_ID` as the primary key.
* **Output:** Generated a highly refined `Final_Capstone_Dataset` containing total patient volumes, clinical EDAC scores, and Nurse Communication scores.

### 2. Data Visualization (Tableau)
* **Correlation Analysis:** Developed a quadrant scatter plot mapping Nurse Communication scores against EDAC scores to identify statistical trends.
* **Performance Distribution:** Built state-level comparative charts (Bar/Box Plots) to highlight regional disparities in care quality.
* **Actionable Targeting:** Segmented facilities into "Role Models" (High Satisfaction/Low Returns) and "High Risk" (Low Satisfaction/High Returns) to guide administrative interventions.

## 💡 Key Findings
The statistical analysis of the CMS datasets revealed a clear, actionable trend:
> **There is a statistically significant negative correlation (-0.20) between Nurse Communication and Excess Days in Acute Care.** This trend was found to be strongest in Pneumonia (-0.25) and Heart Failure (-0.19) patients. **Conclusion:** Hospitals that achieve higher patient satisfaction through effective nursing communication experience measurably fewer hospital return days. Funding targeted nursing communication programs is a valid, data-backed clinical intervention to reduce Medicare readmission penalties.

## 📁 Repository Contents
* `scripts/SQL project.sql`: The complete T-SQL script containing table creation, bulk inserts, data cleaning, and table joins.
* `data/Healthcare Quality & Patient Experience Analysis.csv`: The cleaned and joined output data (13,400+ rows) used to build the Tableau dashboard.
* `images/dashboard_preview.png`: High-resolution snapshot of the final visualization.
