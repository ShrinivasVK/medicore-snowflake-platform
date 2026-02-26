/*
================================================================================
Project:        MediCore Health Systems - Snowflake Data Platform
Layer:          Gold (ANALYTICS_DB)
Script:         03_encounters_dynamic.sql
Object:         MEDICORE_ANALYTICS_DB.DEV_CLINICAL.ENCOUNTERS
Purpose:        Central clinical fact table for business consumption.
                Contains PHI - masking policies applied via governance layer.
                Supports readmission, LOS, revenue, and workload KPIs.
Grain:          1 row = 1 encounter
Source:         MEDICORE_TRANSFORM_DB.DEV_CLINICAL.ENCOUNTERS
                MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PATIENTS
                MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PROVIDERS
                MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_DEPARTMENTS
                MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_ICD10_CODES
Dependencies:   Executive KPIs, readmission logic, AI feature engineering
Author:         Data Engineering Team
Version:        1.0
================================================================================
*/

USE ROLE MEDICORE_DATA_ENGINEER;
USE WAREHOUSE MEDICORE_ETL_WH;
USE DATABASE MEDICORE_ANALYTICS_DB;
USE SCHEMA DEV_CLINICAL;

CREATE OR REPLACE DYNAMIC TABLE MEDICORE_ANALYTICS_DB.DEV_CLINICAL.ENCOUNTERS
    TARGET_LAG = '5 minutes'
    WAREHOUSE = MEDICORE_ETL_WH
    REFRESH_MODE = AUTO
AS
SELECT
    e.ENCOUNTER_ID,
    e.PATIENT_ID,
    e.PROVIDER_ID,
    e.DEPARTMENT_ID,
    e.ADMISSION_DATE,
    e.DISCHARGE_DATE,
    e.ENCOUNTER_TYPE,
    e.PRIMARY_ICD10_CODE,
    p.MRN,
    p.FIRST_NAME                                                AS PATIENT_FIRST_NAME,
    p.LAST_NAME                                                 AS PATIENT_LAST_NAME,
    p.DATE_OF_BIRTH                                             AS PATIENT_DATE_OF_BIRTH,
    p.GENDER                                                    AS PATIENT_GENDER,
    pr.PROVIDER_NAME,
    pr.SPECIALTY                                                AS PROVIDER_SPECIALTY,
    d.DEPARTMENT_NAME,
    d.FACILITY_CODE,
    icd.ICD10_DESCRIPTION                                       AS PRIMARY_DIAGNOSIS_DESCRIPTION,
    icd.ICD10_CATEGORY                                          AS PRIMARY_DIAGNOSIS_CATEGORY,
    icd.IS_CHRONIC                                              AS PRIMARY_DIAGNOSIS_IS_CHRONIC,
    EXTRACT(YEAR FROM e.ADMISSION_DATE)                         AS ENCOUNTER_YEAR,
    DATE_TRUNC('MONTH', e.ADMISSION_DATE)                       AS ENCOUNTER_MONTH,
    DATEDIFF('DAY', e.ADMISSION_DATE, e.DISCHARGE_DATE)         AS LENGTH_OF_STAY_DAYS,
    CASE WHEN e.ENCOUNTER_TYPE = 'INPATIENT' THEN TRUE ELSE FALSE END AS IS_INPATIENT_FLAG,
    CASE WHEN e.ENCOUNTER_TYPE = 'OUTPATIENT' THEN TRUE ELSE FALSE END AS IS_OUTPATIENT_FLAG,
    EXTRACT(YEAR FROM e.DISCHARGE_DATE)                         AS DISCHARGE_YEAR,
    DATE_TRUNC('MONTH', e.DISCHARGE_DATE)                       AS DISCHARGE_MONTH,
    e.CREATED_AT,
    e.LOAD_TIMESTAMP,
    e.RECORD_SOURCE,
    e.DATA_QUALITY_STATUS
FROM MEDICORE_TRANSFORM_DB.DEV_CLINICAL.ENCOUNTERS e
LEFT JOIN MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PATIENTS p
    ON e.PATIENT_ID = p.PATIENT_ID
LEFT JOIN MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PROVIDERS pr
    ON e.PROVIDER_ID = pr.PROVIDER_ID
LEFT JOIN MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_DEPARTMENTS d
    ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
LEFT JOIN MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_ICD10_CODES icd
    ON e.PRIMARY_ICD10_CODE = icd.ICD10_CODE;
