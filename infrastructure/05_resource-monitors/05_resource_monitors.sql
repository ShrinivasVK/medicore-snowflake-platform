-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 05: Resource Monitors
-- Script: 05_resource_monitors.sql
--
-- Description:
--   Implements cost governance using Snowflake Resource Monitors.
--   Creates one account-level monitor and three warehouse-level
--   monitors to enforce credit consumption limits.
--
-- Why Cost Controls are Critical in HIPAA Environments:
--   1. Budget predictability is essential for healthcare compliance
--   2. Runaway queries on PHI data can indicate security incidents
--   3. Cost anomalies may signal unauthorized data access patterns
--   4. Financial controls support SOC 2 and HITRUST requirements
--   5. Prevents unexpected billing that could impact patient care IT budgets
--
-- Why ADMIN Warehouse is Excluded from Monitoring:
--   MEDICORE_ADMIN_WH must remain operational at all times to allow
--   platform administrators to diagnose issues, adjust quotas, and
--   perform emergency fixes. Suspending the admin warehouse could
--   prevent recovery from cost incidents. Admin workloads are
--   metadata-only and consume minimal credits.
--
-- Why Monitors are Layered (Account + Warehouse):
--   - Account monitor: Hard cap on total platform spend (financial safety net)
--   - Warehouse monitors: Granular control per workload type
--   - Layered approach allows ETL to hit quota without affecting Analytics
--   - Enables workload-specific cost attribution and budgeting
--
-- Resource Monitors Created:
--   1. MEDICORE_ACCOUNT_MONITOR   - Account-level (500 credits/month)
--   2. MEDICORE_ETL_MONITOR       - ETL warehouse (200 credits/month)
--   3. MEDICORE_ANALYTICS_MONITOR - Analytics warehouse (150 credits/month)
--   4. MEDICORE_ML_MONITOR        - ML warehouse (100 credits/month)
--
-- Execution Requirements:
--   - Must be run as ACCOUNTADMIN
--   - Compatible with MEDICORE_SVC_GITHUB_ACTIONS execution
--   - Idempotent: safe to re-run
--
-- Dependencies:
--   - Phase 03 completed: All 4 MEDICORE warehouses exist
--   - Phase 02 completed: All 18 RBAC roles exist
--
-- !! WARNING !!
--   Resource monitors with SUSPEND triggers will HALT warehouse
--   operations when credit thresholds are reached. Review quotas
--   carefully before execution in production.
--
-- Author: MediCore Platform Team
-- Date: 2026-02-25
-- ============================================================


-- ============================================================
-- SECTION 1: ACCOUNT-LEVEL MONITOR
-- ============================================================
-- The account-level monitor provides a hard cap on total credit
-- consumption across ALL warehouses combined. This is the
-- financial safety net for the entire platform.
--
-- Quota: 500 credits/month
-- Triggers:
--   50%  (250 credits) : NOTIFY - Early warning
--   75%  (375 credits) : NOTIFY - Warning threshold
--   90%  (450 credits) : NOTIFY - Critical warning
--   100% (500 credits) : SUSPEND - Block new queries on ALL warehouses
-- ============================================================

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE RESOURCE MONITOR MEDICORE_ACCOUNT_MONITOR
    WITH
        CREDIT_QUOTA = 500
        FREQUENCY = MONTHLY
        START_TIMESTAMP = IMMEDIATELY
    TRIGGERS
        ON 50 PERCENT DO NOTIFY
        ON 75 PERCENT DO NOTIFY
        ON 90 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND;

ALTER ACCOUNT SET RESOURCE_MONITOR = MEDICORE_ACCOUNT_MONITOR;


-- ============================================================
-- SECTION 2: WAREHOUSE-LEVEL MONITORS
-- ============================================================
-- Individual warehouse monitors provide granular cost control
-- per workload type. Enables workload isolation - one workload
-- hitting quota does not affect others.
-- ============================================================

-- ------------------------------------------------------------
-- MEDICORE_ETL_MONITOR
-- Warehouse: MEDICORE_ETL_WH
-- Quota: 200 credits/month
-- Triggers:
--   75%  (150 credits) : NOTIFY
--   90%  (180 credits) : NOTIFY
--   100% (200 credits) : SUSPEND
-- Rationale: ETL pipelines are the highest sustained consumer.
--            200 credits sized for daily batch loads and
--            Dynamic Table refreshes.
-- ------------------------------------------------------------
CREATE OR REPLACE RESOURCE MONITOR MEDICORE_ETL_MONITOR
    WITH
        CREDIT_QUOTA = 200
        FREQUENCY = MONTHLY
        START_TIMESTAMP = IMMEDIATELY
    TRIGGERS
        ON 75 PERCENT DO NOTIFY
        ON 90 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND;

-- ------------------------------------------------------------
-- MEDICORE_ANALYTICS_MONITOR
-- Warehouse: MEDICORE_ANALYTICS_WH
-- Quota: 150 credits/month
-- Triggers:
--   75%  (112.5 credits) : NOTIFY
--   90%  (135 credits)   : NOTIFY
--   100% (150 credits)   : SUSPEND
-- Rationale: Serves clinical, billing, analysts, and executives.
--            Query acceleration enabled reduces compute needs.
-- ------------------------------------------------------------
CREATE OR REPLACE RESOURCE MONITOR MEDICORE_ANALYTICS_MONITOR
    WITH
        CREDIT_QUOTA = 150
        FREQUENCY = MONTHLY
        START_TIMESTAMP = IMMEDIATELY
    TRIGGERS
        ON 75 PERCENT DO NOTIFY
        ON 90 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND;

-- ------------------------------------------------------------
-- MEDICORE_ML_MONITOR
-- Warehouse: MEDICORE_ML_WH
-- Quota: 100 credits/month
-- Triggers:
--   75%  (75 credits)  : NOTIFY
--   90%  (90 credits)  : NOTIFY
--   100% (100 credits) : SUSPEND
-- Rationale: ML training is compute-intensive but infrequent.
--            100 credits provides headroom for model training cycles.
-- ------------------------------------------------------------
CREATE OR REPLACE RESOURCE MONITOR MEDICORE_ML_MONITOR
    WITH
        CREDIT_QUOTA = 100
        FREQUENCY = MONTHLY
        START_TIMESTAMP = IMMEDIATELY
    TRIGGERS
        ON 75 PERCENT DO NOTIFY
        ON 90 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND;


-- ============================================================
-- SECTION 3: WAREHOUSE ATTACHMENTS
-- ============================================================
-- Assigns warehouse-level monitors to their respective warehouses.
-- MEDICORE_ADMIN_WH is intentionally excluded to ensure platform
-- administrators can always perform emergency fixes.
-- ============================================================

ALTER WAREHOUSE MEDICORE_ETL_WH SET RESOURCE_MONITOR = MEDICORE_ETL_MONITOR;

ALTER WAREHOUSE MEDICORE_ANALYTICS_WH SET RESOURCE_MONITOR = MEDICORE_ANALYTICS_MONITOR;

ALTER WAREHOUSE MEDICORE_ML_WH SET RESOURCE_MONITOR = MEDICORE_ML_MONITOR;


-- ============================================================
-- SECTION 4: VERIFICATION QUERIES
-- ============================================================
-- Confirms all resource monitors are created and assigned.
-- ============================================================

SHOW RESOURCE MONITORS;

SHOW WAREHOUSES LIKE 'MEDICORE_%';


-- ============================================================
-- PHASE 05 SUMMARY
-- ============================================================
--
-- RESOURCE MONITORS CREATED: 4
--
--   1. MEDICORE_ACCOUNT_MONITOR (Account-level)
--      - Quota: 500 credits/month
--      - Triggers: NOTIFY@50%, NOTIFY@75%, NOTIFY@90%, SUSPEND@100%
--      - Applied to: Account
--
--   2. MEDICORE_ETL_MONITOR
--      - Quota: 200 credits/month
--      - Triggers: NOTIFY@75%, NOTIFY@90%, SUSPEND@100%
--      - Assigned to: MEDICORE_ETL_WH
--
--   3. MEDICORE_ANALYTICS_MONITOR
--      - Quota: 150 credits/month
--      - Triggers: NOTIFY@75%, NOTIFY@90%, SUSPEND@100%
--      - Assigned to: MEDICORE_ANALYTICS_WH
--
--   4. MEDICORE_ML_MONITOR
--      - Quota: 100 credits/month
--      - Triggers: NOTIFY@75%, NOTIFY@90%, SUSPEND@100%
--      - Assigned to: MEDICORE_ML_WH
--
-- WAREHOUSE NOT MONITORED: MEDICORE_ADMIN_WH
--   - Intentionally excluded for emergency access
--   - Platform Admin warehouse must remain unsuspended
--
-- TOTAL WAREHOUSE-LEVEL ALLOCATION: 450 credits/month
--   - ETL: 200 (44%)
--   - Analytics: 150 (33%)
--   - ML: 100 (22%)
--
-- ============================================================
-- END OF PHASE 05: RESOURCE MONITORS
-- ============================================================
