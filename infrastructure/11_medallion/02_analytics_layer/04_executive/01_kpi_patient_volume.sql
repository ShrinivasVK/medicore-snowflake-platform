/*
================================================================================
Project:        MediCore Health Systems - Snowflake Data Platform
Layer:          Gold (ANALYTICS_DB) - Executive Aggregation
Script:         01_kpi_patient_volume.sql
Object:         MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.KPI_PATIENT_VOLUME
Purpose:        Aggregated patient volume metrics for executive dashboard.
                Contains NO PHI - optimized for Streamlit visualization.
Grain:          1 row = 1 month
Source:         MEDICORE_ANALYTICS_DB.DEV_CLINICAL.ENCOUNTERS
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

CREATE OR REPLACE TABLE MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.KPI_PATIENT_VOLUME AS
WITH base_encounters AS (
    SELECT
        ENCOUNTER_ID,
        PATIENT_ID,
        ADMISSION_DATE,
        ENCOUNTER_MONTH
    FROM MEDICORE_ANALYTICS_DB.DEV_CLINICAL.ENCOUNTERS
    WHERE ADMISSION_DATE IS NOT NULL
),

patient_first_encounter AS (
    SELECT
        PATIENT_ID,
        MIN(ENCOUNTER_MONTH)                                AS FIRST_ENCOUNTER_MONTH
    FROM base_encounters
    GROUP BY PATIENT_ID
),

monthly_aggregation AS (
    SELECT
        e.ENCOUNTER_MONTH                                   AS MONTH_KEY,
        COUNT(DISTINCT e.PATIENT_ID)                        AS TOTAL_DISTINCT_PATIENTS,
        COUNT(e.ENCOUNTER_ID)                               AS TOTAL_ENCOUNTERS,
        COUNT(DISTINCT CASE 
            WHEN pfe.FIRST_ENCOUNTER_MONTH = e.ENCOUNTER_MONTH 
            THEN e.PATIENT_ID 
        END)                                                AS NEW_PATIENTS
    FROM base_encounters e
    LEFT JOIN patient_first_encounter pfe
        ON e.PATIENT_ID = pfe.PATIENT_ID
    GROUP BY e.ENCOUNTER_MONTH
),

active_patients_30_days AS (
    SELECT
        m.MONTH_KEY,
        COUNT(DISTINCT e.PATIENT_ID)                        AS ACTIVE_PATIENTS_LAST_30_DAYS
    FROM monthly_aggregation m
    LEFT JOIN base_encounters e
        ON e.ADMISSION_DATE BETWEEN DATEADD('DAY', -30, LAST_DAY(m.MONTH_KEY)) 
                                AND LAST_DAY(m.MONTH_KEY)
    GROUP BY m.MONTH_KEY
)

SELECT
    ma.MONTH_KEY,
    ma.TOTAL_DISTINCT_PATIENTS,
    ma.TOTAL_ENCOUNTERS,
    ma.NEW_PATIENTS,
    COALESCE(ap.ACTIVE_PATIENTS_LAST_30_DAYS, 0)            AS ACTIVE_PATIENTS_LAST_30_DAYS,
    CASE 
        WHEN ma.TOTAL_DISTINCT_PATIENTS > 0 
        THEN ROUND(ma.TOTAL_ENCOUNTERS::FLOAT / ma.TOTAL_DISTINCT_PATIENTS, 2)
        ELSE 0 
    END                                                     AS AVERAGE_ENCOUNTERS_PER_PATIENT,
    CURRENT_TIMESTAMP()                                     AS REFRESH_TIMESTAMP
FROM monthly_aggregation ma
LEFT JOIN active_patients_30_days ap
    ON ma.MONTH_KEY = ap.MONTH_KEY
ORDER BY ma.MONTH_KEY;

/*
================================================================================
TASK SCAFFOLD (DO NOT RESUME)
================================================================================
CREATE OR REPLACE TASK MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.REFRESH_KPI_PATIENT_VOLUME
    WAREHOUSE = MEDICORE_ANALYTICS_WH
    SCHEDULE = 'USING CRON 0 * * * * UTC'
AS
    CREATE OR REPLACE TABLE MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.KPI_PATIENT_VOLUME AS
    WITH base_encounters AS (
        SELECT
            ENCOUNTER_ID,
            PATIENT_ID,
            ADMISSION_DATE,
            ENCOUNTER_MONTH
        FROM MEDICORE_ANALYTICS_DB.DEV_CLINICAL.ENCOUNTERS
        WHERE ADMISSION_DATE IS NOT NULL
    ),
    patient_first_encounter AS (
        SELECT
            PATIENT_ID,
            MIN(ENCOUNTER_MONTH) AS FIRST_ENCOUNTER_MONTH
        FROM base_encounters
        GROUP BY PATIENT_ID
    ),
    monthly_aggregation AS (
        SELECT
            e.ENCOUNTER_MONTH AS MONTH_KEY,
            COUNT(DISTINCT e.PATIENT_ID) AS TOTAL_DISTINCT_PATIENTS,
            COUNT(e.ENCOUNTER_ID) AS TOTAL_ENCOUNTERS,
            COUNT(DISTINCT CASE 
                WHEN pfe.FIRST_ENCOUNTER_MONTH = e.ENCOUNTER_MONTH 
                THEN e.PATIENT_ID 
            END) AS NEW_PATIENTS
        FROM base_encounters e
        LEFT JOIN patient_first_encounter pfe
            ON e.PATIENT_ID = pfe.PATIENT_ID
        GROUP BY e.ENCOUNTER_MONTH
    ),
    active_patients_30_days AS (
        SELECT
            m.MONTH_KEY,
            COUNT(DISTINCT e.PATIENT_ID) AS ACTIVE_PATIENTS_LAST_30_DAYS
        FROM monthly_aggregation m
        LEFT JOIN base_encounters e
            ON e.ADMISSION_DATE BETWEEN DATEADD('DAY', -30, LAST_DAY(m.MONTH_KEY)) 
                                    AND LAST_DAY(m.MONTH_KEY)
        GROUP BY m.MONTH_KEY
    )
    SELECT
        ma.MONTH_KEY,
        ma.TOTAL_DISTINCT_PATIENTS,
        ma.TOTAL_ENCOUNTERS,
        ma.NEW_PATIENTS,
        COALESCE(ap.ACTIVE_PATIENTS_LAST_30_DAYS, 0) AS ACTIVE_PATIENTS_LAST_30_DAYS,
        CASE 
            WHEN ma.TOTAL_DISTINCT_PATIENTS > 0 
            THEN ROUND(ma.TOTAL_ENCOUNTERS::FLOAT / ma.TOTAL_DISTINCT_PATIENTS, 2)
            ELSE 0 
        END AS AVERAGE_ENCOUNTERS_PER_PATIENT,
        CURRENT_TIMESTAMP() AS REFRESH_TIMESTAMP
    FROM monthly_aggregation ma
    LEFT JOIN active_patients_30_days ap
        ON ma.MONTH_KEY = ap.MONTH_KEY
    ORDER BY ma.MONTH_KEY;
================================================================================
*/
