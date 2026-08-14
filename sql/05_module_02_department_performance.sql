-- =====================================================
-- Portfolio 4: Hospital Operations & Patient Flow Analysis
-- =====================================================
-- Author: Hisham Malek
-- Database: PostgreSQL
--
-- Phase: 5 - SQL Analysis
-- Module: 2 - Department Performance
--
-- Project Goal:
-- Analyze hospital operations using patient, doctor, admission, treatment, and billing data
-- to understand patient flow, hospital workload, department performance, and revenue patterns.
--
-- Analysis Goal:
-- Identify department workload, activity patterns, cost performance, and revenue 
-- contribution to support operational planning, resource allocation, and hospital decision 
-- making.
-- =====================================================

-- =====================================================
-- Analysis 2.1: Total Admissions by Department
--
-- Business Question:
-- Which departments handle the highest number of patient admissions?
--
-- Purpose:
-- Identify departments with the highest patient workload,
-- understand operational demand, and support future staffing
-- and resource planning decisions.
-- =====================================================
SELECT
    dp.department_id,
    dp.department_name,
    COUNT(*) AS total_admissions,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS department_admissions_percentage
FROM
    admissions a
    JOIN doctors d ON a.doctor_id = d.doctor_id
    JOIN departments dp ON d.department_id = dp.department_id
GROUP BY
    dp.department_id,
    dp.department_name
ORDER BY
    total_admissions DESC;

-- =====================================================
-- Analysis 2.2A: Yearly Admissions by Department
--
-- Business Question:
-- How does patient admission demand change across departments over the years?
--
-- Purpose:
-- Analyze yearly admission trends by department to identify
-- changes in patient demand, growth patterns, and operational planning needs.
-- =====================================================
SELECT
    dp.department_id,
    dp.department_name,
    c.year AS admission_year,
    COUNT(*) AS yearly_admissions
FROM
    admissions a
    JOIN doctors d ON a.doctor_id = d.doctor_id
    JOIN departments dp ON d.department_id = dp.department_id
    JOIN calendar c ON a.admission_date = c.calendar_date
GROUP BY
    dp.department_id,
    dp.department_name,
    c.year
ORDER BY
    dp.department_id,
    admission_year;

-- =====================================================
-- Analysis 2.2B: Monthly Admissions by Department
--
-- Business Question:
-- Which months show higher patient admission demand across departments?
--
-- Purpose:
-- Analyze monthly admission trends by department to identify
-- seasonal demand, peak periods, and operational planning needs.
-- =====================================================
SELECT
    dp.department_id,
    dp.department_name,
    c.year AS admission_year,
    c.month_no AS admission_month_no,
    c.month AS admission_month,
    COUNT(*) AS monthly_admissions
FROM
    admissions a
    JOIN doctors d ON a.doctor_id = d.doctor_id
    JOIN departments dp ON d.department_id = dp.department_id
    JOIN calendar c ON a.admission_date = c.calendar_date
GROUP BY
    dp.department_id,
    dp.department_name,
    c.year,
    c.month_no,
    c.month
ORDER BY
    dp.department_id,
    admission_year,
    admission_month_no;

-- =====================================================
-- Analysis 2.3A: Weekday vs Weekend Admissions by Department
--
-- Business Question:
-- Do departments experience different admission patterns between weekdays and weekends?
--
-- Purpose:
-- Analyze weekday and weekend admission distribution by department to understand
-- operational demand patterns and support staffing and scheduling decisions.
-- =====================================================
SELECT
    dp.department_id,
    dp.department_name,
    CASE
        WHEN EXTRACT(
            DOW
            FROM
                a.admission_date
        ) IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS admission_period,
    COUNT(*) AS total_admissions
FROM
    admissions a
    JOIN doctors d ON a.doctor_id = d.doctor_id
    JOIN departments dp ON d.department_id = dp.department_id
GROUP BY
    dp.department_id,
    dp.department_name,
    admission_period
ORDER BY
    dp.department_id,
    total_admissions DESC;

-- =====================================================
-- Analysis 2.3B: Busiest Admission Day by Department
--
-- Business Question:
-- Which day of the week has the highest admission volume for each department?
--
-- Purpose:
-- Identify department-specific peak admission days to support weekly staffing schedules,
-- operational preparation, and resource allocation.
-- =====================================================
WITH
    daily_admissions AS (
        SELECT
            dp.department_id,
            dp.department_name,
            TRIM(TO_CHAR (a.admission_date, 'Day')) AS admission_day,
            COUNT(*) AS total_admissions
        FROM
            admissions a
            JOIN doctors d ON a.doctor_id = d.doctor_id
            JOIN departments dp ON d.department_id = dp.department_id
        GROUP BY
            dp.department_id,
            dp.department_name,
            admission_day
    ),
    ranked_days AS (
        SELECT
            department_id,
            department_name,
            admission_day,
            total_admissions,
            RANK() OVER (
                PARTITION BY
                    department_id
                ORDER BY
                    total_admissions DESC
            ) AS day_rank
        FROM
            daily_admissions
    )
SELECT
    *
FROM
    ranked_days
WHERE
    day_rank = 1;

-- =====================================================
-- Analysis 2.3C: Weekly Admission Distribution by Department
--
-- Business Question:
-- How are admissions distributed across days of the week for each department?
--
-- Purpose:
-- Identify department-specific peak admission days to support weekly staffing schedules,
-- operational preparation, and resource allocation.
-- =====================================================
SELECT
    dp.department_id,
    dp.department_name,
    TRIM(TO_CHAR (a.admission_date, 'Day')) AS admission_day,
    COUNT(*) AS total_admissions
FROM
    admissions a
    JOIN doctors d ON a.doctor_id = d.doctor_id
    JOIN departments dp ON d.department_id = dp.department_id
GROUP BY
    dp.department_id,
    dp.department_name,
    admission_day
ORDER BY
    dp.department_id,
    total_admissions DESC;

-- =====================================================
-- Analysis 2.4A: Treatment Activity Breakdown by Department
--
-- Business Question:
-- Which types of treatments contribute to workload across each department?
--
-- Purpose:
-- Analyze treatment category distribution across departments to understand clinical
-- activity patterns and support operational planning and resource allocation.
-- =====================================================
SELECT
    dp.department_id,
    dp.department_name,
    t.treatment_type,
    COUNT(*) AS total_treatments
FROM
    treatment t
    JOIN admissions a ON t.admission_id = a.admission_id
    JOIN doctors d ON a.doctor_id = d.doctor_id
    JOIN departments dp ON d.department_id = dp.department_id
GROUP BY
    dp.department_id,
    dp.department_name,
    t.treatment_type
ORDER BY
    dp.department_id,
    total_treatments DESC;

-- =====================================================
-- Analysis 2.4B: Resource Cost Breakdown by Department
--
-- Business Question:
-- Which departments generate the highest treatment-related costs?
--
-- Purpose:
-- Analyze treatment, medicine, and laboratory costs by department
-- to understand resource demand and operational cost patterns.
-- =====================================================
SELECT
    dp.department_id,
    dp.department_name,
    SUM(t.treatment_cost) AS total_treatment_cost,
    SUM(t.medicine_cost) AS total_medicine_cost,
    SUM(t.lab_cost) AS total_lab_cost,
    SUM(
        COALESCE(t.treatment_cost, 0) + COALESCE(t.medicine_cost, 0) + COALESCE(t.lab_cost, 0)
    ) AS total_resource_cost
FROM
    treatment t
    JOIN admissions a ON t.admission_id = a.admission_id
    JOIN doctors d ON a.doctor_id = d.doctor_id
    JOIN departments dp ON d.department_id = dp.department_id
GROUP BY
    dp.department_id,
    dp.department_name
ORDER BY
    total_resource_cost DESC;

-- =====================================================
-- Analysis 2.5A: Revenue Performance by Department
--
-- Business Question:
-- Which departments generate the highest revenue for the hospital?
--
-- Purpose:
-- Analyze department revenue contribution to understand
-- financial performance and support budgeting decisions.
-- =====================================================
SELECT
    dp.department_id,
    dp.department_name,
    SUM(b.total_bill) AS total_revenue
FROM
    billing b
    JOIN admissions a ON b.admission_id = a.admission_id
    JOIN doctors d ON a.doctor_id = d.doctor_id
    JOIN departments dp ON d.department_id = dp.department_id
GROUP BY
    dp.department_id,
    dp.department_name
ORDER BY
    total_revenue DESC;