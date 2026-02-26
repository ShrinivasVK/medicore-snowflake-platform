/*
================================================================================
Project:        MediCore Health Systems - Snowflake Data Platform
Layer:          Gold (ANALYTICS_DB)
Script:         04_lab_results_dynamic.sql
Object:         MEDICORE_ANALYTICS_DB.DEV_CLINICAL.LAB_RESULTS
Purpose:        Clinical lab results fact table for business consumption.
                Contains PHI - masking policies applied via governance layer.
                Supports abnormal lab KPIs, trend analysis, and AI features.
Grain:          1 row = 1 lab result
Source:         MEDICORE_TRANSFORM_DB.DEV_CLINICAL.LAB_RESULTS
                MEDICORE_TRANSFORM_DB.DEV_CLINICAL.ENCOUNTERS
                MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PATIENTS
Dependencies:   Executive clinical dashboards, AI feature engineering
Author:         Data Engineering Team
Version:        1.0
================================================================================
*/

USE ROLE MEDICORE_DATA_ENGINEER;
USE WAREHOUSE MEDICORE_ETL_WH;
USE DATABASE MEDICORE_ANALYTICS_DB;
USE SCHEMA DEV_CLINICAL;

CREATE OR REPLACE DYNAMIC TABLE MEDICORE_ANALYTICS_DB.DEV_CLINICAL.LAB_RESULTS
    TARGET_LAG = '5 minutes'
    WAREHOUSE = MEDICORE_ETL_WH
    REFRESH_MODE = AUTO
AS
SELECT
    lr.LAB_RESULT_ID,
    lr.ENCOUNTER_ID,
    e.PATIENT_ID,
    lr.TEST_NAME,
    lr.RESULT_VALUE,
    lr.RESULT_UNIT,
    lr.RESULT_DATE,
    lr.IS_ABNORMAL,
    p.MRN,
    p.FIRST_NAME                                    AS PATIENT_FIRST_NAME,
    p.LAST_NAME                                     AS PATIENT_LAST_NAME,
    e.ADMISSION_DATE,
    e.DISCHARGE_DATE,
    e.ENCOUNTER_TYPE,
    e.PRIMARY_ICD10_CODE,
    EXTRACT(YEAR FROM lr.RESULT_DATE)               AS RESULT_YEAR,
    DATE_TRUNC('MONTH', lr.RESULT_DATE)             AS RESULT_MONTH,
    lr.IS_ABNORMAL                                  AS IS_ABNORMAL_FLAG,
    lr.CREATED_AT,
    lr.LOAD_TIMESTAMP,
    lr.RECORD_SOURCE,
    lr.DATA_QUALITY_STATUS
FROM MEDICORE_TRANSFORM_DB.DEV_CLINICAL.LAB_RESULTS lr
LEFT JOIN MEDICORE_TRANSFORM_DB.DEV_CLINICAL.ENCOUNTERS e
    ON lr.ENCOUNTER_ID = e.ENCOUNTER_ID
LEFT JOIN MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PATIENTS p
    ON e.PATIENT_ID = p.PATIENT_ID;
