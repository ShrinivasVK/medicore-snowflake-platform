-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 00: GitHub Integration - TEST CASES
-- File: 00_test_git_setup.sql
-- Version: 2.0.0
--
-- Change Reason: Updated all references from GOVERNANCE_DB to
--               MEDICORE_GOVERNANCE_DB to align with refined
--               database naming convention established in
--               Phase 01 v2.0.0. All schema references, secret
--               paths, repository paths, and LIST stage paths
--               updated accordingly. GIT REPOSITORY object now
--               uses fully qualified three-part name
--               MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PLATFORM_REPO
--               to prevent session context errors.
--
-- Description:
--   Comprehensive test cases to validate Phase 00 GitHub Integration
--   implementation including secrets, API integration, and Git
--   repository. All objects live in MEDICORE_GOVERNANCE_DB.SECURITY
--   as bootstrapped by Phase 01.
--
-- How to Run:
--   - Execute as ACCOUNTADMIN
--   - Phase 01 must be completed before running these tests
--   - Run each test case individually
--   - Record PASS/FAIL in 00_test_results_log.md
--
-- Author: [YOUR_NAME]
-- Date: [YYYY-MM-DD]
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE MEDICORE_GOVERNANCE_DB;
USE SCHEMA MEDICORE_GOVERNANCE_DB.SECURITY;

-- ============================================================
-- TEST CATEGORY: EXISTENCE - Verify all objects were created
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID   : TC_00_001
-- Phase     : 00 - GitHub Integration
-- Category  : EXISTENCE
-- Description: Verify GITHUB_TOKEN secret exists in
--              MEDICORE_GOVERNANCE_DB.SECURITY
-- Expected  : Secret named GITHUB_TOKEN is listed
-- ------------------------------------------------------------
SHOW SECRETS LIKE 'GITHUB_TOKEN' IN SCHEMA MEDICORE_GOVERNANCE_DB.SECURITY;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_002
-- Phase     : 00 - GitHub Integration
-- Category  : EXISTENCE
-- Description: Verify MEDICORE_GITHUB_INTEGRATION API integration exists
-- Expected  : API integration is listed and enabled
-- ------------------------------------------------------------
SHOW API INTEGRATIONS LIKE 'MEDICORE_GITHUB_INTEGRATION';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_003
-- Phase     : 00 - GitHub Integration
-- Category  : EXISTENCE
-- Description: Verify MEDICORE_PLATFORM_REPO Git repository exists
--              in MEDICORE_GOVERNANCE_DB.SECURITY schema
-- Expected  : Git repository is listed
-- ------------------------------------------------------------
SHOW GIT REPOSITORIES LIKE 'MEDICORE_PLATFORM_REPO' IN SCHEMA MEDICORE_GOVERNANCE_DB.SECURITY;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ============================================================
-- TEST CATEGORY: CONFIGURATION - Verify correct settings
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID   : TC_00_004
-- Phase     : 00 - GitHub Integration
-- Category  : CONFIGURATION
-- Description: Verify GITHUB_TOKEN secret is of type PASSWORD
-- Expected  : secret_type = 'PASSWORD'
-- ------------------------------------------------------------
SHOW SECRETS LIKE 'GITHUB_TOKEN' IN SCHEMA MEDICORE_GOVERNANCE_DB.SECURITY;
SELECT
    "name",
    "secret_type",
    "database_name",
    "schema_name"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'GITHUB_TOKEN'
  AND "secret_type" = 'PASSWORD';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_005
-- Phase     : 00 - GitHub Integration
-- Category  : CONFIGURATION
-- Description: Verify API integration is enabled
-- Expected  : enabled = 'true'
-- ------------------------------------------------------------
SHOW API INTEGRATIONS LIKE 'MEDICORE_GITHUB_INTEGRATION';
SELECT
    "name",
    "enabled",
    "type",
    "category"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_GITHUB_INTEGRATION'
  AND "enabled" = 'true';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_006
-- Phase     : 00 - GitHub Integration
-- Category  : CONFIGURATION
-- Description: Verify Git repository origin URL is correct
-- Expected  : origin = 'https://github.com/ShrinivasVK/medicore-snowflake-platform.git'
-- ------------------------------------------------------------
SHOW GIT REPOSITORIES LIKE 'MEDICORE_PLATFORM_REPO' IN SCHEMA MEDICORE_GOVERNANCE_DB.SECURITY;
SELECT
    "name",
    "origin",
    "api_integration",
    "git_credentials"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "name" = 'MEDICORE_PLATFORM_REPO'
  AND "origin" = 'https://github.com/ShrinivasVK/medicore-snowflake-platform.git';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_007
-- Phase     : 00 - GitHub Integration
-- Category  : CONFIGURATION
-- Description: Verify Git repository uses correct API integration
-- Expected  : api_integration = 'MEDICORE_GITHUB_INTEGRATION'
-- ------------------------------------------------------------
SHOW GIT REPOSITORIES LIKE 'MEDICORE_PLATFORM_REPO' IN SCHEMA MEDICORE_GOVERNANCE_DB.SECURITY;
SELECT
    "name",
    "api_integration"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "api_integration" = 'MEDICORE_GITHUB_INTEGRATION';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_008
-- Phase     : 00 - GitHub Integration
-- Category  : CONFIGURATION
-- Description: Verify Git repository uses correct credentials secret
-- Expected  : git_credentials references
--             MEDICORE_GOVERNANCE_DB.SECURITY.GITHUB_TOKEN
-- ------------------------------------------------------------
SHOW GIT REPOSITORIES LIKE 'MEDICORE_PLATFORM_REPO' IN SCHEMA MEDICORE_GOVERNANCE_DB.SECURITY;
SELECT
    "name",
    "git_credentials"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "git_credentials" LIKE '%MEDICORE_GOVERNANCE_DB%SECURITY%GITHUB_TOKEN%';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ============================================================
-- TEST CATEGORY: SECURITY - Verify schema location
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID   : TC_00_009
-- Phase     : 00 - GitHub Integration
-- Category  : SECURITY
-- Description: Verify secret is stored in correct database and schema
-- Expected  : database_name = 'MEDICORE_GOVERNANCE_DB',
--             schema_name   = 'SECURITY'
-- ------------------------------------------------------------
SHOW SECRETS LIKE 'GITHUB_TOKEN' IN SCHEMA MEDICORE_GOVERNANCE_DB.SECURITY;
SELECT
    "name",
    "database_name",
    "schema_name"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "database_name" = 'MEDICORE_GOVERNANCE_DB'
  AND "schema_name"   = 'SECURITY';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_010
-- Phase     : 00 - GitHub Integration
-- Category  : SECURITY
-- Description: Verify Git repository is in correct database and schema
-- Expected  : database_name = 'MEDICORE_GOVERNANCE_DB',
--             schema_name   = 'SECURITY'
-- ------------------------------------------------------------
SHOW GIT REPOSITORIES LIKE 'MEDICORE_PLATFORM_REPO' IN SCHEMA MEDICORE_GOVERNANCE_DB.SECURITY;
SELECT
    "name",
    "database_name",
    "schema_name"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "database_name" = 'MEDICORE_GOVERNANCE_DB'
  AND "schema_name"   = 'SECURITY';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ============================================================
-- TEST CATEGORY: FUNCTIONALITY - Verify operations work
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID   : TC_00_011
-- Phase     : 00 - GitHub Integration
-- Category  : FUNCTIONALITY
-- Description: Verify repository can be fetched successfully
-- Expected  : Command completes without error
-- Note      : Uses fully qualified name to avoid session
--             context errors
-- ------------------------------------------------------------
ALTER GIT REPOSITORY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PLATFORM_REPO FETCH;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_012
-- Phase     : 00 - GitHub Integration
-- Category  : FUNCTIONALITY
-- Description: Verify repository branches are visible
-- Expected  : At least 'main' branch is listed
-- ------------------------------------------------------------
SHOW GIT BRANCHES IN MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PLATFORM_REPO;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_013
-- Phase     : 00 - GitHub Integration
-- Category  : FUNCTIONALITY
-- Description: Verify files are accessible in repository root
-- Expected  : Files and folders listed from main branch root
-- ------------------------------------------------------------
LIST @MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PLATFORM_REPO/branches/main/;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_014
-- Phase     : 00 - GitHub Integration
-- Category  : FUNCTIONALITY
-- Description: Verify Phase 00 implementation file exists in repo
-- Expected  : 00_github_integration.sql file is listed
-- ------------------------------------------------------------
LIST @MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PLATFORM_REPO/branches/main/infrastructure/00_git-setup/;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_015
-- Phase     : 00 - GitHub Integration
-- Category  : FUNCTIONALITY
-- Description: Verify Phase 01 implementation file exists in repo
-- Expected  : 01_account_administration.sql file is listed
-- ------------------------------------------------------------
LIST @MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PLATFORM_REPO/branches/main/infrastructure/01_account-admin/;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ============================================================
-- PHASE 00 TEST SUMMARY
-- ============================================================
-- Total Test Cases: 15
--
-- Test Checklist:
--
-- EXISTENCE (3 tests):
-- [ ] TC_00_001 - GITHUB_TOKEN secret exists in MEDICORE_GOVERNANCE_DB.SECURITY
-- [ ] TC_00_002 - MEDICORE_GITHUB_INTEGRATION API integration exists
-- [ ] TC_00_003 - MEDICORE_PLATFORM_REPO Git repository exists
--
-- CONFIGURATION (5 tests):
-- [ ] TC_00_004 - Secret type is PASSWORD
-- [ ] TC_00_005 - API integration is enabled
-- [ ] TC_00_006 - Repository origin URL is correct
-- [ ] TC_00_007 - Repository uses correct API integration
-- [ ] TC_00_008 - Repository uses correct credentials secret
--
-- SECURITY (2 tests):
-- [ ] TC_00_009 - Secret is in MEDICORE_GOVERNANCE_DB.SECURITY
-- [ ] TC_00_010 - Repository is in MEDICORE_GOVERNANCE_DB.SECURITY
--
-- FUNCTIONALITY (5 tests):
-- [ ] TC_00_011 - Repository fetch completes without error
-- [ ] TC_00_012 - Repository branches are visible
-- [ ] TC_00_013 - Repository root files are accessible
-- [ ] TC_00_014 - Phase 00 implementation file exists in repo
-- [ ] TC_00_015 - Phase 01 implementation file exists in repo
--
-- OVERALL PHASE 00 RESULT: [ ] PASS  [ ] FAIL
-- Tested By:
-- Test Date:
-- ============================================================
-- END OF PHASE 00 TEST CASES
-- ============================================================