/*
================================================================================
Project:        MediCore Health Systems - Snowflake Data Platform
Layer:          Gold (ANALYTICS_DB)
Script:         01_claims_dynamic.sql
Object:         MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIMS
Purpose:        Central billing fact table for business consumption.
                Contains PHI and financial identifiers - masking policies
                applied via governance layer.
                Supports revenue KPIs, denial analysis, and payer mix reporting.
Grain:          1 row = 1 claim
Source:         MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIMS
                MEDICORE_TRANSFORM_DB.DEV_CLINICAL.ENCOUNTERS
                MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PATIENTS
Dependencies:   Executive revenue summary, denial KPIs, AI feature engineering
Author:         Data Engineering Team
Version:        1.0
================================================================================
*/

USE ROLE MEDICORE_DATA_ENGINEER;
USE WAREHOUSE MEDICORE_ETL_WH;
USE DATABASE MEDICORE_ANALYTICS_DB;
USE SCHEMA DEV_BILLING;

CREATE OR REPLACE DYNAMIC TABLE MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIMS
    TARGET_LAG = '5 minutes'
    WAREHOUSE = MEDICORE_ETL_WH
    REFRESH_MODE = AUTO
AS
SELECT
    c.CLAIM_ID,
    c.ENCOUNTER_ID,
    c.PATIENT_ID,
    c.CLAIM_BILLED_AMOUNT,
    c.CLAIM_STATUS,
    c.PAYER_TYPE,
    c.SERVICE_DATE,
    p.MRN,
    p.FIRST_NAME                                                    AS PATIENT_FIRST_NAME,
    p.LAST_NAME                                                     AS PATIENT_LAST_NAME,
    e.ADMISSION_DATE,
    e.DISCHARGE_DATE,
    e.ENCOUNTER_TYPE,
    e.PRIMARY_ICD10_CODE,
    e.DEPARTMENT_ID,
    EXTRACT(YEAR FROM c.SERVICE_DATE)                               AS CLAIM_YEAR,
    DATE_TRUNC('MONTH', c.SERVICE_DATE)                             AS CLAIM_MONTH,
    CASE WHEN c.CLAIM_STATUS = 'DENIED' THEN TRUE ELSE FALSE END    AS IS_DENIED_FLAG,
    c.DENIAL_FLAG                                                   AS DENIAL_FLAG_NUMERIC,
    CASE
        WHEN c.CLAIM_BILLED_AMOUNT < 1000 THEN 'SMALL'
        WHEN c.CLAIM_BILLED_AMOUNT < 10000 THEN 'MEDIUM'
        WHEN c.CLAIM_BILLED_AMOUNT < 50000 THEN 'LARGE'
        ELSE 'VERY_LARGE'
    END                                                             AS REVENUE_BUCKET,
    c.RAW_CREATED_AT,
    c.LOAD_TIMESTAMP,
    c.RECORD_SOURCE,
    c.DATA_QUALITY_STATUS
FROM MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIMS c
LEFT JOIN MEDICORE_TRANSFORM_DB.DEV_CLINICAL.ENCOUNTERS e
    ON c.ENCOUNTER_ID = e.ENCOUNTER_ID
LEFT JOIN MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PATIENTS p
    ON c.PATIENT_ID = p.PATIENT_ID;
