-- =====================================================
 -- Portfolio 4: Hospital Operations & Patient Flow Analysis
 -- =====================================================
 -- Author: Hisham Malek
 -- Database: PostgreSQL
 --
 -- Phase: 4 - Load Data
 --
 -- Project Goal:
 -- Analyze hospital operations using patient, doctor, admission, treatment, and billing data
 -- to understand patient flow, hospital workload, department performance, and revenue patterns.
 --
 -- The goal is to identify operational inefficiencies such as doctor workload imbalance,
 -- patient readmission patterns, and resource utilization across departments.
 --
 -- This analysis will support data-driven decision on staffing, hospital capacity planning,
 -- and financial performance optimization.
 -- =====================================================
 


-- =====================================================
-- LOAD TABLE: Departments
-- =====================================================

\copy Departments(Department_ID, Department_Name, Floor_Number) FROM 'C:/Users/conne/Documents/GitHub/Portfolio_4/hospital_management_analysis/data/clean/csv/departments_clean.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');


-- =====================================================
-- LOAD TABLE: Patients
-- =====================================================

\copy Patients(Patient_ID, Patient_Name,	Gender,	Date_of_Birth, Blood_Group,	Phone, City) FROM 'C:/Users/conne/Documents/GitHub/Portfolio_4/hospital_management_analysis/data/clean/csv/patients_clean.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');


-- =====================================================
-- LOAD TABLE: Doctors
-- =====================================================

\copy Doctors(Doctor_ID, Doctor_Name, Department_ID,	Specialization,	Consultation_Fee) FROM 'C:/Users/conne/Documents/GitHub/Portfolio_4/hospital_management_analysis/data/clean/csv/doctors_clean.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');


-- =====================================================
-- LOAD TABLE: Calendar
-- =====================================================

\copy Calendar(Calendar_Date, Month, Month_No, Quarter, Year) FROM 'C:/Users/conne/Documents/GitHub/Portfolio_4/hospital_management_analysis/data/clean/csv/calendar_clean.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');


-- =====================================================
-- LOAD TABLE: Admissions
-- =====================================================

\copy Admissions(Admission_ID, Patient_ID, Doctor_ID, Admission_Date, Room_Type, Discharge_Date) FROM 'C:/Users/conne/Documents/GitHub/Portfolio_4/hospital_management_analysis/data/clean/csv/admissions_clean.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');


-- =====================================================
-- LOAD TABLE: Treatment
-- =====================================================

\copy Treatment(Treatment_ID, Admission_ID, Treatment_Type, Treatment_Cost, Medicine_Cost, Lab_Cost) FROM 'C:/Users/conne/Documents/GitHub/Portfolio_4/hospital_management_analysis/data/clean/csv/treatment_clean.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');


-- =====================================================
-- LOAD TABLE: Billing
-- =====================================================

\copy Billing(Admission_ID, Total_Bill, Insurance_Cover, Final_Amount_Payable, Payment_Mode, EMI_Months, Monthly_EMI, Payment_Status) FROM 'C:/Users/conne/Documents/GitHub/Portfolio_4/hospital_management_analysis/data/clean/csv/billing_clean.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');