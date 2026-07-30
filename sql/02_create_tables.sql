-- =====================================================
 -- Portfolio 4: Hospital Operations & Patient Flow Analysis
 -- =====================================================
 -- Author: Hisham Malek
 -- Database: PostgreSQL
 --
 -- Phase: 3 - Create Tables
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
 -- TABLE: Departments
 -- =====================================================
 -- Purpose:
 -- The departments table defines the different medical units in the hospital
 -- where doctors are assigned and patient care is delivered.
 -- =====================================================
 
 CREATE TABLE Departments (
 Department_ID INT PRIMARY KEY,
 Department_Name VARCHAR(100) NOT NULL,
 Floor_Number INT
 );
 
 
 -- =====================================================
 -- TABLE: Patients
 -- =====================================================
 -- Purpose:
 -- Stores demographic and contact information of hospital patients.
 -- =====================================================
 
 CREATE TABLE Patients (
 Patient_ID INT PRIMARY KEY,
 Patient_Name VARCHAR(150) NOT NULL,
 Gender VARCHAR(10),
 Date_of_Birth DATE,
 Blood_Group VARCHAR(5),
 Phone VARCHAR(30),
 City VARCHAR(100)
 );
 
 
 -- =====================================================
 -- TABLE: Doctors
 -- =====================================================
 -- Purpose:
 -- Stores information about doctors in the hospital system,
 -- including their department, specialization category, and consultation fees.
 -- =====================================================
 
 CREATE TABLE Doctors (
 Doctor_ID INT PRIMARY KEY,
 Doctor_Name VARCHAR(150) NOT NULL,
 Department_ID INT,
 Specialization VARCHAR(150),
 Consultation_Fee NUMERIC(10, 2),
 
 FOREIGN KEY (Department_ID)
 REFERENCES Departments(Department_ID)
 );
 
 
 -- =====================================================
 -- TABLE: Calendar
 -- =====================================================
 -- Purpose:
 -- The calendar table is a date reference table used to standardize time-based analysis
 -- across all hospital data (admissions, billing, treatments, etc.).
 -- =====================================================
 
 CREATE TABLE Calendar (
 Calendar_Date DATE PRIMARY KEY,
 Month VARCHAR(20),
 Month_No INT,
 Quarter VARCHAR(2),
 Year INT
 );
 
 
 -- =====================================================
 -- TABLE: Admissions
 -- =====================================================
 -- Purpose:
 -- Records each hospital admission event where a patient
 -- is admitted under a doctor for a specific time period.
 -- =====================================================
 
 CREATE TABLE Admissions (
 Admission_ID INT PRIMARY KEY,
 
 Patient_ID INT NOT NULL,
 Doctor_ID INT NOT NULL,
 
 Admission_Date DATE,
 Discharge_Date DATE,
 Room_Type VARCHAR(50),
 
 FOREIGN KEY (Patient_ID)
 REFERENCES Patients(Patient_ID),
 
 FOREIGN KEY (Doctor_ID)
 REFERENCES Doctors(Doctor_ID)
 );
 
 
 -- =====================================================
 -- TABLE: Treatment
 -- =====================================================
 -- Purpose:
 -- Represents medical procedures performed during a hospital admission,
 -- including type of treatment and associated cost breakdown.
 -- =====================================================
 
 CREATE TABLE Treatment (
 Treatment_ID INT PRIMARY KEY,
 
 Admission_ID INT,
 
 Treatment_Type VARCHAR(50),
 Treatment_Cost NUMERIC(10, 2),
 Medicine_Cost NUMERIC(10, 2),
 Lab_Cost NUMERIC(10,2),
 
 FOREIGN KEY (Admission_ID)
 REFERENCES Admissions(Admission_ID)
 );
 
 
 -- =====================================================
 -- TABLE: Billing
 -- =====================================================
 -- Purpose:
 -- The financial report of one hospital admission, including total charges,
 -- insurance coverage, and patient payment status.
 -- =====================================================
 
 CREATE TABLE Billing (
 Admission_ID INT PRIMARY KEY,
 
 Total_Bill NUMERIC(10,2),
 Insurance_Cover NUMERIC(10,2),
 Final_Amount_Payable NUMERIC(10,2),
 
 Payment_Mode VARCHAR(20),
 EMI_Months INT,
 Monthly_EMI NUMERIC(10,2),
 
 Payment_Status VARCHAR(20),
 
 FOREIGN KEY (Admission_ID)
 REFERENCES Admissions(Admission_ID)
 );