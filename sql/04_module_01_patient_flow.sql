-- =====================================================
 -- Portfolio 4: Hospital Operations & Patient Flow Analysis
 -- =====================================================
 -- Author: Hisham Malek
 -- Database: PostgreSQL
 --
 -- Phase: 5 - SQL Analysis
 -- Module: 1 - Patient Flow Analysis
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
 -- Analysis 1.1A: Total Registered Patients
 --
 -- Business Question:
 -- How many unique patients are registered in the hospital system?
 --
 -- Purpose:
 -- Establish the total patient population before analyzing admission activity.
-- =====================================================

SELECT
    COUNT(*) AS total_patients
FROM patients;



-- =====================================================
 -- Analysis 1.1B: Total Admissions
 --
 -- Business Question:
 -- How many hospital admissions events occurred during the analysis period?
 --
 -- Purpose:
 -- Measure overall hospital activity and operational workload.
-- =====================================================

SELECT
    COUNT(*) AS total_admissions
FROM admissions;



-- =====================================================
 -- Analysis 1.1C: Average Admissions per Admitted Patient
 --
 -- Business Question:
 -- How many admissions does each admitted patient have on average?
 --
 -- Purpose:
 -- Understand patient activity level and hospital utilization.
-- =====================================================

SELECT
    ROUND(
        COUNT(a.admission_id) * 1.0 / COUNT(DISTINCT p.patient_id), 2
    ) AS avg_admissions_per_admitted_patient
FROM patients p
JOIN admissions a
    ON p.patient_id = a.patient_id;



-- =====================================================
 -- Analysis 1.1D: Patient Admission Conversion Rate
 --
 -- Business Question:
 -- What percentage of registered patients have been admitted to the hospital?
 --
 -- Purpose:
 -- Measure patient utilization by identifying the proportion
 -- of registered patients who required hospital admission.
-- =====================================================

SELECT
    COUNT(DISTINCT a.patient_id) AS admitted_patients,
    COUNT(DISTINCT p.patient_id) AS total_registered_patients,
    ROUND(
        COUNT(DISTINCT a.patient_id) * 100.0 / COUNT(DISTINCT p.patient_id), 2
    ) AS patient_admission_rate_percentage
FROM patients p
LEFT JOIN admissions a
    ON p.patient_id = a.patient_id;



-- =====================================================
 -- Analysis 1.1E: Repeat Admission Rate
 --
 -- Business Question:
 -- What percentage of admitted patients have multiple admissions?
 --
 -- Purpose:
 -- Identify repeat hospital utilization patterns to understand
 -- returning patient demand and support healthcare resource planning.
-- =====================================================

WITH patient_admission_count AS (
    SELECT
        patient_id,
        COUNT(admission_id) AS admission_count
    FROM admissions
    GROUP BY patient_id
)

SELECT
    COUNT(*) FILTER (
        WHERE admission_count > 1
    ) AS repeat_admitted_patients,

    COUNT(*) FILTER (
        WHERE admission_count = 1
    ) AS single_admission_patients,

    COUNT(*) AS total_admitted_patients,

    ROUND(
        COUNT(*) FILTER (
            WHERE admission_count > 1
        ) * 100.0 / COUNT(*), 2
    ) AS repeat_admission_rate_percentage
FROM patient_admission_count;



-- =====================================================
 -- Analysis 1.1F: High Admission Frequency Patients
 --
 -- Business Question:
 -- Which patients have the highest number of admissions?
 --
 -- Purpose:
 -- Identify high admission frequency patterns to understand repeat 
 -- hospital utilization and support resource planning.
-- =====================================================

WITH patient_summary AS (
    SELECT
        p.patient_id,
        p.gender,
        p.date_of_birth,
        p.blood_group,
        p.city,
        MIN(a.admission_date) AS first_admission_date,
        COUNT(a.admission_id) AS total_admissions
    FROM patients p
    JOIN admissions a
        ON p.patient_id = a.patient_id
    GROUP BY
        p.patient_id,
        p.gender,
        p.date_of_birth,
        p.blood_group,
        p.city
)

SELECT
    patient_id,
    gender,

    CASE
        WHEN EXTRACT(YEAR FROM AGE(first_admission_date, date_of_birth)) BETWEEN 0 AND 17 
            THEN '0-17'

        WHEN EXTRACT(YEAR FROM AGE(first_admission_date, date_of_birth)) BETWEEN 18 AND 35 
            THEN '18-35'

        WHEN EXTRACT(YEAR FROM AGE(first_admission_date, date_of_birth)) BETWEEN 36 AND 50 
            THEN '36-50'
            
        WHEN EXTRACT(YEAR FROM AGE(first_admission_date, date_of_birth)) BETWEEN 51 AND 65 
            THEN '51-65'
        ELSE '65+'
    END AS age_group,

    blood_group,
    city,
    total_admissions
FROM patient_summary
ORDER BY total_admissions DESC
LIMIT 10;



-- =====================================================
 -- Analysis 1.2A: Monthly Admission Trend
 --
 -- Business Question:
 -- How many patient admissions occur each month?
 --
 -- Purpose:
 -- Understand patient demand, busiest months, staffing and hospital capacity planning.
-- =====================================================

SELECT
    c.year,
	c.month_no,
    c.month,
    COUNT(*) AS monthly_admissions
FROM admissions a
JOIN calendar c
    ON a.admission_date = c.calendar_date
GROUP BY 
    c.year, c.month_no, c.month
ORDER BY
    c.year, c.month_no;



-- =====================================================
 -- Analysis 1.2B: Top 5 Busiest Admission Months
 --
 -- Business Question:
 -- Which months have the highest number of patient admissions?
 --
 -- Purpose:
 -- Identify peak demand periods to support staff scheduling, room capacity planning, 
 -- resource allocation and operational preparation.
-- =====================================================

SELECT
    CONCAT(c.month, ' ', c.year) AS admission_month,
    COUNT(*) AS monthly_admissions
FROM admissions a
JOIN calendar c
    ON a.admission_date = c.calendar_date
GROUP BY c.year, c.month_no, c.month
ORDER BY monthly_admissions DESC
LIMIT 5;



-- =====================================================
 -- Analysis 1.3A: Room Type Distribution
 --
 -- Business Question:
 -- Which room types are most frequently used by admitted patients?
 --
 -- Purpose:
 -- Understand hospital capacity demand and resource utilization.
-- =====================================================

SELECT
    room_type,
    COUNT(*) AS room_type_admissions
FROM admissions
GROUP BY room_type
ORDER BY room_type_admissions DESC;



-- =====================================================
 -- Analysis 1.3B: Room Type Utilization Percentage
 --
 -- Business Question:
 -- What percentage of admissions belongs to each room type?
 --
 -- Purpose:
 -- Understand hospital capacity demand and resource utilization.
-- =====================================================

SELECT
    room_type,
    COUNT(*) AS room_type_admissions,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2
    ) AS room_type_percentage
FROM admissions
GROUP BY room_type
ORDER BY room_type_percentage DESC;



-- =====================================================
 -- Analysis 1.4A: Admission Pattern by Day
 --
 -- Business Question:
 -- Which days of the week have the highest admission activity?
 --
 -- Purpose:
 -- Analyze patient admission patterns across weekdays to identify peak hospital demand.
-- =====================================================

SELECT
    EXTRACT(DOW FROM admission_date) AS day_number,
	CASE
    	WHEN EXTRACT(DOW FROM admission_date) = 0 THEN 'Sunday'
		WHEN EXTRACT(DOW FROM admission_date) = 1 THEN 'Monday'
		WHEN EXTRACT(DOW FROM admission_date) = 2 THEN 'Tuesday'
		WHEN EXTRACT(DOW FROM admission_date) = 3 THEN 'Wednesday'
		WHEN EXTRACT(DOW FROM admission_date) = 4 THEN 'Thursday'
		WHEN EXTRACT(DOW FROM admission_date) = 5 THEN 'Friday'
		WHEN EXTRACT(DOW FROM admission_date) = 6 THEN 'Saturday'
	END AS admission_day,
	COUNT(*) AS total_admissions
FROM admissions
GROUP BY day_number, admission_day
ORDER BY total_admissions DESC;



-- =====================================================
 -- Analysis 1.4B: Weekday vs Weekend Admission Patterns
 --
 -- Business Question:
 -- Are admissions higher during weekdays or weekends?
 --
 -- Purpose:
 -- Understand whether hospital demand differs between weekdays and weekends.
-- =====================================================

SELECT
    CASE
        WHEN EXTRACT(DOW FROM admission_date) IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS admission_period,
    COUNT(*) AS total_admissions,
	ROUND(
		COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2
	) AS admissions_percentage
FROM admissions
GROUP BY admission_period
ORDER BY total_admissions DESC;



-- =====================================================
 -- Analysis 1.5A: Yearly Admission Trend
 --
 -- Business Question:
 -- Is hospital admission demand increasing or decreasing over the years?
 --
 -- Purpose:
 -- Analyze long-term admission patterns to understand hospital growth,
 -- demand changes, capacity planning needs and future resource requirements.
-- =====================================================

SELECT
    EXTRACT(YEAR FROM admission_date) AS admission_year,
	COUNT(*) AS total_admissions
FROM admissions
GROUP BY admission_year
ORDER BY admission_year;



-- =====================================================
 -- Analysis 1.5B: Year-over-Year Admission Growth
 --
 -- Business Question:
 -- Did admissions increase or decrease compared with the previous year?
 --
 -- Purpose:
 -- Analyze long-term admission patterns to understand hospital growth,
 -- demand changes, capacity planning needs and future resource requirements.
-- =====================================================

WITH yearly_admissions AS (
    SELECT
        EXTRACT(YEAR FROM admission_date) AS admission_year,
        COUNT(*) AS total_admissions
    FROM admissions
    GROUP BY admission_year
),

yearly_growth AS(
    SELECT
        admission_year,
        total_admissions,

        LAG(total_admissions) OVER (
            ORDER BY admission_year
        ) AS previous_year_admissions
    FROM yearly_admissions
)

SELECT
    admission_year,
    total_admissions,
    previous_year_admissions,
    ROUND(
        (total_admissions - previous_year_admissions) * 100.0
        / previous_year_admissions, 2
    ) AS yoy_growth_percentage

FROM yearly_growth;