-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 03: Warehouse Management - Test Cases
-- Script: 03_test_warehouse_management.sql
-- Version: 2.0.0
--
-- Change Reason: Replaced TC_03_034 and TC_03_035 which tested
--               MEDICORE_SECURITY_ADMIN grants (role removed in
--               Phase 02 v2.0.0) with tests for
--               MEDICORE_COMPLIANCE_OFFICER grants on
--               MEDICORE_ADMIN_WH. Added TC_03_042 and TC_03_043
--               to verify MEDICORE_SVC_GITHUB_ACTIONS USAGE and
--               OPERATE grants on MEDICORE_ETL_WH. Updated all
--               grant counts and test summary totals accordingly.
--
-- Description: Validation queries for all warehouse objects created
--              in 03_warehouse_management.sql v2.0.0.
--
-- How to Run:  Execute as ACCOUNTADMIN sequentially.
--              Record outcomes in 03_test_warehouse_results.md.
--
-- Author: [YOUR_NAME]
-- Date: [YYYY-MM-DD]
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================
-- CATEGORY 1: EXISTENCE TESTS
-- Verify all 4 warehouses exist
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_03_001
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_ADMIN_WH warehouse exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT WAREHOUSE_NAME, WAREHOUSE_SIZE, AUTO_SUSPEND, AUTO_RESUME
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME = 'MEDICORE_ADMIN_WH'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_002
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_ETL_WH warehouse exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT WAREHOUSE_NAME, WAREHOUSE_SIZE, AUTO_SUSPEND, AUTO_RESUME
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME = 'MEDICORE_ETL_WH'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_003
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_ANALYTICS_WH warehouse exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT WAREHOUSE_NAME, WAREHOUSE_SIZE, AUTO_SUSPEND, AUTO_RESUME
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME = 'MEDICORE_ANALYTICS_WH'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_004
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_ML_WH warehouse exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT WAREHOUSE_NAME, WAREHOUSE_SIZE, AUTO_SUSPEND, AUTO_RESUME
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME = 'MEDICORE_ML_WH'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :


-- ============================================================
-- CATEGORY 2: CONFIGURATION TESTS
-- Verify warehouse properties match specifications
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_03_005
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ADMIN_WH size is X-Small
-- Expected   : WAREHOUSE_SIZE = 'X-Small'
-- ------------------------------------------------------------
SELECT WAREHOUSE_NAME, WAREHOUSE_SIZE
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME = 'MEDICORE_ADMIN_WH'
AND DELETED_ON IS NULL
AND WAREHOUSE_SIZE = 'X-Small';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_006
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ADMIN_WH auto-suspend is 60 seconds
-- Expected   : AUTO_SUSPEND = 60
-- ------------------------------------------------------------
SELECT WAREHOUSE_NAME, AUTO_SUSPEND
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME = 'MEDICORE_ADMIN_WH'
AND DELETED_ON IS NULL
AND AUTO_SUSPEND = 60;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_007
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ADMIN_WH auto-resume is enabled
-- Expected   : AUTO_RESUME = 'true'
-- ------------------------------------------------------------
SELECT WAREHOUSE_NAME, AUTO_RESUME
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME = 'MEDICORE_ADMIN_WH'
AND DELETED_ON IS NULL
AND AUTO_RESUME = 'true';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_008
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ADMIN_WH query acceleration is disabled
-- Expected   : enable_query_acceleration = 'false'
-- ------------------------------------------------------------
SHOW WAREHOUSES LIKE 'MEDICORE_ADMIN_WH';
SELECT "name", "enable_query_acceleration"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "enable_query_acceleration" = 'false';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_009
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ADMIN_WH statement timeout is 1800 seconds
-- Expected   : statement_timeout_in_seconds = 1800
-- ------------------------------------------------------------
SHOW WAREHOUSES LIKE 'MEDICORE_ADMIN_WH';
SELECT "name", "statement_timeout_in_seconds"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "statement_timeout_in_seconds" = 1800;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_010
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ADMIN_WH queued timeout is 600 seconds
-- Expected   : statement_queued_timeout_in_seconds = 600
-- ------------------------------------------------------------
SHOW WAREHOUSES LIKE 'MEDICORE_ADMIN_WH';
SELECT "name", "statement_queued_timeout_in_seconds"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "statement_queued_timeout_in_seconds" = 600;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_011
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ETL_WH size is Medium
-- Expected   : WAREHOUSE_SIZE = 'Medium'
-- ------------------------------------------------------------
SELECT WAREHOUSE_NAME, WAREHOUSE_SIZE
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME = 'MEDICORE_ETL_WH'
AND DELETED_ON IS NULL
AND WAREHOUSE_SIZE = 'Medium';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_012
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ETL_WH auto-suspend is 300 seconds
-- Expected   : AUTO_SUSPEND = 300
-- ------------------------------------------------------------
SELECT WAREHOUSE_NAME, AUTO_SUSPEND
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME = 'MEDICORE_ETL_WH'
AND DELETED_ON IS NULL
AND AUTO_SUSPEND = 300;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_013
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ETL_WH auto-resume is enabled
-- Expected   : AUTO_RESUME = 'true'
-- ------------------------------------------------------------
SELECT WAREHOUSE_NAME, AUTO_RESUME
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME = 'MEDICORE_ETL_WH'
AND DELETED_ON IS NULL
AND AUTO_RESUME = 'true';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_014
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ETL_WH query acceleration is disabled
-- Expected   : enable_query_acceleration = 'false'
-- ------------------------------------------------------------
SHOW WAREHOUSES LIKE 'MEDICORE_ETL_WH';
SELECT "name", "enable_query_acceleration"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "enable_query_acceleration" = 'false';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_015
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ETL_WH statement timeout is 7200 seconds
-- Expected   : statement_timeout_in_seconds = 7200
-- ------------------------------------------------------------
SHOW WAREHOUSES LIKE 'MEDICORE_ETL_WH';
SELECT "name", "statement_timeout_in_seconds"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "statement_timeout_in_seconds" = 7200;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_016
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ETL_WH queued timeout is 1800 seconds
-- Expected   : statement_queued_timeout_in_seconds = 1800
-- ------------------------------------------------------------
SHOW WAREHOUSES LIKE 'MEDICORE_ETL_WH';
SELECT "name", "statement_queued_timeout_in_seconds"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "statement_queued_timeout_in_seconds" = 1800;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_017
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ANALYTICS_WH size is Small
-- Expected   : WAREHOUSE_SIZE = 'Small'
-- ------------------------------------------------------------
SELECT WAREHOUSE_NAME, WAREHOUSE_SIZE
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME = 'MEDICORE_ANALYTICS_WH'
AND DELETED_ON IS NULL
AND WAREHOUSE_SIZE = 'Small';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_018
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ANALYTICS_WH auto-suspend is 120 seconds
-- Expected   : AUTO_SUSPEND = 120
-- ------------------------------------------------------------
SELECT WAREHOUSE_NAME, AUTO_SUSPEND
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME = 'MEDICORE_ANALYTICS_WH'
AND DELETED_ON IS NULL
AND AUTO_SUSPEND = 120;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_019
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ANALYTICS_WH auto-resume is enabled
-- Expected   : AUTO_RESUME = 'true'
-- ------------------------------------------------------------
SELECT WAREHOUSE_NAME, AUTO_RESUME
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME = 'MEDICORE_ANALYTICS_WH'
AND DELETED_ON IS NULL
AND AUTO_RESUME = 'true';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_020
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ANALYTICS_WH query acceleration is enabled
-- Expected   : enable_query_acceleration = 'true'
-- ------------------------------------------------------------
SHOW WAREHOUSES LIKE 'MEDICORE_ANALYTICS_WH';
SELECT "name", "enable_query_acceleration"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "enable_query_acceleration" = 'true';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_021
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ANALYTICS_WH QAS scale factor is 4
-- Expected   : query_acceleration_max_scale_factor = 4
-- ------------------------------------------------------------
SHOW WAREHOUSES LIKE 'MEDICORE_ANALYTICS_WH';
SELECT "name", "query_acceleration_max_scale_factor"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "query_acceleration_max_scale_factor" = 4;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_022
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ANALYTICS_WH statement timeout is 3600 seconds
-- Expected   : statement_timeout_in_seconds = 3600
-- ------------------------------------------------------------
SHOW WAREHOUSES LIKE 'MEDICORE_ANALYTICS_WH';
SELECT "name", "statement_timeout_in_seconds"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "statement_timeout_in_seconds" = 3600;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_023
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ANALYTICS_WH queued timeout is 900 seconds
-- Expected   : statement_queued_timeout_in_seconds = 900
-- ------------------------------------------------------------
SHOW WAREHOUSES LIKE 'MEDICORE_ANALYTICS_WH';
SELECT "name", "statement_queued_timeout_in_seconds"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "statement_queued_timeout_in_seconds" = 900;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_024
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ML_WH size is Large
-- Expected   : WAREHOUSE_SIZE = 'Large'
-- ------------------------------------------------------------
SELECT WAREHOUSE_NAME, WAREHOUSE_SIZE
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME = 'MEDICORE_ML_WH'
AND DELETED_ON IS NULL
AND WAREHOUSE_SIZE = 'Large';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_025
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ML_WH auto-suspend is 300 seconds
-- Expected   : AUTO_SUSPEND = 300
-- ------------------------------------------------------------
SELECT WAREHOUSE_NAME, AUTO_SUSPEND
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME = 'MEDICORE_ML_WH'
AND DELETED_ON IS NULL
AND AUTO_SUSPEND = 300;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_026
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ML_WH auto-resume is enabled
-- Expected   : AUTO_RESUME = 'true'
-- ------------------------------------------------------------
SELECT WAREHOUSE_NAME, AUTO_RESUME
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME = 'MEDICORE_ML_WH'
AND DELETED_ON IS NULL
AND AUTO_RESUME = 'true';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_027
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ML_WH query acceleration is enabled
-- Expected   : enable_query_acceleration = 'true'
-- ------------------------------------------------------------
SHOW WAREHOUSES LIKE 'MEDICORE_ML_WH';
SELECT "name", "enable_query_acceleration"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "enable_query_acceleration" = 'true';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_028
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ML_WH QAS scale factor is 8
-- Expected   : query_acceleration_max_scale_factor = 8
-- ------------------------------------------------------------
SHOW WAREHOUSES LIKE 'MEDICORE_ML_WH';
SELECT "name", "query_acceleration_max_scale_factor"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "query_acceleration_max_scale_factor" = 8;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_029
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ML_WH statement timeout is 14400 seconds
-- Expected   : statement_timeout_in_seconds = 14400
-- ------------------------------------------------------------
SHOW WAREHOUSES LIKE 'MEDICORE_ML_WH';
SELECT "name", "statement_timeout_in_seconds"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "statement_timeout_in_seconds" = 14400;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_030
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ML_WH queued timeout is 1800 seconds
-- Expected   : statement_queued_timeout_in_seconds = 1800
-- ------------------------------------------------------------
SHOW WAREHOUSES LIKE 'MEDICORE_ML_WH';
SELECT "name", "statement_queued_timeout_in_seconds"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "statement_queued_timeout_in_seconds" = 1800;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :


-- ============================================================
-- CATEGORY 3: GRANTS TESTS
-- Verify all warehouse privilege grants are correct
-- ============================================================

-- ------------------------------------------------------------
-- MEDICORE_ADMIN_WH GRANTS
-- Expected: 5 privilege grants
--   USAGE + OPERATE + MODIFY : MEDICORE_PLATFORM_ADMIN
--   USAGE + OPERATE          : MEDICORE_COMPLIANCE_OFFICER
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_03_031
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ADMIN_WH granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ADMIN_WH'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_032
-- Category   : GRANTS
-- Description: Verify OPERATE on MEDICORE_ADMIN_WH granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ADMIN_WH'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'OPERATE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_033
-- Category   : GRANTS
-- Description: Verify MODIFY on MEDICORE_ADMIN_WH granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ADMIN_WH'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'MODIFY'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_034
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ADMIN_WH granted to MEDICORE_COMPLIANCE_OFFICER
-- Expected   : 1 row returned
-- Note       : MEDICORE_COMPLIANCE_OFFICER replaces MEDICORE_SECURITY_ADMIN
--              which was removed in Phase 02 v2.0.0
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ADMIN_WH'
AND GRANTEE_NAME = 'MEDICORE_COMPLIANCE_OFFICER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_035
-- Category   : GRANTS
-- Description: Verify OPERATE on MEDICORE_ADMIN_WH granted to MEDICORE_COMPLIANCE_OFFICER
-- Expected   : 1 row returned
-- Note       : MEDICORE_COMPLIANCE_OFFICER replaces MEDICORE_SECURITY_ADMIN
--              which was removed in Phase 02 v2.0.0
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ADMIN_WH'
AND GRANTEE_NAME = 'MEDICORE_COMPLIANCE_OFFICER'
AND PRIVILEGE = 'OPERATE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- BOUNDARY CHECK: Confirm MEDICORE_SECURITY_ADMIN has NO grants
-- on MEDICORE_ADMIN_WH (role does not exist in 18-role design)
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_03_036
-- Category   : GRANTS
-- Description: Verify MEDICORE_SECURITY_ADMIN has NO grants on MEDICORE_ADMIN_WH
-- Expected   : 0 rows returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ADMIN_WH'
AND GRANTEE_NAME = 'MEDICORE_SECURITY_ADMIN'
AND DELETED_ON IS NULL;
-- Expected result: 0 rows
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- MEDICORE_ETL_WH GRANTS
-- Expected: 10 privilege grants
--   USAGE + OPERATE + MODIFY : MEDICORE_DATA_ENGINEER
--   USAGE + OPERATE + MODIFY : MEDICORE_PLATFORM_ADMIN
--   USAGE + OPERATE          : MEDICORE_SVC_ETL_LOADER
--   USAGE + OPERATE          : MEDICORE_SVC_GITHUB_ACTIONS
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_03_037
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ETL_WH granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ETL_WH'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_038
-- Category   : GRANTS
-- Description: Verify OPERATE on MEDICORE_ETL_WH granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ETL_WH'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'OPERATE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_039
-- Category   : GRANTS
-- Description: Verify MODIFY on MEDICORE_ETL_WH granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ETL_WH'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'MODIFY'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_040
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ETL_WH granted to MEDICORE_SVC_ETL_LOADER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ETL_WH'
AND GRANTEE_NAME = 'MEDICORE_SVC_ETL_LOADER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_041
-- Category   : GRANTS
-- Description: Verify OPERATE on MEDICORE_ETL_WH granted to MEDICORE_SVC_ETL_LOADER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ETL_WH'
AND GRANTEE_NAME = 'MEDICORE_SVC_ETL_LOADER'
AND PRIVILEGE = 'OPERATE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_042
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ETL_WH granted to MEDICORE_SVC_GITHUB_ACTIONS
-- Expected   : 1 row returned
-- Note       : Required for Schemachange CI/CD deployments
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ETL_WH'
AND GRANTEE_NAME = 'MEDICORE_SVC_GITHUB_ACTIONS'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_043
-- Category   : GRANTS
-- Description: Verify OPERATE on MEDICORE_ETL_WH granted to MEDICORE_SVC_GITHUB_ACTIONS
-- Expected   : 1 row returned
-- Note       : Required for Schemachange CI/CD deployments
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ETL_WH'
AND GRANTEE_NAME = 'MEDICORE_SVC_GITHUB_ACTIONS'
AND PRIVILEGE = 'OPERATE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_044
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ETL_WH granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ETL_WH'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_045
-- Category   : GRANTS
-- Description: Verify OPERATE on MEDICORE_ETL_WH granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ETL_WH'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'OPERATE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_046
-- Category   : GRANTS
-- Description: Verify MODIFY on MEDICORE_ETL_WH granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ETL_WH'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'MODIFY'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- MEDICORE_ANALYTICS_WH GRANTS
-- Expected: 16 privilege grants
--   USAGE + OPERATE + MODIFY : MEDICORE_PLATFORM_ADMIN
--   USAGE                    : 13 roles (clinical, billing,
--                              analyst, compliance, executive,
--                              app, reference, data engineer)
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_03_047
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ANALYTICS_WH granted to MEDICORE_CLINICAL_PHYSICIAN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ANALYTICS_WH'
AND GRANTEE_NAME = 'MEDICORE_CLINICAL_PHYSICIAN'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_048
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ANALYTICS_WH granted to MEDICORE_CLINICAL_NURSE
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ANALYTICS_WH'
AND GRANTEE_NAME = 'MEDICORE_CLINICAL_NURSE'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_049
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ANALYTICS_WH granted to MEDICORE_CLINICAL_READER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ANALYTICS_WH'
AND GRANTEE_NAME = 'MEDICORE_CLINICAL_READER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_050
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ANALYTICS_WH granted to MEDICORE_BILLING_SPECIALIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ANALYTICS_WH'
AND GRANTEE_NAME = 'MEDICORE_BILLING_SPECIALIST'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_051
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ANALYTICS_WH granted to MEDICORE_BILLING_READER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ANALYTICS_WH'
AND GRANTEE_NAME = 'MEDICORE_BILLING_READER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_052
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ANALYTICS_WH granted to MEDICORE_ANALYST_PHI
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ANALYTICS_WH'
AND GRANTEE_NAME = 'MEDICORE_ANALYST_PHI'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_053
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ANALYTICS_WH granted to MEDICORE_ANALYST_RESTRICTED
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ANALYTICS_WH'
AND GRANTEE_NAME = 'MEDICORE_ANALYST_RESTRICTED'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_054
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ANALYTICS_WH granted to MEDICORE_COMPLIANCE_OFFICER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ANALYTICS_WH'
AND GRANTEE_NAME = 'MEDICORE_COMPLIANCE_OFFICER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_055
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ANALYTICS_WH granted to MEDICORE_EXT_AUDITOR
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ANALYTICS_WH'
AND GRANTEE_NAME = 'MEDICORE_EXT_AUDITOR'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_056
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ANALYTICS_WH granted to MEDICORE_EXECUTIVE
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ANALYTICS_WH'
AND GRANTEE_NAME = 'MEDICORE_EXECUTIVE'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_057
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ANALYTICS_WH granted to MEDICORE_APP_STREAMLIT
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ANALYTICS_WH'
AND GRANTEE_NAME = 'MEDICORE_APP_STREAMLIT'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_058
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ANALYTICS_WH granted to MEDICORE_REFERENCE_READER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ANALYTICS_WH'
AND GRANTEE_NAME = 'MEDICORE_REFERENCE_READER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_059
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ANALYTICS_WH granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ANALYTICS_WH'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_060
-- Category   : GRANTS
-- Description: Verify OPERATE on MEDICORE_ANALYTICS_WH granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ANALYTICS_WH'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'OPERATE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_061
-- Category   : GRANTS
-- Description: Verify MODIFY on MEDICORE_ANALYTICS_WH granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ANALYTICS_WH'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'MODIFY'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_062
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ANALYTICS_WH granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ANALYTICS_WH'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- MEDICORE_ML_WH GRANTS
-- Expected: 5 privilege grants
--   USAGE + OPERATE + MODIFY : MEDICORE_PLATFORM_ADMIN
--   USAGE + OPERATE          : MEDICORE_DATA_SCIENTIST
--   USAGE                    : MEDICORE_DATA_ENGINEER
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_03_063
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ML_WH granted to MEDICORE_DATA_SCIENTIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ML_WH'
AND GRANTEE_NAME = 'MEDICORE_DATA_SCIENTIST'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_064
-- Category   : GRANTS
-- Description: Verify OPERATE on MEDICORE_ML_WH granted to MEDICORE_DATA_SCIENTIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ML_WH'
AND GRANTEE_NAME = 'MEDICORE_DATA_SCIENTIST'
AND PRIVILEGE = 'OPERATE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_065
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ML_WH granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ML_WH'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_066
-- Category   : GRANTS
-- Description: Verify OPERATE on MEDICORE_ML_WH granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ML_WH'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'OPERATE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_067
-- Category   : GRANTS
-- Description: Verify MODIFY on MEDICORE_ML_WH granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ML_WH'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'MODIFY'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_068
-- Category   : GRANTS
-- Description: Verify USAGE on MEDICORE_ML_WH granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'WAREHOUSE'
AND NAME = 'MEDICORE_ML_WH'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :


-- ============================================================
-- CATEGORY 4: BOUNDARY TESTS
-- Verify Phase 03 boundary compliance
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_03_069
-- Category   : BOUNDARY
-- Description: Verify no resource monitors assigned to any
--              MEDICORE warehouse yet (deferred to Phase 05)
-- Expected   : RESOURCE_MONITOR is null for all 4 rows
-- ------------------------------------------------------------
SELECT WAREHOUSE_NAME, RESOURCE_MONITOR
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME LIKE 'MEDICORE%'
AND DELETED_ON IS NULL;
-- Expected result: 4 rows, all with NULL RESOURCE_MONITOR
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_070
-- Category   : BOUNDARY
-- Description: Verify MEDICORE_ACCOUNT_MONITOR does not exist yet
-- Expected   : COUNT = 0
-- ------------------------------------------------------------
SELECT COUNT(*) AS monitor_count
FROM SNOWFLAKE.ACCOUNT_USAGE.RESOURCE_MONITORS
WHERE NAME = 'MEDICORE_ACCOUNT_MONITOR'
AND DELETED_ON IS NULL;
-- Expected result: COUNT = 0
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_03_071
-- Category   : BOUNDARY
-- Description: Verify exactly 4 MEDICORE warehouses exist
--              and no unexpected warehouses were created
-- Expected   : COUNT = 4
-- ------------------------------------------------------------
SELECT COUNT(*) AS warehouse_count
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME LIKE 'MEDICORE%'
AND DELETED_ON IS NULL;
-- Expected result: COUNT = 4
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :


-- ============================================================
-- PHASE 03 TEST SUMMARY
-- ============================================================
-- Total Test Cases : 71
--
-- CATEGORY 1 - EXISTENCE      :  4 tests  (TC_03_001 to TC_03_004)
-- CATEGORY 2 - CONFIGURATION  : 26 tests  (TC_03_005 to TC_03_030)
-- CATEGORY 3 - GRANTS         : 38 tests  (TC_03_031 to TC_03_068)
--   MEDICORE_ADMIN_WH          :  6 tests  (TC_03_031 to TC_03_036)
--   MEDICORE_ETL_WH            : 10 tests  (TC_03_037 to TC_03_046)
--   MEDICORE_ANALYTICS_WH      : 16 tests  (TC_03_047 to TC_03_062)
--   MEDICORE_ML_WH             :  6 tests  (TC_03_063 to TC_03_068)
-- CATEGORY 4 - BOUNDARY       :  3 tests  (TC_03_069 to TC_03_071)
--
-- Key Changes vs v1.0.0:
--   TC_03_034: Now tests COMPLIANCE_OFFICER USAGE on ADMIN_WH
--   TC_03_035: Now tests COMPLIANCE_OFFICER OPERATE on ADMIN_WH
--   TC_03_036: NEW — confirms SECURITY_ADMIN has 0 grants (boundary)
--   TC_03_042: NEW — confirms SVC_GITHUB_ACTIONS USAGE on ETL_WH
--   TC_03_043: NEW — confirms SVC_GITHUB_ACTIONS OPERATE on ETL_WH
--   TC_03_071: NEW — confirms exactly 4 MEDICORE warehouses exist
--
-- OVERALL PHASE 03 RESULT: [ ] PASS  [ ] FAIL
-- Tested By:
-- Test Date:
-- ============================================================
-- END OF PHASE 03 TEST CASES
-- ============================================================