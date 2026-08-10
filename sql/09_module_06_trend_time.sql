-- =====================================================
-- Portfolio 4: Hospital Operations & Patient Flow Analysis
-- =====================================================
-- Author: Hisham Malek
-- Database: PostgreSQL
--
-- Phase: 5 - SQL Analysis
-- Module: 6 - Trend and Time Analysis
--
-- Project Goal:
-- Analyze hospital operations using patient, doctor, admission, treatment, and billing data
-- to understand patient flow, hospital workload, department performance, and revenue patterns.
--
-- Analysis Goal:
-- Identify patient admission trends, demand patterns, and resource utilization to support
-- hospital capacity planning and operational decision making.
-- =====================================================



-- =====================================================
-- Analysis 6.1A: Monthly Admissions
--
-- Business Question:
-- How does hospital admission volume change month by month across 2020-2024?
--
-- Purpose:
-- Analyze monthly admissions activity patterns to understand changes 
-- in clinical demand and support capacity and staffing decisions.
-- =====================================================

SELECT
    c.year,
    c.month,
    c.month_no,
    COUNT(a.admission_id) AS total_admissions
FROM
    admissions a
    JOIN calendar c ON a.admission_date = c.calendar_date
GROUP BY
    c.year,
    c.month,
    c.month_no
ORDER BY
    c.year,
    c.month_no;



-- =====================================================
-- Analysis 6.1B: Yearly Admissions
--
-- Business Question:
-- How does total hospital admission volume change from year to year across 2020-2024?
--
-- Purpose:
-- Analyze yearly admissions activity patterns to understand changes 
-- in clinical demand and support capacity and staffing decisions.
-- =====================================================

SELECT
    c.year,
    COUNT(a.admission_id) AS total_admissions,
    COUNT(DISTINCT a.patient_id) AS total_patients,
    ROUND(
        COUNT(a.admission_id) * 1.0 / COUNT(DISTINCT a.patient_id),
        2
    ) AS admissions_per_patient
FROM
    admissions a
    JOIN calendar c ON a.admission_date = c.calendar_date
GROUP BY
    c.year
ORDER BY
    c.year ASC;



-- =====================================================
-- Analysis 6.1C: Year-over-Year Growth
--
-- Business Question:
-- How does hospital admission volume change from one year to the next across 2020-2024?
--
-- Purpose:
-- Analyze year-over-year changes in admission volume to identify
-- growth, decline, and changes in hospital demand over time.
-- =====================================================

SELECT
    c.year,
    COUNT(a.admission_id) AS total_admissions,
    LAG (COUNT(a.admission_id)) OVER (
        ORDER BY
            c.year
    ) AS previous_year_admissions,
    COUNT(a.admission_id) - LAG (COUNT(a.admission_id)) OVER (
        ORDER BY
            c.year
    ) AS yoy_growth,
    ROUND(
        (
            COUNT(a.admission_id) - LAG (COUNT(a.admission_id)) OVER (
                ORDER BY
                    c.year
            )
        ) * 100.0 / (
            LAG (COUNT(a.admission_id)) OVER (
                ORDER BY
                    c.year
            )
        ),
        2
    ) AS yoy_growth_percentage
FROM
    admissions a
    JOIN calendar c ON a.admission_date = c.calendar_date
GROUP BY
    c.year;



-- =====================================================
-- Analysis 6.1D: Repeat Patient Analysis
--
-- Business Question:
-- How many patients had multiple admissions within each year from 2020-2024?
--
-- Purpose:
-- Analyze repeat admission patterns to understand recurring patient demand
-- and identify the proportion of patients with multiple admissions within each year.
-- =====================================================

WITH
    patient_data AS (
        SELECT
            c.year,
            a.patient_id,
            COUNT(a.admission_id) AS total_admissions
        FROM
            admissions a
            JOIN calendar c ON a.admission_date = c.calendar_date
        GROUP BY
            c.year,
            a.patient_id
        HAVING
            COUNT(a.admission_id) > 1
    ),
    repeat_patient_data AS (
        SELECT
            year,
            COUNT(*) AS repeat_patients
        FROM
            patient_data
        GROUP BY
            year
    ),
    yearly_patient_data AS (
        SELECT
            c.year,
            COUNT(DISTINCT a.patient_id) AS total_patients
        FROM
            admissions a
            JOIN calendar c ON a.admission_date = c.calendar_date
        GROUP BY
            c.year
    )
SELECT
    y.year,
    y.total_patients,
    r.repeat_patients,
    ROUND(r.repeat_patients * 100.0 / y.total_patients, 2) AS repeat_patients_percentage
FROM
    yearly_patient_data y
    JOIN repeat_patient_data r ON y.year = r.year
ORDER BY
    y.year;