-- =====================================================
-- Portfolio 4: Hospital Operations & Patient Flow Analysis
-- =====================================================
-- Author: Hisham Malek
-- Database: PostgreSQL
--
-- Phase: 5 - SQL Analysis
-- Module: 3 - Hospital Stay Analysis
--
-- Project Goal:
-- Analyze hospital operations using patient, doctor, admission, treatment, and billing data
-- to understand patient flow, hospital workload, department performance, and revenue patterns.
--
-- Analysis Goal:
-- Identify length of stay patterns, admission and discharge flow, room utilization
-- efficiency, and patient demographic characteristics to support operational planning,
-- resource allocation, and hospital decision making.
-- =====================================================

-- =====================================================
-- Analysis 3.1A: Average Length of Stay (LOS)
--
-- Business Question:
-- What is the average patient length of stay in the hospital?
--
-- Purpose:
-- Measure the average hospitalization duration to understand overall patient stay
-- patterns and support hospital capacity planning, resource allocation, 
-- and operational efficiency.
-- =====================================================
SELECT
    ROUND(AVG(discharge_date - admission_date), 2) AS average_length_of_stay
FROM
    admissions;

-- =====================================================
-- Analysis 3.1B: Length of Stay (LOS) by Department
--
-- Business Question:
-- Which departments have longer or shorter patient stays?
--
-- Purpose:
-- Compare average patient length of stay across departments to identify departments
-- with longer or shorter hospitalization patterns and support capacity planning,
-- resource allocation, and operational efficiency.
-- =====================================================
SELECT
    dp.department_id,
    dp.department_name,
    ROUND(AVG(discharge_date - admission_date), 2) AS average_length_of_stay
FROM
    admissions a
    JOIN doctors d ON a.doctor_id = d.doctor_id
    JOIN departments dp ON d.department_id = dp.department_id
GROUP BY
    dp.department_id,
    dp.department_name
ORDER BY
    average_length_of_stay DESC;

-- =====================================================
-- Analysis 3.1C: Length of Stay (LOS) Distribution
--
-- Business Question:
-- How are patient stays distributed across different length-of-stay categories?
--
-- Purpose:
-- Analyze patient length of stay distribution to identify common hospitalization
-- patterns and support capacity planning, resource allocation, discharge preparation, 
-- and operational efficiency.
-- =====================================================
WITH
    los_data AS (
        SELECT
            admission_id,
            discharge_date - admission_date AS los_days
        FROM
            admissions
    )
SELECT
    CASE
        WHEN los_days <= 3 THEN '0-3 days'
        WHEN los_days <= 7 THEN '4-7 days'
        ELSE '8-14 days'
    END AS los_category,
    COUNT(*) AS total_admissions
FROM
    los_data
GROUP BY
    los_category
ORDER BY
    los_category;

-- =====================================================
-- Analysis 3.2A: Monthly Admission & Discharge Trend
--
-- Business Question:
-- How do monthly patient admissions and discharges change over time?
--
-- Purpose:
-- Analyze patient movement patterns by comparing incoming and outgoing
-- patient volume to understand hospital workload changes and operational flow.
-- =====================================================
WITH
    patient_events AS (
        SELECT
            admission_date AS event_date,
            'Admission' AS event_type
        FROM
            admissions
        UNION ALL
        SELECT
            discharge_date AS event_date,
            'Discharge' AS event_type
        FROM
            admissions
    )
SELECT
    c.year,
    c.month,
    c.month_no,
    pe.event_type,
    COUNT(*) AS total_events
FROM
    patient_events pe
    JOIN calendar c ON pe.event_date = c.calendar_date
GROUP BY
    c.year,
    c.month,
    c.month_no,
    pe.event_type
ORDER BY
    c.year,
    c.month_no,
    pe.event_type;

-- =====================================================
-- Analysis 3.2B: Monthly Net Patient Flow
--
-- Business Question:
-- What is the net patient flow (admissions minus discharges) for each month?
--
-- Purpose:
-- Analyze the balance between incoming and outgoing patients
-- to identify periods of increasing or decreasing hospital workload,
-- room demand, and operational capacity requirements.
-- =====================================================
WITH
    patient_events AS (
        SELECT
            admission_date AS event_date,
            'Admission' AS event_type
        FROM
            admissions
        UNION ALL
        SELECT
            discharge_date AS event_date,
            'Discharge' AS event_type
        FROM
            admissions
    )
SELECT
    c.year,
    c.month,
    c.month_no,
    COUNT(*) FILTER (
        WHERE
            event_type = 'Admission'
    ) AS total_admissions,
    COUNT(*) FILTER (
        WHERE
            event_type = 'Discharge'
    ) AS total_discharge,
    COUNT(*) FILTER (
        WHERE
            event_type = 'Admission'
    ) - COUNT(*) FILTER (
        WHERE
            event_type = 'Discharge'
    ) AS net_patient_flow
FROM
    patient_events pe
    JOIN calendar c ON pe.event_date = c.calendar_date
GROUP BY
    c.year,
    c.month,
    c.month_no
ORDER BY
    c.year,
    c.month_no;

-- =====================================================
-- Analysis 3.2C: Admissions-to-Discharges Gap
--
-- Business Question:
-- Which months have the largest gap between patient admissions and patient discharges?
--
-- Purpose:
-- Measure the difference between incoming and outgoing patient volume to identify 
-- months with higher hospital workload, months with increased room pressure, and 
-- months requiring additional operational planning.
-- =====================================================
WITH
    patient_events AS (
        SELECT
            admission_date AS event_date,
            'Admission' AS event_type
        FROM
            admissions
        UNION ALL
        SELECT
            discharge_date AS event_date,
            'Discharge' AS event_type
        FROM
            admissions
    ),
    monthly_flow AS (
        SELECT
            c.year,
            c.month,
            c.month_no,
            COUNT(*) FILTER (
                WHERE
                    event_type = 'Admission'
            ) AS total_admissions,
            COUNT(*) FILTER (
                WHERE
                    event_type = 'Discharge'
            ) AS total_discharges
        FROM
            patient_events pe
            JOIN calendar c ON pe.event_date = c.calendar_date
        GROUP BY
            c.year,
            c.month,
            c.month_no
    )
SELECT
    year,
    month,
    total_admissions,
    total_discharges,
    ABS(total_admissions - total_discharges) AS patient_gap
FROM
    monthly_flow
ORDER BY
    patient_gap DESC;

-- =====================================================
-- Analysis 3.3A: Average LOS by Room Type
--
-- Business Question:
-- Which room types have the longest or shortest average patient length of stay?
--
-- Purpose:
-- Identify room types with longer or shorter patient stays to support 
-- room utilization, resource allocation, operational planning,
-- and hospital capacity management.
-- =====================================================
SELECT
    room_type,
    ROUND(AVG(discharge_date - admission_date), 2) AS average_length_of_stay
FROM
    admissions
GROUP BY
    room_type
ORDER BY
    average_length_of_stay DESC;

-- =====================================================
-- Analysis 3.3B: Monthly Patient Census
--
-- Business Question:
-- What is the number of active patients at the end of each month?
--
-- Purpose:
-- Analyze the number of active patients at the end of each month
-- to understand hospital occupancy, room utilization, and operational capacity.
-- =====================================================
WITH
    monthly_calendar AS (
        SELECT
            year,
            month,
            month_no,
            CAST(
                date_trunc ('month', calendar_date) + interval '1 month' - interval '1 day' AS date
            ) AS month_end
        FROM
            calendar
        GROUP BY
            year,
            month,
            month_no,
            date_trunc ('month', calendar_date)
    )
SELECT
    mc.year,
    mc.month,
    mc.month_no,
    COUNT(DISTINCT a.patient_id) AS active_patients
FROM
    monthly_calendar mc
    JOIN admissions a ON a.admission_date <= mc.month_end
    AND a.discharge_date > mc.month_end
GROUP BY
    mc.year,
    mc.month,
    mc.month_no,
    mc.month_end
ORDER BY
    mc.year,
    mc.month_no;

-- =====================================================
-- Analysis 3.3C: Prolonged Patient Stay Cases
--
-- Business Question:
-- Which patients have prolonged hospital stays that may impact room utilization?
--
-- Purpose:
-- Identify prolonged hospitalization cases to understand room utilization pressure,
-- support discharge planning, and improve hospital capacity management.
-- =====================================================

SELECT
    a.admission_id,
    a.patient_id,

      CASE
        WHEN (
            EXTRACT(YEAR FROM AGE(a.admission_date, p.date_of_birth))
        ) BETWEEN 0 AND 17
            THEN '0-17 years'
        
        WHEN (
            EXTRACT(YEAR FROM AGE(a.admission_date, p.date_of_birth))
        ) BETWEEN 18 AND 35
            THEN '18-35 years'
        
        WHEN (
            EXTRACT(YEAR FROM AGE(a.admission_date, p.date_of_birth))
        ) BETWEEN 36 AND 50
            THEN '36-50 years'
        
        WHEN (
            EXTRACT(YEAR FROM AGE(a.admission_date, p.date_of_birth))
        ) BETWEEN 51 AND 65
            THEN '51-65 years'
        
        ELSE '65+ years'
END AS age_group,

    a.room_type,
    dp.department_name,
    (a.discharge_date - a.admission_date) AS length_of_stay
FROM 
    patients p
    JOIN admissions a ON p.patient_id = a.patient_id
    JOIN doctors d ON a.doctor_id = d.doctor_id
    JOIN departments dp ON d.department_id = dp.department_id
ORDER BY 
    length_of_stay DESC
LIMIT 10;

-- =====================================================
-- Analysis 3.4A: Admissions by Gender
--
-- Business Question:
-- How many admissions are there from each gender?
--
-- Purpose:
-- Analyze the distribution of admissions by gender to understand patient demographics.
-- =====================================================
SELECT
    p.gender,
    COUNT(*) AS total_admissions
FROM
    admissions a
    JOIN patients p ON a.patient_id = p.patient_id
GROUP BY
    p.gender
ORDER BY
    total_admissions DESC;

-- =====================================================
-- Analysis 3.4B: Admissions by Age Group
--
-- Business Question:
-- Which age groups contribute the highest number of hospital admissions?
--
-- Purpose:
-- Analyze the distribution of admissions by age group to understand healthcare demand
-- patterns, support resource planning, and identify population groups contributing 
-- higher hospital demand.
-- =====================================================
SELECT
    CASE
        WHEN (
            EXTRACT(YEAR FROM AGE(a.admission_date, p.date_of_birth)) 
        ) BETWEEN 0 AND 17
            THEN '0-17 years'
        
        WHEN (
            EXTRACT(YEAR FROM AGE(a.admission_date, p.date_of_birth))
        ) BETWEEN 18 AND 35
            THEN '18-35 years'
        
        WHEN (
            EXTRACT(YEAR FROM AGE(a.admission_date, p.date_of_birth))
        ) BETWEEN 36 AND 50
            THEN '36-50 years'
        
       WHEN (
            EXTRACT(YEAR FROM AGE (a.admission_date, p.date_of_birth))
        ) BETWEEN 51 AND 65
            THEN '51-65 years' 
        ELSE '65+ years'
    END AS age_group,
    COUNT(a.admission_id) AS total_admissions
FROM
    patients p
    JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY
    age_group
ORDER BY
    total_admissions DESC;

-- =====================================================
-- Analysis 3.4C: Admissions by City
--
-- Business Question:
-- Which cities have the highest number of hospital admissions?
--
-- Purpose:
-- Analyze geographic distribution of admissions to understand
-- patient demand patterns and support healthcare planning,
-- outreach strategies, and resource allocation.
-- =====================================================
SELECT
    p.city,
    COUNT(a.admission_id) AS total_admissions,
    ROUND(
        (
            COUNT(a.admission_id) * 100.0 / SUM(COUNT(a.admission_id)) OVER ()
        ),
        2
    ) AS percentage_of_total_admissions
FROM
    patients p
    JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY
    p.city
ORDER BY
    COUNT(a.admission_id) DESC
LIMIT
    10;

-- =====================================================
-- Analysis 3.4D: Admissions by Blood Group
--
-- Business Question:
-- Which blood groups have the highest number of hospital admissions?
--
-- Purpose:
-- Analyze admission distribution by blood group to understand
-- patient demographic patterns and support healthcare resource planning.
-- =====================================================
SELECT
    p.blood_group,
    COUNT(a.admission_id) AS total_admissions
FROM
    patients p
    JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY
    p.blood_group
ORDER BY
    total_admissions DESC;