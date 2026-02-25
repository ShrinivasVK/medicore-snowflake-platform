-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 06: Monitoring Views
-- Script: 06_monitoring_views.sql
--
-- Description:
--   Creates monitoring views to provide visibility into credit
--   usage, warehouse utilization, query performance, resource
--   monitor consumption, and cost attribution. All views are
--   centralized in MEDICORE_GOVERNANCE_DB.AUDIT schema.
--
-- Data Latency Note:
--   All views in this script pull from SNOWFLAKE.ACCOUNT_USAGE,
--   which has a latency of up to 45 minutes to 3 hours depending
--   on the view. Query results may not reflect real-time data.
--   For real-time metrics, use INFORMATION_SCHEMA instead.
--
-- Views Created:
--   1. V_WAREHOUSE_CREDIT_USAGE     - Credit consumption by warehouse
--   2. V_WAREHOUSE_UTILIZATION      - Warehouse load and utilization
--   3. V_QUERY_PERFORMANCE          - Query execution metrics
--   4. V_LONG_RUNNING_QUERIES       - Queries exceeding 5 minutes
--   5. V_FAILED_QUERIES             - Queries with errors
--   6. V_RESOURCE_MONITOR_STATUS    - Resource monitor consumption
--   7. V_COST_BY_WAREHOUSE_MONTH    - Monthly cost aggregations
--   8. V_ACTIVE_WAREHOUSE_LOAD      - Current warehouse load metrics
--
-- Security:
--   SELECT granted to MEDICORE_PLATFORM_ADMIN and
--   MEDICORE_COMPLIANCE_OFFICER only. Not accessible to
--   clinical, billing, analyst, or executive roles.
--
-- Execution Requirements:
--   - Must be run as ACCOUNTADMIN
--   - MEDICORE_GOVERNANCE_DB.AUDIT schema must exist
--   - Compatible with MEDICORE_SVC_GITHUB_ACTIONS
--
-- Author: MediCore Platform Team
-- Date: 2026-02-25
-- ============================================================


USE ROLE ACCOUNTADMIN;
USE DATABASE MEDICORE_GOVERNANCE_DB;
USE SCHEMA MEDICORE_GOVERNANCE_DB.AUDIT;


-- ============================================================
-- SECTION 1: WAREHOUSE CREDIT MONITORING
-- ============================================================
-- Views for tracking credit consumption across warehouses.
-- ============================================================

-- ------------------------------------------------------------
-- V_WAREHOUSE_CREDIT_USAGE
-- Purpose: Detailed credit usage by warehouse with time windows
-- Data Latency: Up to 3 hours
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW MEDICORE_GOVERNANCE_DB.AUDIT.V_WAREHOUSE_CREDIT_USAGE
    COMMENT = 'Detailed credit usage by MEDICORE warehouses. Includes compute and cloud services credits. Data latency: up to 3 hours from SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY.'
AS
SELECT
    WAREHOUSE_NAME                                          AS WAREHOUSE_NAME,
    START_TIME                                              AS START_TIME,
    END_TIME                                                AS END_TIME,
    CREDITS_USED                                            AS CREDITS_USED_COMPUTE,
    CREDITS_USED_CLOUD_SERVICES                             AS CREDITS_USED_CLOUD_SERVICES,
    CREDITS_USED + CREDITS_USED_CLOUD_SERVICES              AS TOTAL_CREDITS,
    ROUND((CREDITS_USED + CREDITS_USED_CLOUD_SERVICES) / 
          NULLIF(SUM(CREDITS_USED + CREDITS_USED_CLOUD_SERVICES) 
                 OVER (PARTITION BY DATE_TRUNC('MONTH', START_TIME)), 0) * 100, 2)
                                                            AS PERCENTAGE_OF_MONTH,
    DATE_TRUNC('MONTH', START_TIME)                         AS USAGE_MONTH,
    CURRENT_TIMESTAMP()                                     AS CREATED_AT
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE WAREHOUSE_NAME LIKE 'MEDICORE_%'
  AND START_TIME >= DATEADD('DAY', -90, CURRENT_DATE())
ORDER BY START_TIME DESC;


-- ============================================================
-- SECTION 2: QUERY MONITORING
-- ============================================================
-- Views for tracking query execution, performance, and failures.
-- ============================================================

-- ------------------------------------------------------------
-- V_QUERY_PERFORMANCE
-- Purpose: Query execution metrics for performance analysis
-- Data Latency: Up to 45 minutes
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW MEDICORE_GOVERNANCE_DB.AUDIT.V_QUERY_PERFORMANCE
    COMMENT = 'Query execution metrics for MEDICORE warehouses. Includes timing, data volumes, and resource consumption. Data latency: up to 45 minutes from SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY.'
AS
SELECT
    QUERY_ID                                                AS QUERY_ID,
    QUERY_TEXT                                              AS QUERY_TEXT,
    USER_NAME                                               AS USER_NAME,
    ROLE_NAME                                               AS ROLE_NAME,
    WAREHOUSE_NAME                                          AS WAREHOUSE_NAME,
    WAREHOUSE_SIZE                                          AS WAREHOUSE_SIZE,
    DATABASE_NAME                                           AS DATABASE_NAME,
    SCHEMA_NAME                                             AS SCHEMA_NAME,
    QUERY_TYPE                                              AS QUERY_TYPE,
    EXECUTION_STATUS                                        AS EXECUTION_STATUS,
    START_TIME                                              AS START_TIME,
    END_TIME                                                AS END_TIME,
    TOTAL_ELAPSED_TIME / 1000                               AS EXECUTION_TIME_SECONDS,
    EXECUTION_TIME / 1000                                   AS COMPILE_TIME_SECONDS,
    QUEUED_OVERLOAD_TIME / 1000                             AS QUEUED_TIME_SECONDS,
    BYTES_SCANNED                                           AS BYTES_SCANNED,
    ROWS_PRODUCED                                           AS ROWS_PRODUCED,
    BYTES_WRITTEN                                           AS BYTES_WRITTEN,
    ROWS_WRITTEN                                            AS ROWS_WRITTEN,
    PARTITIONS_SCANNED                                      AS PARTITIONS_SCANNED,
    PARTITIONS_TOTAL                                        AS PARTITIONS_TOTAL,
    ROUND(PARTITIONS_SCANNED / NULLIF(PARTITIONS_TOTAL, 0) * 100, 2) 
                                                            AS PARTITION_SCAN_PERCENTAGE,
    CREDITS_USED_CLOUD_SERVICES                             AS CREDITS_USED,
    CURRENT_TIMESTAMP()                                     AS CREATED_AT
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE WAREHOUSE_NAME LIKE 'MEDICORE_%'
  AND START_TIME >= DATEADD('DAY', -30, CURRENT_DATE())
ORDER BY START_TIME DESC;


-- ------------------------------------------------------------
-- V_LONG_RUNNING_QUERIES
-- Purpose: Queries exceeding 5 minutes execution time
-- Data Latency: Up to 45 minutes
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW MEDICORE_GOVERNANCE_DB.AUDIT.V_LONG_RUNNING_QUERIES
    COMMENT = 'Queries exceeding 5 minutes execution time on MEDICORE warehouses. Use for optimization targeting and runaway query detection. Data latency: up to 45 minutes from SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY.'
AS
SELECT
    QUERY_ID                                                AS QUERY_ID,
    QUERY_TEXT                                              AS QUERY_TEXT,
    USER_NAME                                               AS USER_NAME,
    ROLE_NAME                                               AS ROLE_NAME,
    WAREHOUSE_NAME                                          AS WAREHOUSE_NAME,
    WAREHOUSE_SIZE                                          AS WAREHOUSE_SIZE,
    DATABASE_NAME                                           AS DATABASE_NAME,
    SCHEMA_NAME                                             AS SCHEMA_NAME,
    QUERY_TYPE                                              AS QUERY_TYPE,
    EXECUTION_STATUS                                        AS EXECUTION_STATUS,
    START_TIME                                              AS START_TIME,
    END_TIME                                                AS END_TIME,
    TOTAL_ELAPSED_TIME / 1000                               AS EXECUTION_TIME_SECONDS,
    TOTAL_ELAPSED_TIME / 60000                              AS EXECUTION_TIME_MINUTES,
    BYTES_SCANNED                                           AS BYTES_SCANNED,
    ROWS_PRODUCED                                           AS ROWS_PRODUCED,
    PARTITIONS_SCANNED                                      AS PARTITIONS_SCANNED,
    PARTITIONS_TOTAL                                        AS PARTITIONS_TOTAL,
    CURRENT_TIMESTAMP()                                     AS CREATED_AT
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE WAREHOUSE_NAME LIKE 'MEDICORE_%'
  AND TOTAL_ELAPSED_TIME > 300000
  AND START_TIME >= DATEADD('DAY', -30, CURRENT_DATE())
ORDER BY TOTAL_ELAPSED_TIME DESC;


-- ------------------------------------------------------------
-- V_FAILED_QUERIES
-- Purpose: Queries with errors for troubleshooting
-- Data Latency: Up to 45 minutes
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW MEDICORE_GOVERNANCE_DB.AUDIT.V_FAILED_QUERIES
    COMMENT = 'Queries with errors on MEDICORE warehouses. Includes error codes and messages for troubleshooting. Data latency: up to 45 minutes from SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY.'
AS
SELECT
    QUERY_ID                                                AS QUERY_ID,
    QUERY_TEXT                                              AS QUERY_TEXT,
    USER_NAME                                               AS USER_NAME,
    ROLE_NAME                                               AS ROLE_NAME,
    WAREHOUSE_NAME                                          AS WAREHOUSE_NAME,
    DATABASE_NAME                                           AS DATABASE_NAME,
    SCHEMA_NAME                                             AS SCHEMA_NAME,
    QUERY_TYPE                                              AS QUERY_TYPE,
    EXECUTION_STATUS                                        AS EXECUTION_STATUS,
    ERROR_CODE                                              AS ERROR_CODE,
    ERROR_MESSAGE                                           AS ERROR_MESSAGE,
    START_TIME                                              AS START_TIME,
    END_TIME                                                AS END_TIME,
    TOTAL_ELAPSED_TIME / 1000                               AS EXECUTION_TIME_SECONDS,
    CURRENT_TIMESTAMP()                                     AS CREATED_AT
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE WAREHOUSE_NAME LIKE 'MEDICORE_%'
  AND ERROR_CODE IS NOT NULL
  AND START_TIME >= DATEADD('DAY', -30, CURRENT_DATE())
ORDER BY START_TIME DESC;


-- ============================================================
-- SECTION 3: RESOURCE MONITOR TRACKING
-- ============================================================
-- Views for tracking resource monitor consumption and limits.
-- ============================================================

-- ------------------------------------------------------------
-- V_RESOURCE_MONITOR_STATUS
-- Purpose: Resource monitor consumption and thresholds
-- Data Latency: Up to 3 hours
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW MEDICORE_GOVERNANCE_DB.AUDIT.V_RESOURCE_MONITOR_STATUS
    COMMENT = 'Resource monitor consumption and thresholds for MEDICORE monitors. Tracks quota usage and proximity to suspend triggers. Data latency: up to 3 hours from SNOWFLAKE.ACCOUNT_USAGE.RESOURCE_MONITORS.'
AS
SELECT
    NAME                                                    AS MONITOR_NAME,
    CREDIT_QUOTA                                            AS CREDIT_QUOTA,
    USED_CREDITS                                            AS USED_CREDITS,
    REMAINING_CREDITS                                       AS REMAINING_CREDITS,
    ROUND(USED_CREDITS / NULLIF(CREDIT_QUOTA, 0) * 100, 2)  AS PERCENTAGE_USED,
    FREQUENCY                                               AS RESET_FREQUENCY,
    START_TIME                                              AS PERIOD_START,
    END_TIME                                                AS PERIOD_END,
    SUSPEND_AT                                              AS SUSPEND_TRIGGER_PERCENT,
    SUSPEND_IMMEDIATELY_AT                                  AS SUSPEND_IMMEDIATE_PERCENT,
    NOTIFY_AT                                               AS NOTIFY_TRIGGER_PERCENT,
    CASE 
        WHEN USED_CREDITS / NULLIF(CREDIT_QUOTA, 0) >= 0.90 THEN 'CRITICAL'
        WHEN USED_CREDITS / NULLIF(CREDIT_QUOTA, 0) >= 0.75 THEN 'WARNING'
        WHEN USED_CREDITS / NULLIF(CREDIT_QUOTA, 0) >= 0.50 THEN 'MODERATE'
        ELSE 'HEALTHY'
    END                                                     AS HEALTH_STATUS,
    CREATED_ON                                              AS MONITOR_CREATED_ON,
    CURRENT_TIMESTAMP()                                     AS CREATED_AT
FROM SNOWFLAKE.ACCOUNT_USAGE.RESOURCE_MONITORS
WHERE NAME LIKE 'MEDICORE_%'
  AND DELETED IS NULL
ORDER BY PERCENTAGE_USED DESC;


-- ============================================================
-- SECTION 4: CAPACITY & LOAD MONITORING
-- ============================================================
-- Views for tracking warehouse utilization and load patterns.
-- ============================================================

-- ------------------------------------------------------------
-- V_WAREHOUSE_UTILIZATION
-- Purpose: Warehouse utilization metrics over time
-- Data Latency: Up to 3 hours
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW MEDICORE_GOVERNANCE_DB.AUDIT.V_WAREHOUSE_UTILIZATION
    COMMENT = 'Warehouse utilization metrics for MEDICORE warehouses. Tracks load patterns for capacity planning. Data latency: up to 3 hours from SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_LOAD_HISTORY.'
AS
SELECT
    WAREHOUSE_NAME                                          AS WAREHOUSE_NAME,
    START_TIME                                              AS START_TIME,
    END_TIME                                                AS END_TIME,
    AVG_RUNNING                                             AS AVG_QUERIES_RUNNING,
    AVG_QUEUED_LOAD                                         AS AVG_QUERIES_QUEUED,
    AVG_QUEUED_PROVISIONING                                 AS AVG_QUERIES_PROVISIONING,
    AVG_BLOCKED                                             AS AVG_QUERIES_BLOCKED,
    AVG_RUNNING + AVG_QUEUED_LOAD + AVG_QUEUED_PROVISIONING AS TOTAL_LOAD,
    CASE 
        WHEN AVG_QUEUED_LOAD > 5 THEN 'HIGH_QUEUE'
        WHEN AVG_RUNNING > 10 THEN 'HIGH_LOAD'
        WHEN AVG_BLOCKED > 0 THEN 'BLOCKED'
        ELSE 'NORMAL'
    END                                                     AS LOAD_STATUS,
    DATE_TRUNC('HOUR', START_TIME)                          AS HOUR_BUCKET,
    CURRENT_TIMESTAMP()                                     AS CREATED_AT
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_LOAD_HISTORY
WHERE WAREHOUSE_NAME LIKE 'MEDICORE_%'
  AND START_TIME >= DATEADD('DAY', -30, CURRENT_DATE())
ORDER BY START_TIME DESC;


-- ------------------------------------------------------------
-- V_ACTIVE_WAREHOUSE_LOAD
-- Purpose: Current warehouse load snapshot
-- Data Latency: Up to 3 hours
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW MEDICORE_GOVERNANCE_DB.AUDIT.V_ACTIVE_WAREHOUSE_LOAD
    COMMENT = 'Current warehouse load metrics for MEDICORE warehouses. Aggregates recent load patterns for operational monitoring. Data latency: up to 3 hours from SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_LOAD_HISTORY.'
AS
SELECT
    WAREHOUSE_NAME                                          AS WAREHOUSE_NAME,
    COUNT(*)                                                AS SAMPLE_COUNT,
    ROUND(AVG(AVG_RUNNING), 2)                              AS AVG_QUERIES_RUNNING,
    ROUND(AVG(AVG_QUEUED_LOAD), 2)                          AS AVG_QUERIES_QUEUED,
    ROUND(AVG(AVG_BLOCKED), 2)                              AS AVG_QUERIES_BLOCKED,
    ROUND(MAX(AVG_RUNNING), 2)                              AS PEAK_QUERIES_RUNNING,
    ROUND(MAX(AVG_QUEUED_LOAD), 2)                          AS PEAK_QUERIES_QUEUED,
    MIN(START_TIME)                                         AS PERIOD_START,
    MAX(END_TIME)                                           AS PERIOD_END,
    CURRENT_TIMESTAMP()                                     AS CREATED_AT
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_LOAD_HISTORY
WHERE WAREHOUSE_NAME LIKE 'MEDICORE_%'
  AND START_TIME >= DATEADD('HOUR', -24, CURRENT_TIMESTAMP())
GROUP BY WAREHOUSE_NAME
ORDER BY AVG_QUERIES_RUNNING DESC;


-- ============================================================
-- SECTION 5: MONTHLY COST AGGREGATIONS
-- ============================================================
-- Views for cost attribution and monthly reporting.
-- ============================================================

-- ------------------------------------------------------------
-- V_COST_BY_WAREHOUSE_MONTH
-- Purpose: Monthly credit costs by warehouse for budgeting
-- Data Latency: Up to 3 hours
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW MEDICORE_GOVERNANCE_DB.AUDIT.V_COST_BY_WAREHOUSE_MONTH
    COMMENT = 'Monthly credit costs by MEDICORE warehouse. Use for budgeting, cost attribution, and chargeback reporting. Data latency: up to 3 hours from SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY.'
AS
SELECT
    WAREHOUSE_NAME                                          AS WAREHOUSE_NAME,
    DATE_TRUNC('MONTH', START_TIME)                         AS USAGE_MONTH,
    ROUND(SUM(CREDITS_USED), 4)                             AS CREDITS_USED_COMPUTE,
    ROUND(SUM(CREDITS_USED_CLOUD_SERVICES), 4)              AS CREDITS_USED_CLOUD_SERVICES,
    ROUND(SUM(CREDITS_USED) + SUM(CREDITS_USED_CLOUD_SERVICES), 4) 
                                                            AS TOTAL_CREDITS,
    COUNT(DISTINCT DATE_TRUNC('DAY', START_TIME))           AS ACTIVE_DAYS,
    ROUND((SUM(CREDITS_USED) + SUM(CREDITS_USED_CLOUD_SERVICES)) / 
          NULLIF(COUNT(DISTINCT DATE_TRUNC('DAY', START_TIME)), 0), 4) 
                                                            AS AVG_CREDITS_PER_DAY,
    ROUND(SUM(CREDITS_USED) + SUM(CREDITS_USED_CLOUD_SERVICES), 4) * 3.00 
                                                            AS ESTIMATED_COST_USD,
    CURRENT_TIMESTAMP()                                     AS CREATED_AT
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE WAREHOUSE_NAME LIKE 'MEDICORE_%'
  AND START_TIME >= DATEADD('MONTH', -12, CURRENT_DATE())
GROUP BY WAREHOUSE_NAME, DATE_TRUNC('MONTH', START_TIME)
ORDER BY USAGE_MONTH DESC, TOTAL_CREDITS DESC;


-- ============================================================
-- SECTION 6: SECURITY GRANTS
-- ============================================================
-- Grant SELECT to admin and compliance roles only.
-- ============================================================

GRANT SELECT ON MEDICORE_GOVERNANCE_DB.AUDIT.V_WAREHOUSE_CREDIT_USAGE TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT SELECT ON MEDICORE_GOVERNANCE_DB.AUDIT.V_WAREHOUSE_CREDIT_USAGE TO ROLE MEDICORE_COMPLIANCE_OFFICER;

GRANT SELECT ON MEDICORE_GOVERNANCE_DB.AUDIT.V_QUERY_PERFORMANCE TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT SELECT ON MEDICORE_GOVERNANCE_DB.AUDIT.V_QUERY_PERFORMANCE TO ROLE MEDICORE_COMPLIANCE_OFFICER;

GRANT SELECT ON MEDICORE_GOVERNANCE_DB.AUDIT.V_LONG_RUNNING_QUERIES TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT SELECT ON MEDICORE_GOVERNANCE_DB.AUDIT.V_LONG_RUNNING_QUERIES TO ROLE MEDICORE_COMPLIANCE_OFFICER;

GRANT SELECT ON MEDICORE_GOVERNANCE_DB.AUDIT.V_FAILED_QUERIES TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT SELECT ON MEDICORE_GOVERNANCE_DB.AUDIT.V_FAILED_QUERIES TO ROLE MEDICORE_COMPLIANCE_OFFICER;

GRANT SELECT ON MEDICORE_GOVERNANCE_DB.AUDIT.V_RESOURCE_MONITOR_STATUS TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT SELECT ON MEDICORE_GOVERNANCE_DB.AUDIT.V_RESOURCE_MONITOR_STATUS TO ROLE MEDICORE_COMPLIANCE_OFFICER;

GRANT SELECT ON MEDICORE_GOVERNANCE_DB.AUDIT.V_WAREHOUSE_UTILIZATION TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT SELECT ON MEDICORE_GOVERNANCE_DB.AUDIT.V_WAREHOUSE_UTILIZATION TO ROLE MEDICORE_COMPLIANCE_OFFICER;

GRANT SELECT ON MEDICORE_GOVERNANCE_DB.AUDIT.V_ACTIVE_WAREHOUSE_LOAD TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT SELECT ON MEDICORE_GOVERNANCE_DB.AUDIT.V_ACTIVE_WAREHOUSE_LOAD TO ROLE MEDICORE_COMPLIANCE_OFFICER;

GRANT SELECT ON MEDICORE_GOVERNANCE_DB.AUDIT.V_COST_BY_WAREHOUSE_MONTH TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT SELECT ON MEDICORE_GOVERNANCE_DB.AUDIT.V_COST_BY_WAREHOUSE_MONTH TO ROLE MEDICORE_COMPLIANCE_OFFICER;


-- ============================================================
-- SECTION 7: VERIFICATION QUERIES
-- ============================================================
-- Confirm all views were created successfully.
-- ============================================================

SHOW VIEWS IN SCHEMA MEDICORE_GOVERNANCE_DB.AUDIT;

SELECT COUNT(*) AS ROW_COUNT FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_WAREHOUSE_CREDIT_USAGE;

SELECT COUNT(*) AS ROW_COUNT FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_RESOURCE_MONITOR_STATUS;


-- ============================================================
-- PHASE 06 SUMMARY
-- ============================================================
--
-- VIEWS CREATED: 8
--
--   Section 1 - Warehouse Credit Monitoring:
--     1. V_WAREHOUSE_CREDIT_USAGE
--
--   Section 2 - Query Monitoring:
--     2. V_QUERY_PERFORMANCE
--     3. V_LONG_RUNNING_QUERIES
--     4. V_FAILED_QUERIES
--
--   Section 3 - Resource Monitor Tracking:
--     5. V_RESOURCE_MONITOR_STATUS
--
--   Section 4 - Capacity & Load Monitoring:
--     6. V_WAREHOUSE_UTILIZATION
--     7. V_ACTIVE_WAREHOUSE_LOAD
--
--   Section 5 - Monthly Cost Aggregations:
--     8. V_COST_BY_WAREHOUSE_MONTH
--
-- GRANTS ISSUED: 16
--   - SELECT on all 8 views to MEDICORE_PLATFORM_ADMIN
--   - SELECT on all 8 views to MEDICORE_COMPLIANCE_OFFICER
--
-- DATA LATENCY:
--   - Query views: up to 45 minutes
--   - Warehouse/Resource views: up to 3 hours
--
-- ============================================================
-- END OF PHASE 06: MONITORING VIEWS
-- ============================================================
