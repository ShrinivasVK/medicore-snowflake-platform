/*
================================================================================
Project:        MediCore Health Systems - Snowflake Data Platform
Layer:          Gold (ANALYTICS_DB)
Script:         01_patients_dynamic.sql
Object:         MEDICORE_ANALYTICS_DB.DEV_CLINICAL.PATIENTS
Purpose:        Conformed patient dimension for business consumption.
                Contains PHI - masking policies applied via governance layer.
                Supports encounters, claims, readmission logic, and KPIs.
Grain:          1 row = 1 patient
Source:         MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PATIENTS
Dependencies:   Downstream joins with ENCOUNTERS, CLAIMS, de-identified layer
Author:         Data Engineering Team
Version:        1.0
================================================================================
*/

USE ROLE MEDICORE_DATA_ENGINEER;
USE WAREHOUSE MEDICORE_ETL_WH;
USE DATABASE MEDICORE_ANALYTICS_DB;
USE SCHEMA DEV_CLINICAL;

CREATE OR REPLACE DYNAMIC TABLE MEDICORE_ANALYTICS_DB.DEV_CLINICAL.PATIENTS
    TARGET_LAG = '5 minutes'
    WAREHOUSE = MEDICORE_ETL_WH
    REFRESH_MODE = AUTO
AS
SELECT
    PATIENT_ID,
    MRN,
    FIRST_NAME,
    LAST_NAME,
    DATE_OF_BIRTH,
    GENDER,
    PHONE_NUMBER,
    ZIP_CODE,
    CREATED_AT,
    LOAD_TIMESTAMP,
    RECORD_SOURCE,
    DATA_QUALITY_STATUS
FROM MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PATIENTS;
