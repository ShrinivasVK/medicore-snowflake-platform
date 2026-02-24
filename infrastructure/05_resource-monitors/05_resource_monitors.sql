-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 05: Resource Monitors
-- Script: 05_resource_monitors.sql
--
-- Description:
--   Creates resource monitors to implement cost controls at both
--   account level and individual warehouse level. This script
--   COMPLETES THE DEFERRED WORK FROM PHASE 03 by assigning
--   resource monitors to all 4 MEDICORE warehouses.
--
-- Resource Monitors Created:
--   1. MEDICORE_ACCOUNT_MONITOR     - Account-level (10,000 credits/month)
--   2. MEDICORE_ADMIN_WH_MONITOR    - Admin warehouse (100 credits/month)
--   3. MEDICORE_ETL_WH_MONITOR      - ETL warehouse (3,000 credits/month)
--   4. MEDICORE_ANALYTICS_WH_MONITOR- Analytics warehouse (5,000 credits/month)
--   5. MEDICORE_ML_WH_MONITOR       - ML warehouse (1,500 credits/month)
--
-- Execution Requirements:
--   - Must be run as ACCOUNTADMIN
--   - Execute statements sequentially from top to bottom
--   - Estimated execution time: 1-2 minutes
--
-- Dependencies:
--   - Phase 01 (Account Administration) completed
--   - Phase 02 (RBAC Setup) completed - all 17 roles exist
--   - Phase 03 (Warehouse Management) completed - all 4 warehouses exist
--   - Phase 04 (Database Structure) completed - GOVERNANCE_DB exists
--
-- !! WARNING !!
--   Resource monitors with SUSPEND or SUSPEND_IMMEDIATE triggers will
--   HALT warehouse operations when credit thresholds are reached.
--   - SUSPEND: Allows running queries to complete, blocks new queries
--   - SUSPEND_IMMEDIATE: Cancels running queries immediately
--   Review credit quotas carefully before execution. In production,
--   quotas should be sized against actual workload baselines.
--
-- !! NOTIFICATION NOTE !!
--   Email notifications require account-level notification integration
--   to be configured separately (NOTIFICATION INTEGRATION object).
--   This script sets up monitors with NOTIFY triggers, but actual
--   email delivery requires additional configuration.
--   -- Replace with real DL email before production:
--   -- platform-alerts@medicore-health.com
--
-- Author: [YOUR_NAME]
-- Date: [YYYY-MM-DD]
-- ============================================================


-- ============================================================
-- SECTION 1: EXECUTION CONTEXT
-- ============================================================

USE ROLE ACCOUNTADMIN;


-- ============================================================
-- SECTION 2: ACCOUNT-LEVEL RESOURCE MONITOR
-- ============================================================
-- The account-level monitor provides a hard cap on total credit
-- consumption across ALL warehouses combined. This is the
-- financial safety net for the entire platform.
-- ============================================================

-- ------------------------------------------------------------
-- MEDICORE_ACCOUNT_MONITOR
-- Purpose: Hard cap on total account credit consumption
-- Quota: 10,000 credits per month
-- Triggers:
--   75%  (7,500 credits)  : NOTIFY - Warning threshold
--   90%  (9,000 credits)  : NOTIFY - Critical warning
--   100% (10,000 credits) : SUSPEND - Block new queries
--   110% (11,000 credits) : SUSPEND_IMMEDIATE - Emergency stop
-- Rationale: Protects against total platform cost overrun.
--            In production, size against actual workload baseline.
-- ------------------------------------------------------------
CREATE OR REPLACE RESOURCE MONITOR MEDICORE_ACCOUNT_MONITOR
    WITH
        CREDIT_QUOTA = 10000
        FREQUENCY = MONTHLY
        START_TIMESTAMP = IMMEDIATELY
    TRIGGERS
        ON 75 PERCENT DO NOTIFY
        ON 90 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND
        ON 110 PERCENT DO SUSPEND_IMMEDIATE;

-- Apply account-level monitor to the account
-- This ensures ALL credit consumption is tracked at the account level
ALTER ACCOUNT SET RESOURCE_MONITOR = MEDICORE_ACCOUNT_MONITOR;

-- Verification: Account monitor applied
SHOW RESOURCE MONITORS LIKE 'MEDICORE_ACCOUNT_MONITOR';


-- ============================================================
-- SECTION 3: WAREHOUSE-LEVEL RESOURCE MONITORS
-- ============================================================
-- Individual warehouse monitors provide granular cost control
-- per workload type. Each monitor is created and immediately
-- assigned to its warehouse to ensure the relationship is clear.
-- ============================================================

-- ------------------------------------------------------------
-- MONITOR 1: MEDICORE_ADMIN_WH_MONITOR
-- Warehouse: MEDICORE_ADMIN_WH
-- Quota: 100 credits per month
-- Triggers:
--   75%  (75 credits)   : NOTIFY
--   90%  (90 credits)   : NOTIFY
--   100% (100 credits)  : SUSPEND
-- Rationale: Admin queries are metadata-only and lightweight.
--            If this quota is hit, something unusual is happening
--            on the admin warehouse that warrants investigation.
--            No SUSPEND_IMMEDIATE because admin queries are low-risk.
-- ------------------------------------------------------------
CREATE OR REPLACE RESOURCE MONITOR MEDICORE_ADMIN_WH_MONITOR
    WITH
        CREDIT_QUOTA = 100
        FREQUENCY = MONTHLY
        START_TIMESTAMP = IMMEDIATELY
    TRIGGERS
        ON 75 PERCENT DO NOTIFY
        ON 90 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND;

-- Assign monitor to warehouse (completes Phase 03 deferred work)
ALTER WAREHOUSE MEDICORE_ADMIN_WH SET RESOURCE_MONITOR = MEDICORE_ADMIN_WH_MONITOR;

-- Verification
SHOW RESOURCE MONITORS LIKE 'MEDICORE_ADMIN_WH_MONITOR';

-- ------------------------------------------------------------
-- MONITOR 2: MEDICORE_ETL_WH_MONITOR
-- Warehouse: MEDICORE_ETL_WH
-- Quota: 3,000 credits per month
-- Triggers:
--   75%  (2,250 credits) : NOTIFY
--   90%  (2,700 credits) : NOTIFY
--   100% (3,000 credits) : SUSPEND
--   110% (3,300 credits) : SUSPEND_IMMEDIATE
-- Rationale: ETL pipelines are the highest sustained consumer.
--            3,000 credits sized for daily batch loads and
--            Dynamic Table refreshes. SUSPEND_IMMEDIATE at 110%
--            because a runaway pipeline could cascade and affect
--            downstream reporting.
-- ------------------------------------------------------------
CREATE OR REPLACE RESOURCE MONITOR MEDICORE_ETL_WH_MONITOR
    WITH
        CREDIT_QUOTA = 3000
        FREQUENCY = MONTHLY
        START_TIMESTAMP = IMMEDIATELY
    TRIGGERS
        ON 75 PERCENT DO NOTIFY
        ON 90 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND
        ON 110 PERCENT DO SUSPEND_IMMEDIATE;

-- Assign monitor to warehouse (completes Phase 03 deferred work)
ALTER WAREHOUSE MEDICORE_ETL_WH SET RESOURCE_MONITOR = MEDICORE_ETL_WH_MONITOR;

-- Verification
SHOW RESOURCE MONITORS LIKE 'MEDICORE_ETL_WH_MONITOR';

-- ------------------------------------------------------------
-- MONITOR 3: MEDICORE_ANALYTICS_WH_MONITOR
-- Warehouse: MEDICORE_ANALYTICS_WH
-- Quota: 5,000 credits per month
-- Triggers:
--   75%  (3,750 credits) : NOTIFY
--   90%  (4,500 credits) : NOTIFY
--   100% (5,000 credits) : SUSPEND
--   110% (5,500 credits) : SUSPEND_IMMEDIATE
-- Rationale: Largest allocation because this warehouse serves
--            the most users (clinical, billing, analysts, execs).
--            Suspension here directly impacts clinical staff.
--            The 110% SUSPEND_IMMEDIATE is a hard safety net
--            only — not expected to trigger in normal operations.
-- ------------------------------------------------------------
CREATE OR REPLACE RESOURCE MONITOR MEDICORE_ANALYTICS_WH_MONITOR
    WITH
        CREDIT_QUOTA = 5000
        FREQUENCY = MONTHLY
        START_TIMESTAMP = IMMEDIATELY
    TRIGGERS
        ON 75 PERCENT DO NOTIFY
        ON 90 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND
        ON 110 PERCENT DO SUSPEND_IMMEDIATE;

-- Assign monitor to warehouse (completes Phase 03 deferred work)
ALTER WAREHOUSE MEDICORE_ANALYTICS_WH SET RESOURCE_MONITOR = MEDICORE_ANALYTICS_WH_MONITOR;

-- Verification
SHOW RESOURCE MONITORS LIKE 'MEDICORE_ANALYTICS_WH_MONITOR';

-- ------------------------------------------------------------
-- MONITOR 4: MEDICORE_ML_WH_MONITOR
-- Warehouse: MEDICORE_ML_WH
-- Quota: 1,500 credits per month
-- Triggers:
--   75%  (1,125 credits) : NOTIFY
--   90%  (1,350 credits) : NOTIFY
--   100% (1,500 credits) : SUSPEND
--   110% (1,650 credits) : SUSPEND_IMMEDIATE
-- Rationale: ML training is compute-intensive but infrequent.
--            1,500 credits provides headroom for model training
--            cycles. SUSPEND_IMMEDIATE because ML jobs that exceed
--            quota should be investigated before resuming — not
--            silently continue consuming credits.
-- ------------------------------------------------------------
CREATE OR REPLACE RESOURCE MONITOR MEDICORE_ML_WH_MONITOR
    WITH
        CREDIT_QUOTA = 1500
        FREQUENCY = MONTHLY
        START_TIMESTAMP = IMMEDIATELY
    TRIGGERS
        ON 75 PERCENT DO NOTIFY
        ON 90 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND
        ON 110 PERCENT DO SUSPEND_IMMEDIATE;

-- Assign monitor to warehouse (completes Phase 03 deferred work)
ALTER WAREHOUSE MEDICORE_ML_WH SET RESOURCE_MONITOR = MEDICORE_ML_WH_MONITOR;

-- Verification
SHOW RESOURCE MONITORS LIKE 'MEDICORE_ML_WH_MONITOR';


-- ============================================================
-- SECTION 4: MONITOR ASSIGNMENT VERIFICATION
-- ============================================================
-- Consolidated verification that all warehouses have their
-- resource monitors correctly assigned.
-- ============================================================

-- Verify all resource monitors exist
SHOW RESOURCE MONITORS LIKE 'MEDICORE%';

-- Verify warehouse-to-monitor assignments
-- Note: ACCOUNT_USAGE views have up to 2-hour latency
-- Use SHOW WAREHOUSES for immediate verification
SHOW WAREHOUSES LIKE 'MEDICORE%';


-- ============================================================
-- SECTION 5: CREDIT CONSUMPTION BASELINE VIEWS
-- ============================================================
-- Creating foundational views for cost monitoring that will
-- be expanded in Phase 06 (Monitoring Views).
-- ============================================================

USE DATABASE GOVERNANCE_DB;
USE SCHEMA SECURITY;

-- ------------------------------------------------------------
-- VIEW 1: MEDICORE_CREDIT_USAGE_SUMMARY
-- Purpose: Current month credit consumption per warehouse
-- Usage: Quick overview of warehouse credit burn rate
-- Foundation for: Phase 06 cost dashboards
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW GOVERNANCE_DB.SECURITY.MEDICORE_CREDIT_USAGE_SUMMARY
AS
SELECT 
    warehouse_name,
    SUM(credits_used_compute) AS credits_used_compute,
    SUM(credits_used_cloud_services) AS credits_used_cloud_services,
    SUM(credits_used_compute + credits_used_cloud_services) AS total_credits_used
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE start_time >= DATE_TRUNC('MONTH', CURRENT_DATE())
AND warehouse_name LIKE 'MEDICORE%'
GROUP BY warehouse_name
ORDER BY total_credits_used DESC;

-- ------------------------------------------------------------
-- VIEW 2: MEDICORE_RESOURCE_MONITOR_STATUS
-- Purpose: All MediCore resource monitors with quota status
-- Usage: Monitor credit quota utilisation at a glance
-- Foundation for: Phase 06 alerting and dashboards
-- Note: ACCOUNT_USAGE.RESOURCE_MONITORS has limited columns;
--       use SHOW RESOURCE MONITORS for full trigger details
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW GOVERNANCE_DB.SECURITY.MEDICORE_RESOURCE_MONITOR_STATUS
AS
SELECT 
    name AS monitor_name,
    credit_quota,
    used_credits,
    remaining_credits,
    ROUND((used_credits / NULLIF(credit_quota, 0)) * 100, 2) AS percent_used,
    CASE 
        WHEN (used_credits / NULLIF(credit_quota, 0)) >= 1.0 THEN 'SUSPENDED'
        WHEN (used_credits / NULLIF(credit_quota, 0)) >= 0.9 THEN 'CRITICAL'
        WHEN (used_credits / NULLIF(credit_quota, 0)) >= 0.75 THEN 'WARNING'
        ELSE 'NORMAL'
    END AS status
FROM SNOWFLAKE.ACCOUNT_USAGE.RESOURCE_MONITORS
WHERE name LIKE 'MEDICORE%';

-- Note: These views are foundational for Phase 06 - Monitoring Views
-- Phase 06 will build a more comprehensive monitoring layer including:
-- - Daily/weekly/monthly trend analysis
-- - Cost forecasting
-- - Anomaly detection
-- - Role-based cost attribution


-- ============================================================
-- SECTION 6: GRANTS ON GOVERNANCE VIEWS
-- ============================================================
-- Granting SELECT on credit monitoring views to appropriate
-- administrative and compliance roles.
-- ============================================================

-- MEDICORE_PLATFORM_ADMIN: Full visibility into cost metrics
-- Rationale: Platform admins need to monitor and manage costs
GRANT SELECT ON VIEW GOVERNANCE_DB.SECURITY.MEDICORE_CREDIT_USAGE_SUMMARY 
    TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT SELECT ON VIEW GOVERNANCE_DB.SECURITY.MEDICORE_RESOURCE_MONITOR_STATUS 
    TO ROLE MEDICORE_PLATFORM_ADMIN;

-- MEDICORE_SECURITY_ADMIN: Visibility for security cost audits
-- Rationale: Security admins may need to investigate unusual consumption patterns
GRANT SELECT ON VIEW GOVERNANCE_DB.SECURITY.MEDICORE_CREDIT_USAGE_SUMMARY 
    TO ROLE MEDICORE_SECURITY_ADMIN;
GRANT SELECT ON VIEW GOVERNANCE_DB.SECURITY.MEDICORE_RESOURCE_MONITOR_STATUS 
    TO ROLE MEDICORE_SECURITY_ADMIN;

-- MEDICORE_COMPLIANCE_OFFICER: Visibility for compliance reporting
-- Rationale: Compliance needs cost data for budget compliance verification
GRANT SELECT ON VIEW GOVERNANCE_DB.SECURITY.MEDICORE_CREDIT_USAGE_SUMMARY 
    TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON VIEW GOVERNANCE_DB.SECURITY.MEDICORE_RESOURCE_MONITOR_STATUS 
    TO ROLE MEDICORE_COMPLIANCE_OFFICER;


-- ============================================================
-- SECTION 7: VERIFICATION QUERIES
-- ============================================================
-- Comprehensive verification of all Phase 05 components
-- ============================================================

-- Verify all 5 resource monitors exist (use SHOW for immediate results)
-- Note: ACCOUNT_USAGE has up to 2-hour latency
SHOW RESOURCE MONITORS LIKE 'MEDICORE%';

-- Verify account monitor is applied
-- Note: This query checks the account-level resource monitor setting
SHOW PARAMETERS LIKE 'RESOURCE_MONITOR' IN ACCOUNT;

-- Verify all warehouse monitors are assigned (immediate check)
-- Using SHOW for real-time data (ACCOUNT_USAGE has latency)
SHOW WAREHOUSES LIKE 'MEDICORE%';

-- Verify governance views exist and are queryable
SELECT COUNT(*) AS warehouse_count FROM GOVERNANCE_DB.SECURITY.MEDICORE_CREDIT_USAGE_SUMMARY;
SELECT COUNT(*) AS monitor_count FROM GOVERNANCE_DB.SECURITY.MEDICORE_RESOURCE_MONITOR_STATUS;

-- Verify no MEDICORE warehouse has NULL resource monitor
-- Note: Using SHOW WAREHOUSES output for immediate verification
-- In ACCOUNT_USAGE, check after 2-hour latency window:
-- SELECT WAREHOUSE_NAME, RESOURCE_MONITOR
-- FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
-- WHERE WAREHOUSE_NAME LIKE 'MEDICORE%'
-- AND DELETED_ON IS NULL
-- AND RESOURCE_MONITOR IS NULL;
-- Expected: 0 rows (all warehouses have monitors assigned)


-- ============================================================
-- SECTION 8: PHASE 05 SUMMARY
-- ============================================================
--
-- RESOURCE MONITORS CREATED: 5
--   1. MEDICORE_ACCOUNT_MONITOR (Account-level)
--      - Quota: 10,000 credits/month
--      - Triggers: NOTIFY@75%, NOTIFY@90%, SUSPEND@100%, SUSPEND_IMMEDIATE@110%
--      - Applied to: Account (ALTER ACCOUNT SET RESOURCE_MONITOR)
--
--   2. MEDICORE_ADMIN_WH_MONITOR
--      - Quota: 100 credits/month
--      - Triggers: NOTIFY@75%, NOTIFY@90%, SUSPEND@100%
--      - Assigned to: MEDICORE_ADMIN_WH
--
--   3. MEDICORE_ETL_WH_MONITOR
--      - Quota: 3,000 credits/month
--      - Triggers: NOTIFY@75%, NOTIFY@90%, SUSPEND@100%, SUSPEND_IMMEDIATE@110%
--      - Assigned to: MEDICORE_ETL_WH
--
--   4. MEDICORE_ANALYTICS_WH_MONITOR
--      - Quota: 5,000 credits/month
--      - Triggers: NOTIFY@75%, NOTIFY@90%, SUSPEND@100%, SUSPEND_IMMEDIATE@110%
--      - Assigned to: MEDICORE_ANALYTICS_WH
--
--   5. MEDICORE_ML_WH_MONITOR
--      - Quota: 1,500 credits/month
--      - Triggers: NOTIFY@75%, NOTIFY@90%, SUSPEND@100%, SUSPEND_IMMEDIATE@110%
--      - Assigned to: MEDICORE_ML_WH
--
-- TOTAL MONTHLY CREDIT ALLOCATION: 9,600 credits (warehouse-level)
--   - Admin: 100 (1%)
--   - ETL: 3,000 (31%)
--   - Analytics: 5,000 (52%)
--   - ML: 1,500 (16%)
--
-- GOVERNANCE VIEWS CREATED: 2
--   - GOVERNANCE_DB.SECURITY.MEDICORE_CREDIT_USAGE_SUMMARY
--   - GOVERNANCE_DB.SECURITY.MEDICORE_RESOURCE_MONITOR_STATUS
--
-- VIEW GRANTS: 6
--   - SELECT on both views to PLATFORM_ADMIN, SECURITY_ADMIN, COMPLIANCE_OFFICER
--
-- PHASE 03 DEFERRED ITEMS NOW COMPLETE:
--   ✓ MEDICORE_ACCOUNT_MONITOR created and applied to account
--   ✓ MEDICORE_ADMIN_WH_MONITOR created and assigned to MEDICORE_ADMIN_WH
--   ✓ MEDICORE_ETL_WH_MONITOR created and assigned to MEDICORE_ETL_WH
--   ✓ MEDICORE_ANALYTICS_WH_MONITOR created and assigned to MEDICORE_ANALYTICS_WH
--   ✓ MEDICORE_ML_WH_MONITOR created and assigned to MEDICORE_ML_WH
--   ✓ All ALTER WAREHOUSE SET RESOURCE_MONITOR statements executed
--
-- PHASE 06 DEPENDENCIES:
--   - Resource monitors in place for cost tracking
--   - Baseline views available for monitoring dashboards
--   - Phase 06 will expand monitoring with:
--     * Daily/weekly/monthly trend views
--     * Cost forecasting
--     * Query-level attribution
--     * Alerting integration
--
-- PRODUCTION SIZING CONSIDERATIONS:
--   - Quotas in this script are illustrative and should be adjusted
--     based on actual workload baselines in production
--   - Monitor credit consumption for 2-4 weeks before setting
--     final production quotas
--   - Consider seasonal variations (month-end, quarter-end reporting)
--   - ETL quota may need increase during initial data migration
--   - Analytics quota may spike during regulatory audit periods
--
-- NOTIFICATION CONFIGURATION:
--   - NOTIFY triggers are configured but email delivery requires
--     NOTIFICATION INTEGRATION object to be created separately
--   - Recommended: Create notification integration and update monitors
--     to use NOTIFY_USERS parameter for email alerts
--   - Target DL: platform-alerts@medicore-health.com (placeholder)
--
-- ============================================================
-- END OF PHASE 05: RESOURCE MONITORS
-- ============================================================
