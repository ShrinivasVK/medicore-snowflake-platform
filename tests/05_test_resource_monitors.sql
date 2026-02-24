-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 05: Resource Monitors - Test Cases
-- Script: 05_test_resource_monitors.sql
--
-- Description: Validation queries for all resource monitor
--              objects created in 05_resource_monitors.sql
-- How to Run:  Execute as ACCOUNTADMIN sequentially
-- Results:     Record outcomes in 05_test_resource_monitor_results.md
--
-- Author: [YOUR_NAME]
-- Date: [YYYY-MM-DD]
-- ============================================================

USE ROLE ACCOUNTADMIN;


-- ============================================================
-- CATEGORY 1: EXISTENCE TESTS
-- Verify all resource monitors and governance views were created
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_05_001
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_ACCOUNT_MONITOR exists
-- Expected   : 1 row returned with name = MEDICORE_ACCOUNT_MONITOR
-- ------------------------------------------------------------
SHOW RESOURCE MONITORS LIKE 'MEDICORE_ACCOUNT_MONITOR';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_002
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_ADMIN_WH_MONITOR exists
-- Expected   : 1 row returned with name = MEDICORE_ADMIN_WH_MONITOR
-- ------------------------------------------------------------
SHOW RESOURCE MONITORS LIKE 'MEDICORE_ADMIN_WH_MONITOR';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_003
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_ETL_WH_MONITOR exists
-- Expected   : 1 row returned with name = MEDICORE_ETL_WH_MONITOR
-- ------------------------------------------------------------
SHOW RESOURCE MONITORS LIKE 'MEDICORE_ETL_WH_MONITOR';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_004
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_ANALYTICS_WH_MONITOR exists
-- Expected   : 1 row returned with name = MEDICORE_ANALYTICS_WH_MONITOR
-- ------------------------------------------------------------
SHOW RESOURCE MONITORS LIKE 'MEDICORE_ANALYTICS_WH_MONITOR';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_005
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_ML_WH_MONITOR exists
-- Expected   : 1 row returned with name = MEDICORE_ML_WH_MONITOR
-- ------------------------------------------------------------
SHOW RESOURCE MONITORS LIKE 'MEDICORE_ML_WH_MONITOR';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_006
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_CREDIT_USAGE_SUMMARY view exists
-- Expected   : COUNT = 1
-- ------------------------------------------------------------
SELECT COUNT(*) AS view_exists
FROM GOVERNANCE_DB.INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'SECURITY'
AND TABLE_NAME = 'MEDICORE_CREDIT_USAGE_SUMMARY';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_007
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_RESOURCE_MONITOR_STATUS view exists
-- Expected   : COUNT = 1
-- ------------------------------------------------------------
SELECT COUNT(*) AS view_exists
FROM GOVERNANCE_DB.INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'SECURITY'
AND TABLE_NAME = 'MEDICORE_RESOURCE_MONITOR_STATUS';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------


-- ============================================================
-- CATEGORY 2: CONFIGURATION TESTS
-- Verify credit quotas, frequency, and trigger thresholds
-- Note: ACCOUNT_USAGE has up to 2-hour latency for new monitors
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_05_008
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ACCOUNT_MONITOR credit quota is 10000
-- Expected   : credit_quota = 10000.00
-- Note       : ACCOUNT_USAGE latency - may need re-run after 2 hours
-- ------------------------------------------------------------
SELECT name, credit_quota
FROM SNOWFLAKE.ACCOUNT_USAGE.RESOURCE_MONITORS
WHERE name = 'MEDICORE_ACCOUNT_MONITOR';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_009
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ADMIN_WH_MONITOR credit quota is 100
-- Expected   : credit_quota = 100.00
-- Note       : ACCOUNT_USAGE latency - may need re-run after 2 hours
-- ------------------------------------------------------------
SELECT name, credit_quota
FROM SNOWFLAKE.ACCOUNT_USAGE.RESOURCE_MONITORS
WHERE name = 'MEDICORE_ADMIN_WH_MONITOR';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_010
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ETL_WH_MONITOR credit quota is 3000
-- Expected   : credit_quota = 3000.00
-- Note       : ACCOUNT_USAGE latency - may need re-run after 2 hours
-- ------------------------------------------------------------
SELECT name, credit_quota
FROM SNOWFLAKE.ACCOUNT_USAGE.RESOURCE_MONITORS
WHERE name = 'MEDICORE_ETL_WH_MONITOR';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_011
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ANALYTICS_WH_MONITOR credit quota is 5000
-- Expected   : credit_quota = 5000.00
-- Note       : ACCOUNT_USAGE latency - may need re-run after 2 hours
-- ------------------------------------------------------------
SELECT name, credit_quota
FROM SNOWFLAKE.ACCOUNT_USAGE.RESOURCE_MONITORS
WHERE name = 'MEDICORE_ANALYTICS_WH_MONITOR';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_012
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ML_WH_MONITOR credit quota is 1500
-- Expected   : credit_quota = 1500.00
-- Note       : ACCOUNT_USAGE latency - may need re-run after 2 hours
-- ------------------------------------------------------------
SELECT name, credit_quota
FROM SNOWFLAKE.ACCOUNT_USAGE.RESOURCE_MONITORS
WHERE name = 'MEDICORE_ML_WH_MONITOR';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_013
-- Category   : CONFIGURATION
-- Description: Verify all monitors have MONTHLY frequency
-- Expected   : 5 rows returned, all with frequency = MONTHLY
-- ------------------------------------------------------------
SHOW RESOURCE MONITORS LIKE 'MEDICORE%';
-- Check: All 5 monitors should show frequency = MONTHLY
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_014
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ACCOUNT_MONITOR has SUSPEND at 100% and SUSPEND_IMMEDIATE at 110%
-- Expected   : suspend_at shows 100%, suspend_immediately_at shows 110%
-- ------------------------------------------------------------
SHOW RESOURCE MONITORS LIKE 'MEDICORE_ACCOUNT_MONITOR';
-- Check columns: suspend_at = 100%, suspend_immediately_at = 110%
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_015
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ADMIN_WH_MONITOR has SUSPEND at 100% but NO SUSPEND_IMMEDIATE
-- Expected   : suspend_at shows 100%, suspend_immediately_at is empty/null
-- ------------------------------------------------------------
SHOW RESOURCE MONITORS LIKE 'MEDICORE_ADMIN_WH_MONITOR';
-- Check: suspend_at = 100%, suspend_immediately_at should be empty
-- This is intentional - admin queries are low-risk
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_016
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ETL_WH_MONITOR has SUSPEND_IMMEDIATE at 110%
-- Expected   : suspend_immediately_at shows 110%
-- ------------------------------------------------------------
SHOW RESOURCE MONITORS LIKE 'MEDICORE_ETL_WH_MONITOR';
-- Check: suspend_immediately_at = 110%
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_017
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ANALYTICS_WH_MONITOR has SUSPEND_IMMEDIATE at 110%
-- Expected   : suspend_immediately_at shows 110%
-- ------------------------------------------------------------
SHOW RESOURCE MONITORS LIKE 'MEDICORE_ANALYTICS_WH_MONITOR';
-- Check: suspend_immediately_at = 110%
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_018
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ML_WH_MONITOR has SUSPEND_IMMEDIATE at 110%
-- Expected   : suspend_immediately_at shows 110%
-- ------------------------------------------------------------
SHOW RESOURCE MONITORS LIKE 'MEDICORE_ML_WH_MONITOR';
-- Check: suspend_immediately_at = 110%
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------


-- ============================================================
-- CATEGORY 3: ASSIGNMENT TESTS
-- Verify monitors are correctly assigned to account/warehouses
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_05_019
-- Category   : ASSIGNMENT
-- Description: Verify account-level monitor is set to MEDICORE_ACCOUNT_MONITOR
-- Expected   : value = MEDICORE_ACCOUNT_MONITOR
-- ------------------------------------------------------------
SHOW PARAMETERS LIKE 'RESOURCE_MONITOR' IN ACCOUNT;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_020
-- Category   : ASSIGNMENT
-- Description: Verify MEDICORE_ADMIN_WH has MEDICORE_ADMIN_WH_MONITOR assigned
-- Expected   : resource_monitor = MEDICORE_ADMIN_WH_MONITOR
-- ------------------------------------------------------------
SHOW WAREHOUSES LIKE 'MEDICORE_ADMIN_WH';
-- Check: resource_monitor column = MEDICORE_ADMIN_WH_MONITOR
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_021
-- Category   : ASSIGNMENT
-- Description: Verify MEDICORE_ETL_WH has MEDICORE_ETL_WH_MONITOR assigned
-- Expected   : resource_monitor = MEDICORE_ETL_WH_MONITOR
-- ------------------------------------------------------------
SHOW WAREHOUSES LIKE 'MEDICORE_ETL_WH';
-- Check: resource_monitor column = MEDICORE_ETL_WH_MONITOR
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_022
-- Category   : ASSIGNMENT
-- Description: Verify MEDICORE_ANALYTICS_WH has MEDICORE_ANALYTICS_WH_MONITOR assigned
-- Expected   : resource_monitor = MEDICORE_ANALYTICS_WH_MONITOR
-- ------------------------------------------------------------
SHOW WAREHOUSES LIKE 'MEDICORE_ANALYTICS_WH';
-- Check: resource_monitor column = MEDICORE_ANALYTICS_WH_MONITOR
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_023
-- Category   : ASSIGNMENT
-- Description: Verify MEDICORE_ML_WH has MEDICORE_ML_WH_MONITOR assigned
-- Expected   : resource_monitor = MEDICORE_ML_WH_MONITOR
-- ------------------------------------------------------------
SHOW WAREHOUSES LIKE 'MEDICORE_ML_WH';
-- Check: resource_monitor column = MEDICORE_ML_WH_MONITOR
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_024
-- Category   : ASSIGNMENT
-- Description: Verify no MEDICORE warehouse has NULL resource monitor
-- Expected   : COUNT = 0 (no unmonitored warehouses)
-- Note       : ACCOUNT_USAGE latency - may need re-run after 2 hours
-- ------------------------------------------------------------
SELECT COUNT(*) AS unmonitored_warehouses
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME LIKE 'MEDICORE%'
AND RESOURCE_MONITOR IS NULL
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------


-- ============================================================
-- CATEGORY 4: VIEWS TESTS
-- Verify governance views are correctly defined and queryable
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_05_025
-- Category   : VIEWS
-- Description: Verify MEDICORE_CREDIT_USAGE_SUMMARY is queryable
-- Expected   : Query executes without error (row count may be 0 on fresh account)
-- ------------------------------------------------------------
SELECT COUNT(*) AS row_count
FROM GOVERNANCE_DB.SECURITY.MEDICORE_CREDIT_USAGE_SUMMARY;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Row count may be 0 if no warehouse usage history yet
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_026
-- Category   : VIEWS
-- Description: Verify MEDICORE_RESOURCE_MONITOR_STATUS is queryable and has monitors
-- Expected   : COUNT >= 5 (one row per MEDICORE monitor)
-- Note       : May take up to 2 hours for ACCOUNT_USAGE to populate
-- ------------------------------------------------------------
SELECT COUNT(*) AS monitor_count
FROM GOVERNANCE_DB.SECURITY.MEDICORE_RESOURCE_MONITOR_STATUS;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_027
-- Category   : VIEWS
-- Description: Verify MEDICORE_RESOURCE_MONITOR_STATUS has correct columns
-- Expected   : Query returns without column reference errors
-- ------------------------------------------------------------
SELECT MONITOR_NAME, CREDIT_QUOTA, USED_CREDITS,
       REMAINING_CREDITS, PERCENT_USED, STATUS
FROM GOVERNANCE_DB.SECURITY.MEDICORE_RESOURCE_MONITOR_STATUS
LIMIT 1;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_028
-- Category   : VIEWS
-- Description: Verify MEDICORE_CREDIT_USAGE_SUMMARY filters only MEDICORE warehouses
-- Expected   : COUNT = 0 (no non-MEDICORE rows)
-- ------------------------------------------------------------
SELECT COUNT(*) AS non_medicore_rows
FROM GOVERNANCE_DB.SECURITY.MEDICORE_CREDIT_USAGE_SUMMARY
WHERE WAREHOUSE_NAME NOT LIKE 'MEDICORE%';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------


-- ============================================================
-- CATEGORY 5: GRANTS TESTS
-- Verify SELECT grants on governance views
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_05_029
-- Category   : GRANTS
-- Description: Verify SELECT on MEDICORE_CREDIT_USAGE_SUMMARY granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SHOW GRANTS ON VIEW GOVERNANCE_DB.SECURITY.MEDICORE_CREDIT_USAGE_SUMMARY;
-- Check for: privilege=SELECT, grantee_name=MEDICORE_PLATFORM_ADMIN
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_030
-- Category   : GRANTS
-- Description: Verify SELECT on MEDICORE_CREDIT_USAGE_SUMMARY granted to MEDICORE_SECURITY_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SHOW GRANTS ON VIEW GOVERNANCE_DB.SECURITY.MEDICORE_CREDIT_USAGE_SUMMARY;
-- Check for: privilege=SELECT, grantee_name=MEDICORE_SECURITY_ADMIN
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_031
-- Category   : GRANTS
-- Description: Verify SELECT on MEDICORE_CREDIT_USAGE_SUMMARY granted to MEDICORE_COMPLIANCE_OFFICER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SHOW GRANTS ON VIEW GOVERNANCE_DB.SECURITY.MEDICORE_CREDIT_USAGE_SUMMARY;
-- Check for: privilege=SELECT, grantee_name=MEDICORE_COMPLIANCE_OFFICER
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_032
-- Category   : GRANTS
-- Description: Verify SELECT on MEDICORE_RESOURCE_MONITOR_STATUS granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SHOW GRANTS ON VIEW GOVERNANCE_DB.SECURITY.MEDICORE_RESOURCE_MONITOR_STATUS;
-- Check for: privilege=SELECT, grantee_name=MEDICORE_PLATFORM_ADMIN
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_033
-- Category   : GRANTS
-- Description: Verify SELECT on MEDICORE_RESOURCE_MONITOR_STATUS granted to MEDICORE_SECURITY_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SHOW GRANTS ON VIEW GOVERNANCE_DB.SECURITY.MEDICORE_RESOURCE_MONITOR_STATUS;
-- Check for: privilege=SELECT, grantee_name=MEDICORE_SECURITY_ADMIN
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_034
-- Category   : GRANTS
-- Description: Verify SELECT on MEDICORE_RESOURCE_MONITOR_STATUS granted to MEDICORE_COMPLIANCE_OFFICER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SHOW GRANTS ON VIEW GOVERNANCE_DB.SECURITY.MEDICORE_RESOURCE_MONITOR_STATUS;
-- Check for: privilege=SELECT, grantee_name=MEDICORE_COMPLIANCE_OFFICER
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------


-- ============================================================
-- CATEGORY 6: PHASE03_COMPLETION TESTS
-- Verify all Phase 03 deferred items are now complete
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_05_035
-- Category   : PHASE03_COMPLETION
-- Description: Verify all 5 MEDICORE resource monitors exist (Phase 03 deferred)
-- Expected   : COUNT = 5
-- Note       : ACCOUNT_USAGE latency - may need re-run after 2 hours
-- ------------------------------------------------------------
SELECT COUNT(*) AS medicore_monitor_count
FROM SNOWFLAKE.ACCOUNT_USAGE.RESOURCE_MONITORS
WHERE NAME LIKE 'MEDICORE%'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_036
-- Category   : PHASE03_COMPLETION
-- Description: Verify all 4 MEDICORE warehouses have monitors assigned (Phase 03 deferred)
-- Expected   : COUNT = 4
-- Note       : ACCOUNT_USAGE latency - may need re-run after 2 hours
-- ------------------------------------------------------------
SELECT COUNT(*) AS monitored_warehouse_count
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME LIKE 'MEDICORE%'
AND RESOURCE_MONITOR IS NOT NULL
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_05_037
-- Category   : PHASE03_COMPLETION
-- Description: Verify total monthly warehouse credit allocation is 9600 (Phase 03 spec)
-- Expected   : SUM = 9600 (100 + 3000 + 5000 + 1500)
-- Note       : ACCOUNT_USAGE latency - may need re-run after 2 hours
-- ------------------------------------------------------------
SELECT SUM(CREDIT_QUOTA) AS total_warehouse_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.RESOURCE_MONITORS
WHERE NAME IN (
    'MEDICORE_ADMIN_WH_MONITOR',
    'MEDICORE_ETL_WH_MONITOR',
    'MEDICORE_ANALYTICS_WH_MONITOR',
    'MEDICORE_ML_WH_MONITOR'
)
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------


-- ============================================================
-- TEST SUMMARY
-- Total Test Cases  : 37
--
-- EXISTENCE          Tests :  7 (TC_05_001 to TC_05_007)
-- CONFIGURATION      Tests : 11 (TC_05_008 to TC_05_018)
-- ASSIGNMENT         Tests :  6 (TC_05_019 to TC_05_024)
-- VIEWS              Tests :  4 (TC_05_025 to TC_05_028)
-- GRANTS             Tests :  6 (TC_05_029 to TC_05_034)
-- PHASE03_COMPLETION Tests :  3 (TC_05_035 to TC_05_037)
--
-- ACCOUNT_USAGE LATENCY NOTE:
-- Tests marked with latency caveat may need to be
-- re-run after 2 hours if run immediately after
-- Phase 05 script execution. Use SHOW commands for
-- immediate verification where available.
--
-- Run all tests and record results in
-- 05_test_resource_monitor_results.md
-- ============================================================
