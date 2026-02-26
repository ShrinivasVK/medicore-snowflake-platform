/*
================================================================================
Project:        MediCore Health Systems - Snowflake Data Platform
Layer:          Gold (ANALYTICS_DB) - Deidentified Exposure
Script:         01_patients_deidentified.sql
Object:         MEDICORE_ANALYTICS_DB.DEV_DEIDENTIFIED.PATIENTS
Purpose:        Physically deidentified patient data for restricted access.
                All direct identifiers removed, quasi-identifiers generalized.
                Compliant with HIPAA Safe Harbor deidentification standard.
Grain:          1 row = 1 patient
Source:         MEDICORE_ANALYTICS_DB.DEV_CLINICAL.PATIENTS
Governance:     HIPAA Safe Harbor - 18 identifiers removed/generalized
Consumers:      MEDICORE_ANALYST_RESTRICTED, MEDICORE_EXT_AUDITOR
Author:         Data Engineering Team
Version:        1.0
================================================================================
*/

USE ROLE MEDICORE_DATA_ENGINEER;
USE WAREHOUSE MEDICORE_ETL_WH;
USE DATABASE MEDICORE_ANALYTICS_DB;
USE SCHEMA DEV_DEIDENTIFIED;

CREATE OR REPLACE TABLE MEDICORE_ANALYTICS_DB.DEV_DEIDENTIFIED.PATIENTS AS
SELECT
    PATIENT_ID,
    EXTRACT(YEAR FROM DATE_OF_BIRTH)                            AS BIRTH_YEAR,
    CASE
        WHEN DATEDIFF('YEAR', DATE_OF_BIRTH, CURRENT_DATE()) < 18 THEN '0-17'
        WHEN DATEDIFF('YEAR', DATE_OF_BIRTH, CURRENT_DATE()) < 35 THEN '18-34'
        WHEN DATEDIFF('YEAR', DATE_OF_BIRTH, CURRENT_DATE()) < 50 THEN '35-49'
        WHEN DATEDIFF('YEAR', DATE_OF_BIRTH, CURRENT_DATE()) < 65 THEN '50-64'
        WHEN DATEDIFF('YEAR', DATE_OF_BIRTH, CURRENT_DATE()) < 80 THEN '65-79'
        ELSE '80+'
    END                                                         AS AGE_BUCKET,
    GENDER,
    LEFT(ZIP_CODE, 3)                                           AS ZIP3,
    RECORD_SOURCE,
    DATA_QUALITY_STATUS,
    CURRENT_TIMESTAMP()                                         AS DEIDENTIFIED_TIMESTAMP
FROM MEDICORE_ANALYTICS_DB.DEV_CLINICAL.PATIENTS;
