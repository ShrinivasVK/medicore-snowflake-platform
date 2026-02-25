-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 03: Warehouse Management
-- Script: 03_warehouse_management.sql
-- Version: 2.0.0
--
-- Change Reason: Removed MEDICORE_SECURITY_ADMIN references
--               (role not part of refined 18-role design).
--               Added MEDICORE_COMPLIANCE_OFFICER grants on
--               MEDICORE_ADMIN_WH for audit query access.
--               Added MEDICORE_SVC_GITHUB_ACTIONS grants on
--               MEDICORE_ETL_WH for CI/CD deployments.
--               Added Section 1 execution context for
--               consistency with Phase 01 and Phase 02.
--               Updated role count reference from 17 to 18.
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
--   - Estimated execution time: 2-3 minutes
--
-- Dependencies:
--   - Phase 01 (Account Administration) must be completed
--   - Phase 02 (RBAC Setup) Sections 1-5 must be completed
--   - All 18 MEDICORE_ roles must exist before running Section 3
--
-- Related Phases:
--   - Phase 05 will create resource monitors and assign them to
--     these warehouses. Until Phase 05 is executed, warehouses
--     operate without credit quotas.
--   - Phase 08 will apply governance tags to warehouses.
--
-- !! WARNING !!
--   Tags referenced in comments are created in Phase 08.
--   Resource monitors are created in Phase 05.
--   Warehouses operate without credit quotas until Phase 05 runs.
--
-- !! NOTE ON MULTI-CLUSTER !!
--   Multi-cluster warehouses (MIN/MAX_CLUSTER_COUNT > 1) require
--   Enterprise Edition or higher. This script uses single-cluster
--   warehouses for Standard Edition compatibility.
--
-- Author: [YOUR_NAME]
-- Date: [YYYY-MM-DD]
-- ============================================================


-- ============================================================
-- SECTION 1: EXECUTION CONTEXT
-- ============================================================

USE ROLE ACCOUNTADMIN;


-- ============================================================
-- SECTION 2: VIRTUAL WAREHOUSES
-- ============================================================
-- Creating 4 workload-specific warehouses with appropriate sizing
-- and timeout configurations. Single-cluster for Standard Edition.
-- Resource monitors are assigned in Phase 05.
-- ============================================================

-- ------------------------------------------------------------
-- WAREHOUSE 1: MEDICORE_ADMIN_WH
-- Purpose  : Administrative queries, metadata operations, audit
-- Workload : Light — SHOW commands, ACCOUNT_USAGE queries
-- Users    : MEDICORE_PLATFORM_ADMIN, MEDICORE_COMPLIANCE_OFFICER
-- ------------------------------------------------------------
CREATE OR REPLACE WAREHOUSE MEDICORE_ADMIN_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    ENABLE_QUERY_ACCELERATION = FALSE
    STATEMENT_TIMEOUT_IN_SECONDS = 1800
    STATEMENT_QUEUED_TIMEOUT_IN_SECONDS = 600
    COMMENT = 'Administrative warehouse for platform and compliance operations. X-Small size for lightweight metadata queries. 1-minute auto-suspend to minimize idle costs. Primary users: MEDICORE_PLATFORM_ADMIN, MEDICORE_COMPLIANCE_OFFICER. Workload: Admin/Audit. Resource monitor assigned in Phase 05.';

-- NOTE: Resource monitor assignment deferred to Phase 05
-- Monitor to be assigned: MEDICORE_ADMIN_WH_MONITOR
-- See: infrastructure/05_resource-monitors/05_resource_monitors.sql

-- ------------------------------------------------------------
-- WAREHOUSE 2: MEDICORE_ETL_WH
-- Purpose  : Data ingestion, transformation pipelines, CI/CD
-- Workload : Heavy batch processing, Dynamic Tables, loading
-- Users    : MEDICORE_DATA_ENGINEER, MEDICORE_SVC_ETL_LOADER,
--            MEDICORE_SVC_GITHUB_ACTIONS
-- ------------------------------------------------------------
CREATE OR REPLACE WAREHOUSE MEDICORE_ETL_WH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    ENABLE_QUERY_ACCELERATION = FALSE
    STATEMENT_TIMEOUT_IN_SECONDS = 7200
    STATEMENT_QUEUED_TIMEOUT_IN_SECONDS = 1800
    COMMENT = 'ETL warehouse for data pipeline operations and CI/CD deployments. Medium size for batch transformations. 5-minute auto-suspend to allow pipeline continuity. Primary users: MEDICORE_DATA_ENGINEER, MEDICORE_SVC_ETL_LOADER, MEDICORE_SVC_GITHUB_ACTIONS. Workload: ETL/Batch/CI-CD. Resource monitor assigned in Phase 05.';

-- NOTE: Resource monitor assignment deferred to Phase 05
-- Monitor to be assigned: MEDICORE_ETL_WH_MONITOR
-- See: infrastructure/05_resource-monitors/05_resource_monitors.sql

-- ------------------------------------------------------------
-- WAREHOUSE 3: MEDICORE_ANALYTICS_WH
-- Purpose  : Business analytics, clinical reporting, dashboards
-- Workload : Mixed interactive queries, high concurrency
-- Users    : Clinical, Billing, Analyst, Compliance, Executive,
--            Application, and Reference Reader roles
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
    COMMENT = 'Analytics warehouse for business intelligence and reporting. Query acceleration enabled for ad-hoc analytics. 2-minute auto-suspend balances cost and user experience. Primary users: All clinical, billing, analyst, compliance, and executive roles. Workload: Analytics/BI. Resource monitor assigned in Phase 05.';

-- NOTE: Resource monitor assignment deferred to Phase 05
-- Monitor to be assigned: MEDICORE_ANALYTICS_WH_MONITOR
-- See: infrastructure/05_resource-monitors/05_resource_monitors.sql

-- ------------------------------------------------------------
-- WAREHOUSE 4: MEDICORE_ML_WH
-- Purpose  : Machine learning, feature engineering, model training
-- Workload : Heavy compute, large scans, Snowpark, Cortex AI
-- Users    : MEDICORE_DATA_SCIENTIST, MEDICORE_DATA_ENGINEER
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
    COMMENT = 'Machine learning warehouse for AI/ML workloads. Large size for compute-intensive model training. Query acceleration with high scale factor (8x) for large dataset scans. 5-minute auto-suspend for iterative ML workflows. Primary users: MEDICORE_DATA_SCIENTIST, MEDICORE_DATA_ENGINEER. Workload: ML/AI/Cortex. Resource monitor assigned in Phase 05.';

-- NOTE: Resource monitor assignment deferred to Phase 05
-- Monitor to be assigned: MEDICORE_ML_WH_MONITOR
-- See: infrastructure/05_resource-monitors/05_resource_monitors.sql

-- VERIFICATION: All warehouses created
SHOW WAREHOUSES LIKE 'MEDICORE_%';


-- ============================================================
-- SECTION 3: WAREHOUSE USAGE GRANTS
-- ============================================================
-- Granting appropriate privileges to roles from Phase 02.
-- Privilege levels:
--   USAGE   : Can use warehouse to execute queries
--   OPERATE : Can start, stop, suspend, and resume warehouse
--   MODIFY  : Can change warehouse size and configuration
-- ============================================================

-- ------------------------------------------------------------
-- MEDICORE_ADMIN_WH GRANTS
-- Platform admin gets full control.
-- Compliance officer gets usage and operate for audit queries.
-- Note: MEDICORE_SECURITY_ADMIN removed — security governance
-- responsibilities consolidated into MEDICORE_COMPLIANCE_OFFICER
-- and MEDICORE_PLATFORM_ADMIN per Phase 02 design.
-- ------------------------------------------------------------

-- Platform Admin: Full control over admin warehouse
GRANT USAGE   ON WAREHOUSE MEDICORE_ADMIN_WH TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT OPERATE ON WAREHOUSE MEDICORE_ADMIN_WH TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT MODIFY  ON WAREHOUSE MEDICORE_ADMIN_WH TO ROLE MEDICORE_PLATFORM_ADMIN;

-- Compliance Officer: Usage and operate for audit and governance queries
-- Replaces MEDICORE_SECURITY_ADMIN which is not part of the 18-role design
GRANT USAGE   ON WAREHOUSE MEDICORE_ADMIN_WH TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT OPERATE ON WAREHOUSE MEDICORE_ADMIN_WH TO ROLE MEDICORE_COMPLIANCE_OFFICER;

-- ------------------------------------------------------------
-- MEDICORE_ETL_WH GRANTS
-- Engineering roles get full control.
-- ETL service account gets usage and operate for pipelines.
-- GitHub Actions service account gets usage and operate for
-- Schemachange CI/CD deployments.
-- ------------------------------------------------------------

-- Data Engineer: Full control over ETL warehouse
GRANT USAGE   ON WAREHOUSE MEDICORE_ETL_WH TO ROLE MEDICORE_DATA_ENGINEER;
GRANT OPERATE ON WAREHOUSE MEDICORE_ETL_WH TO ROLE MEDICORE_DATA_ENGINEER;
GRANT MODIFY  ON WAREHOUSE MEDICORE_ETL_WH TO ROLE MEDICORE_DATA_ENGINEER;

-- ETL Service Account: Usage and operate for automated pipelines
GRANT USAGE   ON WAREHOUSE MEDICORE_ETL_WH TO ROLE MEDICORE_SVC_ETL_LOADER;
GRANT OPERATE ON WAREHOUSE MEDICORE_ETL_WH TO ROLE MEDICORE_SVC_ETL_LOADER;

-- GitHub Actions Service Account: Usage and operate for CI/CD deployments
-- Required for Schemachange to execute migration scripts
GRANT USAGE   ON WAREHOUSE MEDICORE_ETL_WH TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT OPERATE ON WAREHOUSE MEDICORE_ETL_WH TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

-- Platform Admin: Full management capability over ETL warehouse
GRANT USAGE   ON WAREHOUSE MEDICORE_ETL_WH TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT OPERATE ON WAREHOUSE MEDICORE_ETL_WH TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT MODIFY  ON WAREHOUSE MEDICORE_ETL_WH TO ROLE MEDICORE_PLATFORM_ADMIN;

-- ------------------------------------------------------------
-- MEDICORE_ANALYTICS_WH GRANTS
-- All analytics consumers get usage.
-- Platform admin gets full control.
-- Data engineer gets usage for validation queries.
-- ------------------------------------------------------------

-- Clinical Roles
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_CLINICAL_PHYSICIAN;
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_CLINICAL_NURSE;
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_CLINICAL_READER;

-- Billing Roles
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

-- Application Role
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_APP_STREAMLIT;

-- Reference Reader (base role — ensures all authenticated users can query)
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_REFERENCE_READER;

-- Platform Admin: Full management capability over analytics warehouse
GRANT USAGE   ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT OPERATE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT MODIFY  ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_PLATFORM_ADMIN;

-- Data Engineer: Usage for validation and testing queries
GRANT USAGE ON WAREHOUSE MEDICORE_ANALYTICS_WH TO ROLE MEDICORE_DATA_ENGINEER;

-- ------------------------------------------------------------
-- MEDICORE_ML_WH GRANTS
-- Data Scientists get primary usage and operate.
-- Platform admin gets full control.
-- Data engineer gets usage for feature engineering validation.
-- ------------------------------------------------------------

-- Data Scientist: Usage and operate for ML workflows
GRANT USAGE   ON WAREHOUSE MEDICORE_ML_WH TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT OPERATE ON WAREHOUSE MEDICORE_ML_WH TO ROLE MEDICORE_DATA_SCIENTIST;

-- Platform Admin: Full management capability over ML warehouse
GRANT USAGE   ON WAREHOUSE MEDICORE_ML_WH TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT OPERATE ON WAREHOUSE MEDICORE_ML_WH TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT MODIFY  ON WAREHOUSE MEDICORE_ML_WH TO ROLE MEDICORE_PLATFORM_ADMIN;

-- Data Engineer: Usage for feature engineering and pipeline validation
GRANT USAGE ON WAREHOUSE MEDICORE_ML_WH TO ROLE MEDICORE_DATA_ENGINEER;


-- ============================================================
-- SECTION 4: VERIFICATION QUERIES
-- ============================================================

-- Verify all 4 warehouses exist with correct properties
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
-- WAREHOUSES CREATED: 4 (single-cluster, Standard Edition)
--   MEDICORE_ADMIN_WH     (X-Small, 60s auto-suspend,  QAS off)
--   MEDICORE_ETL_WH       (Medium,  300s auto-suspend, QAS off)
--   MEDICORE_ANALYTICS_WH (Small,   120s auto-suspend, QAS 4x)
--   MEDICORE_ML_WH        (Large,   300s auto-suspend, QAS 8x)
--
-- WAREHOUSE GRANTS SUMMARY:
--
--   MEDICORE_ADMIN_WH (5 grants):
--     USAGE + OPERATE + MODIFY : MEDICORE_PLATFORM_ADMIN
--     USAGE + OPERATE          : MEDICORE_COMPLIANCE_OFFICER
--
--   MEDICORE_ETL_WH (10 grants):
--     USAGE + OPERATE + MODIFY : MEDICORE_DATA_ENGINEER
--     USAGE + OPERATE + MODIFY : MEDICORE_PLATFORM_ADMIN
--     USAGE + OPERATE          : MEDICORE_SVC_ETL_LOADER
--     USAGE + OPERATE          : MEDICORE_SVC_GITHUB_ACTIONS
--
--   MEDICORE_ANALYTICS_WH (16 grants):
--     USAGE + OPERATE + MODIFY : MEDICORE_PLATFORM_ADMIN
--     USAGE                    : MEDICORE_CLINICAL_PHYSICIAN
--     USAGE                    : MEDICORE_CLINICAL_NURSE
--     USAGE                    : MEDICORE_CLINICAL_READER
--     USAGE                    : MEDICORE_BILLING_SPECIALIST
--     USAGE                    : MEDICORE_BILLING_READER
--     USAGE                    : MEDICORE_ANALYST_PHI
--     USAGE                    : MEDICORE_ANALYST_RESTRICTED
--     USAGE                    : MEDICORE_COMPLIANCE_OFFICER
--     USAGE                    : MEDICORE_EXT_AUDITOR
--     USAGE                    : MEDICORE_EXECUTIVE
--     USAGE                    : MEDICORE_APP_STREAMLIT
--     USAGE                    : MEDICORE_REFERENCE_READER
--     USAGE                    : MEDICORE_DATA_ENGINEER
--
--   MEDICORE_ML_WH (5 grants):
--     USAGE + OPERATE + MODIFY : MEDICORE_PLATFORM_ADMIN
--     USAGE + OPERATE          : MEDICORE_DATA_SCIENTIST
--     USAGE                    : MEDICORE_DATA_ENGINEER
--
-- TOTAL PRIVILEGE GRANTS: 36
--
-- DEFERRED TO PHASE 05 (Resource Monitors):
--   MEDICORE_ACCOUNT_MONITOR       (account-level)
--   MEDICORE_ADMIN_WH_MONITOR      (per-warehouse)
--   MEDICORE_ETL_WH_MONITOR        (per-warehouse)
--   MEDICORE_ANALYTICS_WH_MONITOR  (per-warehouse)
--   MEDICORE_ML_WH_MONITOR         (per-warehouse)
--   All ALTER WAREHOUSE SET RESOURCE_MONITOR statements
--
-- DEFERRED TO PHASE 08 (Data Governance):
--   Governance tag application on all 4 warehouses
--   ALTER WAREHOUSE SET TAG statements
--
-- PHASE 04 DEPENDENCIES:
--   - Warehouses exist for DDL execution during database setup
--   - MEDICORE_ETL_WH available for SVC_GITHUB_ACTIONS deployments
--   - Role-to-warehouse mapping complete for all 18 roles
--   - NOTE: Warehouses operate without credit quotas until Phase 05
--
-- ============================================================
-- END OF PHASE 03: WAREHOUSE MANAGEMENT
-- ============================================================