-- =====================================================
 -- Portfolio 4: Hospital Operations & Patient Flow Analysis
 -- =====================================================
 -- Author: Hisham Malek
 -- Database: PostgreSQL
 --
 -- Phase: 5 - SQL Analysis
 -- Module: 5 - Doctor Performance Analysis
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
 -- Analysis 5.1A: Doctor Workload Distribution & Staffing Pressure
 --
 -- Business Question:
 -- Are doctor workloads evenly distributed, or are some doctors carrying 
 -- significantly higher workloads that may indicate staffing pressure?
 --
 -- Purpose:
 -- Analyze doctor admission activity patterns to understand clinical demand,
 -- identify doctors with higher patient volume, and support staffing decisions.
-- =====================================================

WITH admissions_patients_data AS (
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
	total_admissions,

	ROUND(
		AVG(total_admissions) OVER (), 2
	) AS average_doctor_admissions,

	ROUND(
		total_admissions - AVG(total_admissions) OVER (), 2
	) AS difference_from_average,

	ROUND(
		(
		(total_admissions - AVG(total_admissions) OVER())
		/ AVG(total_admissions) OVER ()
		* 100
		), 2
	) AS workload_percentage_difference
FROM admissions_patients_data
ORDER BY workload_percentage_difference DESC
LIMIT 10;



-- =====================================================
 -- Analysis 5.1B: Doctor Patient Load
 --
 -- Business Question:
 -- Which doctors handle the highest number of unique patients?
 --
 -- Purpose:
 -- Analyze doctor admission activity patterns to understand clinical demand,
 -- identify doctors with higher patient volume, and support staffing decisions.
-- =====================================================

WITH doctor_patient_load AS (
	SELECT
		d.doctor_id,
		d.doctor_name,
		dp.department_name,
		COUNT(DISTINCT a.patient_id) AS total_patients
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
		ORDER BY total_patients DESC
	) AS patient_load_rank,
	doctor_id,
	doctor_name,
	department_name,
	total_patients
FROM doctor_patient_load
ORDER BY patient_load_rank
LIMIT 10;



-- =====================================================
 -- Analysis 5.2A: Most Frequent Treatment Type by Doctor
 --
 -- Business Question:
 -- Which treatment types are most frequently handled by each doctor?
 --
 -- Purpose:
 -- Analyze the treatment mix handled by each doctor to identify
 -- their most frequently performed treatment type and understand
 -- the distribution of their clinical activity.
-- =====================================================

WITH doctor_data AS (
	SELECT
		d.doctor_id,
		d.doctor_name,
		dp.department_name,
		t.treatment_type,
		COUNT(t.admission_id) AS treatments
	FROM treatment t
	JOIN admissions a
		ON t.admission_id = a.admission_id
	JOIN doctors d
		ON a.doctor_id = d.doctor_id
	JOIN departments dp
		ON d.department_id = dp.department_id
	GROUP BY 
		d.doctor_id,
		d.doctor_name,
		dp.department_name,
		t.treatment_type
),

ranked_doctors AS (
	SELECT
		RANK() OVER (
			PARTITION BY doctor_id
			ORDER BY treatments DESC
		) AS treatment_type_rank,
		doctor_id,
		doctor_name,
		department_name,
		treatment_type,
		treatments,

		ROUND(
			treatments * 100.0 / SUM(treatments) OVER (PARTITION BY doctor_id), 2
		) AS treatment_percentage
	FROM doctor_data
)

SELECT
	doctor_id,
	doctor_name,
	department_name,
	treatment_type,
	treatments,
	treatment_percentage
FROM ranked_doctors
WHERE treatment_type_rank = 1
ORDER BY treatment_percentage DESC;



-- =====================================================
 -- Analysis 5.2B: Room Usage Variation Across Doctors
 --
 -- Business Question:
 -- How are hospital admissions distributed across room types for each doctor? 
 --
 -- Purpose:
 -- Analyze room usage patterns by doctor to understand admission volume across
 -- General, Private, and ICU rooms and support staffing and room-resource planning.
-- =====================================================

WITH doctor_data AS (
	SELECT
		d.doctor_id,
		d.doctor_name,
		dp.department_name,
		a.room_type,
		COUNT(a.admission_id) AS total_admissions
	FROM admissions a
	JOIN doctors d
		ON a.doctor_id = d.doctor_id
	JOIN departments dp
		ON d.department_id = dp.department_id
	GROUP BY
		d.doctor_id,
		d.doctor_name,
		dp.department_name,
		a.room_type
)
SELECT
	doctor_id,
	doctor_name,
	department_name,

	SUM(
		CASE
        	WHEN room_type = 'General'
            THEN total_admissions
			ELSE 0
		END
	) AS general_admissions,

	SUM(
		CASE
        	WHEN room_type = 'Private'
            THEN total_admissions
			ELSE 0
		END
	) AS private_admissions,

	SUM(
		CASE
        	WHEN room_type = 'ICU'
            THEN total_admissions
			ELSE 0
		END
	) AS icu_admissions
FROM doctor_data
GROUP BY 
	doctor_id,
	doctor_name,
	department_name
ORDER BY general_admissions DESC;