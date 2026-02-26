/*
================================================================================
Project:        MediCore Health Systems - Snowflake Data Platform
Layer:          Gold (ANALYTICS_DB)
Script:         01_dim_departments_dynamic.sql
Object:         MEDICORE_ANALYTICS_DB.DEV_REFERENCE.DIM_DEPARTMENTS
Purpose:        Conformed department dimension for business consumption.
                Mirrors cleaned structure from Silver layer.
Source:         MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_DEPARTMENTS
Grain:          1 row = 1 department
Dependencies:   MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_DEPARTMENTS
Author:         Data Engineering Team
Version:        1.0
================================================================================
*/

USE ROLE MEDICORE_DATA_ENGINEER;
USE WAREHOUSE MEDICORE_ETL_WH;
USE DATABASE MEDICORE_ANALYTICS_DB;
USE SCHEMA DEV_REFERENCE;

CREATE OR REPLACE DYNAMIC TABLE MEDICORE_ANALYTICS_DB.DEV_REFERENCE.DIM_DEPARTMENTS
    TARGET_LAG = '5 minutes'
    WAREHOUSE = MEDICORE_ETL_WH
    REFRESH_MODE = AUTO
AS
SELECT
    DEPARTMENT_ID,
    DEPARTMENT_NAME,
    FACILITY_CODE,
    ACTIVE_FLAG,
    CREATED_AT,
    LOAD_TIMESTAMP,
    RECORD_SOURCE,
    DATA_QUALITY_STATUS
FROM MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_DEPARTMENTS;
