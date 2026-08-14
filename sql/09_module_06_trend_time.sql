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

-- =====================================================
-- Analysis 6.2A: Monthly Demand Patterns
--
-- Business Question:
-- Which months consistently experience higher or lower admission demand across
-- 2020-2024?
--
-- Purpose:
-- Analyze monthly admission demand across multiple years to identify consistently
-- high and low-demand months and support seasonal capacity and resource planning.
-- =====================================================
WITH
    monthly_admission_data AS (
        SELECT
            c.month_no,
            c.month,
            COUNT(a.admission_id) AS total_admissions
        FROM
            admissions a
            JOIN calendar c ON a.admission_date = c.calendar_date
        GROUP BY
            c.month_no,
            c.month,
            c.year
    )
SELECT
    month,
    ROUND(AVG(total_admissions), 2) AS average_monthly_admissions,
    MIN(total_admissions) AS lowest_admissions,
    MAX(total_admissions) AS highest_admissions
FROM
    monthly_admission_data
GROUP BY
    month_no,
    month
ORDER BY
    average_monthly_admissions DESC;

-- =====================================================
-- Analysis 6.2B: Monthly Demand Variability
--
-- Business Question:
-- Which calendar months have the most consistent or fluctuating admission 
-- demand across 2020–2024?
--
-- Purpose:
-- Analyze admission variability across calendar months to identify
-- months with more consistent or fluctuating demand and support
-- flexible staffing, bed capacity, and resource planning.
-- =====================================================
WITH
    monthly_admission_data AS (
        SELECT
            month_no,
            month,
            year,
            COUNT(a.admission_id) AS total_admissions
        FROM
            admissions a
            JOIN calendar c ON a.admission_date = c.calendar_date
        GROUP BY
            month_no,
            month,
            year
    )
SELECT
    month,
    ROUND(AVG(total_admissions), 2) AS average_monthly_admissions,
    ROUND(STDDEV (total_admissions), 2) AS variability_monthly_admissions,
    MIN(total_admissions) AS lowest_admissions,
    MAX(total_admissions) AS highest_admissions
FROM
    monthly_admission_data
GROUP BY
    month_no,
    month
ORDER BY
    variability_monthly_admissions DESC;

-- =====================================================
-- Analysis 6.3A: Weekday vs Weekend
--
-- Business Question:
-- How does weekday vs weekend admission demand change across 2020-2024?
--
-- Purpose:
-- Analyze weekday and weekend admission patterns across years to identify
-- changes in weekly demand distribution and support staffing, scheduling,
-- and resource planning.
-- =====================================================
WITH
    yearly_admission_data AS (
        SELECT
            c.year,
            CASE
                WHEN EXTRACT(
                    DOW
                    FROM
                        a.admission_date
                ) IN (0, 6) THEN 'Weekend'
                ELSE 'Weekday'
            END AS admission_period,
            COUNT(a.admission_id) AS total_admissions
        FROM
            admissions a
            JOIN calendar c ON a.admission_date = c.calendar_date
        GROUP BY
            admission_period,
            year
    ),
    yearly_weekday_weekend AS (
        SELECT
            year,
            SUM(
                CASE
                    WHEN admission_period = 'Weekday' THEN total_admissions
                    ELSE 0
                END
            ) AS weekday_admissions,
            SUM(
                CASE
                    WHEN admission_period = 'Weekend' THEN total_admissions
                    ELSE 0
                END
            ) AS weekend_admissions
        FROM
            yearly_admission_data
        GROUP BY
            year
    )
SELECT
    year,
    weekday_admissions + weekend_admissions AS total_admissions,
    weekday_admissions,
    ROUND(
        (weekday_admissions) * 100.0 / (weekday_admissions + weekend_admissions),
        2
    ) AS weekday_percentage,
    weekend_admissions,
    ROUND(
        (weekend_admissions) * 100.0 / (weekday_admissions + weekend_admissions),
        2
    ) AS weekend_percentage
FROM
    yearly_weekday_weekend
ORDER BY
    year ASC;

-- =====================================================
-- Analysis 6.4A: Revenue Over Time
--
-- Business Question:
-- How does hospital revenue change over time, and are there noticeable
-- seasonal patterns?
--
-- Purpose:
-- Analyze revenue patterns across time to identify growth, decline, and
-- potential seasonal patterns, helping the hospital understand changes
-- in financial performance and demand.
-- =====================================================
SELECT
    c.year,
    c.month_no,
    c.month,
    ROUND(SUM(b.total_bill), 2) AS total_revenue
FROM
    billing b
    JOIN admissions a ON b.admission_id = a.admission_id
    JOIN calendar c ON a.admission_date = c.calendar_date
GROUP BY
    c.year,
    c.month_no,
    c.month
ORDER BY
    c.year,
    c.month_no;

-- =====================================================
-- Analysis 6.4B: Revenue Growth
--
-- Business Question:
-- How has hospital revenue changed from year to year?
--
-- Purpose:
-- Analyze annual revenue growth or decline to identify changes
-- in the hospital's financial performance over the 2020-2024 period.
-- =====================================================
WITH
    year_revenue AS (
        SELECT
            c.year,
            SUM(b.total_bill) AS total_revenue
        FROM
            billing b
            JOIN admissions a ON b.admission_id = a.admission_id
            JOIN calendar c ON a.admission_date = c.calendar_date
        GROUP BY
            c.year
    ),
    previous_year_revenue AS (
        SELECT
            year,
            total_revenue,
            LAG (total_revenue) OVER (
                ORDER BY
                    year
            ) AS previous_revenue
        FROM
            year_revenue
    )
SELECT
    year,
    total_revenue,
    previous_revenue,
    ROUND(
        (total_revenue - previous_revenue) * 100.0 / previous_revenue,
        2
    ) AS yoy_growth_percentage
FROM
    previous_year_revenue
ORDER BY
    year ASC;

-- =====================================================
-- Analysis 6.5A: Long-Term Admission Demand Trend
--
-- Business Question:
-- How has monthly hospital admission demand evolved over the 2020-2024 period,
-- and is there an underlying long-term trend?
--
-- Purpose:
-- Analyze the relationship between time and monthly admission volume to identify
-- whether hospital demand shows an overall upward, downward, or relatively stable
-- long-term trend.
-- =====================================================
WITH
    monthly_admission_data AS (
        SELECT
            c.year,
            c.month_no,
            c.month,
            COUNT(a.admission_id) AS total_admissions
        FROM
            admissions a
            JOIN calendar c ON a.admission_date = c.calendar_date
        GROUP BY
            c.month_no,
            c.month,
            c.year
    ),
    month_row_number AS (
        SELECT
            year,
            month_no,
            month,
            ROW_NUMBER() OVER (
                ORDER BY
                    year,
                    month_no
            ) AS month_index,
            total_admissions
        FROM
            monthly_admission_data
    )
SELECT
    CORR(month_index, total_admissions) AS long_term_trend_correlation
FROM
    month_row_number;

-- =====================================================
-- Analysis 6.5B: Future Admission Forecast
--
-- Business Question:
-- Based on the historical admission trend from 2020-2024, what is the projected
-- monthly admission demand for the next 12 months?
--
-- Purpose:
-- Use a linear regression trend model based on historical monthly admission volume
-- to estimate future admission demand for 2025.
-- =====================================================
WITH
	monthly_admission_data AS (
		SELECT
			c.year,
			c.month_no,
			c.month,
			ROW_NUMBER() OVER(
				ORDER BY year, month_no
			) AS month_index,
			COUNT(a.admission_id) AS total_admissions
		FROM
			admissions a
			JOIN calendar c ON a.admission_date = c.calendar_date
		GROUP BY 
			c.year,
			c.month_no,
			c.month
	),
	trend_model AS (
		SELECT
			REGR_SLOPE(total_admissions, month_index) AS trend_slope,
			REGR_INTERCEPT(total_admissions, month_index) AS trend_intercept
		FROM monthly_admission_data
	),
	future_months AS (
		SELECT
			GENERATE_SERIES(
				DATE '2025-01-01',
				DATE '2025-12-01',
				INTERVAL '1 month'
			) AS future_date
	),
	forecast_data AS (
		SELECT
			fm.future_date,
			ROW_NUMBER() OVER (ORDER BY fm.future_date) + 60 AS month_index,
			tm.trend_slope,
			tm.trend_intercept,
			tm.trend_intercept + (tm.trend_slope * (ROW_NUMBER() OVER (ORDER BY fm.future_date) + 60)) AS forecast_admissions
		FROM future_months fm
		CROSS JOIN trend_model tm
	)
SELECT
	EXTRACT(YEAR FROM future_date) AS year,
	EXTRACT(MONTH FROM future_date) AS month_no,
	TO_CHAR(future_date, 'Month') AS month,
	month_index,
	ROUND(
		forecast_admissions::numeric,
        2
		) AS forecast_admissions
FROM forecast_data
ORDER BY year ASC;