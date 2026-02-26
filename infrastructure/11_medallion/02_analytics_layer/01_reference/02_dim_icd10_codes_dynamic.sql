/*
================================================================================
Project:        MediCore Health Systems - Snowflake Data Platform
Layer:          Gold (ANALYTICS_DB)
Script:         02_dim_icd10_codes_dynamic.sql
Object:         MEDICORE_ANALYTICS_DB.DEV_REFERENCE.DIM_ICD10_CODES
Purpose:        Conformed ICD-10 diagnosis code dimension for business consumption.
                Supports clinical diagnosis analysis, revenue denial analysis,
                executive KPI aggregation, and AI-ready feature derivation.
Grain:          1 row = 1 ICD10 code
Source:         MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_ICD10_CODES
Dependencies:   Downstream joins with ENCOUNTERS and CLAIMS fact tables
Author:         Data Engineering Team
Version:        1.0
================================================================================
*/

USE ROLE MEDICORE_DATA_ENGINEER;
USE WAREHOUSE MEDICORE_ETL_WH;
USE DATABASE MEDICORE_ANALYTICS_DB;
USE SCHEMA DEV_REFERENCE;

CREATE OR REPLACE DYNAMIC TABLE MEDICORE_ANALYTICS_DB.DEV_REFERENCE.DIM_ICD10_CODES
    TARGET_LAG = '5 minutes'
    WAREHOUSE = MEDICORE_ETL_WH
    REFRESH_MODE = AUTO
AS
SELECT
    ICD10_CODE,
    ICD10_DESCRIPTION,
    ICD10_CATEGORY,
    IS_CHRONIC,
    CREATED_AT,
    LOAD_TIMESTAMP,
    RECORD_SOURCE,
    DATA_QUALITY_STATUS
FROM MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_ICD10_CODES;
