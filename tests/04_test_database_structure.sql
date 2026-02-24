-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 04: Database Structure - Test Cases
-- Script: 04_test_database_structure.sql
--
-- Description: Validation queries for all database and schema
--              objects created in 04_database_structure.sql
-- How to Run:  Execute as ACCOUNTADMIN sequentially
-- Results:     Record outcomes in 04_test_database_results.md
--
-- Author: [YOUR_NAME]
-- Date: [YYYY-MM-DD]
-- ============================================================

USE ROLE ACCOUNTADMIN;


-- ============================================================
-- CATEGORY 1: EXISTENCE TESTS
-- Verify all databases and schemas were created
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_04_001
-- Category   : EXISTENCE
-- Description: Verify RAW_DB database exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT DATABASE_NAME, RETENTION_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE DATABASE_NAME = 'RAW_DB'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_002
-- Category   : EXISTENCE
-- Description: Verify TRANSFORM_DB database exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT DATABASE_NAME, RETENTION_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE DATABASE_NAME = 'TRANSFORM_DB'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_003
-- Category   : EXISTENCE
-- Description: Verify ANALYTICS_DB database exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT DATABASE_NAME, RETENTION_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE DATABASE_NAME = 'ANALYTICS_DB'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_004
-- Category   : EXISTENCE
-- Description: Verify AI_READY_DB database exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT DATABASE_NAME, RETENTION_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE DATABASE_NAME = 'AI_READY_DB'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_005
-- Category   : EXISTENCE
-- Description: Verify RAW_DB.CLINICAL schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'RAW_DB'
AND SCHEMA_NAME = 'CLINICAL'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_006
-- Category   : EXISTENCE
-- Description: Verify RAW_DB.BILLING schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'RAW_DB'
AND SCHEMA_NAME = 'BILLING'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_007
-- Category   : EXISTENCE
-- Description: Verify RAW_DB.REFERENCE schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'RAW_DB'
AND SCHEMA_NAME = 'REFERENCE'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_008
-- Category   : EXISTENCE
-- Description: Verify RAW_DB.AUDIT schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'RAW_DB'
AND SCHEMA_NAME = 'AUDIT'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_009
-- Category   : EXISTENCE
-- Description: Verify TRANSFORM_DB.CLINICAL schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'TRANSFORM_DB'
AND SCHEMA_NAME = 'CLINICAL'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_010
-- Category   : EXISTENCE
-- Description: Verify TRANSFORM_DB.BILLING schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'TRANSFORM_DB'
AND SCHEMA_NAME = 'BILLING'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_011
-- Category   : EXISTENCE
-- Description: Verify TRANSFORM_DB.REFERENCE schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'TRANSFORM_DB'
AND SCHEMA_NAME = 'REFERENCE'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_012
-- Category   : EXISTENCE
-- Description: Verify TRANSFORM_DB.COMMON schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'TRANSFORM_DB'
AND SCHEMA_NAME = 'COMMON'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_013
-- Category   : EXISTENCE
-- Description: Verify ANALYTICS_DB.CLINICAL schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'ANALYTICS_DB'
AND SCHEMA_NAME = 'CLINICAL'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_014
-- Category   : EXISTENCE
-- Description: Verify ANALYTICS_DB.BILLING schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'ANALYTICS_DB'
AND SCHEMA_NAME = 'BILLING'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_015
-- Category   : EXISTENCE
-- Description: Verify ANALYTICS_DB.REFERENCE schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'ANALYTICS_DB'
AND SCHEMA_NAME = 'REFERENCE'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_016
-- Category   : EXISTENCE
-- Description: Verify ANALYTICS_DB.EXECUTIVE schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'ANALYTICS_DB'
AND SCHEMA_NAME = 'EXECUTIVE'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_017
-- Category   : EXISTENCE
-- Description: Verify ANALYTICS_DB.DEIDENTIFIED schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'ANALYTICS_DB'
AND SCHEMA_NAME = 'DEIDENTIFIED'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_018
-- Category   : EXISTENCE
-- Description: Verify AI_READY_DB.FEATURES schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'AI_READY_DB'
AND SCHEMA_NAME = 'FEATURES'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_019
-- Category   : EXISTENCE
-- Description: Verify AI_READY_DB.TRAINING schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'AI_READY_DB'
AND SCHEMA_NAME = 'TRAINING'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_020
-- Category   : EXISTENCE
-- Description: Verify AI_READY_DB.SEMANTIC schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'AI_READY_DB'
AND SCHEMA_NAME = 'SEMANTIC'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_021
-- Category   : EXISTENCE
-- Description: Verify AI_READY_DB.EMBEDDINGS schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'AI_READY_DB'
AND SCHEMA_NAME = 'EMBEDDINGS'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_022
-- Category   : EXISTENCE
-- Description: Verify RAW_DB.AUDIT schema is TRANSIENT
-- Expected   : IS_TRANSIENT = 'YES'
-- ------------------------------------------------------------
SELECT IS_TRANSIENT
FROM RAW_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME = 'AUDIT';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------


-- ============================================================
-- CATEGORY 2: CONFIGURATION TESTS
-- Verify retention and schema counts match specification
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_04_023
-- Category   : CONFIGURATION
-- Description: Verify RAW_DB retention is 90 days
-- Expected   : RETENTION_TIME = 90
-- ------------------------------------------------------------
SELECT DATABASE_NAME, RETENTION_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE DATABASE_NAME = 'RAW_DB'
AND DELETED IS NULL
AND RETENTION_TIME = 90;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_024
-- Category   : CONFIGURATION
-- Description: Verify TRANSFORM_DB retention is 30 days
-- Expected   : RETENTION_TIME = 30
-- ------------------------------------------------------------
SELECT DATABASE_NAME, RETENTION_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE DATABASE_NAME = 'TRANSFORM_DB'
AND DELETED IS NULL
AND RETENTION_TIME = 30;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_025
-- Category   : CONFIGURATION
-- Description: Verify ANALYTICS_DB retention is 30 days
-- Expected   : RETENTION_TIME = 30
-- ------------------------------------------------------------
SELECT DATABASE_NAME, RETENTION_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE DATABASE_NAME = 'ANALYTICS_DB'
AND DELETED IS NULL
AND RETENTION_TIME = 30;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_026
-- Category   : CONFIGURATION
-- Description: Verify AI_READY_DB retention is 14 days
-- Expected   : RETENTION_TIME = 14
-- ------------------------------------------------------------
SELECT DATABASE_NAME, RETENTION_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE DATABASE_NAME = 'AI_READY_DB'
AND DELETED IS NULL
AND RETENTION_TIME = 14;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_027
-- Category   : CONFIGURATION
-- Description: Verify RAW_DB has exactly 4 schemas
-- Expected   : schema_count = 4
-- ------------------------------------------------------------
SELECT COUNT(*) AS schema_count
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'RAW_DB'
AND SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_028
-- Category   : CONFIGURATION
-- Description: Verify TRANSFORM_DB has exactly 4 schemas
-- Expected   : schema_count = 4
-- ------------------------------------------------------------
SELECT COUNT(*) AS schema_count
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'TRANSFORM_DB'
AND SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_029
-- Category   : CONFIGURATION
-- Description: Verify ANALYTICS_DB has exactly 5 schemas
-- Expected   : schema_count = 5
-- ------------------------------------------------------------
SELECT COUNT(*) AS schema_count
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'ANALYTICS_DB'
AND SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_030
-- Category   : CONFIGURATION
-- Description: Verify AI_READY_DB has exactly 4 schemas
-- Expected   : schema_count = 4
-- ------------------------------------------------------------
SELECT COUNT(*) AS schema_count
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'AI_READY_DB'
AND SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------


-- ============================================================
-- CATEGORY 3: GRANTS TESTS
-- Verify database and schema grants
-- ============================================================

-- ------------------------------------------------------------
-- RAW_DB DATABASE GRANTS
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_031
-- Category   : GRANTS
-- Description: Verify USAGE on RAW_DB granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'RAW_DB'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_032
-- Category   : GRANTS
-- Description: Verify USAGE on RAW_DB granted to MEDICORE_SVC_ETL_LOADER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'RAW_DB'
AND GRANTEE_NAME = 'MEDICORE_SVC_ETL_LOADER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_033
-- Category   : GRANTS
-- Description: Verify USAGE on RAW_DB granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'RAW_DB'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_034
-- Category   : GRANTS
-- Description: Verify USAGE on RAW_DB granted to MEDICORE_COMPLIANCE_OFFICER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'RAW_DB'
AND GRANTEE_NAME = 'MEDICORE_COMPLIANCE_OFFICER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- RAW_DB SCHEMA OWNERSHIP GRANTS
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_035
-- Category   : GRANTS
-- Description: Verify OWNERSHIP on RAW_DB.CLINICAL granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'RAW_DB.CLINICAL'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'OWNERSHIP'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_036
-- Category   : GRANTS
-- Description: Verify OWNERSHIP on RAW_DB.BILLING granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'RAW_DB.BILLING'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'OWNERSHIP'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_037
-- Category   : GRANTS
-- Description: Verify OWNERSHIP on RAW_DB.REFERENCE granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'RAW_DB.REFERENCE'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'OWNERSHIP'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_038
-- Category   : GRANTS
-- Description: Verify OWNERSHIP on RAW_DB.AUDIT granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'RAW_DB.AUDIT'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'OWNERSHIP'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- RAW_DB SCHEMA USAGE GRANTS
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_039
-- Category   : GRANTS
-- Description: Verify USAGE on RAW_DB.CLINICAL granted to MEDICORE_SVC_ETL_LOADER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'RAW_DB.CLINICAL'
AND GRANTEE_NAME = 'MEDICORE_SVC_ETL_LOADER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_040
-- Category   : GRANTS
-- Description: Verify USAGE on RAW_DB.BILLING granted to MEDICORE_SVC_ETL_LOADER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'RAW_DB.BILLING'
AND GRANTEE_NAME = 'MEDICORE_SVC_ETL_LOADER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_041
-- Category   : GRANTS
-- Description: Verify USAGE on RAW_DB.CLINICAL granted to MEDICORE_COMPLIANCE_OFFICER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'RAW_DB.CLINICAL'
AND GRANTEE_NAME = 'MEDICORE_COMPLIANCE_OFFICER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TRANSFORM_DB DATABASE GRANTS
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_042
-- Category   : GRANTS
-- Description: Verify USAGE on TRANSFORM_DB granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'TRANSFORM_DB'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_043
-- Category   : GRANTS
-- Description: Verify USAGE on TRANSFORM_DB granted to MEDICORE_DATA_SCIENTIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'TRANSFORM_DB'
AND GRANTEE_NAME = 'MEDICORE_DATA_SCIENTIST'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_044
-- Category   : GRANTS
-- Description: Verify USAGE on TRANSFORM_DB granted to MEDICORE_COMPLIANCE_OFFICER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'TRANSFORM_DB'
AND GRANTEE_NAME = 'MEDICORE_COMPLIANCE_OFFICER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_045
-- Category   : GRANTS
-- Description: Verify USAGE on TRANSFORM_DB granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'TRANSFORM_DB'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TRANSFORM_DB SCHEMA OWNERSHIP GRANTS
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_046
-- Category   : GRANTS
-- Description: Verify OWNERSHIP on TRANSFORM_DB.CLINICAL granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'TRANSFORM_DB.CLINICAL'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'OWNERSHIP'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_047
-- Category   : GRANTS
-- Description: Verify OWNERSHIP on TRANSFORM_DB.BILLING granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'TRANSFORM_DB.BILLING'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'OWNERSHIP'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_048
-- Category   : GRANTS
-- Description: Verify OWNERSHIP on TRANSFORM_DB.COMMON granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'TRANSFORM_DB.COMMON'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'OWNERSHIP'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TRANSFORM_DB SCHEMA USAGE GRANTS
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_049
-- Category   : GRANTS
-- Description: Verify USAGE on TRANSFORM_DB.CLINICAL granted to MEDICORE_DATA_SCIENTIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'TRANSFORM_DB.CLINICAL'
AND GRANTEE_NAME = 'MEDICORE_DATA_SCIENTIST'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- ANALYTICS_DB DATABASE GRANTS
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_050
-- Category   : GRANTS
-- Description: Verify USAGE on ANALYTICS_DB granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_051
-- Category   : GRANTS
-- Description: Verify USAGE on ANALYTICS_DB granted to MEDICORE_CLINICAL_PHYSICIAN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_CLINICAL_PHYSICIAN'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_052
-- Category   : GRANTS
-- Description: Verify USAGE on ANALYTICS_DB granted to MEDICORE_CLINICAL_NURSE
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_CLINICAL_NURSE'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_053
-- Category   : GRANTS
-- Description: Verify USAGE on ANALYTICS_DB granted to MEDICORE_BILLING_SPECIALIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_BILLING_SPECIALIST'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_054
-- Category   : GRANTS
-- Description: Verify USAGE on ANALYTICS_DB granted to MEDICORE_ANALYST_PHI
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_ANALYST_PHI'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_055
-- Category   : GRANTS
-- Description: Verify USAGE on ANALYTICS_DB granted to MEDICORE_ANALYST_RESTRICTED
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_ANALYST_RESTRICTED'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_056
-- Category   : GRANTS
-- Description: Verify USAGE on ANALYTICS_DB granted to MEDICORE_EXECUTIVE
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_EXECUTIVE'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_057
-- Category   : GRANTS
-- Description: Verify USAGE on ANALYTICS_DB granted to MEDICORE_EXT_AUDITOR
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_EXT_AUDITOR'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- ANALYTICS_DB SCHEMA USAGE GRANTS
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_058
-- Category   : GRANTS
-- Description: Verify USAGE on ANALYTICS_DB.CLINICAL granted to MEDICORE_CLINICAL_PHYSICIAN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'ANALYTICS_DB.CLINICAL'
AND GRANTEE_NAME = 'MEDICORE_CLINICAL_PHYSICIAN'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_059
-- Category   : GRANTS
-- Description: Verify USAGE on ANALYTICS_DB.BILLING granted to MEDICORE_BILLING_SPECIALIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'ANALYTICS_DB.BILLING'
AND GRANTEE_NAME = 'MEDICORE_BILLING_SPECIALIST'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_060
-- Category   : GRANTS
-- Description: Verify USAGE on ANALYTICS_DB.EXECUTIVE granted to MEDICORE_EXECUTIVE
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'ANALYTICS_DB.EXECUTIVE'
AND GRANTEE_NAME = 'MEDICORE_EXECUTIVE'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_061
-- Category   : GRANTS
-- Description: Verify USAGE on ANALYTICS_DB.DEIDENTIFIED granted to MEDICORE_EXT_AUDITOR
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'ANALYTICS_DB.DEIDENTIFIED'
AND GRANTEE_NAME = 'MEDICORE_EXT_AUDITOR'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_062
-- Category   : GRANTS
-- Description: Verify USAGE on ANALYTICS_DB.REFERENCE granted to MEDICORE_REFERENCE_READER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'ANALYTICS_DB.REFERENCE'
AND GRANTEE_NAME = 'MEDICORE_REFERENCE_READER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- AI_READY_DB DATABASE GRANTS
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_063
-- Category   : GRANTS
-- Description: Verify USAGE on AI_READY_DB granted to MEDICORE_DATA_SCIENTIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'AI_READY_DB'
AND GRANTEE_NAME = 'MEDICORE_DATA_SCIENTIST'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_064
-- Category   : GRANTS
-- Description: Verify USAGE on AI_READY_DB granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'AI_READY_DB'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_065
-- Category   : GRANTS
-- Description: Verify USAGE on AI_READY_DB granted to MEDICORE_ANALYST_PHI
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'AI_READY_DB'
AND GRANTEE_NAME = 'MEDICORE_ANALYST_PHI'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_066
-- Category   : GRANTS
-- Description: Verify USAGE on AI_READY_DB granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'AI_READY_DB'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- AI_READY_DB SCHEMA OWNERSHIP GRANTS
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_067
-- Category   : GRANTS
-- Description: Verify OWNERSHIP on AI_READY_DB.FEATURES granted to MEDICORE_DATA_SCIENTIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'AI_READY_DB.FEATURES'
AND GRANTEE_NAME = 'MEDICORE_DATA_SCIENTIST'
AND PRIVILEGE = 'OWNERSHIP'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_068
-- Category   : GRANTS
-- Description: Verify OWNERSHIP on AI_READY_DB.TRAINING granted to MEDICORE_DATA_SCIENTIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'AI_READY_DB.TRAINING'
AND GRANTEE_NAME = 'MEDICORE_DATA_SCIENTIST'
AND PRIVILEGE = 'OWNERSHIP'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_069
-- Category   : GRANTS
-- Description: Verify OWNERSHIP on AI_READY_DB.SEMANTIC granted to MEDICORE_DATA_SCIENTIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'AI_READY_DB.SEMANTIC'
AND GRANTEE_NAME = 'MEDICORE_DATA_SCIENTIST'
AND PRIVILEGE = 'OWNERSHIP'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_070
-- Category   : GRANTS
-- Description: Verify OWNERSHIP on AI_READY_DB.EMBEDDINGS granted to MEDICORE_DATA_SCIENTIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'AI_READY_DB.EMBEDDINGS'
AND GRANTEE_NAME = 'MEDICORE_DATA_SCIENTIST'
AND PRIVILEGE = 'OWNERSHIP'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------


-- ============================================================
-- CATEGORY 4: FUTURE GRANTS TESTS
-- Verify future grants are configured correctly
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_04_071
-- Category   : FUTURE_GRANTS
-- Description: Verify SVC_ETL_LOADER has future INSERT on RAW_DB.CLINICAL tables
-- Expected   : 1 row returned showing INSERT privilege
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA RAW_DB.CLINICAL;
-- Look for: grant_to=ROLE, grantee_name=MEDICORE_SVC_ETL_LOADER, privilege=INSERT
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_072
-- Category   : FUTURE_GRANTS
-- Description: Verify SVC_ETL_LOADER has future INSERT on RAW_DB.BILLING tables
-- Expected   : 1 row returned showing INSERT privilege
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA RAW_DB.BILLING;
-- Look for: grant_to=ROLE, grantee_name=MEDICORE_SVC_ETL_LOADER, privilege=INSERT
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_073
-- Category   : FUTURE_GRANTS
-- Description: Verify COMPLIANCE_OFFICER has future SELECT on RAW_DB.CLINICAL tables
-- Expected   : 1 row returned showing SELECT privilege
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA RAW_DB.CLINICAL;
-- Look for: grant_to=ROLE, grantee_name=MEDICORE_COMPLIANCE_OFFICER, privilege=SELECT
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_074
-- Category   : FUTURE_GRANTS
-- Description: Verify DATA_SCIENTIST has future SELECT on TRANSFORM_DB.CLINICAL tables
-- Expected   : 1 row returned showing SELECT privilege
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA TRANSFORM_DB.CLINICAL;
-- Look for: grant_to=ROLE, grantee_name=MEDICORE_DATA_SCIENTIST, privilege=SELECT
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_075
-- Category   : FUTURE_GRANTS
-- Description: Verify CLINICAL_PHYSICIAN has future SELECT on ANALYTICS_DB.CLINICAL tables
-- Expected   : 1 row returned showing SELECT privilege
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA ANALYTICS_DB.CLINICAL;
-- Look for: grant_to=ROLE, grantee_name=MEDICORE_CLINICAL_PHYSICIAN, privilege=SELECT
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_076
-- Category   : FUTURE_GRANTS
-- Description: Verify CLINICAL_NURSE has future SELECT on ANALYTICS_DB.CLINICAL tables
-- Expected   : 1 row returned showing SELECT privilege
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA ANALYTICS_DB.CLINICAL;
-- Look for: grant_to=ROLE, grantee_name=MEDICORE_CLINICAL_NURSE, privilege=SELECT
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_077
-- Category   : FUTURE_GRANTS
-- Description: Verify BILLING_SPECIALIST has future SELECT on ANALYTICS_DB.BILLING tables
-- Expected   : 1 row returned showing SELECT privilege
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA ANALYTICS_DB.BILLING;
-- Look for: grant_to=ROLE, grantee_name=MEDICORE_BILLING_SPECIALIST, privilege=SELECT
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_078
-- Category   : FUTURE_GRANTS
-- Description: Verify ANALYST_RESTRICTED has future SELECT on ANALYTICS_DB.EXECUTIVE tables
-- Expected   : 1 row returned showing SELECT privilege
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA ANALYTICS_DB.EXECUTIVE;
-- Look for: grant_to=ROLE, grantee_name=MEDICORE_ANALYST_RESTRICTED, privilege=SELECT
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_079
-- Category   : FUTURE_GRANTS
-- Description: Verify ANALYST_RESTRICTED has future SELECT on ANALYTICS_DB.DEIDENTIFIED tables
-- Expected   : 1 row returned showing SELECT privilege
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA ANALYTICS_DB.DEIDENTIFIED;
-- Look for: grant_to=ROLE, grantee_name=MEDICORE_ANALYST_RESTRICTED, privilege=SELECT
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_080
-- Category   : FUTURE_GRANTS
-- Description: Verify EXT_AUDITOR has future SELECT on ANALYTICS_DB.DEIDENTIFIED tables
-- Expected   : 1 row returned showing SELECT privilege
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA ANALYTICS_DB.DEIDENTIFIED;
-- Look for: grant_to=ROLE, grantee_name=MEDICORE_EXT_AUDITOR, privilege=SELECT
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_081
-- Category   : FUTURE_GRANTS
-- Description: Verify EXECUTIVE has future SELECT on ANALYTICS_DB.EXECUTIVE tables
-- Expected   : 1 row returned showing SELECT privilege
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA ANALYTICS_DB.EXECUTIVE;
-- Look for: grant_to=ROLE, grantee_name=MEDICORE_EXECUTIVE, privilege=SELECT
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_082
-- Category   : FUTURE_GRANTS
-- Description: Verify ANALYST_PHI has future SELECT on AI_READY_DB.FEATURES tables
-- Expected   : 1 row returned showing SELECT privilege
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA AI_READY_DB.FEATURES;
-- Look for: grant_to=ROLE, grantee_name=MEDICORE_ANALYST_PHI, privilege=SELECT
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_083
-- Category   : FUTURE_GRANTS
-- Description: Verify ANALYST_PHI has future SELECT on AI_READY_DB.TRAINING tables
-- Expected   : 1 row returned showing SELECT privilege
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA AI_READY_DB.TRAINING;
-- Look for: grant_to=ROLE, grantee_name=MEDICORE_ANALYST_PHI, privilege=SELECT
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :
-- ------------------------------------------------------------


-- ============================================================
-- CATEGORY 5: BOUNDARY TESTS
-- Verify access boundaries are correctly enforced
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_04_084
-- Category   : BOUNDARY
-- Description: Verify restricted roles have NO access to RAW_DB
-- Expected   : COUNT = 0
-- ------------------------------------------------------------
SELECT COUNT(*) AS unexpected_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'RAW_DB'
AND GRANTEE_NAME IN (
    'MEDICORE_CLINICAL_PHYSICIAN',
    'MEDICORE_CLINICAL_NURSE',
    'MEDICORE_BILLING_SPECIALIST',
    'MEDICORE_EXECUTIVE',
    'MEDICORE_ANALYST_RESTRICTED',
    'MEDICORE_EXT_AUDITOR'
)
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Should return COUNT = 0
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_085
-- Category   : BOUNDARY
-- Description: Verify restricted roles have NO access to TRANSFORM_DB
-- Expected   : COUNT = 0
-- ------------------------------------------------------------
SELECT COUNT(*) AS unexpected_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'TRANSFORM_DB'
AND GRANTEE_NAME IN (
    'MEDICORE_CLINICAL_PHYSICIAN',
    'MEDICORE_CLINICAL_NURSE',
    'MEDICORE_BILLING_SPECIALIST',
    'MEDICORE_EXECUTIVE',
    'MEDICORE_ANALYST_RESTRICTED',
    'MEDICORE_EXT_AUDITOR',
    'MEDICORE_APP_STREAMLIT'
)
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Should return COUNT = 0
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_086
-- Category   : BOUNDARY
-- Description: Verify restricted roles have NO access to AI_READY_DB
-- Expected   : COUNT = 0
-- ------------------------------------------------------------
SELECT COUNT(*) AS unexpected_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'AI_READY_DB'
AND GRANTEE_NAME IN (
    'MEDICORE_CLINICAL_PHYSICIAN',
    'MEDICORE_CLINICAL_NURSE',
    'MEDICORE_BILLING_SPECIALIST',
    'MEDICORE_EXECUTIVE',
    'MEDICORE_ANALYST_RESTRICTED',
    'MEDICORE_EXT_AUDITOR',
    'MEDICORE_APP_STREAMLIT',
    'MEDICORE_COMPLIANCE_OFFICER'
)
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Should return COUNT = 0
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_087
-- Category   : BOUNDARY
-- Description: Verify ANALYST_RESTRICTED cannot access PHI schemas in ANALYTICS_DB
-- Expected   : COUNT = 0
-- ------------------------------------------------------------
SELECT COUNT(*) AS unexpected_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME IN (
    'ANALYTICS_DB.CLINICAL',
    'ANALYTICS_DB.BILLING'
)
AND GRANTEE_NAME = 'MEDICORE_ANALYST_RESTRICTED'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Should return COUNT = 0
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_088
-- Category   : BOUNDARY
-- Description: Verify EXT_AUDITOR restricted to DEIDENTIFIED schema only
-- Expected   : COUNT = 0 (no access to CLINICAL, BILLING, REFERENCE, EXECUTIVE)
-- ------------------------------------------------------------
SELECT COUNT(*) AS unexpected_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME IN (
    'ANALYTICS_DB.CLINICAL',
    'ANALYTICS_DB.BILLING',
    'ANALYTICS_DB.REFERENCE',
    'ANALYTICS_DB.EXECUTIVE'
)
AND GRANTEE_NAME = 'MEDICORE_EXT_AUDITOR'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Should return COUNT = 0
-- ------------------------------------------------------------


-- ============================================================
-- TEST SUMMARY
-- Total Test Cases  : 88
--
-- EXISTENCE      Tests : 22 (TC_04_001 to TC_04_022)
-- CONFIGURATION  Tests :  8 (TC_04_023 to TC_04_030)
-- GRANTS         Tests : 40 (TC_04_031 to TC_04_070)
-- FUTURE_GRANTS  Tests : 13 (TC_04_071 to TC_04_083)
-- BOUNDARY       Tests :  5 (TC_04_084 to TC_04_088)
--
-- Run all tests and record results in
-- 04_test_database_results.md
-- ============================================================
