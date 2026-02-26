/*
================================================================================
Project:        MediCore Health Systems - Snowflake Data Platform
Layer:          Gold (ANALYTICS_DB) - Executive Aggregation
Script:         02_kpi_revenue_summary.sql
Object:         MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.KPI_REVENUE_SUMMARY
Purpose:        Aggregated revenue metrics for executive dashboard.
                Contains NO PHI - optimized for Streamlit visualization.
                Supports revenue trends, denial rates, and per-encounter metrics.
Grain:          1 row = 1 month
Source:         MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIMS
Consumers:      Streamlit Executive Dashboard, MEDICORE_EXECUTIVE role,
                MEDICORE_ANALYST_RESTRICTED role
Author:         Data Engineering Team
Version:        1.0
================================================================================
*/

USE ROLE MEDICORE_DATA_ENGINEER;
USE WAREHOUSE MEDICORE_ANALYTICS_WH;
USE DATABASE MEDICORE_ANALYTICS_DB;
USE SCHEMA DEV_EXECUTIVE;

CREATE OR REPLACE TABLE MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.KPI_REVENUE_SUMMARY AS
WITH base_claims AS (
    SELECT
        CLAIM_ID,
        ENCOUNTER_ID,
        CLAIM_MONTH,
        COALESCE(CLAIM_BILLED_AMOUNT, 0)                    AS BILLED_AMOUNT,
        CLAIM_STATUS,
        DENIAL_FLAG_NUMERIC,
        PAYER_TYPE
    FROM MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIMS
    WHERE CLAIM_MONTH IS NOT NULL
),

monthly_aggregation AS (
    SELECT
        CLAIM_MONTH                                         AS MONTH_KEY,
        COUNT(CLAIM_ID)                                     AS TOTAL_CLAIMS,
        SUM(BILLED_AMOUNT)                                  AS TOTAL_BILLED_AMOUNT,
        SUM(BILLED_AMOUNT)                                  AS TOTAL_PAID_AMOUNT,
        0                                                   AS TOTAL_ADJUSTMENT_AMOUNT,
        SUM(BILLED_AMOUNT)                                  AS TOTAL_NET_REVENUE,
        SUM(DENIAL_FLAG_NUMERIC)                            AS TOTAL_DENIED_CLAIMS,
        COUNT(DISTINCT ENCOUNTER_ID)                        AS DISTINCT_ENCOUNTERS
    FROM base_claims
    GROUP BY CLAIM_MONTH
)

SELECT
    MONTH_KEY,
    TOTAL_CLAIMS,
    TOTAL_BILLED_AMOUNT,
    TOTAL_PAID_AMOUNT,
    TOTAL_ADJUSTMENT_AMOUNT,
    TOTAL_NET_REVENUE,
    CASE 
        WHEN TOTAL_CLAIMS > 0 
        THEN ROUND(TOTAL_NET_REVENUE / TOTAL_CLAIMS, 2)
        ELSE 0 
    END                                                     AS AVERAGE_REVENUE_PER_CLAIM,
    CASE 
        WHEN TOTAL_CLAIMS > 0 
        THEN ROUND(TOTAL_DENIED_CLAIMS::FLOAT / TOTAL_CLAIMS * 100, 2)
        ELSE 0 
    END                                                     AS DENIAL_RATE_PERCENT,
    CASE 
        WHEN DISTINCT_ENCOUNTERS > 0 
        THEN ROUND(TOTAL_NET_REVENUE / DISTINCT_ENCOUNTERS, 2)
        ELSE 0 
    END                                                     AS REVENUE_PER_ENCOUNTER,
    TOTAL_DENIED_CLAIMS,
    DISTINCT_ENCOUNTERS,
    CURRENT_TIMESTAMP()                                     AS REFRESH_TIMESTAMP
FROM monthly_aggregation
ORDER BY MONTH_KEY;

/*
================================================================================
TASK SCAFFOLD (DO NOT RESUME)
================================================================================
CREATE OR REPLACE TASK MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.REFRESH_KPI_REVENUE_SUMMARY
    WAREHOUSE = MEDICORE_ANALYTICS_WH
    SCHEDULE = 'USING CRON 0 * * * * UTC'
AS
    CREATE OR REPLACE TABLE MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.KPI_REVENUE_SUMMARY AS
    WITH base_claims AS (
        SELECT
            CLAIM_ID,
            ENCOUNTER_ID,
            CLAIM_MONTH,
            COALESCE(CLAIM_BILLED_AMOUNT, 0) AS BILLED_AMOUNT,
            CLAIM_STATUS,
            DENIAL_FLAG_NUMERIC,
            PAYER_TYPE
        FROM MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIMS
        WHERE CLAIM_MONTH IS NOT NULL
    ),
    monthly_aggregation AS (
        SELECT
            CLAIM_MONTH AS MONTH_KEY,
            COUNT(CLAIM_ID) AS TOTAL_CLAIMS,
            SUM(BILLED_AMOUNT) AS TOTAL_BILLED_AMOUNT,
            SUM(BILLED_AMOUNT) AS TOTAL_PAID_AMOUNT,
            0 AS TOTAL_ADJUSTMENT_AMOUNT,
            SUM(BILLED_AMOUNT) AS TOTAL_NET_REVENUE,
            SUM(DENIAL_FLAG_NUMERIC) AS TOTAL_DENIED_CLAIMS,
            COUNT(DISTINCT ENCOUNTER_ID) AS DISTINCT_ENCOUNTERS
        FROM base_claims
        GROUP BY CLAIM_MONTH
    )
    SELECT
        MONTH_KEY,
        TOTAL_CLAIMS,
        TOTAL_BILLED_AMOUNT,
        TOTAL_PAID_AMOUNT,
        TOTAL_ADJUSTMENT_AMOUNT,
        TOTAL_NET_REVENUE,
        CASE 
            WHEN TOTAL_CLAIMS > 0 
            THEN ROUND(TOTAL_NET_REVENUE / TOTAL_CLAIMS, 2)
            ELSE 0 
        END AS AVERAGE_REVENUE_PER_CLAIM,
        CASE 
            WHEN TOTAL_CLAIMS > 0 
            THEN ROUND(TOTAL_DENIED_CLAIMS::FLOAT / TOTAL_CLAIMS * 100, 2)
            ELSE 0 
        END AS DENIAL_RATE_PERCENT,
        CASE 
            WHEN DISTINCT_ENCOUNTERS > 0 
            THEN ROUND(TOTAL_NET_REVENUE / DISTINCT_ENCOUNTERS, 2)
            ELSE 0 
        END AS REVENUE_PER_ENCOUNTER,
        TOTAL_DENIED_CLAIMS,
        DISTINCT_ENCOUNTERS,
        CURRENT_TIMESTAMP() AS REFRESH_TIMESTAMP
    FROM monthly_aggregation
    ORDER BY MONTH_KEY;
================================================================================
*/
