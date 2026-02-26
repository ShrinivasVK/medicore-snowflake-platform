/*
================================================================================
Project:        MediCore Health Systems - Snowflake Data Platform
Layer:          Gold (ANALYTICS_DB) - Executive Aggregation
Script:         03_kpi_clinical_outcomes.sql
Object:         MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.KPI_CLINICAL_OUTCOMES
Purpose:        Aggregated clinical outcome metrics for executive dashboard.
                Contains NO PHI - optimized for Streamlit visualization.
                Supports LOS trends, readmission tracking, and lab monitoring.
Grain:          1 row = 1 month
Source:         MEDICORE_ANALYTICS_DB.DEV_CLINICAL.ENCOUNTERS
                MEDICORE_ANALYTICS_DB.DEV_CLINICAL.LAB_RESULTS
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

CREATE OR REPLACE TABLE MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.KPI_CLINICAL_OUTCOMES AS
WITH inpatient_encounters AS (
    SELECT
        ENCOUNTER_ID,
        PATIENT_ID,
        ADMISSION_DATE,
        DISCHARGE_DATE,
        LENGTH_OF_STAY_DAYS,
        ENCOUNTER_MONTH,
        DISCHARGE_MONTH
    FROM MEDICORE_ANALYTICS_DB.DEV_CLINICAL.ENCOUNTERS
    WHERE IS_INPATIENT_FLAG = TRUE
      AND ADMISSION_DATE IS NOT NULL
),

readmission_logic AS (
    SELECT
        ENCOUNTER_ID,
        PATIENT_ID,
        ADMISSION_DATE,
        DISCHARGE_DATE,
        DISCHARGE_MONTH,
        LENGTH_OF_STAY_DAYS,
        LEAD(ADMISSION_DATE) OVER (
            PARTITION BY PATIENT_ID 
            ORDER BY ADMISSION_DATE
        )                                                       AS NEXT_ADMISSION_DATE,
        CASE 
            WHEN LEAD(ADMISSION_DATE) OVER (
                PARTITION BY PATIENT_ID 
                ORDER BY ADMISSION_DATE
            ) <= DATEADD('DAY', 30, DISCHARGE_DATE)
            THEN 1 
            ELSE 0 
        END                                                     AS IS_READMISSION_CASE
    FROM inpatient_encounters
),

monthly_inpatient_aggregation AS (
    SELECT
        DISCHARGE_MONTH                                         AS MONTH_KEY,
        COUNT(ENCOUNTER_ID)                                     AS TOTAL_INPATIENT_ENCOUNTERS,
        COALESCE(AVG(LENGTH_OF_STAY_DAYS), 0)                   AS AVERAGE_LENGTH_OF_STAY,
        COALESCE(MEDIAN(LENGTH_OF_STAY_DAYS), 0)                AS MEDIAN_LENGTH_OF_STAY,
        SUM(IS_READMISSION_CASE)                                AS TOTAL_READMISSIONS,
        CASE 
            WHEN COUNT(ENCOUNTER_ID) > 0 
            THEN ROUND(SUM(IS_READMISSION_CASE)::FLOAT / COUNT(ENCOUNTER_ID) * 100, 2)
            ELSE 0 
        END                                                     AS READMISSION_RATE_PERCENT
    FROM readmission_logic
    WHERE DISCHARGE_MONTH IS NOT NULL
    GROUP BY DISCHARGE_MONTH
),

lab_aggregation AS (
    SELECT
        RESULT_MONTH                                            AS MONTH_KEY,
        COUNT(LAB_RESULT_ID)                                    AS TOTAL_LAB_TESTS,
        SUM(CASE WHEN IS_ABNORMAL_FLAG = TRUE THEN 1 ELSE 0 END) AS TOTAL_ABNORMAL_LABS,
        CASE 
            WHEN COUNT(LAB_RESULT_ID) > 0 
            THEN ROUND(SUM(CASE WHEN IS_ABNORMAL_FLAG = TRUE THEN 1 ELSE 0 END)::FLOAT 
                       / COUNT(LAB_RESULT_ID) * 100, 2)
            ELSE 0 
        END                                                     AS ABNORMAL_LAB_RATE_PERCENT
    FROM MEDICORE_ANALYTICS_DB.DEV_CLINICAL.LAB_RESULTS
    WHERE RESULT_MONTH IS NOT NULL
    GROUP BY RESULT_MONTH
)

SELECT
    COALESCE(mia.MONTH_KEY, la.MONTH_KEY)                       AS MONTH_KEY,
    COALESCE(mia.TOTAL_INPATIENT_ENCOUNTERS, 0)                 AS TOTAL_INPATIENT_ENCOUNTERS,
    COALESCE(mia.AVERAGE_LENGTH_OF_STAY, 0)                     AS AVERAGE_LENGTH_OF_STAY,
    COALESCE(mia.MEDIAN_LENGTH_OF_STAY, 0)                      AS MEDIAN_LENGTH_OF_STAY,
    COALESCE(mia.TOTAL_READMISSIONS, 0)                         AS TOTAL_READMISSIONS,
    COALESCE(mia.READMISSION_RATE_PERCENT, 0)                   AS READMISSION_RATE_PERCENT,
    COALESCE(la.TOTAL_LAB_TESTS, 0)                             AS TOTAL_LAB_TESTS,
    COALESCE(la.TOTAL_ABNORMAL_LABS, 0)                         AS TOTAL_ABNORMAL_LABS,
    COALESCE(la.ABNORMAL_LAB_RATE_PERCENT, 0)                   AS ABNORMAL_LAB_RATE_PERCENT,
    CURRENT_TIMESTAMP()                                         AS REFRESH_TIMESTAMP
FROM monthly_inpatient_aggregation mia
FULL OUTER JOIN lab_aggregation la
    ON mia.MONTH_KEY = la.MONTH_KEY
ORDER BY MONTH_KEY;

/*
================================================================================
TASK SCAFFOLD (DO NOT RESUME)
================================================================================
CREATE OR REPLACE TASK MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.REFRESH_KPI_CLINICAL_OUTCOMES
    WAREHOUSE = MEDICORE_ANALYTICS_WH
    SCHEDULE = 'USING CRON 0 * * * * UTC'
AS
    CREATE OR REPLACE TABLE MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.KPI_CLINICAL_OUTCOMES AS
    WITH inpatient_encounters AS (
        SELECT
            ENCOUNTER_ID,
            PATIENT_ID,
            ADMISSION_DATE,
            DISCHARGE_DATE,
            LENGTH_OF_STAY_DAYS,
            ENCOUNTER_MONTH,
            DISCHARGE_MONTH
        FROM MEDICORE_ANALYTICS_DB.DEV_CLINICAL.ENCOUNTERS
        WHERE IS_INPATIENT_FLAG = TRUE
          AND ADMISSION_DATE IS NOT NULL
    ),
    readmission_logic AS (
        SELECT
            ENCOUNTER_ID,
            PATIENT_ID,
            ADMISSION_DATE,
            DISCHARGE_DATE,
            DISCHARGE_MONTH,
            LENGTH_OF_STAY_DAYS,
            LEAD(ADMISSION_DATE) OVER (
                PARTITION BY PATIENT_ID 
                ORDER BY ADMISSION_DATE
            ) AS NEXT_ADMISSION_DATE,
            CASE 
                WHEN LEAD(ADMISSION_DATE) OVER (
                    PARTITION BY PATIENT_ID 
                    ORDER BY ADMISSION_DATE
                ) <= DATEADD('DAY', 30, DISCHARGE_DATE)
                THEN 1 
                ELSE 0 
            END AS IS_READMISSION_CASE
        FROM inpatient_encounters
    ),
    monthly_inpatient_aggregation AS (
        SELECT
            DISCHARGE_MONTH AS MONTH_KEY,
            COUNT(ENCOUNTER_ID) AS TOTAL_INPATIENT_ENCOUNTERS,
            COALESCE(AVG(LENGTH_OF_STAY_DAYS), 0) AS AVERAGE_LENGTH_OF_STAY,
            COALESCE(MEDIAN(LENGTH_OF_STAY_DAYS), 0) AS MEDIAN_LENGTH_OF_STAY,
            SUM(IS_READMISSION_CASE) AS TOTAL_READMISSIONS,
            CASE 
                WHEN COUNT(ENCOUNTER_ID) > 0 
                THEN ROUND(SUM(IS_READMISSION_CASE)::FLOAT / COUNT(ENCOUNTER_ID) * 100, 2)
                ELSE 0 
            END AS READMISSION_RATE_PERCENT
        FROM readmission_logic
        WHERE DISCHARGE_MONTH IS NOT NULL
        GROUP BY DISCHARGE_MONTH
    ),
    lab_aggregation AS (
        SELECT
            RESULT_MONTH AS MONTH_KEY,
            COUNT(LAB_RESULT_ID) AS TOTAL_LAB_TESTS,
            SUM(CASE WHEN IS_ABNORMAL_FLAG = TRUE THEN 1 ELSE 0 END) AS TOTAL_ABNORMAL_LABS,
            CASE 
                WHEN COUNT(LAB_RESULT_ID) > 0 
                THEN ROUND(SUM(CASE WHEN IS_ABNORMAL_FLAG = TRUE THEN 1 ELSE 0 END)::FLOAT 
                           / COUNT(LAB_RESULT_ID) * 100, 2)
                ELSE 0 
            END AS ABNORMAL_LAB_RATE_PERCENT
        FROM MEDICORE_ANALYTICS_DB.DEV_CLINICAL.LAB_RESULTS
        WHERE RESULT_MONTH IS NOT NULL
        GROUP BY RESULT_MONTH
    )
    SELECT
        COALESCE(mia.MONTH_KEY, la.MONTH_KEY) AS MONTH_KEY,
        COALESCE(mia.TOTAL_INPATIENT_ENCOUNTERS, 0) AS TOTAL_INPATIENT_ENCOUNTERS,
        COALESCE(mia.AVERAGE_LENGTH_OF_STAY, 0) AS AVERAGE_LENGTH_OF_STAY,
        COALESCE(mia.MEDIAN_LENGTH_OF_STAY, 0) AS MEDIAN_LENGTH_OF_STAY,
        COALESCE(mia.TOTAL_READMISSIONS, 0) AS TOTAL_READMISSIONS,
        COALESCE(mia.READMISSION_RATE_PERCENT, 0) AS READMISSION_RATE_PERCENT,
        COALESCE(la.TOTAL_LAB_TESTS, 0) AS TOTAL_LAB_TESTS,
        COALESCE(la.TOTAL_ABNORMAL_LABS, 0) AS TOTAL_ABNORMAL_LABS,
        COALESCE(la.ABNORMAL_LAB_RATE_PERCENT, 0) AS ABNORMAL_LAB_RATE_PERCENT,
        CURRENT_TIMESTAMP() AS REFRESH_TIMESTAMP
    FROM monthly_inpatient_aggregation mia
    FULL OUTER JOIN lab_aggregation la
        ON mia.MONTH_KEY = la.MONTH_KEY
    ORDER BY MONTH_KEY;
================================================================================
*/
