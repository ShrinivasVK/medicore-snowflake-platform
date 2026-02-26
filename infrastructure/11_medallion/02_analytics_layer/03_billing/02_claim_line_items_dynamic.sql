/*
================================================================================
Project:        MediCore Health Systems - Snowflake Data Platform
Layer:          Gold (ANALYTICS_DB)
Script:         02_claim_line_items_dynamic.sql
Object:         MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIM_LINE_ITEMS
Purpose:        Most granular billing fact table for business consumption.
                Supports CPT-level revenue analysis, procedure KPIs,
                and revenue contribution reporting.
Grain:          1 row = 1 claim line item
Source:         MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIM_LINE_ITEMS
                MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIMS
                MEDICORE_TRANSFORM_DB.DEV_CLINICAL.ENCOUNTERS
Dependencies:   Revenue by procedure KPIs, executive revenue summary, AI features
Author:         Data Engineering Team
Version:        1.0
================================================================================
*/

USE ROLE MEDICORE_DATA_ENGINEER;
USE WAREHOUSE MEDICORE_ETL_WH;
USE DATABASE MEDICORE_ANALYTICS_DB;
USE SCHEMA DEV_BILLING;

CREATE OR REPLACE DYNAMIC TABLE MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIM_LINE_ITEMS
    TARGET_LAG = '5 minutes'
    WAREHOUSE = MEDICORE_ETL_WH
    REFRESH_MODE = AUTO
AS
SELECT
    cli.LINE_ITEM_ID,
    cli.CLAIM_ID,
    c.ENCOUNTER_ID,
    c.PATIENT_ID,
    cli.PROCEDURE_CODE,
    cli.LINE_BILLED_AMOUNT,
    cli.QUANTITY,
    cli.UNIT_CHARGE_AMOUNT,
    c.CLAIM_STATUS,
    c.PAYER_TYPE,
    c.SERVICE_DATE,
    e.DEPARTMENT_ID,
    e.ENCOUNTER_TYPE,
    e.PRIMARY_ICD10_CODE,
    EXTRACT(YEAR FROM c.SERVICE_DATE)                                   AS SERVICE_YEAR,
    DATE_TRUNC('MONTH', c.SERVICE_DATE)                                 AS SERVICE_MONTH,
    COALESCE(cli.LINE_BILLED_AMOUNT, 0)                                 AS LINE_NET_REVENUE,
    CASE WHEN c.CLAIM_STATUS = 'DENIED' THEN TRUE ELSE FALSE END        AS IS_DENIED_LINE_FLAG,
    CASE WHEN c.CLAIM_STATUS = 'DENIED' THEN 1 ELSE 0 END               AS DENIAL_FLAG_NUMERIC,
    cli.RAW_CREATED_AT,
    cli.LOAD_TIMESTAMP,
    cli.RECORD_SOURCE,
    cli.DATA_QUALITY_STATUS
FROM MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIM_LINE_ITEMS cli
LEFT JOIN MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIMS c
    ON cli.CLAIM_ID = c.CLAIM_ID
LEFT JOIN MEDICORE_TRANSFORM_DB.DEV_CLINICAL.ENCOUNTERS e
    ON c.ENCOUNTER_ID = e.ENCOUNTER_ID;
