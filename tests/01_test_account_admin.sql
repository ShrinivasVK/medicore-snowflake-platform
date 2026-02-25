-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 01: Account Administration - TEST CASES
-- File: 01_test_account_admin.sql
-- Version: 2.0.0
--
-- Change Reason: Updated all references from GOVERNANCE_DB to
--               MEDICORE_GOVERNANCE_DB to align with refined
--               database naming convention. All policy references,
--               schema references, and INFORMATION_SCHEMA calls
--               updated accordingly.
--
-- Description:
--   Comprehensive test cases to validate Phase 01 Account Administration
--   implementation including governance database bootstrap, network policy,
--   password policy, session policy, and account parameters.
--
-- How to Run:
--   - Execute as ACCOUNTADMIN
--   - Run each test case individually
--   - Record PASS/FAIL in 00_test_results_log.md
--
-- Author: [YOUR_NAME]
-- Date: [YYYY-MM-DD]
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================
-- TEST CATEGORY: EXISTENCE - Database and Schema
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID   : TC_01_001
-- Phase     : 01 - Account Administration
-- Category  : EXISTENCE
-- Description: Verify MEDICORE_GOVERNANCE_DB database exists
-- Expected  : Database MEDICORE_GOVERNANCE_DB is listed
-- ------------------------------------------------------------
SHOW DATABASES LIKE 'MEDICORE_GOVERNANCE_DB';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_002
-- Phase     : 01 - Account Administration
-- Category  : EXISTENCE
-- Description: Verify SECURITY schema exists in MEDICORE_GOVERNANCE_DB
-- Expected  : Schema SECURITY is listed in MEDICORE_GOVERNANCE_DB
-- ------------------------------------------------------------
SHOW SCHEMAS LIKE 'SECURITY' IN DATABASE MEDICORE_GOVERNANCE_DB;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_003
-- Phase     : 01 - Account Administration
-- Category  : EXISTENCE
-- Description: Verify Phase 04 governance schemas do NOT exist yet
-- Expected  : POLICIES, TAGS, DATA_QUALITY, AUDIT schemas are absent
--             These are created exclusively in Phase 04
-- ------------------------------------------------------------
SHOW SCHEMAS IN DATABASE MEDICORE_GOVERNANCE_DB;
SELECT "name" FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" NOT IN ('SECURITY', 'INFORMATION_SCHEMA', 'PUBLIC');
-- Expected result: 0 rows (no extra schemas should exist after Phase 01)
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ============================================================
-- TEST CATEGORY: EXISTENCE - Network Policy Objects
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID   : TC_01_004
-- Phase     : 01 - Account Administration
-- Category  : EXISTENCE
-- Description: Verify MEDICORE_ALLOWED_IPS network rule exists
-- Expected  : Network rule exists in MEDICORE_GOVERNANCE_DB.SECURITY
-- ------------------------------------------------------------
SHOW NETWORK RULES LIKE 'MEDICORE_ALLOWED_IPS' IN SCHEMA MEDICORE_GOVERNANCE_DB.SECURITY;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_005
-- Phase     : 01 - Account Administration
-- Category  : EXISTENCE
-- Description: Verify MEDICORE_NETWORK_POLICY exists
-- Expected  : Network policy is listed
-- ------------------------------------------------------------
SHOW NETWORK POLICIES LIKE 'MEDICORE_NETWORK_POLICY';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ============================================================
-- TEST CATEGORY: EXISTENCE - Password Policy
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID   : TC_01_006
-- Phase     : 01 - Account Administration
-- Category  : EXISTENCE
-- Description: Verify MEDICORE_PASSWORD_POLICY exists in correct schema
-- Expected  : Password policy exists in MEDICORE_GOVERNANCE_DB.SECURITY
-- ------------------------------------------------------------
SHOW PASSWORD POLICIES LIKE 'MEDICORE_PASSWORD_POLICY' IN SCHEMA MEDICORE_GOVERNANCE_DB.SECURITY;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ============================================================
-- TEST CATEGORY: EXISTENCE - Session Policy
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID   : TC_01_007
-- Phase     : 01 - Account Administration
-- Category  : EXISTENCE
-- Description: Verify MEDICORE_SESSION_POLICY exists in correct schema
-- Expected  : Session policy exists in MEDICORE_GOVERNANCE_DB.SECURITY
-- ------------------------------------------------------------
SHOW SESSION POLICIES LIKE 'MEDICORE_SESSION_POLICY' IN SCHEMA MEDICORE_GOVERNANCE_DB.SECURITY;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ============================================================
-- TEST CATEGORY: POLICY - Network Policy Applied
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID   : TC_01_008
-- Phase     : 01 - Account Administration
-- Category  : POLICY
-- Description: Verify network policy is applied at account level
-- Expected  : NETWORK_POLICY parameter = 'MEDICORE_NETWORK_POLICY'
-- ------------------------------------------------------------
SHOW PARAMETERS LIKE 'NETWORK_POLICY' IN ACCOUNT;
SELECT key, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE key = 'NETWORK_POLICY' AND value = 'MEDICORE_NETWORK_POLICY';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_009
-- Phase     : 01 - Account Administration
-- Category  : POLICY
-- Description: Verify network rule is type IPV4 with INGRESS mode
-- Expected  : type = 'IPV4', mode = 'INGRESS'
-- ------------------------------------------------------------
SHOW NETWORK RULES LIKE 'MEDICORE_ALLOWED_IPS' IN SCHEMA MEDICORE_GOVERNANCE_DB.SECURITY;
SELECT "name", "type", "mode" FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "type" = 'IPV4' AND "mode" = 'INGRESS';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_010
-- Phase     : 01 - Account Administration
-- Category  : POLICY
-- Description: Verify network policy has exactly 1 allowed network rule
-- Expected  : entries_in_allowed_network_rules = 1
-- ------------------------------------------------------------
SHOW NETWORK POLICIES LIKE 'MEDICORE_NETWORK_POLICY';
SELECT "name", "entries_in_allowed_network_rules"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "entries_in_allowed_network_rules" = 1;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ============================================================
-- TEST CATEGORY: CONFIGURATION - Password Policy Parameters
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID   : TC_01_011
-- Phase     : 01 - Account Administration
-- Category  : CONFIGURATION
-- Description: Verify password minimum length is 14 characters
-- Expected  : PASSWORD_MIN_LENGTH = 14
-- ------------------------------------------------------------
DESCRIBE PASSWORD POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY;
SELECT property, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE property = 'PASSWORD_MIN_LENGTH' AND value = '14';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_012
-- Phase     : 01 - Account Administration
-- Category  : CONFIGURATION
-- Description: Verify password max age is 90 days
-- Expected  : PASSWORD_MAX_AGE_DAYS = 90
-- ------------------------------------------------------------
DESCRIBE PASSWORD POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY;
SELECT property, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE property = 'PASSWORD_MAX_AGE_DAYS' AND value = '90';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_013
-- Phase     : 01 - Account Administration
-- Category  : CONFIGURATION
-- Description: Verify password history is 12 passwords
-- Expected  : PASSWORD_HISTORY = 12
-- ------------------------------------------------------------
DESCRIBE PASSWORD POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY;
SELECT property, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE property = 'PASSWORD_HISTORY' AND value = '12';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_014
-- Phase     : 01 - Account Administration
-- Category  : CONFIGURATION
-- Description: Verify lockout after 5 failed attempts
-- Expected  : PASSWORD_MAX_RETRIES = 5
-- ------------------------------------------------------------
DESCRIBE PASSWORD POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY;
SELECT property, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE property = 'PASSWORD_MAX_RETRIES' AND value = '5';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_015
-- Phase     : 01 - Account Administration
-- Category  : CONFIGURATION
-- Description: Verify lockout time is 30 minutes
-- Expected  : PASSWORD_LOCKOUT_TIME_MINS = 30
-- ------------------------------------------------------------
DESCRIBE PASSWORD POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY;
SELECT property, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE property = 'PASSWORD_LOCKOUT_TIME_MINS' AND value = '30';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_016
-- Phase     : 01 - Account Administration
-- Category  : CONFIGURATION
-- Description: Verify minimum special characters requirement
-- Expected  : PASSWORD_MIN_SPECIAL_CHARS = 1
-- ------------------------------------------------------------
DESCRIBE PASSWORD POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY;
SELECT property, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE property = 'PASSWORD_MIN_SPECIAL_CHARS' AND value = '1';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ============================================================
-- TEST CATEGORY: CONFIGURATION - Session Policy Parameters
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID   : TC_01_017
-- Phase     : 01 - Account Administration
-- Category  : CONFIGURATION
-- Description: Verify session idle timeout is 240 minutes (4 hours)
-- Expected  : SESSION_IDLE_TIMEOUT_MINS = 240
-- ------------------------------------------------------------
DESCRIBE SESSION POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_SESSION_POLICY;
SELECT property, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE property = 'SESSION_IDLE_TIMEOUT_MINS' AND value = '240';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_018
-- Phase     : 01 - Account Administration
-- Category  : CONFIGURATION
-- Description: Verify UI session idle timeout is 240 minutes (4 hours)
-- Expected  : SESSION_UI_IDLE_TIMEOUT_MINS = 240
-- ------------------------------------------------------------
DESCRIBE SESSION POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_SESSION_POLICY;
SELECT property, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE property = 'SESSION_UI_IDLE_TIMEOUT_MINS' AND value = '240';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ============================================================
-- TEST CATEGORY: CONFIGURATION - Account Parameters
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID   : TC_01_019
-- Phase     : 01 - Account Administration
-- Category  : CONFIGURATION
-- Description: Verify timezone is set to America/Chicago
-- Expected  : TIMEZONE = 'America/Chicago'
-- ------------------------------------------------------------
SHOW PARAMETERS LIKE 'TIMEZONE' IN ACCOUNT;
SELECT key, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE key = 'TIMEZONE' AND value = 'America/Chicago';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_020
-- Phase     : 01 - Account Administration
-- Category  : CONFIGURATION
-- Description: Verify statement timeout is 3600 seconds (1 hour)
-- Expected  : STATEMENT_TIMEOUT_IN_SECONDS = 3600
-- ------------------------------------------------------------
SHOW PARAMETERS LIKE 'STATEMENT_TIMEOUT_IN_SECONDS' IN ACCOUNT;
SELECT key, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE key = 'STATEMENT_TIMEOUT_IN_SECONDS' AND value = '3600';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_021
-- Phase     : 01 - Account Administration
-- Category  : CONFIGURATION
-- Description: Verify statement queued timeout is 1800 seconds (30 min)
-- Expected  : STATEMENT_QUEUED_TIMEOUT_IN_SECONDS = 1800
-- ------------------------------------------------------------
SHOW PARAMETERS LIKE 'STATEMENT_QUEUED_TIMEOUT_IN_SECONDS' IN ACCOUNT;
SELECT key, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE key = 'STATEMENT_QUEUED_TIMEOUT_IN_SECONDS' AND value = '1800';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_022
-- Phase     : 01 - Account Administration
-- Category  : CONFIGURATION
-- Description: Verify data retention is 14 days
-- Expected  : DATA_RETENTION_TIME_IN_DAYS = 14
-- ------------------------------------------------------------
SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN ACCOUNT;
SELECT key, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE key = 'DATA_RETENTION_TIME_IN_DAYS' AND value = '14';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_023
-- Phase     : 01 - Account Administration
-- Category  : CONFIGURATION
-- Description: Verify minimum data retention is 7 days
-- Expected  : MIN_DATA_RETENTION_TIME_IN_DAYS = 7
-- ------------------------------------------------------------
SHOW PARAMETERS LIKE 'MIN_DATA_RETENTION_TIME_IN_DAYS' IN ACCOUNT;
SELECT key, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE key = 'MIN_DATA_RETENTION_TIME_IN_DAYS' AND value = '7';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_024
-- Phase     : 01 - Account Administration
-- Category  : CONFIGURATION
-- Description: Verify storage integration required for stage creation
-- Expected  : REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION = true
-- ------------------------------------------------------------
SHOW PARAMETERS LIKE 'REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION' IN ACCOUNT;
SELECT key, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE key = 'REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION' AND value = 'true';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_025
-- Phase     : 01 - Account Administration
-- Category  : CONFIGURATION
-- Description: Verify storage integration required for stage operation
-- Expected  : REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_OPERATION = true
-- ------------------------------------------------------------
SHOW PARAMETERS LIKE 'REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_OPERATION' IN ACCOUNT;
SELECT key, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE key = 'REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_OPERATION' AND value = 'true';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ============================================================
-- TEST CATEGORY: SECURITY - Business Critical Parameters
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID   : TC_01_026
-- Phase     : 01 - Account Administration
-- Category  : SECURITY
-- Description: Verify periodic data rekeying is enabled (Business Critical)
-- Expected  : PERIODIC_DATA_REKEYING = true
-- ------------------------------------------------------------
SHOW PARAMETERS LIKE 'PERIODIC_DATA_REKEYING' IN ACCOUNT;
SELECT key, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE key = 'PERIODIC_DATA_REKEYING' AND value = 'true';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_027
-- Phase     : 01 - Account Administration
-- Category  : SECURITY
-- Description: Verify OAuth privileged roles are blocked
-- Expected  : OAUTH_ADD_PRIVILEGED_ROLES_TO_BLOCKED_LIST = true
-- ------------------------------------------------------------
SHOW PARAMETERS LIKE 'OAUTH_ADD_PRIVILEGED_ROLES_TO_BLOCKED_LIST' IN ACCOUNT;
SELECT key, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE key = 'OAUTH_ADD_PRIVILEGED_ROLES_TO_BLOCKED_LIST' AND value = 'true';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_028
-- Phase     : 01 - Account Administration
-- Category  : SECURITY
-- Description: Verify external OAuth privileged roles are blocked
-- Expected  : EXTERNAL_OAUTH_ADD_PRIVILEGED_ROLES_TO_BLOCKED_LIST = true
-- ------------------------------------------------------------
SHOW PARAMETERS LIKE 'EXTERNAL_OAUTH_ADD_PRIVILEGED_ROLES_TO_BLOCKED_LIST' IN ACCOUNT;
SELECT key, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE key = 'EXTERNAL_OAUTH_ADD_PRIVILEGED_ROLES_TO_BLOCKED_LIST' AND value = 'true';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_029
-- Phase     : 01 - Account Administration
-- Category  : SECURITY
-- Description: Verify identifier-first login is enabled
-- Expected  : ENABLE_IDENTIFIER_FIRST_LOGIN = true
-- ------------------------------------------------------------
SHOW PARAMETERS LIKE 'ENABLE_IDENTIFIER_FIRST_LOGIN' IN ACCOUNT;
SELECT key, value FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE key = 'ENABLE_IDENTIFIER_FIRST_LOGIN' AND value = 'true';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ============================================================
-- TEST CATEGORY: POLICY - Policy Application Verification
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID   : TC_01_030
-- Phase     : 01 - Account Administration
-- Category  : POLICY
-- Description: Verify password policy is applied at account level
-- Expected  : Policy reference shows account-level attachment
-- ------------------------------------------------------------
SELECT
    policy_db,
    policy_schema,
    policy_name,
    ref_database_name,
    ref_schema_name,
    ref_entity_name,
    ref_entity_domain
FROM TABLE(MEDICORE_GOVERNANCE_DB.INFORMATION_SCHEMA.POLICY_REFERENCES(
    POLICY_NAME => 'MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY'
));
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_01_031
-- Phase     : 01 - Account Administration
-- Category  : POLICY
-- Description: Verify session policy is applied at account level
-- Expected  : Policy reference shows account-level attachment
-- ------------------------------------------------------------
SELECT
    policy_db,
    policy_schema,
    policy_name,
    ref_database_name,
    ref_schema_name,
    ref_entity_name,
    ref_entity_domain
FROM TABLE(MEDICORE_GOVERNANCE_DB.INFORMATION_SCHEMA.POLICY_REFERENCES(
    POLICY_NAME => 'MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_SESSION_POLICY'
));
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ============================================================
-- TEST CATEGORY: BOOTSTRAP BOUNDARY - Phase 01 Scope Check
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID   : TC_01_032
-- Phase     : 01 - Account Administration
-- Category  : BOOTSTRAP BOUNDARY
-- Description: Verify only SECURITY schema exists in MEDICORE_GOVERNANCE_DB
--              after Phase 01. POLICIES, TAGS, DATA_QUALITY, AUDIT
--              must NOT exist yet — those belong to Phase 04.
-- Expected  : Only SECURITY (plus system schemas) present
-- ------------------------------------------------------------
SELECT "name" AS schema_name
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" NOT IN ('SECURITY', 'INFORMATION_SCHEMA', 'PUBLIC');
-- Expected result: 0 rows
-- If any rows are returned, Phase 04 schemas were created prematurely
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ============================================================
-- PHASE 01 TEST SUMMARY
-- ============================================================
-- Total Test Cases: 32
--
-- Test Checklist:
--
-- EXISTENCE (7 tests):
-- [ ] TC_01_001 - MEDICORE_GOVERNANCE_DB database exists
-- [ ] TC_01_002 - SECURITY schema exists in MEDICORE_GOVERNANCE_DB
-- [ ] TC_01_003 - No Phase 04 schemas exist yet (boundary check)
-- [ ] TC_01_004 - MEDICORE_ALLOWED_IPS network rule exists
-- [ ] TC_01_005 - MEDICORE_NETWORK_POLICY exists
-- [ ] TC_01_006 - MEDICORE_PASSWORD_POLICY exists
-- [ ] TC_01_007 - MEDICORE_SESSION_POLICY exists
--
-- POLICY (4 tests):
-- [ ] TC_01_008 - Network policy applied to account
-- [ ] TC_01_009 - Network rule type IPV4 and mode INGRESS
-- [ ] TC_01_010 - Network policy has 1 allowed rule
-- [ ] TC_01_030 - Password policy applied at account level
-- [ ] TC_01_031 - Session policy applied at account level
--
-- PASSWORD POLICY CONFIGURATION (6 tests):
-- [ ] TC_01_011 - Min length = 14
-- [ ] TC_01_012 - Max age = 90 days
-- [ ] TC_01_013 - History = 12 passwords
-- [ ] TC_01_014 - Max retries = 5
-- [ ] TC_01_015 - Lockout time = 30 minutes
-- [ ] TC_01_016 - Min special chars = 1
--
-- SESSION POLICY CONFIGURATION (2 tests):
-- [ ] TC_01_017 - Idle timeout = 240 minutes
-- [ ] TC_01_018 - UI idle timeout = 240 minutes
--
-- ACCOUNT PARAMETERS (7 tests):
-- [ ] TC_01_019 - Timezone = America/Chicago
-- [ ] TC_01_020 - Statement timeout = 3600 seconds
-- [ ] TC_01_021 - Queued timeout = 1800 seconds
-- [ ] TC_01_022 - Data retention = 14 days
-- [ ] TC_01_023 - Min data retention = 7 days
-- [ ] TC_01_024 - Storage integration required for stage creation
-- [ ] TC_01_025 - Storage integration required for stage operation
--
-- SECURITY / BUSINESS CRITICAL (4 tests):
-- [ ] TC_01_026 - Periodic data rekeying enabled
-- [ ] TC_01_027 - OAuth privileged roles blocked
-- [ ] TC_01_028 - External OAuth privileged roles blocked
-- [ ] TC_01_029 - Identifier-first login enabled
--
-- BOOTSTRAP BOUNDARY (1 test):
-- [ ] TC_01_032 - Only SECURITY schema exists post Phase 01
--
-- OVERALL PHASE 01 RESULT: [ ] PASS  [ ] FAIL
-- Tested By:
-- Test Date:
-- ============================================================
-- END OF PHASE 01 TEST CASES
-- ============================================================