-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 00: GitHub Integration - TEST CASES
-- File: 00_test_git_setup.sql
--
-- Description:
--   Comprehensive test cases to validate Phase 00 GitHub Integration
--   implementation including secrets, API integration, and Git repository.
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
-- TEST CATEGORY: EXISTENCE - Verify all objects were created
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID   : TC_00_001
-- Phase     : 00 - GitHub Integration
-- Category  : EXISTENCE
-- Description: Verify GITHUB_TOKEN secret exists in GOVERNANCE_DB.SECURITY
-- Expected  : Secret named GITHUB_TOKEN exists with type PASSWORD
-- ------------------------------------------------------------
SHOW SECRETS LIKE 'GITHUB_TOKEN' IN SCHEMA GOVERNANCE_DB.SECURITY;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_002
-- Phase     : 00 - GitHub Integration
-- Category  : EXISTENCE
-- Description: Verify MEDICORE_GITHUB_INTEGRATION API integration exists
-- Expected  : API integration exists and is of type EXTERNAL_API
-- ------------------------------------------------------------
SHOW API INTEGRATIONS LIKE 'MEDICORE_GITHUB_INTEGRATION';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_003
-- Phase     : 00 - GitHub Integration
-- Category  : EXISTENCE
-- Description: Verify MEDICORE_PLATFORM_REPO Git repository exists
-- Expected  : Git repository exists in GOVERNANCE_DB.SECURITY schema
-- ------------------------------------------------------------
SHOW GIT REPOSITORIES LIKE 'MEDICORE_PLATFORM_REPO' IN SCHEMA GOVERNANCE_DB.SECURITY;
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
SELECT 
    name,
    secret_type,
    database_name,
    schema_name
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID(-3)))
WHERE name = 'GITHUB_TOKEN' AND secret_type = 'PASSWORD';
-- Re-run if needed:
-- SHOW SECRETS LIKE 'GITHUB_TOKEN' IN SCHEMA GOVERNANCE_DB.SECURITY;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_005
-- Phase     : 00 - GitHub Integration
-- Category  : CONFIGURATION
-- Description: Verify API integration is enabled
-- Expected  : enabled = true
-- ------------------------------------------------------------
SELECT 
    name,
    enabled,
    type,
    category
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID(-4)))
WHERE name = 'MEDICORE_GITHUB_INTEGRATION';
-- Re-run if needed:
-- SHOW API INTEGRATIONS LIKE 'MEDICORE_GITHUB_INTEGRATION';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_006
-- Phase     : 00 - GitHub Integration
-- Category  : CONFIGURATION
-- Description: Verify Git repository origin URL is correct
-- Expected  : origin = 'https://github.com/ShrinivasVK/medicore-snowflake-platform.git'
-- ------------------------------------------------------------
SELECT 
    name,
    origin,
    api_integration,
    git_credentials
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID(-5)))
WHERE name = 'MEDICORE_PLATFORM_REPO';
-- Re-run if needed:
-- SHOW GIT REPOSITORIES LIKE 'MEDICORE_PLATFORM_REPO' IN SCHEMA GOVERNANCE_DB.SECURITY;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_007
-- Phase     : 00 - GitHub Integration
-- Category  : CONFIGURATION
-- Description: Verify Git repository uses correct API integration
-- Expected  : api_integration = 'MEDICORE_GITHUB_INTEGRATION'
-- ------------------------------------------------------------
SHOW GIT REPOSITORIES LIKE 'MEDICORE_PLATFORM_REPO' IN SCHEMA GOVERNANCE_DB.SECURITY;
SELECT 
    name,
    api_integration
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE api_integration = 'MEDICORE_GITHUB_INTEGRATION';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_008
-- Phase     : 00 - GitHub Integration
-- Category  : CONFIGURATION
-- Description: Verify Git repository uses correct credentials secret
-- Expected  : git_credentials = 'GOVERNANCE_DB.SECURITY.GITHUB_TOKEN'
-- ------------------------------------------------------------
SHOW GIT REPOSITORIES LIKE 'MEDICORE_PLATFORM_REPO' IN SCHEMA GOVERNANCE_DB.SECURITY;
SELECT 
    name,
    git_credentials
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE git_credentials = 'GOVERNANCE_DB.SECURITY.GITHUB_TOKEN';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ============================================================
-- TEST CATEGORY: SECURITY - Verify schema location
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID   : TC_00_009
-- Phase     : 00 - GitHub Integration
-- Category  : SECURITY
-- Description: Verify secret is in correct schema (GOVERNANCE_DB.SECURITY)
-- Expected  : database_name = 'GOVERNANCE_DB', schema_name = 'SECURITY'
-- ------------------------------------------------------------
SHOW SECRETS LIKE 'GITHUB_TOKEN' IN SCHEMA GOVERNANCE_DB.SECURITY;
SELECT 
    name,
    database_name,
    schema_name
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE database_name = 'GOVERNANCE_DB' AND schema_name = 'SECURITY';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_010
-- Phase     : 00 - GitHub Integration
-- Category  : SECURITY
-- Description: Verify Git repository is in correct schema (GOVERNANCE_DB.SECURITY)
-- Expected  : database_name = 'GOVERNANCE_DB', schema_name = 'SECURITY'
-- ------------------------------------------------------------
SHOW GIT REPOSITORIES LIKE 'MEDICORE_PLATFORM_REPO' IN SCHEMA GOVERNANCE_DB.SECURITY;
SELECT 
    name,
    database_name,
    schema_name
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE database_name = 'GOVERNANCE_DB' AND schema_name = 'SECURITY';
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
-- ------------------------------------------------------------
ALTER GIT REPOSITORY GOVERNANCE_DB.SECURITY.MEDICORE_PLATFORM_REPO FETCH;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_012
-- Phase     : 00 - GitHub Integration
-- Category  : FUNCTIONALITY
-- Description: Verify repository branches are visible
-- Expected  : At least 'main' branch is listed
-- ------------------------------------------------------------
SHOW GIT BRANCHES IN GOVERNANCE_DB.SECURITY.MEDICORE_PLATFORM_REPO;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_013
-- Phase     : 00 - GitHub Integration
-- Category  : FUNCTIONALITY
-- Description: Verify files are accessible in repository
-- Expected  : Files listed from infrastructure folder
-- ------------------------------------------------------------
LIST @GOVERNANCE_DB.SECURITY.MEDICORE_PLATFORM_REPO/branches/main/infrastructure/;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_014
-- Phase     : 00 - GitHub Integration
-- Category  : FUNCTIONALITY
-- Description: Verify Phase 00 implementation file exists in repo
-- Expected  : 00_github_integration.sql file is listed
-- ------------------------------------------------------------
LIST @GOVERNANCE_DB.SECURITY.MEDICORE_PLATFORM_REPO/branches/main/infrastructure/00_git-setup/;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID   : TC_00_015
-- Phase     : 00 - GitHub Integration
-- Category  : FUNCTIONALITY
-- Description: Verify Phase 01 implementation file exists in repo
-- Expected  : 01_account_administration.sql file is listed
-- ------------------------------------------------------------
LIST @GOVERNANCE_DB.SECURITY.MEDICORE_PLATFORM_REPO/branches/main/infrastructure/01_account-admin/;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ============================================================
-- PHASE 00 TEST SUMMARY
-- ============================================================
-- Total Test Cases: 15
--
-- Test Checklist:
-- [ ] TC_00_001 - Secret GITHUB_TOKEN exists
-- [ ] TC_00_002 - API integration exists
-- [ ] TC_00_003 - Git repository exists
-- [ ] TC_00_004 - Secret type is PASSWORD
-- [ ] TC_00_005 - API integration is enabled
-- [ ] TC_00_006 - Repository origin URL correct
-- [ ] TC_00_007 - Repository uses correct API integration
-- [ ] TC_00_008 - Repository uses correct credentials
-- [ ] TC_00_009 - Secret in correct schema
-- [ ] TC_00_010 - Repository in correct schema
-- [ ] TC_00_011 - Repository fetch works
-- [ ] TC_00_012 - Branches are visible
-- [ ] TC_00_013 - Files are accessible
-- [ ] TC_00_014 - Phase 00 file exists in repo
-- [ ] TC_00_015 - Phase 01 file exists in repo
--
-- OVERALL PHASE 00 RESULT: [ ] PASS  [ ] FAIL
-- Tested By:
-- Test Date:
-- ============================================================
