/*
================================================================================
Project:        MediCore Health Systems - Snowflake Data Platform
Layer:          Gold (ANALYTICS_DB)
Script:         02_providers_dynamic.sql
Object:         MEDICORE_ANALYTICS_DB.DEV_CLINICAL.PROVIDERS
Purpose:        Conformed provider dimension for business consumption.
                Supports provider performance metrics, revenue analysis,
                and clinical workload reporting.
Grain:          1 row = 1 provider
Source:         MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PROVIDERS
Dependencies:   Downstream joins with ENCOUNTERS, CLAIMS, DIM_DEPARTMENTS
Author:         Data Engineering Team
Version:        1.0
===============================================================================
*/

USE ROLE MEDICORE_DATA_ENGINEER;
USE WAREHOUSE MEDICORE_ETL_WH;
USE DATABASE MEDICORE_ANALYTICS_DB;
USE SCHEMA DEV_CLINICAL;

CREATE OR REPLACE DYNAMIC TABLE MEDICORE_ANALYTICS_DB.DEV_CLINICAL.PROVIDERS
    TARGET_LAG = '5 minutes'
    WAREHOUSE = MEDICORE_ETL_WH
    REFRESH_MODE = AUTO
AS
SELECT
    PROVIDER_ID,
    PROVIDER_NAME,
    SPECIALTY,
    DEPARTMENT_ID,
    CREATED_AT,
    LOAD_TIMESTAMP,
    RECORD_SOURCE,
    DATA_QUALITY_STATUS
FROM MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PROVIDERS;
