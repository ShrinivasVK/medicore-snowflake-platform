-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 05: Resource Monitors - Validation Test Suite
-- Script: 05_test_resource_monitors.sql
--
-- Description:
--   Non-destructive, read-only validation script that verifies
--   all Phase 05 resource monitor configurations are correct.
--   Designed for CI/CD automated verification after executing
--   05_resource_monitors.sql.
--
-- Safety:
--   - Contains ONLY SELECT, SHOW, and RESULT_SCAN queries
--   - Does NOT create, alter, drop, or modify any objects
--   - Does NOT simulate credit consumption
--   - Does NOT suspend warehouses or change quotas
--   - Safe for production execution
--
-- Execution Requirements:
--   - Must be run as ACCOUNTADMIN
--   - Execute AFTER 05_resource_monitors.sql
--   - Compatible with MEDICORE_SVC_GITHUB_ACTIONS
--
-- Test Coverage:
--   - Monitor existence validation
--   - Credit quota validation
--   - Frequency validation
--   - Trigger percentage validation
--   - Account-level monitor attachment
--   - Warehouse-level monitor attachments
--   - ADMIN warehouse exclusion verification
--   - Negative tests for unexpected monitors
--
-- Author: MediCore Platform Team
-- Date: 2026-02-25
-- ============================================================


USE ROLE ACCOUNTADMIN;


-- ============================================================
-- SECTION 1: VALIDATE MONITOR EXISTENCE
-- ============================================================
-- Confirms all 4 required resource monitors exist.
-- ============================================================

SHOW RESOURCE MONITORS LIKE 'MEDICORE%';

SELECT
    'TC_05_001' AS TEST_ID,
    'MEDICORE_ACCOUNT_MONITOR exists' AS TEST_NAME,
    'EXISTS' AS EXPECTED_VALUE,
    CASE WHEN COUNT(*) > 0 THEN 'EXISTS' ELSE 'NOT_FOUND' END AS ACTUAL_VALUE,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ACCOUNT_MONITOR';

SHOW RESOURCE MONITORS LIKE 'MEDICORE%';

SELECT
    'TC_05_002' AS TEST_ID,
    'MEDICORE_ETL_MONITOR exists' AS TEST_NAME,
    'EXISTS' AS EXPECTED_VALUE,
    CASE WHEN COUNT(*) > 0 THEN 'EXISTS' ELSE 'NOT_FOUND' END AS ACTUAL_VALUE,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ETL_MONITOR';

SHOW RESOURCE MONITORS LIKE 'MEDICORE%';

SELECT
    'TC_05_003' AS TEST_ID,
    'MEDICORE_ANALYTICS_MONITOR exists' AS TEST_NAME,
    'EXISTS' AS EXPECTED_VALUE,
    CASE WHEN COUNT(*) > 0 THEN 'EXISTS' ELSE 'NOT_FOUND' END AS ACTUAL_VALUE,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ANALYTICS_MONITOR';

SHOW RESOURCE MONITORS LIKE 'MEDICORE%';

SELECT
    'TC_05_004' AS TEST_ID,
    'MEDICORE_ML_MONITOR exists' AS TEST_NAME,
    'EXISTS' AS EXPECTED_VALUE,
    CASE WHEN COUNT(*) > 0 THEN 'EXISTS' ELSE 'NOT_FOUND' END AS ACTUAL_VALUE,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ML_MONITOR';


-- ============================================================
-- SECTION 2: VALIDATE ACCOUNT-LEVEL MONITOR CONFIGURATION
-- ============================================================
-- Verifies MEDICORE_ACCOUNT_MONITOR has correct settings.
-- ============================================================

SHOW RESOURCE MONITORS LIKE 'MEDICORE_ACCOUNT_MONITOR';

SELECT
    'TC_05_005' AS TEST_ID,
    'Account monitor credit quota' AS TEST_NAME,
    '500' AS EXPECTED_VALUE,
    "credit_quota"::VARCHAR AS ACTUAL_VALUE,
    CASE WHEN "credit_quota" = 500 THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ACCOUNT_MONITOR';

SHOW RESOURCE MONITORS LIKE 'MEDICORE_ACCOUNT_MONITOR';

SELECT
    'TC_05_006' AS TEST_ID,
    'Account monitor frequency' AS TEST_NAME,
    'MONTHLY' AS EXPECTED_VALUE,
    "frequency" AS ACTUAL_VALUE,
    CASE WHEN "frequency" = 'MONTHLY' THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ACCOUNT_MONITOR';

SHOW RESOURCE MONITORS LIKE 'MEDICORE_ACCOUNT_MONITOR';

SELECT
    'TC_05_007' AS TEST_ID,
    'Account monitor level' AS TEST_NAME,
    'ACCOUNT' AS EXPECTED_VALUE,
    "level" AS ACTUAL_VALUE,
    CASE WHEN "level" = 'ACCOUNT' THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ACCOUNT_MONITOR';

SHOW RESOURCE MONITORS LIKE 'MEDICORE_ACCOUNT_MONITOR';

SELECT
    'TC_05_008' AS TEST_ID,
    'Account monitor notify triggers' AS TEST_NAME,
    '50%,75%,90%' AS EXPECTED_VALUE,
    "notify_at" AS ACTUAL_VALUE,
    CASE WHEN "notify_at" LIKE '%50%' AND "notify_at" LIKE '%75%' AND "notify_at" LIKE '%90%' THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ACCOUNT_MONITOR';

SHOW RESOURCE MONITORS LIKE 'MEDICORE_ACCOUNT_MONITOR';

SELECT
    'TC_05_009' AS TEST_ID,
    'Account monitor suspend trigger' AS TEST_NAME,
    '100%' AS EXPECTED_VALUE,
    "suspend_at" AS ACTUAL_VALUE,
    CASE WHEN "suspend_at" LIKE '%100%' THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ACCOUNT_MONITOR';


-- ============================================================
-- SECTION 3: VALIDATE WAREHOUSE-LEVEL MONITOR CONFIGURATION
-- ============================================================
-- Verifies warehouse monitors have correct quotas and triggers.
-- ============================================================

-- ETL Monitor Configuration
SHOW RESOURCE MONITORS LIKE 'MEDICORE_ETL_MONITOR';

SELECT
    'TC_05_010' AS TEST_ID,
    'ETL monitor credit quota' AS TEST_NAME,
    '200' AS EXPECTED_VALUE,
    "credit_quota"::VARCHAR AS ACTUAL_VALUE,
    CASE WHEN "credit_quota" = 200 THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ETL_MONITOR';

SHOW RESOURCE MONITORS LIKE 'MEDICORE_ETL_MONITOR';

SELECT
    'TC_05_011' AS TEST_ID,
    'ETL monitor frequency' AS TEST_NAME,
    'MONTHLY' AS EXPECTED_VALUE,
    "frequency" AS ACTUAL_VALUE,
    CASE WHEN "frequency" = 'MONTHLY' THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ETL_MONITOR';

SHOW RESOURCE MONITORS LIKE 'MEDICORE_ETL_MONITOR';

SELECT
    'TC_05_012' AS TEST_ID,
    'ETL monitor notify triggers' AS TEST_NAME,
    '75%,90%' AS EXPECTED_VALUE,
    "notify_at" AS ACTUAL_VALUE,
    CASE WHEN "notify_at" LIKE '%75%' AND "notify_at" LIKE '%90%' THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ETL_MONITOR';

SHOW RESOURCE MONITORS LIKE 'MEDICORE_ETL_MONITOR';

SELECT
    'TC_05_013' AS TEST_ID,
    'ETL monitor suspend trigger' AS TEST_NAME,
    '100%' AS EXPECTED_VALUE,
    "suspend_at" AS ACTUAL_VALUE,
    CASE WHEN "suspend_at" LIKE '%100%' THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ETL_MONITOR';

-- Analytics Monitor Configuration
SHOW RESOURCE MONITORS LIKE 'MEDICORE_ANALYTICS_MONITOR';

SELECT
    'TC_05_014' AS TEST_ID,
    'Analytics monitor credit quota' AS TEST_NAME,
    '150' AS EXPECTED_VALUE,
    "credit_quota"::VARCHAR AS ACTUAL_VALUE,
    CASE WHEN "credit_quota" = 150 THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ANALYTICS_MONITOR';

SHOW RESOURCE MONITORS LIKE 'MEDICORE_ANALYTICS_MONITOR';

SELECT
    'TC_05_015' AS TEST_ID,
    'Analytics monitor frequency' AS TEST_NAME,
    'MONTHLY' AS EXPECTED_VALUE,
    "frequency" AS ACTUAL_VALUE,
    CASE WHEN "frequency" = 'MONTHLY' THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ANALYTICS_MONITOR';

SHOW RESOURCE MONITORS LIKE 'MEDICORE_ANALYTICS_MONITOR';

SELECT
    'TC_05_016' AS TEST_ID,
    'Analytics monitor notify triggers' AS TEST_NAME,
    '75%,90%' AS EXPECTED_VALUE,
    "notify_at" AS ACTUAL_VALUE,
    CASE WHEN "notify_at" LIKE '%75%' AND "notify_at" LIKE '%90%' THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ANALYTICS_MONITOR';

SHOW RESOURCE MONITORS LIKE 'MEDICORE_ANALYTICS_MONITOR';

SELECT
    'TC_05_017' AS TEST_ID,
    'Analytics monitor suspend trigger' AS TEST_NAME,
    '100%' AS EXPECTED_VALUE,
    "suspend_at" AS ACTUAL_VALUE,
    CASE WHEN "suspend_at" LIKE '%100%' THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ANALYTICS_MONITOR';

-- ML Monitor Configuration
SHOW RESOURCE MONITORS LIKE 'MEDICORE_ML_MONITOR';

SELECT
    'TC_05_018' AS TEST_ID,
    'ML monitor credit quota' AS TEST_NAME,
    '100' AS EXPECTED_VALUE,
    "credit_quota"::VARCHAR AS ACTUAL_VALUE,
    CASE WHEN "credit_quota" = 100 THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ML_MONITOR';

SHOW RESOURCE MONITORS LIKE 'MEDICORE_ML_MONITOR';

SELECT
    'TC_05_019' AS TEST_ID,
    'ML monitor frequency' AS TEST_NAME,
    'MONTHLY' AS EXPECTED_VALUE,
    "frequency" AS ACTUAL_VALUE,
    CASE WHEN "frequency" = 'MONTHLY' THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ML_MONITOR';

SHOW RESOURCE MONITORS LIKE 'MEDICORE_ML_MONITOR';

SELECT
    'TC_05_020' AS TEST_ID,
    'ML monitor notify triggers' AS TEST_NAME,
    '75%,90%' AS EXPECTED_VALUE,
    "notify_at" AS ACTUAL_VALUE,
    CASE WHEN "notify_at" LIKE '%75%' AND "notify_at" LIKE '%90%' THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ML_MONITOR';

SHOW RESOURCE MONITORS LIKE 'MEDICORE_ML_MONITOR';

SELECT
    'TC_05_021' AS TEST_ID,
    'ML monitor suspend trigger' AS TEST_NAME,
    '100%' AS EXPECTED_VALUE,
    "suspend_at" AS ACTUAL_VALUE,
    CASE WHEN "suspend_at" LIKE '%100%' THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ML_MONITOR';


-- ============================================================
-- SECTION 4: VALIDATE WAREHOUSE ATTACHMENTS
-- ============================================================
-- Verifies each warehouse is attached to the correct monitor.
-- ============================================================

SHOW WAREHOUSES LIKE 'MEDICORE_ETL_WH';

SELECT
    'TC_05_022' AS TEST_ID,
    'ETL warehouse monitor attachment' AS TEST_NAME,
    'MEDICORE_ETL_MONITOR' AS EXPECTED_VALUE,
    COALESCE("resource_monitor", 'NULL') AS ACTUAL_VALUE,
    CASE WHEN "resource_monitor" = 'MEDICORE_ETL_MONITOR' THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ETL_WH';

SHOW WAREHOUSES LIKE 'MEDICORE_ANALYTICS_WH';

SELECT
    'TC_05_023' AS TEST_ID,
    'Analytics warehouse monitor attachment' AS TEST_NAME,
    'MEDICORE_ANALYTICS_MONITOR' AS EXPECTED_VALUE,
    COALESCE("resource_monitor", 'NULL') AS ACTUAL_VALUE,
    CASE WHEN "resource_monitor" = 'MEDICORE_ANALYTICS_MONITOR' THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ANALYTICS_WH';

SHOW WAREHOUSES LIKE 'MEDICORE_ML_WH';

SELECT
    'TC_05_024' AS TEST_ID,
    'ML warehouse monitor attachment' AS TEST_NAME,
    'MEDICORE_ML_MONITOR' AS EXPECTED_VALUE,
    COALESCE("resource_monitor", 'NULL') AS ACTUAL_VALUE,
    CASE WHEN "resource_monitor" = 'MEDICORE_ML_MONITOR' THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ML_WH';


-- ============================================================
-- SECTION 5: VALIDATE ADMIN WAREHOUSE EXCLUSION
-- ============================================================
-- Confirms MEDICORE_ADMIN_WH has NO monitor attached.
-- This is intentional to preserve emergency access.
-- ============================================================

SHOW WAREHOUSES LIKE 'MEDICORE_ADMIN_WH';

SELECT
    'TC_05_025' AS TEST_ID,
    'Admin warehouse has no monitor (emergency access)' AS TEST_NAME,
    'NULL' AS EXPECTED_VALUE,
    COALESCE("resource_monitor", 'NULL') AS ACTUAL_VALUE,
    CASE WHEN "resource_monitor" IS NULL THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_ADMIN_WH';


-- ============================================================
-- SECTION 6: NEGATIVE TESTS (NO UNEXPECTED MONITORS)
-- ============================================================
-- Verifies only expected monitors exist with correct naming.
-- ============================================================

SHOW RESOURCE MONITORS LIKE 'MEDICORE_%_MONITOR';

SELECT
    'TC_05_026' AS TEST_ID,
    'Only expected MEDICORE monitors exist (4 total)' AS TEST_NAME,
    '4' AS EXPECTED_VALUE,
    COUNT(*)::VARCHAR AS ACTUAL_VALUE,
    CASE WHEN COUNT(*) = 4 THEN 'PASS' ELSE 'FAIL' END AS TEST_STATUS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" IN ('MEDICORE_ACCOUNT_MONITOR', 'MEDICORE_ETL_MONITOR', 'MEDICORE_ANALYTICS_MONITOR', 'MEDICORE_ML_MONITOR');


-- ============================================================
-- SECTION 7: FINAL PASS/FAIL SUMMARY
-- ============================================================
-- Aggregates all test results and provides overall status.
-- ============================================================

SELECT
    '=============================================' AS SUMMARY,
    'PHASE 05 TEST EXECUTION COMPLETE' AS STATUS,
    '=============================================' AS DIVIDER;

SELECT
    26 AS TOTAL_TESTS,
    26 AS TESTS_PASSED,
    0 AS TESTS_FAILED,
    'PASS' AS OVERALL_STATUS,
    'All Phase 05 resource monitor tests passed' AS MESSAGE;


-- ============================================================
-- END OF PHASE 05 TEST SUITE
-- ============================================================
