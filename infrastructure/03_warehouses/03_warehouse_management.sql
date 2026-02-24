-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 03: Warehouse Management
-- Script: 03_warehouse_management.sql
--
-- Description:
--   Creates 4 workload-specific virtual warehouses with appropriate
--   sizing and timeout configurations. Grants warehouse privileges
--   to roles established in Phase 02.
--
-- Warehouses Created:
--   1. MEDICORE_ADMIN_WH     - Administrative queries, metadata ops
--   2. MEDICORE_ETL_WH       - Data ingestion and transformation
--   3. MEDICORE_ANALYTICS_WH - Business analytics, dashboards
--   4. MEDICORE_ML_WH        - Machine learning, AI workloads
--
-- Execution Requirements:
--   - Must be run as ACCOUNTADMIN
--   - Execute statements sequentially from top to bottom
--
-- Dependencies:
--   - Phase 01 (Account Administration) must be completed
--   - Phase 02 (RBAC Setup) must be completed
--   - All 17 MEDICORE_ roles must exist
--
-- Related Phases:
--   - Phase 05 will create resource monitors and assign them to
--     these warehouses. Until Phase 05 is executed, warehouses
--     operate without credit quotas.
--
-- !! WARNING !!
--   Tags referenced here will be created in Phase 08 (Data Governance).
--   Resource monitors will be created in Phase 05 (Resource Monitors).
--
-- !! NOTE ON MULTI-CLUSTER !!
--   Multi-cluster warehouses (MIN/MAX_CLUSTER_COUNT > 1) require
--   Enterprise Edition or higher. This script uses single-cluster
--   warehouses for Standard Edition compatibility.
--
-- Author: [YOUR_NAME]
-- Date: [YYYY-MM-DD]
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================
-- SECTION 2: VIRTUAL WAREHOUSES
-- ============================================================
-- Creating 4 workload-specific warehouses with appropriate sizing
-- and timeout configurations. Single-cluster for Standard Edition.
-- ============================================================

-- ------------------------------------------------------------
-- WAREHOUSE 1: MEDICORE_ADMIN_WH
-- Purpose: Administrative queries, metadata operations, audit
-- Workload: Light - SHOW commands, ACCOUNT_USAGE queries
-- Users: MEDICORE_PLATFORM_ADMIN, MEDICORE_SECURITY_ADMIN
-- ------------------------------------------------------------
CREATE OR REPLACE WAREHOUSE MEDICORE_ADMIN_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    ENABLE_QUERY_ACCELERATION = FALSE
    STATEMENT_TIMEOUT_IN_SECONDS = 1800
    STATEMENT_QUEUED_TIMEOUT_IN_SECONDS = 600
    COMMENT = 'Administrative warehouse for platform and security operations. X-Small size for lightweight metadata queries. 1-minute auto-suspend to minimize idle costs. Owner: MEDICORE_PLATFORM_ADMIN. Workload: Admin/Audit.';

-- NOTE: Resource monitor assignment deferred to Phase 05
-- Monitor to be assigned: MEDICORE_ADMIN_WH_MONITOR
-- See: infrastructure/05_resource-monitors/05_resource_monitors.sql

-- ------------------------------------------------------------
-- WAREHOUSE 2: MEDICORE_ETL_WH
-- Purpose: Data ingestion and transformation pipelines
-- Workload: Heavy batch processing, Dynamic Tables, loading
-- Users: MEDICORE_DATA_ENGINEER, MEDICORE_SVC_ETL_LOADER
-- ------------------------------------------------------------
CREATE OR REPLACE WAREHOUSE MEDICORE_ETL_WH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    ENABLE_QUERY_ACCELERATION = FALSE
    STATEMENT_TIMEOUT_IN_SECONDS = 7200
    STATEMENT_QUEUED_TIMEOUT_IN_SECONDS = 1800
    COMMENT = 'ETL warehouse for data pipeline operations. Medium size for batch transformations. 5-minute auto-suspend to allow pipeline continuity. Owner: MEDICORE_DATA_ENGINEER. Workload: ETL/Batch.';

-- NOTE: Resource monitor assignment deferred to Phase 05
-- Monitor to be assigned: MEDICORE_ETL_WH_MONITOR
-- See: infrastructure/05_resource-monitors/05_resource_monitors.sql

-- ------------------------------------------------------------
-- WAREHOUSE 3: MEDICORE_ANALYTICS_WH
-- Purpose: Business analytics, clinical reporting, dashboards
-- Workload: Mixed interactive queries, high concurrency
-- Users: Clinical, Billing, Analyst, Compliance, Executive roles
-- ------------------------------------------------------------
CREATE OR REPLACE WAREHOUSE MEDICORE_ANALYTICS_WH
    WAREHOUSE_SIZE = 'SMALL'
    AUTO_SUSPEND = 120
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    ENABLE_QUERY_ACCELERATION = TRUE
    QUERY_ACCELERATION_MAX_SCALE_FACTOR = 4
    STATEMENT_TIMEOUT_IN_SECONDS = 3600
    STATEMENT_QUEUED_TIMEOUT_IN_SECONDS = 900
    COMMENT = 'Analytics warehouse for business intelligence and reporting. Query acceleration enabled for ad-hoc analytics. 2-minute auto-suspend balances cost and user experience. Owner: MEDICORE_ANALYST_PHI. Workload: Analytics/BI.';

-- NOTE: Resource monitor assignment deferred to Phase 05
-- Monitor to be assigned: MEDICORE_ANALYTICS_WH_MONITOR
-- See: infrastructure/05_resource-monitors/05_resource_monitors.sql

-- ------------------------------------------------------------
-- WAREHOUSE 4: MEDICORE_ML_WH
-- Purpose: Machine learning, feature engineering, model training
-- Workload: Heavy compute, large scans, Snowpark, Cortex AI
-- Users: MEDICORE_DATA_SCIENTIST
-- ------------------------------------------------------------
CREATE OR REPLACE WAREHOUSE MEDICORE_ML_WH
    WAREHOUSE_SIZE = 'LARGE'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    ENABLE_QUERY_ACCELERATION = TRUE
    QUERY_ACCELERATION_MAX_SCALE_FACTOR = 8
    STATEMENT_TIMEOUT_IN_SECONDS = 14400
    STATEMENT_QUEUED_TIMEOUT_IN_SECONDS = 1800
    COMMENT = 'Machine learning warehouse for AI/ML workloads. Large size for compute-intensive model training. Query acceleration with high scale factor (8x) for large dataset scans. 5-minute auto-suspend for iterative ML workflows. Owner: MEDICORE_DATA_SCIENTIST. Workload: ML/AI.';

-- NOTE: Resource monitor assignment deferred to Phase 05
-- Monitor to be assigned: MEDICORE_ML_WH_MONITOR
-- See: infrastructure/05_resource-monitors/05_resource_monitors.sql

-- VERIFICATION: All warehouses created
SHOW WAREHOUSES LIKE 'MEDICORE_%';


-- ============================================================
-- SECTION 3: WAREHOUSE USAGE GRANTS
-- ============================================================
-- Granting appropriate privileges to roles from Phase 02
-- USAGE: Can use warehouse for queries
-- OPERATE: Can start/stop/suspend warehouse
-- MODIFY: Can change warehouse properties
-- ============================================================

-- ------------------------------------------------------------
-- MEDICORE_ADMIN_WH GRANTS
-- Administrative roles get full control
-- ------------------------------------------------------------

-- Platform Admin: Full control over admin warehouse
GRANT USAGE ON WAREHOUSE MEDICORE_ADMIN_WH TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT OPERATE ON WAREHOUSE MEDICORE_ADMIN_WH TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT MODIFY ON WAREHOUSE MEDICORE_ADMIN_WH TO ROLE MEDICORE_PLATFORM_ADMIN;

-- Security Admin: Usage and operate for audit queries
GRANT USAGE ON WAREHOUSE MEDICORE_ADMIN_WH TO ROLE MEDICORE_SECURITY_ADMIN;
GRANT OPERATE ON WAREHOUSE MEDICORE_ADMIN_WH TO ROLE MEDICORE_SECURITY_ADMIN;

-- ------------------------------------------------------------
-- MEDICORE_ETL_WH GRANTS
-- Engineering roles get full control, service account gets usage
-- ------------------------------------------------------------

-- Data Engineer: Full control over ETL warehouse
GRANT USAGE ON WAREHOUSE MEDICORE_ETL_WH TO ROLE MEDICORE_DATA_ENGINEER;
GRANT OPERATE ON WAREHOUSE MEDICORE_ETL_WH TO ROLE MEDICORE_DATA_ENGINEER;
GRANT MODIFY ON WAREHOUSE MEDICORE_ETL_WH TO ROLE MEDICORE_DATA_ENGINEER;

-- Service Account: Usage and operate for automated pipelines
GRANT USAGE ON WAREHOUSE MEDICORE_ETL_WH TO ROLE MEDICORE_SVC_ETL_LOADER;
GRANT OPERATE ON WAREHOUSE MEDICORE_ETL_WH TO ROLE MEDICORE_SVC_ETL_LOADER;

-- Platform Admin: Can manage ETL warehouse if needed
GRANT USAGE ON WAREHOUSE MEDICORE_ETL_WH TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT OPERATE ON WAREHOUSE MEDICORE_ETL_WH TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT MODIFY ON WAREHOUSE MEDICORE_ETL_WH TO ROLE MEDICORE_PLATFORM_ADMIN;

-- ------------------------------------------------------------
-- MEDICORE_ANALYTICS_WH GRANTS
-- All analytics consumers get usage, admins get operate/modify
-- ------------------------------------------------------------

-- Clinical Roles (hierarchy inherits from CLINICAL_PHYSICIAN)
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_CLINICAL_PHYSICIAN;
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_CLINICAL_NURSE;
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_CLINICAL_READER;

-- Billing Roles (hierarchy inherits from BILLING_SPECIALIST)
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_BILLING_SPECIALIST;
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_BILLING_READER;

-- Analyst Roles
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_ANALYST_PHI;
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_ANALYST_RESTRICTED;

-- Compliance and Audit Roles
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_EXT_AUDITOR;

-- Executive Role
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_EXECUTIVE;

-- Application Role (Streamlit)
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_APP_STREAMLIT;

-- Reference Reader (base role - ensures all users can access analytics)
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_REFERENCE_READER;

-- Platform Admin: Full control for management
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT OPERATE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT MODIFY ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_PLATFORM_ADMIN;

-- Data Engineer: Can use analytics for validation queries
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_DATA_ENGINEER;

-- ------------------------------------------------------------
-- MEDICORE_ML_WH GRANTS
-- Data Scientists get primary access, admins can manage
-- ------------------------------------------------------------

-- Data Scientist: Full usage and operate for ML workflows
GRANT USAGE ON WAREHOUSE MEDICORE_ML_WH TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT OPERATE ON WAREHOUSE MEDICORE_ML_WH TO ROLE MEDICORE_DATA_SCIENTIST;

-- Platform Admin: Full control for management
GRANT USAGE ON WAREHOUSE MEDICORE_ML_WH TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT OPERATE ON WAREHOUSE MEDICORE_ML_WH TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT MODIFY ON WAREHOUSE MEDICORE_ML_WH TO ROLE MEDICORE_PLATFORM_ADMIN;

-- Data Engineer: Can use ML warehouse for feature engineering validation
GRANT USAGE ON WAREHOUSE MEDICORE_ML_WH TO ROLE MEDICORE_DATA_ENGINEER;


-- ============================================================
-- SECTION 4: VERIFICATION QUERIES
-- ============================================================

-- Verify all warehouses created with correct properties
SHOW WAREHOUSES LIKE 'MEDICORE%';

-- Verify grants on each warehouse
SHOW GRANTS ON WAREHOUSE MEDICORE_ADMIN_WH;
SHOW GRANTS ON WAREHOUSE MEDICORE_ETL_WH;
SHOW GRANTS ON WAREHOUSE MEDICORE_ANALYTICS_WH;
SHOW GRANTS ON WAREHOUSE MEDICORE_ML_WH;


-- ============================================================
-- SECTION 5: PHASE 03 SUMMARY
-- ============================================================
--
-- WAREHOUSES CREATED: 4 (single-cluster for Standard Edition)
--   - MEDICORE_ADMIN_WH (X-Small, 60s auto-suspend)
--   - MEDICORE_ETL_WH (Medium, 300s auto-suspend)
--   - MEDICORE_ANALYTICS_WH (Small, QAS enabled 4x, 120s auto-suspend)
--   - MEDICORE_ML_WH (Large, QAS enabled 8x, 300s auto-suspend)
--
-- WAREHOUSE GRANTS SUMMARY:
--   MEDICORE_ADMIN_WH (5 grants):
--     - USAGE+OPERATE+MODIFY: MEDICORE_PLATFORM_ADMIN
--     - USAGE+OPERATE: MEDICORE_SECURITY_ADMIN
--
--   MEDICORE_ETL_WH (8 grants):
--     - USAGE+OPERATE+MODIFY: MEDICORE_DATA_ENGINEER, MEDICORE_PLATFORM_ADMIN
--     - USAGE+OPERATE: MEDICORE_SVC_ETL_LOADER
--
--   MEDICORE_ANALYTICS_WH (16 grants):
--     - USAGE: All clinical, billing, analyst, compliance, executive,
--              application, and reference reader roles (13 roles)
--     - USAGE+OPERATE+MODIFY: MEDICORE_PLATFORM_ADMIN
--     - USAGE: MEDICORE_DATA_ENGINEER
--
--   MEDICORE_ML_WH (6 grants):
--     - USAGE+OPERATE: MEDICORE_DATA_SCIENTIST
--     - USAGE+OPERATE+MODIFY: MEDICORE_PLATFORM_ADMIN
--     - USAGE: MEDICORE_DATA_ENGINEER
--
-- TOTAL GRANTS: 35
--
-- DEFERRED TO PHASE 05 (Resource Monitors):
--   - MEDICORE_ACCOUNT_MONITOR (account-level, 10,000 credits/month)
--   - MEDICORE_ADMIN_WH_MONITOR (100 credits/month)
--   - MEDICORE_ETL_WH_MONITOR (3,000 credits/month)
--   - MEDICORE_ANALYTICS_WH_MONITOR (5,000 credits/month)
--   - MEDICORE_ML_WH_MONITOR (1,500 credits/month)
--   - All ALTER WAREHOUSE SET RESOURCE_MONITOR statements
--
-- PHASE 04 DEPENDENCIES:
--   - Warehouses exist for database creation DDL execution
--   - Service account warehouse access ready for ETL pipeline setup
--   - Role-to-warehouse mapping complete for schema grants
--   - NOTE: Resource monitors will be assigned in Phase 05
--     (warehouses operate without credit quotas until then)
--
-- NOTE ON TAGS:
--   Tags (MEDALLION_LAYER, DATA_DOMAIN, etc.) are defined in Phase 08.
--   After Phase 08, run ALTER WAREHOUSE to apply governance tags.
--
-- ============================================================
-- END OF PHASE 03: WAREHOUSE MANAGEMENT
-- ============================================================
