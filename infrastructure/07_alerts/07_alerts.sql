-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 07: Alerts
-- Script: 07_alerts.sql
--
-- Description:
--   Implements automated Snowflake ALERT objects for proactive
--   monitoring of credit usage, query performance, warehouse
--   capacity, and cost governance. Alerts query Phase 06
--   monitoring views and send notifications via email.
--
-- Alerts Created:
--   1. ALERT_RESOURCE_MONITOR_CRITICAL - Resource monitor >= 90%
--   2. ALERT_LONG_RUNNING_QUERY        - Queries > 5 minutes
--   3. ALERT_FAILED_QUERY_SPIKE        - Failed query threshold
--   4. ALERT_HIGH_WAREHOUSE_QUEUE      - Queue overload detection
--   5. ALERT_MONTHLY_COST_SPIKE        - Month-over-month spike
--
-- Notification:
--   All alerts send email via SYSTEM$SEND_EMAIL to:
--   platform-alerts@medicore-health.com
--
-- Security:
--   - Alerts owned by ACCOUNTADMIN
--   - Only MEDICORE_PLATFORM_ADMIN can ENABLE/DISABLE
--   - No access to clinical, billing, or analyst roles
--
-- Execution Requirements:
--   - Must be run as ACCOUNTADMIN
--   - Phase 06 monitoring views must exist
--   - MEDICORE_ADMIN_WH must exist
--   - Email notification integration assumed configured
--   - Compatible with MEDICORE_SVC_GITHUB_ACTIONS
--
-- Initial State:
--   All alerts created in SUSPENDED state.
--   Enable statements provided in Section 5.
--
-- Author: MediCore Platform Team
-- Date: 2026-02-25
-- ============================================================


USE ROLE ACCOUNTADMIN;
USE DATABASE MEDICORE_GOVERNANCE_DB;
USE SCHEMA MEDICORE_GOVERNANCE_DB.AUDIT;


-- ============================================================
-- SECTION 1: RESOURCE MONITOR ALERTS
-- ============================================================
-- Alerts for credit consumption and resource monitor thresholds.
-- ============================================================

-- ------------------------------------------------------------
-- ALERT_RESOURCE_MONITOR_CRITICAL
-- Purpose: Detect resource monitors at >= 90% consumption
-- Schedule: Every 30 minutes
-- Severity: CRITICAL
-- Action: Immediate attention required to prevent suspension
-- ------------------------------------------------------------
CREATE OR REPLACE ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_RESOURCE_MONITOR_CRITICAL
    WAREHOUSE = MEDICORE_ADMIN_WH
    SCHEDULE = 'USING CRON 0,30 * * * * UTC'
    COMMENT = 'CRITICAL: Detects resource monitors at or above 90% credit consumption. Triggers every 30 minutes. Immediate attention required to prevent warehouse suspension. Query source: V_RESOURCE_MONITOR_STATUS.'
    IF (EXISTS (
        SELECT 1
        FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_RESOURCE_MONITOR_STATUS
        WHERE PERCENTAGE_USED >= 90
    ))
    THEN
        CALL SYSTEM$SEND_EMAIL(
            'platform-alerts@medicore-health.com',
            'CRITICAL: MediCore Resource Monitor Alert - Near Suspension Threshold',
            (SELECT OBJECT_CONSTRUCT(
                'severity', 'CRITICAL',
                'alert_name', 'ALERT_RESOURCE_MONITOR_CRITICAL',
                'event_timestamp', CURRENT_TIMESTAMP()::VARCHAR,
                'description', 'One or more resource monitors have reached 90% or higher credit consumption',
                'monitors_affected', (
                    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
                        'monitor_name', MONITOR_NAME,
                        'percentage_used', PERCENTAGE_USED,
                        'credit_quota', CREDIT_QUOTA,
                        'remaining_credits', REMAINING_CREDITS,
                        'health_status', HEALTH_STATUS
                    ))
                    FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_RESOURCE_MONITOR_STATUS
                    WHERE PERCENTAGE_USED >= 90
                ),
                'recommended_action', 'Review credit consumption immediately. Consider increasing quota or optimizing workloads.'
            )::VARCHAR)
        );


-- ============================================================
-- SECTION 2: QUERY ALERTS
-- ============================================================
-- Alerts for query performance and failure monitoring.
-- ============================================================

-- ------------------------------------------------------------
-- ALERT_LONG_RUNNING_QUERY
-- Purpose: Detect queries exceeding 5 minutes in last 15 min
-- Schedule: Every 15 minutes
-- Severity: WARNING
-- Action: Review and optimize long-running queries
-- ------------------------------------------------------------
CREATE OR REPLACE ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_LONG_RUNNING_QUERY
    WAREHOUSE = MEDICORE_ADMIN_WH
    SCHEDULE = 'USING CRON 0,15,30,45 * * * * UTC'
    COMMENT = 'WARNING: Detects queries exceeding 5 minutes execution time in the last 15 minutes. Triggers every 15 minutes. Review query patterns for optimization opportunities. Query source: V_LONG_RUNNING_QUERIES.'
    IF (EXISTS (
        SELECT 1
        FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_LONG_RUNNING_QUERIES
        WHERE START_TIME >= DATEADD('MINUTE', -15, CURRENT_TIMESTAMP())
    ))
    THEN
        CALL SYSTEM$SEND_EMAIL(
            'platform-alerts@medicore-health.com',
            'WARNING: MediCore Long Running Query Alert',
            (SELECT OBJECT_CONSTRUCT(
                'severity', 'WARNING',
                'alert_name', 'ALERT_LONG_RUNNING_QUERY',
                'event_timestamp', CURRENT_TIMESTAMP()::VARCHAR,
                'description', 'Long-running queries detected in the last 15 minutes',
                'query_count', (
                    SELECT COUNT(*)
                    FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_LONG_RUNNING_QUERIES
                    WHERE START_TIME >= DATEADD('MINUTE', -15, CURRENT_TIMESTAMP())
                ),
                'sample_queries', (
                    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
                        'query_id', QUERY_ID,
                        'user_name', USER_NAME,
                        'warehouse_name', WAREHOUSE_NAME,
                        'execution_time_minutes', EXECUTION_TIME_MINUTES
                    ))
                    FROM (
                        SELECT QUERY_ID, USER_NAME, WAREHOUSE_NAME, EXECUTION_TIME_MINUTES
                        FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_LONG_RUNNING_QUERIES
                        WHERE START_TIME >= DATEADD('MINUTE', -15, CURRENT_TIMESTAMP())
                        ORDER BY EXECUTION_TIME_MINUTES DESC
                        LIMIT 5
                    )
                ),
                'recommended_action', 'Review query patterns and consider optimization or warehouse sizing adjustments.'
            )::VARCHAR)
        );


-- ------------------------------------------------------------
-- ALERT_FAILED_QUERY_SPIKE
-- Purpose: Detect > 10 failed queries in last 15 minutes
-- Schedule: Every 15 minutes
-- Severity: WARNING
-- Action: Investigate error patterns
-- ------------------------------------------------------------
CREATE OR REPLACE ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_FAILED_QUERY_SPIKE
    WAREHOUSE = MEDICORE_ADMIN_WH
    SCHEDULE = 'USING CRON 0,15,30,45 * * * * UTC'
    COMMENT = 'WARNING: Detects more than 10 failed queries in the last 15 minutes. Triggers every 15 minutes. Investigate error patterns and user issues. Query source: V_FAILED_QUERIES.'
    IF (EXISTS (
        SELECT 1
        FROM (
            SELECT COUNT(*) AS failed_count
            FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_FAILED_QUERIES
            WHERE START_TIME >= DATEADD('MINUTE', -15, CURRENT_TIMESTAMP())
        )
        WHERE failed_count > 10
    ))
    THEN
        CALL SYSTEM$SEND_EMAIL(
            'platform-alerts@medicore-health.com',
            'WARNING: MediCore Failed Query Spike Alert',
            (SELECT OBJECT_CONSTRUCT(
                'severity', 'WARNING',
                'alert_name', 'ALERT_FAILED_QUERY_SPIKE',
                'event_timestamp', CURRENT_TIMESTAMP()::VARCHAR,
                'description', 'More than 10 failed queries detected in the last 15 minutes',
                'failed_query_count', (
                    SELECT COUNT(*)
                    FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_FAILED_QUERIES
                    WHERE START_TIME >= DATEADD('MINUTE', -15, CURRENT_TIMESTAMP())
                ),
                'error_summary', (
                    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
                        'error_code', ERROR_CODE,
                        'occurrence_count', cnt
                    ))
                    FROM (
                        SELECT ERROR_CODE, COUNT(*) AS cnt
                        FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_FAILED_QUERIES
                        WHERE START_TIME >= DATEADD('MINUTE', -15, CURRENT_TIMESTAMP())
                        GROUP BY ERROR_CODE
                        ORDER BY cnt DESC
                        LIMIT 5
                    )
                ),
                'recommended_action', 'Review error codes and investigate affected users or workloads.'
            )::VARCHAR)
        );


-- ============================================================
-- SECTION 3: WAREHOUSE CAPACITY ALERTS
-- ============================================================
-- Alerts for warehouse load and queue monitoring.
-- ============================================================

-- ------------------------------------------------------------
-- ALERT_HIGH_WAREHOUSE_QUEUE
-- Purpose: Detect warehouses with AVG_QUERIES_QUEUED > 5
-- Schedule: Every 30 minutes
-- Severity: WARNING
-- Action: Consider scaling warehouse
-- ------------------------------------------------------------
CREATE OR REPLACE ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_HIGH_WAREHOUSE_QUEUE
    WAREHOUSE = MEDICORE_ADMIN_WH
    SCHEDULE = 'USING CRON 0,30 * * * * UTC'
    COMMENT = 'WARNING: Detects warehouses with average queued queries exceeding 5. Triggers every 30 minutes. Indicates potential need for warehouse scaling or workload redistribution. Query source: V_ACTIVE_WAREHOUSE_LOAD.'
    IF (EXISTS (
        SELECT 1
        FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_ACTIVE_WAREHOUSE_LOAD
        WHERE AVG_QUERIES_QUEUED > 5
    ))
    THEN
        CALL SYSTEM$SEND_EMAIL(
            'platform-alerts@medicore-health.com',
            'WARNING: MediCore High Warehouse Queue Alert',
            (SELECT OBJECT_CONSTRUCT(
                'severity', 'WARNING',
                'alert_name', 'ALERT_HIGH_WAREHOUSE_QUEUE',
                'event_timestamp', CURRENT_TIMESTAMP()::VARCHAR,
                'description', 'One or more warehouses have high query queue load',
                'warehouses_affected', (
                    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
                        'warehouse_name', WAREHOUSE_NAME,
                        'avg_queries_queued', AVG_QUERIES_QUEUED,
                        'avg_queries_running', AVG_QUERIES_RUNNING,
                        'peak_queries_queued', PEAK_QUERIES_QUEUED
                    ))
                    FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_ACTIVE_WAREHOUSE_LOAD
                    WHERE AVG_QUERIES_QUEUED > 5
                ),
                'recommended_action', 'Consider increasing warehouse size or enabling multi-cluster scaling.'
            )::VARCHAR)
        );


-- ============================================================
-- SECTION 4: COST GOVERNANCE ALERTS
-- ============================================================
-- Alerts for cost anomaly detection and budget management.
-- ============================================================

-- ------------------------------------------------------------
-- ALERT_MONTHLY_COST_SPIKE
-- Purpose: Detect current month > 120% of previous month
-- Schedule: Daily at 08:00 UTC
-- Severity: CRITICAL
-- Action: Review cost drivers immediately
-- ------------------------------------------------------------
CREATE OR REPLACE ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_MONTHLY_COST_SPIKE
    WAREHOUSE = MEDICORE_ADMIN_WH
    SCHEDULE = 'USING CRON 0 8 * * * UTC'
    COMMENT = 'CRITICAL: Detects when current month credit consumption exceeds 120% of the previous month. Triggers daily at 08:00 UTC. Indicates potential cost anomaly or unexpected workload increase. Query source: V_COST_BY_WAREHOUSE_MONTH.'
    IF (EXISTS (
        SELECT 1
        FROM (
            SELECT
                SUM(CASE WHEN USAGE_MONTH = DATE_TRUNC('MONTH', CURRENT_DATE()) THEN TOTAL_CREDITS ELSE 0 END) AS current_month_credits,
                SUM(CASE WHEN USAGE_MONTH = DATE_TRUNC('MONTH', DATEADD('MONTH', -1, CURRENT_DATE())) THEN TOTAL_CREDITS ELSE 0 END) AS previous_month_credits
            FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_COST_BY_WAREHOUSE_MONTH
        )
        WHERE current_month_credits > previous_month_credits * 1.2
          AND previous_month_credits > 0
    ))
    THEN
        CALL SYSTEM$SEND_EMAIL(
            'platform-alerts@medicore-health.com',
            'CRITICAL: MediCore Monthly Cost Spike Alert',
            (SELECT OBJECT_CONSTRUCT(
                'severity', 'CRITICAL',
                'alert_name', 'ALERT_MONTHLY_COST_SPIKE',
                'event_timestamp', CURRENT_TIMESTAMP()::VARCHAR,
                'description', 'Current month credit consumption exceeds 120% of previous month',
                'cost_comparison', (
                    SELECT OBJECT_CONSTRUCT(
                        'current_month', DATE_TRUNC('MONTH', CURRENT_DATE())::VARCHAR,
                        'current_month_credits', current_month_credits,
                        'previous_month_credits', previous_month_credits,
                        'percentage_increase', ROUND((current_month_credits / NULLIF(previous_month_credits, 0) - 1) * 100, 2)
                    )
                    FROM (
                        SELECT
                            SUM(CASE WHEN USAGE_MONTH = DATE_TRUNC('MONTH', CURRENT_DATE()) THEN TOTAL_CREDITS ELSE 0 END) AS current_month_credits,
                            SUM(CASE WHEN USAGE_MONTH = DATE_TRUNC('MONTH', DATEADD('MONTH', -1, CURRENT_DATE())) THEN TOTAL_CREDITS ELSE 0 END) AS previous_month_credits
                        FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_COST_BY_WAREHOUSE_MONTH
                    )
                ),
                'top_consumers', (
                    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
                        'warehouse_name', WAREHOUSE_NAME,
                        'total_credits', TOTAL_CREDITS,
                        'estimated_cost_usd', ESTIMATED_COST_USD
                    ))
                    FROM (
                        SELECT WAREHOUSE_NAME, TOTAL_CREDITS, ESTIMATED_COST_USD
                        FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_COST_BY_WAREHOUSE_MONTH
                        WHERE USAGE_MONTH = DATE_TRUNC('MONTH', CURRENT_DATE())
                        ORDER BY TOTAL_CREDITS DESC
                        LIMIT 5
                    )
                ),
                'recommended_action', 'Review warehouse usage patterns and identify cost drivers immediately.'
            )::VARCHAR)
        );


-- ============================================================
-- SECTION 5: ENABLE ALERTS
-- ============================================================
-- Alerts are created in SUSPENDED state by default.
-- Uncomment and execute to enable production alerting.
-- ============================================================

-- NOTE: Alerts are initially SUSPENDED. Uncomment below to enable.
-- Execute only after validating email notification configuration.

-- ALTER ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_RESOURCE_MONITOR_CRITICAL RESUME;
-- ALTER ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_LONG_RUNNING_QUERY RESUME;
-- ALTER ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_FAILED_QUERY_SPIKE RESUME;
-- ALTER ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_HIGH_WAREHOUSE_QUEUE RESUME;
-- ALTER ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_MONTHLY_COST_SPIKE RESUME;


-- ============================================================
-- SECTION 6: SECURITY GRANTS
-- ============================================================
-- Grant OPERATE privilege to allow PLATFORM_ADMIN to manage alerts.
-- ============================================================

GRANT OPERATE ON ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_RESOURCE_MONITOR_CRITICAL TO ROLE MEDICORE_PLATFORM_ADMIN;

GRANT OPERATE ON ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_LONG_RUNNING_QUERY TO ROLE MEDICORE_PLATFORM_ADMIN;

GRANT OPERATE ON ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_FAILED_QUERY_SPIKE TO ROLE MEDICORE_PLATFORM_ADMIN;

GRANT OPERATE ON ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_HIGH_WAREHOUSE_QUEUE TO ROLE MEDICORE_PLATFORM_ADMIN;

GRANT OPERATE ON ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_MONTHLY_COST_SPIKE TO ROLE MEDICORE_PLATFORM_ADMIN;


-- ============================================================
-- SECTION 7: VERIFICATION QUERIES
-- ============================================================
-- Confirm all alerts were created successfully.
-- ============================================================

SHOW ALERTS IN SCHEMA MEDICORE_GOVERNANCE_DB.AUDIT;

SELECT
    NAME AS ALERT_NAME,
    STATE AS CURRENT_STATE,
    SCHEDULE AS SCHEDULE_CRON,
    CONDITION AS ALERT_CONDITION,
    OWNER AS OWNER_ROLE
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
ORDER BY NAME;


-- ============================================================
-- PHASE 07 SUMMARY
-- ============================================================
--
-- ALERTS CREATED: 5
--
--   Section 1 - Resource Monitor Alerts:
--     1. ALERT_RESOURCE_MONITOR_CRITICAL
--        - Condition: PERCENTAGE_USED >= 90
--        - Schedule: Every 30 minutes
--        - Severity: CRITICAL
--
--   Section 2 - Query Alerts:
--     2. ALERT_LONG_RUNNING_QUERY
--        - Condition: Queries > 5 min in last 15 min
--        - Schedule: Every 15 minutes
--        - Severity: WARNING
--
--     3. ALERT_FAILED_QUERY_SPIKE
--        - Condition: > 10 failed queries in last 15 min
--        - Schedule: Every 15 minutes
--        - Severity: WARNING
--
--   Section 3 - Warehouse Capacity Alerts:
--     4. ALERT_HIGH_WAREHOUSE_QUEUE
--        - Condition: AVG_QUERIES_QUEUED > 5
--        - Schedule: Every 30 minutes
--        - Severity: WARNING
--
--   Section 4 - Cost Governance Alerts:
--     5. ALERT_MONTHLY_COST_SPIKE
--        - Condition: Current month > 120% previous month
--        - Schedule: Daily at 08:00 UTC
--        - Severity: CRITICAL
--
-- INITIAL STATE: All alerts created SUSPENDED
--
-- GRANTS ISSUED: 5
--   - OPERATE on all alerts to MEDICORE_PLATFORM_ADMIN
--
-- NOTIFICATION TARGET:
--   platform-alerts@medicore-health.com
--
-- WAREHOUSE USED: MEDICORE_ADMIN_WH (all alerts)
--
-- ============================================================
-- END OF PHASE 07: ALERTS
-- ============================================================
