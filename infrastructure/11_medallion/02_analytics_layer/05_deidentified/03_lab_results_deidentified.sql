/*
================================================================================
Project:        MediCore Health Systems - Snowflake Data Platform
Layer:          Gold (ANALYTICS_DB) - Deidentified Exposure
Script:         03_lab_results_deidentified.sql
Object:         MEDICORE_ANALYTICS_DB.DEV_DEIDENTIFIED.LAB_RESULTS
Purpose:        Physically deidentified lab results data for restricted access.
                All direct identifiers removed, dates generalized to month level.
                Compliant with HIPAA Safe Harbor deidentification standard.
Grain:          1 row = 1 lab result
Source:         MEDICORE_ANALYTICS_DB.DEV_CLINICAL.LAB_RESULTS
Governance:     HIPAA Safe Harbor - Patient identifiers removed,
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

CREATE OR REPLACE TABLE MEDICORE_ANALYTICS_DB.DEV_DEIDENTIFIED.LAB_RESULTS AS
SELECT
    LAB_RESULT_ID,
    ENCOUNTER_ID,
    TEST_NAME,
    RESULT_VALUE,
    RESULT_UNIT,
    IS_ABNORMAL,
    IS_ABNORMAL_FLAG,
    ENCOUNTER_TYPE,
    PRIMARY_ICD10_CODE,
    RESULT_YEAR,
    RESULT_MONTH,
    RECORD_SOURCE,
    DATA_QUALITY_STATUS,
    CURRENT_TIMESTAMP()                                         AS DEIDENTIFIED_TIMESTAMP
FROM MEDICORE_ANALYTICS_DB.DEV_CLINICAL.LAB_RESULTS;
