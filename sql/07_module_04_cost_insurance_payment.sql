-- =====================================================
-- Portfolio 4: Hospital Operations & Patient Flow Analysis
-- =====================================================
-- Author: Hisham Malek
-- Database: PostgreSQL
--
-- Phase: 5 - SQL Analysis
-- Module: 4 - Cost, Insurance and Payment Analysis
--
-- Project Goal:
-- Analyze hospital operations using patient, doctor, admission, treatment, and billing data
-- to understand patient flow, hospital workload, department performance, and revenue patterns.
--
-- Analysis Goal:
-- Identify hospital revenue patterns, payment performance, insurance contribution,
-- treatment-related costs, revenue-generating services, and outstanding payment risk to
-- support financial planning, resource allocation, and hospital decision making.
-- =====================================================

-- =====================================================
-- Analysis 4.1: Hospital Financial Overview
--
-- Business Question:
-- What is the overall financial performance of the hospital?
--
-- Purpose:
-- Identify the hospital's financial baseline by measuring
-- total billing amount, insurance contribution, and patient
-- payable responsibility.
-- =====================================================
SELECT
    COUNT(*) AS total_bills,
    ROUND(SUM(total_bill), 2) AS total_revenue,
    ROUND(AVG(total_bill), 2) AS average_bill_revenue,
    ROUND(SUM(insurance_cover), 2) AS total_insurance_cover,
    ROUND(AVG(insurance_cover), 2) AS average_insurance_cover,
    ROUND(SUM(final_amount_payable), 2) AS total_final_amount_payable,
    ROUND(AVG(final_amount_payable), 2) AS average_final_amount_payable
FROM
    billing;

-- =====================================================
-- Analysis 4.2A: Revenue by Payment Mode
--
-- Business Question:
-- Which payment methods generate the highest revenue for the hospital?
--
-- Purpose:
-- Analyze revenue contribution from different payment methods
-- to undertand patient payment behaviour and identify the main 
-- channels through which hospital payments are collected
-- =====================================================
SELECT
    payment_mode,
    ROUND(SUM(total_bill)) AS total_revenue,
    COUNT(*) AS total_bills
FROM
    Billing
GROUP BY
    payment_mode
ORDER BY
    total_revenue DESC;

-- =====================================================
-- Analysis 4.2B: Payment Status Distribution
--
-- Business Question:
-- How much hospital billing is paid versus pending?
--
-- Purpose:
-- Analyze payment completion status to understand revenue collection
-- performance, identify unpaid balances, and evaluate potential cash flow risks.
-- =====================================================
SELECT
    payment_status,
    ROUND(SUM(total_bill), 2) AS total_billed_amount,
    ROUND(SUM(final_amount_payable), 2) AS total_patient_payable_amount
FROM
    billing
GROUP BY
    payment_status
ORDER BY
    total_billed_amount DESC;

-- =====================================================
-- Analysis 4.3A: Insurance Contribution
--
-- Business Question:
-- How much does insurance contribute to the hospital's total billing amount?
--
-- Purpose:
-- Understand the role of insurance coverage in reducing patient
-- financial responsibility.
-- =====================================================
SELECT
    ROUND(SUM(total_bill), 2) AS total_bill,
    ROUND(SUM(insurance_cover), 2) AS total_insurance_cover,
    ROUND(SUM(insurance_cover) * 100.0 / SUM(total_bill), 2) AS percentage_insurance_contribution
FROM
    billing;

-- =====================================================
-- Analysis 4.3B: Insurance Coverage Percentage by Admission
--
-- Business Question:
-- What percentage of each hospital bill is covered by insurance?
--
-- Purpose:
-- Understand how much financial support insurance provides for individual hospital
-- bills and identify the distribution of insurance coverage levels.
-- =====================================================
SELECT
    admission_id,
    ROUND(SUM(total_bill), 2) AS total_bill,
    ROUND(SUM(insurance_cover), 2) AS total_insurance_cover,
    ROUND(SUM(insurance_cover) / SUM(total_bill) * 100.0, 2) AS percentage_patients_insurance_cover
FROM
    billing
GROUP BY
    admission_id
ORDER BY
    percentage_patients_insurance_cover DESC;

-- =====================================================
-- Analysis 4.3C: Insurance Coverage Distribution
--
-- Business Question:
-- How are hospital bills distributed based on insurance coverage percentage?
--
-- Purpose:
-- Understand the overall pattern of insurance support across hospital bills,
-- and identify whether most patients receive low, medium, or high insurance coverage.
-- This helps the hospital understand patient financial responsibility and insurance
-- contribution patterns.
-- =====================================================
WITH
    insurance_data AS (
        SELECT
            admission_id,
            ROUND(SUM(total_bill), 2) AS total_bill,
            ROUND(SUM(insurance_cover), 2) AS total_insurance_cover,
            ROUND(SUM(insurance_cover) / SUM(total_bill) * 100.0, 2) AS percentage_patients_insurance_cover
        FROM
            billing
        GROUP BY
            admission_id
    ),
    insurance_group AS (
        SELECT
            *,
            CASE
                WHEN percentage_patients_insurance_cover <= 10 THEN '0-10%'
                WHEN percentage_patients_insurance_cover <= 20 THEN '10-20%'
                WHEN percentage_patients_insurance_cover <= 30 THEN '20-30%'
                WHEN percentage_patients_insurance_cover <= 40 THEN '30-40%'
                WHEN percentage_patients_insurance_cover <= 50 THEN '40-50%'
                WHEN percentage_patients_insurance_cover <= 60 THEN '50-60%'
                WHEN percentage_patients_insurance_cover <= 70 THEN '60-70%'
                WHEN percentage_patients_insurance_cover <= 80 THEN '70-80%'
                WHEN percentage_patients_insurance_cover <= 90 THEN '80-90%'
                ELSE '90-100%'
            END AS insurance_percentage_group
        FROM
            insurance_data
    )
SELECT
    insurance_percentage_group,
    COUNT(*) AS total_bills,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage_of_total_bills
FROM
    insurance_group
GROUP BY
    insurance_percentage_group
ORDER BY
    insurance_percentage_group;

-- =====================================================
-- Analysis 4.3D: Insurance by Department
--
-- Business Question:
-- Which departments receive the highest insurance contribution?
--
-- Purpose:
-- Understand how insurance coverage is distributed across hospital departments
-- and identify departments with higher insurance-supported billing activity.
-- =====================================================
SELECT
    dp.department_id,
    dp.department_name,
    ROUND(SUM(b.total_bill), 2) AS total_bill,
    ROUND(SUM(b.insurance_cover), 2) AS total_insurance_cover,
    ROUND(
        SUM(b.insurance_cover) / SUM(b.total_bill) * 100.0,
        2
    ) AS percentage_insurance_coverage
FROM
    billing b
    JOIN admissions a ON b.admission_id = a.admission_id
    JOIN doctors d ON a.doctor_id = d.doctor_id
    JOIN departments dp ON d.department_id = dp.department_id
GROUP BY
    dp.department_id,
    dp.department_name
ORDER BY
    total_insurance_cover DESC;

-- =====================================================
-- Analysis 4.4A: Treatment Cost Overview
--
-- Business Question:
-- How much does treatment cost contribute to total hospital billing?
--
-- Purpose:
-- Understand the overall financial impact of treatment costs and 
-- measure their contribution to total hospital billing.
-- =====================================================
SELECT
    ROUND(SUM(treatment_cost), 2) AS total_treatment_cost,
    ROUND(AVG(treatment_cost), 2) AS average_treatment_cost,
    ROUND(SUM(treatment_cost) / SUM(total_bill) * 100.0, 2) AS percentage_treatment_cost
FROM
    treatment t
    JOIN admissions a ON t.admission_id = a.admission_id
    JOIN billing b ON a.admission_id = b.admission_id;

-- =====================================================
-- Analysis 4.4B: Medicine Cost Overview
--
-- Business Question:
-- How much does medicine cost contribute to total hospital billing?
--
-- Purpose:
-- Understand the overall financial impact of medicine costs and 
-- measure their contribution to total hospital billing.
-- =====================================================
SELECT
    ROUND(SUM(medicine_cost), 2) AS total_medicine_cost,
    ROUND(AVG(medicine_cost), 2) AS average_medicine_cost,
    ROUND(SUM(medicine_cost) / SUM(total_bill) * 100.0, 2) AS percentage_medicine_cost
FROM
    treatment t
    JOIN admissions a ON t.admission_id = a.admission_id
    JOIN billing b ON a.admission_id = b.admission_id;

-- =====================================================
-- Analysis 4.4C: Lab Cost Overview
--
-- Business Question:
-- How much does laboratory cost contribute to total hospital billing?
--
-- Purpose:
-- Understand the overall financial impact of laboratory costs and 
-- measure their contribution to total hospital billing.
-- =====================================================
SELECT
    ROUND(SUM(lab_cost), 2) AS total_lab_cost,
    ROUND(AVG(lab_cost), 2) AS average_lab_cost,
    ROUND(SUM(lab_cost) / SUM(total_bill) * 100.0, 2) AS percentage_lab_cost
FROM
    treatment t
    JOIN admissions a ON t.admission_id = a.admission_id
    JOIN billing b ON a.admission_id = b.admission_id;

-- =====================================================
-- Analysis 4.4D: Cost by Department
--
-- Business Question:
-- Which hospital departments have the highest-treatment-related costs?
--
-- Purpose:
-- Understand treatment-related costs across departments and identify
-- departments with the highest overall cost.
-- =====================================================
SELECT
    dp.department_id,
    dp.department_name,
    ROUND(SUM(treatment_cost), 2) AS total_treatment_cost,
    ROUND(SUM(medicine_cost), 2) AS total_medicine_cost,
    ROUND(SUM(lab_cost), 2) AS total_lab_cost,
    ROUND(
        SUM(treatment_cost) + SUM(medicine_cost) + SUM(lab_cost),
        2
    ) AS total_treatment_related_cost
FROM
    treatment t
    JOIN admissions a ON t.admission_id = a.admission_id
    JOIN doctors d ON a.doctor_id = d.doctor_id
    JOIN departments dp ON d.department_id = dp.department_id
GROUP BY
    dp.department_id,
    dp.department_name
ORDER BY
    total_treatment_related_cost DESC;

-- =====================================================
-- Analysis 4.5A: Revenue by Room Type
--
-- Business Question:
-- Which room types generate the highest hospital revenue?
--
-- Purpose:
-- Analyze hospital revenue by room type to identify
-- the major revenue-generating room type.
-- =====================================================
SELECT
    a.room_type,
    ROUND(SUM(b.total_bill), 2) AS total_bill
FROM
    admissions a
    JOIN billing b ON a.admission_id = b.admission_id
GROUP BY
    a.room_type
ORDER BY
    total_bill DESC;

-- =====================================================
-- Analysis 4.5B: Revenue by Treatment Type
--
-- Business Question:
-- Which treatment types generate the highest hospital revenue?
--
-- Purpose:
-- Analyze hospital revenue by treatment type to identify
-- the major revenue-generating treatment categories.
-- =====================================================
SELECT
    t.treatment_type,
    ROUND(SUM(b.total_bill), 2) AS total_bill
FROM
    treatment t
    JOIN admissions a ON t.admission_id = a.admission_id
    JOIN billing b ON a.admission_id = b.admission_id
GROUP BY
    t.treatment_type
ORDER BY
    total_bill DESC;

-- =====================================================
-- Analysis 4.6A: Pending Payments
--
-- Business Question:
-- How much revenue remains outstanding from unpaid hospital bills?
--
-- Purpose:
-- Identify unpaid patient balances to evaluate potential revenue leakage,
-- improve collection monitoring, and support financial risk management.
-- =====================================================
SELECT
    ROUND(SUM(total_bill), 2) AS total_billed_amount,
    ROUND(SUM(final_amount_payable), 2) AS total_patient_payable_amount
FROM
    billing
WHERE
    payment_status = 'Pending';

-- =====================================================
-- Analysis 4.6B: Highest Outstanding Bills
--
-- Business Question:
-- Which unpaid hospital bills have the highest outstanding balances?
--
-- Purpose:
-- Identify high-value unpaid bills that may require priority collection
-- follow-up and help the hospital reduce outstanding revenue risk.
-- =====================================================
SELECT
    admission_id,
    payment_status,
    ROUND(SUM(total_bill), 2) AS total_billed_amount,
    ROUND(SUM(insurance_cover), 2) AS insurance_covered_amount,
    ROUND(SUM(final_amount_payable), 2) AS total_patient_payable_amount
FROM
    billing
WHERE
    payment_status = 'Pending'
GROUP BY
    admission_id,
    payment_status
ORDER BY
    total_patient_payable_amount DESC
LIMIT
    10;