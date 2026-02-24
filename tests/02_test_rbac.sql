-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 02: RBAC Setup - Test Cases
-- Script: 02_test_rbac.sql
-- 
-- Description: Validation queries for all RBAC objects created
--              in 02_rbac_setup.sql
-- How to Run:  Execute as ACCOUNTADMIN sequentially
-- Results:     Record outcomes in 02_test_rbac_results.md
--
-- Author: [YOUR_NAME]
-- Date: [YYYY-MM-DD]
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================
-- CATEGORY 1: EXISTENCE TESTS
-- Verify all 17 roles and service account user exist
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_02_001
-- Category   : EXISTENCE
-- Description: Verify total MEDICORE role count is exactly 17
-- Expected   : COUNT = 17
-- ------------------------------------------------------------
SELECT COUNT(*) AS role_count
FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME LIKE 'MEDICORE%'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_002
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_PLATFORM_ADMIN role exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT NAME, COMMENT FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME = 'MEDICORE_PLATFORM_ADMIN' AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_003
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_SECURITY_ADMIN role exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT NAME, COMMENT FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME = 'MEDICORE_SECURITY_ADMIN' AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_004
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_DATA_ENGINEER role exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT NAME, COMMENT FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME = 'MEDICORE_DATA_ENGINEER' AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_005
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_SVC_ETL_LOADER role exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT NAME, COMMENT FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME = 'MEDICORE_SVC_ETL_LOADER' AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_006
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_CLINICAL_PHYSICIAN role exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT NAME, COMMENT FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME = 'MEDICORE_CLINICAL_PHYSICIAN' AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_007
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_CLINICAL_NURSE role exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT NAME, COMMENT FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME = 'MEDICORE_CLINICAL_NURSE' AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_008
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_CLINICAL_READER role exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT NAME, COMMENT FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME = 'MEDICORE_CLINICAL_READER' AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_009
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_BILLING_SPECIALIST role exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT NAME, COMMENT FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME = 'MEDICORE_BILLING_SPECIALIST' AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_010
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_BILLING_READER role exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT NAME, COMMENT FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME = 'MEDICORE_BILLING_READER' AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_011
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_ANALYST_PHI role exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT NAME, COMMENT FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME = 'MEDICORE_ANALYST_PHI' AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_012
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_ANALYST_RESTRICTED role exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT NAME, COMMENT FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME = 'MEDICORE_ANALYST_RESTRICTED' AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_013
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_DATA_SCIENTIST role exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT NAME, COMMENT FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME = 'MEDICORE_DATA_SCIENTIST' AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_014
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_COMPLIANCE_OFFICER role exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT NAME, COMMENT FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME = 'MEDICORE_COMPLIANCE_OFFICER' AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_015
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_EXT_AUDITOR role exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT NAME, COMMENT FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME = 'MEDICORE_EXT_AUDITOR' AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_016
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_EXECUTIVE role exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT NAME, COMMENT FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME = 'MEDICORE_EXECUTIVE' AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_017
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_REFERENCE_READER role exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT NAME, COMMENT FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME = 'MEDICORE_REFERENCE_READER' AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_018
-- Category   : EXISTENCE
-- Description: Verify MEDICORE_APP_STREAMLIT role exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT NAME, COMMENT FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME = 'MEDICORE_APP_STREAMLIT' AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_019
-- Category   : EXISTENCE
-- Description: Verify SVC_ETL_MEDICORE service account user exists
-- Expected   : 1 row returned with user details
-- ------------------------------------------------------------
SELECT NAME, DISABLED, DEFAULT_ROLE, COMMENT 
FROM SNOWFLAKE.ACCOUNT_USAGE.USERS
WHERE NAME = 'SVC_ETL_MEDICORE' AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_020
-- Category   : EXISTENCE
-- Description: Verify SVC_ETL_MEDICORE is in DISABLED state
-- Expected   : DISABLED = TRUE
-- ------------------------------------------------------------
SELECT NAME, DISABLED
FROM SNOWFLAKE.ACCOUNT_USAGE.USERS
WHERE NAME = 'SVC_ETL_MEDICORE' 
AND DELETED_ON IS NULL 
AND DISABLED = 'true';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------


-- ============================================================
-- CATEGORY 2: HIERARCHY TESTS
-- Verify all 11 role inheritance grants exist
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_02_021
-- Category   : HIERARCHY
-- Description: Verify REFERENCE_READER granted to ANALYST_RESTRICTED
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT NAME, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_REFERENCE_READER'
AND GRANTEE_NAME = 'MEDICORE_ANALYST_RESTRICTED'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_022
-- Category   : HIERARCHY
-- Description: Verify REFERENCE_READER granted to CLINICAL_READER
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT NAME, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_REFERENCE_READER'
AND GRANTEE_NAME = 'MEDICORE_CLINICAL_READER'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_023
-- Category   : HIERARCHY
-- Description: Verify REFERENCE_READER granted to BILLING_READER
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT NAME, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_REFERENCE_READER'
AND GRANTEE_NAME = 'MEDICORE_BILLING_READER'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_024
-- Category   : HIERARCHY
-- Description: Verify CLINICAL_READER granted to CLINICAL_NURSE
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_CLINICAL_READER'
AND GRANTEE_NAME = 'MEDICORE_CLINICAL_NURSE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_025
-- Category   : HIERARCHY
-- Description: Verify CLINICAL_NURSE granted to CLINICAL_PHYSICIAN
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_CLINICAL_NURSE'
AND GRANTEE_NAME = 'MEDICORE_CLINICAL_PHYSICIAN'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_026
-- Category   : HIERARCHY
-- Description: Verify BILLING_READER granted to BILLING_SPECIALIST
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_BILLING_READER'
AND GRANTEE_NAME = 'MEDICORE_BILLING_SPECIALIST'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_027
-- Category   : HIERARCHY
-- Description: Verify ANALYST_RESTRICTED granted to ANALYST_PHI
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_ANALYST_RESTRICTED'
AND GRANTEE_NAME = 'MEDICORE_ANALYST_PHI'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_028
-- Category   : HIERARCHY
-- Description: Verify ANALYST_PHI granted to DATA_ENGINEER
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_ANALYST_PHI'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_029
-- Category   : HIERARCHY
-- Description: Verify ANALYST_PHI granted to DATA_SCIENTIST
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_ANALYST_PHI'
AND GRANTEE_NAME = 'MEDICORE_DATA_SCIENTIST'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_030
-- Category   : HIERARCHY
-- Description: Verify ANALYST_RESTRICTED granted to EXECUTIVE
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_ANALYST_RESTRICTED'
AND GRANTEE_NAME = 'MEDICORE_EXECUTIVE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_031
-- Category   : HIERARCHY
-- Description: Verify ANALYST_PHI granted to COMPLIANCE_OFFICER
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_ANALYST_PHI'
AND GRANTEE_NAME = 'MEDICORE_COMPLIANCE_OFFICER'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------


-- ============================================================
-- CATEGORY 3: SECURITY TESTS
-- Verify all system role connections (grants to SYSADMIN/SECURITYADMIN)
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_02_032
-- Category   : SECURITY
-- Description: Verify MEDICORE_PLATFORM_ADMIN granted to SYSADMIN
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_PLATFORM_ADMIN'
AND GRANTEE_NAME = 'SYSADMIN'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_033
-- Category   : SECURITY
-- Description: Verify MEDICORE_SECURITY_ADMIN granted to SECURITYADMIN
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_SECURITY_ADMIN'
AND GRANTEE_NAME = 'SECURITYADMIN'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_034
-- Category   : SECURITY
-- Description: Verify MEDICORE_DATA_ENGINEER granted to SYSADMIN
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_DATA_ENGINEER'
AND GRANTEE_NAME = 'SYSADMIN'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_035
-- Category   : SECURITY
-- Description: Verify MEDICORE_SVC_ETL_LOADER granted to SYSADMIN
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_SVC_ETL_LOADER'
AND GRANTEE_NAME = 'SYSADMIN'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_036
-- Category   : SECURITY
-- Description: Verify MEDICORE_CLINICAL_PHYSICIAN granted to SYSADMIN
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_CLINICAL_PHYSICIAN'
AND GRANTEE_NAME = 'SYSADMIN'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_037
-- Category   : SECURITY
-- Description: Verify MEDICORE_BILLING_SPECIALIST granted to SYSADMIN
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_BILLING_SPECIALIST'
AND GRANTEE_NAME = 'SYSADMIN'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_038
-- Category   : SECURITY
-- Description: Verify MEDICORE_DATA_SCIENTIST granted to SYSADMIN
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_DATA_SCIENTIST'
AND GRANTEE_NAME = 'SYSADMIN'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_039
-- Category   : SECURITY
-- Description: Verify MEDICORE_COMPLIANCE_OFFICER granted to SYSADMIN
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_COMPLIANCE_OFFICER'
AND GRANTEE_NAME = 'SYSADMIN'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_040
-- Category   : SECURITY
-- Description: Verify MEDICORE_EXECUTIVE granted to SYSADMIN
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_EXECUTIVE'
AND GRANTEE_NAME = 'SYSADMIN'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_041
-- Category   : SECURITY
-- Description: Verify MEDICORE_EXT_AUDITOR granted to SYSADMIN
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_EXT_AUDITOR'
AND GRANTEE_NAME = 'SYSADMIN'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_042
-- Category   : SECURITY
-- Description: Verify MEDICORE_APP_STREAMLIT granted to SYSADMIN
-- Expected   : 1 row showing grant exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME, GRANTED_BY
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE NAME = 'MEDICORE_APP_STREAMLIT'
AND GRANTEE_NAME = 'SYSADMIN'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------


-- ============================================================
-- CATEGORY 4: CONFIGURATION TESTS
-- Verify role and user configuration settings
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_02_043
-- Category   : CONFIGURATION
-- Description: Verify SVC_ETL_MEDICORE default role is MEDICORE_SVC_ETL_LOADER
-- Expected   : DEFAULT_ROLE = 'MEDICORE_SVC_ETL_LOADER'
-- ------------------------------------------------------------
SELECT NAME, DEFAULT_ROLE
FROM SNOWFLAKE.ACCOUNT_USAGE.USERS
WHERE NAME = 'SVC_ETL_MEDICORE'
AND DELETED_ON IS NULL
AND DEFAULT_ROLE = 'MEDICORE_SVC_ETL_LOADER';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_044
-- Category   : CONFIGURATION
-- Description: Verify SVC_ETL_MEDICORE has no password set (HAS_PASSWORD = false)
-- Expected   : HAS_PASSWORD = FALSE
-- ------------------------------------------------------------
SHOW USERS LIKE 'SVC_ETL_MEDICORE';
SELECT "name", "has_password"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "has_password" = false;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_045
-- Category   : CONFIGURATION
-- Description: Verify SVC_ETL_MEDICORE has MEDICORE_SVC_ETL_LOADER role assigned
-- Expected   : Grant from role to user exists
-- ------------------------------------------------------------
SELECT ROLE, GRANTED_TO, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE GRANTEE_NAME = 'SVC_ETL_MEDICORE'
AND ROLE = 'MEDICORE_SVC_ETL_LOADER'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_046
-- Category   : CONFIGURATION
-- Description: Verify SVC_ETL_LOADER is standalone (no role hierarchy grants TO it)
-- Expected   : 0 rows - no MEDICORE roles granted to SVC_ETL_LOADER
-- ------------------------------------------------------------
SELECT NAME, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTEE_NAME = 'MEDICORE_SVC_ETL_LOADER'
AND NAME LIKE 'MEDICORE%'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Should return 0 rows (standalone role)
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_047
-- Category   : CONFIGURATION
-- Description: Verify EXT_AUDITOR is standalone (no role hierarchy grants TO it)
-- Expected   : 0 rows - no MEDICORE roles granted to EXT_AUDITOR
-- ------------------------------------------------------------
SELECT NAME, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTEE_NAME = 'MEDICORE_EXT_AUDITOR'
AND NAME LIKE 'MEDICORE%'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Should return 0 rows (standalone role)
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_048
-- Category   : CONFIGURATION
-- Description: Verify APP_STREAMLIT is standalone (no role hierarchy grants TO it)
-- Expected   : 0 rows - no MEDICORE roles granted to APP_STREAMLIT
-- ------------------------------------------------------------
SELECT NAME, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTEE_NAME = 'MEDICORE_APP_STREAMLIT'
AND NAME LIKE 'MEDICORE%'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Should return 0 rows (standalone role)
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_049
-- Category   : CONFIGURATION
-- Description: Verify PLATFORM_ADMIN is standalone (no MEDICORE role hierarchy grants TO it)
-- Expected   : 0 rows - PLATFORM_ADMIN does not inherit from other MEDICORE roles
-- ------------------------------------------------------------
SELECT NAME, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND NAME LIKE 'MEDICORE%'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Should return 0 rows (admin role, no data inheritance)
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_02_050
-- Category   : CONFIGURATION
-- Description: Verify SECURITY_ADMIN is standalone (no MEDICORE role hierarchy grants TO it)
-- Expected   : 0 rows - SECURITY_ADMIN does not inherit from other MEDICORE roles
-- ------------------------------------------------------------
SELECT NAME, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTEE_NAME = 'MEDICORE_SECURITY_ADMIN'
AND NAME LIKE 'MEDICORE%'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Should return 0 rows (admin role, no data inheritance)
-- ------------------------------------------------------------


-- ============================================================
-- TEST SUMMARY
-- Total Test Cases : 50
-- 
-- EXISTENCE     Tests : 20 (TC_02_001 to TC_02_020)
-- HIERARCHY     Tests : 11 (TC_02_021 to TC_02_031)
-- SECURITY      Tests : 11 (TC_02_032 to TC_02_042)
-- CONFIGURATION Tests :  8 (TC_02_043 to TC_02_050)
--
-- Run all tests and record results in 02_test_rbac_results.md
-- ============================================================
