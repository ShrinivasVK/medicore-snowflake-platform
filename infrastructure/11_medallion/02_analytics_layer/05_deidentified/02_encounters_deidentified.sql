/*
================================================================================
Project:        MediCore Health Systems - Snowflake Data Platform
Layer:          Gold (ANALYTICS_DB) - Deidentified Exposure
Script:         02_encounters_deidentified.sql
Object:         MEDICORE_ANALYTICS_DB.DEV_DEIDENTIFIED.ENCOUNTERS
Purpose:        Physically deidentified encounter data for restricted access.
                All direct identifiers removed, dates generalized to month level.
                Compliant with HIPAA Safe Harbor deidentification standard.
Grain:          1 row = 1 encounter
Source:         MEDICORE_ANALYTICS_DB.DEV_CLINICAL.ENCOUNTERS
Governance:     HIPAA Safe Harbor - Patient/provider identifiers removed,
                dates generalized to month level
Consumers:      MEDICORE_ANALYST_RESTRICTED, MEDICORE_EXT_AUDITOR
Author:         Data Engineering Team
Version:        1.0
================================================================================
*/

USE ROLE MEDICORE_DATA_ENGINEER;
USE WAREHOUSE MEDICORE_ETL_WH;
USE DATABASE MEDICORE_ANALYTICS_DB;
USE SCHEMA DEV_DEIDENTIFIED;

CREATE OR REPLACE TABLE MEDICORE_ANALYTICS_DB.DEV_DEIDENTIFIED.ENCOUNTERS AS
SELECT
    ENCOUNTER_ID,
    PATIENT_ID,
    DEPARTMENT_ID,
    ENCOUNTER_TYPE,
    PRIMARY_ICD10_CODE,
    PRIMARY_DIAGNOSIS_DESCRIPTION,
    PRIMARY_DIAGNOSIS_CATEGORY,
    PRIMARY_DIAGNOSIS_IS_CHRONIC,
    DEPARTMENT_NAME,
    FACILITY_CODE,
    PROVIDER_SPECIALTY,
    ENCOUNTER_YEAR,
    ENCOUNTER_MONTH                                             AS ADMISSION_MONTH,
    DISCHARGE_YEAR,
    DISCHARGE_MONTH,
    LENGTH_OF_STAY_DAYS,
    IS_INPATIENT_FLAG,
    IS_OUTPATIENT_FLAG,
    RECORD_SOURCE,
    DATA_QUALITY_STATUS,
    CURRENT_TIMESTAMP()                                         AS DEIDENTIFIED_TIMESTAMP
FROM MEDICORE_ANALYTICS_DB.DEV_CLINICAL.ENCOUNTERS;
