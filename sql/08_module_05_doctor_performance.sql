-- =====================================================
 -- Portfolio 4: Hospital Operations & Patient Flow Analysis
 -- =====================================================
 -- Author: Hisham Malek
 -- Database: PostgreSQL
 --
 -- Phase: 5 - SQL Analysis
 -- Module: 5 - Cost, Insurance and Payment Analysis
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
 -- Analysis 5.1: Doctor Admission Workload
 --
 -- Business Question:
 -- Which doctors handle the highest number of patient admissions?
 --
 -- Purpose:
 -- Analyze doctor admission activity patterns to understand clinical demand,
 -- identify doctors with higher patient volume, and support staffing decisions.
-- =====================================================

WITH doctor_workload AS (
	SELECT
	    d.doctor_id,
	    d.doctor_name,
	    dp.department_name,
	    COUNT(a.admission_id) AS total_admissions
	FROM admissions a
	JOIN doctors d
	    ON a.doctor_id = d.doctor_id
	JOIN departments dp
	    ON d.department_id = dp.department_id
	GROUP BY 
	    d.doctor_id,
	    d.doctor_name,
	    dp.department_name
)

SELECT
	RANK() OVER (
		ORDER BY total_admissions DESC
	) AS workload_rank,
	doctor_id,
	doctor_name,
	department_name,
	total_admissions
FROM doctor_workload
ORDER BY workload_rank
LIMIT 10;