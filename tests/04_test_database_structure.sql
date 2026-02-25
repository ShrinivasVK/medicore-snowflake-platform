-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 04: Database Structure - Test Cases
-- Script: 04_test_database_structure.sql
-- Version: 2.0.0
--
-- Change Reason: Complete rewrite to match 04_database_structure.sql
--               v2.0.0. Key changes:
--               - All database names updated to MEDICORE_ prefix
--               - Flat schema existence tests replaced with full
--                 59-schema coverage (PROD/QA/DEV × domains)
--               - GOVERNANCE_DB schema tests added (5 schemas)
--               - OWNERSHIP grant tests removed entirely —
--                 ACCOUNTADMIN owns all schemas in v2.0.0
--               - MEDICORE_SVC_GITHUB_ACTIONS grant tests added
--               - CREATE privilege grant tests added
--               - Transient schema tests expanded from 1 to 6
--               - Schema counts updated (4/4/5/4 → 12/15/15/12)
--               - Boundary tests updated with MEDICORE_ names,
--                 PROD_ schema names, and new QA/DEV isolation
--                 boundary checks
--               - GOVERNANCE_DB future grant tests added
--
-- Description: Validation queries for all database and schema
--              objects created in 04_database_structure.sql v2.0.0.
--
-- How to Run:  Execute as ACCOUNTADMIN sequentially.
--              Record outcomes in 04_test_database_results.md.
--
-- Author: [YOUR_NAME]
-- Date: [YYYY-MM-DD]
-- ============================================================

USE ROLE ACCOUNTADMIN;


-- ============================================================
-- CATEGORY 1: EXISTENCE TESTS
-- Verify all databases and schemas were created
-- Subcategories:
--   1A — Database existence (5 databases)
--   1B — GOVERNANCE_DB schemas (5 schemas)
--   1C — MEDICORE_RAW_DB schemas (12 schemas)
--   1D — MEDICORE_TRANSFORM_DB schemas (15 schemas)
--   1E — MEDICORE_ANALYTICS_DB schemas (15 schemas)
--   1F — MEDICORE_AI_READY_DB schemas (12 schemas)
--   1G — Transient schema verification (6 transient schemas)
-- ============================================================


-- ------------------------------------------------------------
-- SUBCATEGORY 1A: DATABASE EXISTENCE
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_001
-- Category   : EXISTENCE / 1A
-- Description: Verify MEDICORE_GOVERNANCE_DB database exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT DATABASE_NAME, RETENTION_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE DATABASE_NAME = 'MEDICORE_GOVERNANCE_DB'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_002
-- Category   : EXISTENCE / 1A
-- Description: Verify MEDICORE_RAW_DB database exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT DATABASE_NAME, RETENTION_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE DATABASE_NAME = 'MEDICORE_RAW_DB'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_003
-- Category   : EXISTENCE / 1A
-- Description: Verify MEDICORE_TRANSFORM_DB database exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT DATABASE_NAME, RETENTION_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE DATABASE_NAME = 'MEDICORE_TRANSFORM_DB'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_004
-- Category   : EXISTENCE / 1A
-- Description: Verify MEDICORE_ANALYTICS_DB database exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT DATABASE_NAME, RETENTION_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE DATABASE_NAME = 'MEDICORE_ANALYTICS_DB'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_005
-- Category   : EXISTENCE / 1A
-- Description: Verify MEDICORE_AI_READY_DB database exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT DATABASE_NAME, RETENTION_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE DATABASE_NAME = 'MEDICORE_AI_READY_DB'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :


-- ------------------------------------------------------------
-- SUBCATEGORY 1B: MEDICORE_GOVERNANCE_DB SCHEMAS (5 schemas)
-- Phase 01 created SECURITY. Phase 04 adds POLICIES, TAGS,
-- DATA_QUALITY, AUDIT. All 5 are verified here.
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_006
-- Category   : EXISTENCE / 1B
-- Description: Verify MEDICORE_GOVERNANCE_DB.SECURITY schema exists
--              (created in Phase 01, verified here for completeness)
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_GOVERNANCE_DB'
AND SCHEMA_NAME = 'SECURITY'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_007
-- Category   : EXISTENCE / 1B
-- Description: Verify MEDICORE_GOVERNANCE_DB.POLICIES schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_GOVERNANCE_DB'
AND SCHEMA_NAME = 'POLICIES'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_008
-- Category   : EXISTENCE / 1B
-- Description: Verify MEDICORE_GOVERNANCE_DB.TAGS schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_GOVERNANCE_DB'
AND SCHEMA_NAME = 'TAGS'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_009
-- Category   : EXISTENCE / 1B
-- Description: Verify MEDICORE_GOVERNANCE_DB.DATA_QUALITY schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_GOVERNANCE_DB'
AND SCHEMA_NAME = 'DATA_QUALITY'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_010
-- Category   : EXISTENCE / 1B
-- Description: Verify MEDICORE_GOVERNANCE_DB.AUDIT schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_GOVERNANCE_DB'
AND SCHEMA_NAME = 'AUDIT'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :


-- ------------------------------------------------------------
-- SUBCATEGORY 1C: MEDICORE_RAW_DB SCHEMAS (12 schemas)
-- PROD/QA/DEV × CLINICAL, BILLING, REFERENCE, AUDIT
-- ------------------------------------------------------------

-- PROD schemas
-- ------------------------------------------------------------
-- TEST ID    : TC_04_011
-- Category   : EXISTENCE / 1C
-- Description: Verify MEDICORE_RAW_DB.PROD_CLINICAL schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_RAW_DB'
AND SCHEMA_NAME = 'PROD_CLINICAL'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_012
-- Category   : EXISTENCE / 1C
-- Description: Verify MEDICORE_RAW_DB.PROD_BILLING schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_RAW_DB'
AND SCHEMA_NAME = 'PROD_BILLING'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_013
-- Category   : EXISTENCE / 1C
-- Description: Verify MEDICORE_RAW_DB.PROD_REFERENCE schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_RAW_DB'
AND SCHEMA_NAME = 'PROD_REFERENCE'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_014
-- Category   : EXISTENCE / 1C
-- Description: Verify MEDICORE_RAW_DB.PROD_AUDIT schema exists (transient)
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_RAW_DB'
AND SCHEMA_NAME = 'PROD_AUDIT'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- QA schemas
-- ------------------------------------------------------------
-- TEST ID    : TC_04_015
-- Category   : EXISTENCE / 1C
-- Description: Verify MEDICORE_RAW_DB.QA_CLINICAL schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_RAW_DB'
AND SCHEMA_NAME = 'QA_CLINICAL'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_016
-- Category   : EXISTENCE / 1C
-- Description: Verify MEDICORE_RAW_DB.QA_BILLING schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_RAW_DB'
AND SCHEMA_NAME = 'QA_BILLING'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_017
-- Category   : EXISTENCE / 1C
-- Description: Verify MEDICORE_RAW_DB.QA_REFERENCE schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_RAW_DB'
AND SCHEMA_NAME = 'QA_REFERENCE'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_018
-- Category   : EXISTENCE / 1C
-- Description: Verify MEDICORE_RAW_DB.QA_AUDIT schema exists (transient)
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_RAW_DB'
AND SCHEMA_NAME = 'QA_AUDIT'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- DEV schemas
-- ------------------------------------------------------------
-- TEST ID    : TC_04_019
-- Category   : EXISTENCE / 1C
-- Description: Verify MEDICORE_RAW_DB.DEV_CLINICAL schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_RAW_DB'
AND SCHEMA_NAME = 'DEV_CLINICAL'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_020
-- Category   : EXISTENCE / 1C
-- Description: Verify MEDICORE_RAW_DB.DEV_BILLING schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_RAW_DB'
AND SCHEMA_NAME = 'DEV_BILLING'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_021
-- Category   : EXISTENCE / 1C
-- Description: Verify MEDICORE_RAW_DB.DEV_REFERENCE schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_RAW_DB'
AND SCHEMA_NAME = 'DEV_REFERENCE'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_022
-- Category   : EXISTENCE / 1C
-- Description: Verify MEDICORE_RAW_DB.DEV_AUDIT schema exists (transient)
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_RAW_DB'
AND SCHEMA_NAME = 'DEV_AUDIT'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :


-- ------------------------------------------------------------
-- SUBCATEGORY 1D: MEDICORE_TRANSFORM_DB SCHEMAS (15 schemas)
-- PROD/QA/DEV × CLINICAL, BILLING, REFERENCE, AUDIT, COMMON
-- ------------------------------------------------------------

-- PROD schemas
-- ------------------------------------------------------------
-- TEST ID    : TC_04_023
-- Category   : EXISTENCE / 1D
-- Description: Verify MEDICORE_TRANSFORM_DB.PROD_CLINICAL schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_TRANSFORM_DB'
AND SCHEMA_NAME = 'PROD_CLINICAL'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_024
-- Category   : EXISTENCE / 1D
-- Description: Verify MEDICORE_TRANSFORM_DB.PROD_BILLING schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_TRANSFORM_DB'
AND SCHEMA_NAME = 'PROD_BILLING'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_025
-- Category   : EXISTENCE / 1D
-- Description: Verify MEDICORE_TRANSFORM_DB.PROD_REFERENCE schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_TRANSFORM_DB'
AND SCHEMA_NAME = 'PROD_REFERENCE'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_026
-- Category   : EXISTENCE / 1D
-- Description: Verify MEDICORE_TRANSFORM_DB.PROD_AUDIT schema exists (transient)
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_TRANSFORM_DB'
AND SCHEMA_NAME = 'PROD_AUDIT'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_027
-- Category   : EXISTENCE / 1D
-- Description: Verify MEDICORE_TRANSFORM_DB.PROD_COMMON schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_TRANSFORM_DB'
AND SCHEMA_NAME = 'PROD_COMMON'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- QA schemas
-- ------------------------------------------------------------
-- TEST ID    : TC_04_028
-- Category   : EXISTENCE / 1D
-- Description: Verify MEDICORE_TRANSFORM_DB.QA_CLINICAL schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_TRANSFORM_DB'
AND SCHEMA_NAME = 'QA_CLINICAL'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_029
-- Category   : EXISTENCE / 1D
-- Description: Verify MEDICORE_TRANSFORM_DB.QA_BILLING schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_TRANSFORM_DB'
AND SCHEMA_NAME = 'QA_BILLING'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_030
-- Category   : EXISTENCE / 1D
-- Description: Verify MEDICORE_TRANSFORM_DB.QA_REFERENCE schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_TRANSFORM_DB'
AND SCHEMA_NAME = 'QA_REFERENCE'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_031
-- Category   : EXISTENCE / 1D
-- Description: Verify MEDICORE_TRANSFORM_DB.QA_AUDIT schema exists (transient)
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_TRANSFORM_DB'
AND SCHEMA_NAME = 'QA_AUDIT'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_032
-- Category   : EXISTENCE / 1D
-- Description: Verify MEDICORE_TRANSFORM_DB.QA_COMMON schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_TRANSFORM_DB'
AND SCHEMA_NAME = 'QA_COMMON'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- DEV schemas
-- ------------------------------------------------------------
-- TEST ID    : TC_04_033
-- Category   : EXISTENCE / 1D
-- Description: Verify MEDICORE_TRANSFORM_DB.DEV_CLINICAL schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_TRANSFORM_DB'
AND SCHEMA_NAME = 'DEV_CLINICAL'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_034
-- Category   : EXISTENCE / 1D
-- Description: Verify MEDICORE_TRANSFORM_DB.DEV_BILLING schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_TRANSFORM_DB'
AND SCHEMA_NAME = 'DEV_BILLING'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_035
-- Category   : EXISTENCE / 1D
-- Description: Verify MEDICORE_TRANSFORM_DB.DEV_REFERENCE schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_TRANSFORM_DB'
AND SCHEMA_NAME = 'DEV_REFERENCE'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_036
-- Category   : EXISTENCE / 1D
-- Description: Verify MEDICORE_TRANSFORM_DB.DEV_AUDIT schema exists (transient)
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_TRANSFORM_DB'
AND SCHEMA_NAME = 'DEV_AUDIT'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_037
-- Category   : EXISTENCE / 1D
-- Description: Verify MEDICORE_TRANSFORM_DB.DEV_COMMON schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_TRANSFORM_DB'
AND SCHEMA_NAME = 'DEV_COMMON'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :


-- ------------------------------------------------------------
-- SUBCATEGORY 1E: MEDICORE_ANALYTICS_DB SCHEMAS (15 schemas)
-- PROD/QA/DEV × CLINICAL, BILLING, REFERENCE, EXECUTIVE, DEIDENTIFIED
-- ------------------------------------------------------------

-- PROD schemas
-- ------------------------------------------------------------
-- TEST ID    : TC_04_038
-- Category   : EXISTENCE / 1E
-- Description: Verify MEDICORE_ANALYTICS_DB.PROD_CLINICAL schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_ANALYTICS_DB'
AND SCHEMA_NAME = 'PROD_CLINICAL'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_039
-- Category   : EXISTENCE / 1E
-- Description: Verify MEDICORE_ANALYTICS_DB.PROD_BILLING schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_ANALYTICS_DB'
AND SCHEMA_NAME = 'PROD_BILLING'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_040
-- Category   : EXISTENCE / 1E
-- Description: Verify MEDICORE_ANALYTICS_DB.PROD_REFERENCE schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_ANALYTICS_DB'
AND SCHEMA_NAME = 'PROD_REFERENCE'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_041
-- Category   : EXISTENCE / 1E
-- Description: Verify MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_ANALYTICS_DB'
AND SCHEMA_NAME = 'PROD_EXECUTIVE'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_042
-- Category   : EXISTENCE / 1E
-- Description: Verify MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_ANALYTICS_DB'
AND SCHEMA_NAME = 'PROD_DEIDENTIFIED'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- QA schemas
-- ------------------------------------------------------------
-- TEST ID    : TC_04_043
-- Category   : EXISTENCE / 1E
-- Description: Verify MEDICORE_ANALYTICS_DB.QA_CLINICAL schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_ANALYTICS_DB'
AND SCHEMA_NAME = 'QA_CLINICAL'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_044
-- Category   : EXISTENCE / 1E
-- Description: Verify MEDICORE_ANALYTICS_DB.QA_BILLING schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_ANALYTICS_DB'
AND SCHEMA_NAME = 'QA_BILLING'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_045
-- Category   : EXISTENCE / 1E
-- Description: Verify MEDICORE_ANALYTICS_DB.QA_REFERENCE schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_ANALYTICS_DB'
AND SCHEMA_NAME = 'QA_REFERENCE'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_046
-- Category   : EXISTENCE / 1E
-- Description: Verify MEDICORE_ANALYTICS_DB.QA_EXECUTIVE schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_ANALYTICS_DB'
AND SCHEMA_NAME = 'QA_EXECUTIVE'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_047
-- Category   : EXISTENCE / 1E
-- Description: Verify MEDICORE_ANALYTICS_DB.QA_DEIDENTIFIED schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_ANALYTICS_DB'
AND SCHEMA_NAME = 'QA_DEIDENTIFIED'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- DEV schemas
-- ------------------------------------------------------------
-- TEST ID    : TC_04_048
-- Category   : EXISTENCE / 1E
-- Description: Verify MEDICORE_ANALYTICS_DB.DEV_CLINICAL schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_ANALYTICS_DB'
AND SCHEMA_NAME = 'DEV_CLINICAL'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_049
-- Category   : EXISTENCE / 1E
-- Description: Verify MEDICORE_ANALYTICS_DB.DEV_BILLING schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_ANALYTICS_DB'
AND SCHEMA_NAME = 'DEV_BILLING'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_050
-- Category   : EXISTENCE / 1E
-- Description: Verify MEDICORE_ANALYTICS_DB.DEV_REFERENCE schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_ANALYTICS_DB'
AND SCHEMA_NAME = 'DEV_REFERENCE'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_051
-- Category   : EXISTENCE / 1E
-- Description: Verify MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_ANALYTICS_DB'
AND SCHEMA_NAME = 'DEV_EXECUTIVE'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_052
-- Category   : EXISTENCE / 1E
-- Description: Verify MEDICORE_ANALYTICS_DB.DEV_DEIDENTIFIED schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_ANALYTICS_DB'
AND SCHEMA_NAME = 'DEV_DEIDENTIFIED'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :


-- ------------------------------------------------------------
-- SUBCATEGORY 1F: MEDICORE_AI_READY_DB SCHEMAS (12 schemas)
-- PROD/QA/DEV × FEATURES, TRAINING, SEMANTIC, EMBEDDINGS
-- ------------------------------------------------------------

-- PROD schemas
-- ------------------------------------------------------------
-- TEST ID    : TC_04_053
-- Category   : EXISTENCE / 1F
-- Description: Verify MEDICORE_AI_READY_DB.PROD_FEATURES schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_AI_READY_DB'
AND SCHEMA_NAME = 'PROD_FEATURES'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_054
-- Category   : EXISTENCE / 1F
-- Description: Verify MEDICORE_AI_READY_DB.PROD_TRAINING schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_AI_READY_DB'
AND SCHEMA_NAME = 'PROD_TRAINING'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_055
-- Category   : EXISTENCE / 1F
-- Description: Verify MEDICORE_AI_READY_DB.PROD_SEMANTIC schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_AI_READY_DB'
AND SCHEMA_NAME = 'PROD_SEMANTIC'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_056
-- Category   : EXISTENCE / 1F
-- Description: Verify MEDICORE_AI_READY_DB.PROD_EMBEDDINGS schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_AI_READY_DB'
AND SCHEMA_NAME = 'PROD_EMBEDDINGS'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- QA schemas
-- ------------------------------------------------------------
-- TEST ID    : TC_04_057
-- Category   : EXISTENCE / 1F
-- Description: Verify MEDICORE_AI_READY_DB.QA_FEATURES schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_AI_READY_DB'
AND SCHEMA_NAME = 'QA_FEATURES'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_058
-- Category   : EXISTENCE / 1F
-- Description: Verify MEDICORE_AI_READY_DB.QA_TRAINING schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_AI_READY_DB'
AND SCHEMA_NAME = 'QA_TRAINING'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_059
-- Category   : EXISTENCE / 1F
-- Description: Verify MEDICORE_AI_READY_DB.QA_SEMANTIC schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_AI_READY_DB'
AND SCHEMA_NAME = 'QA_SEMANTIC'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_060
-- Category   : EXISTENCE / 1F
-- Description: Verify MEDICORE_AI_READY_DB.QA_EMBEDDINGS schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_AI_READY_DB'
AND SCHEMA_NAME = 'QA_EMBEDDINGS'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- DEV schemas
-- ------------------------------------------------------------
-- TEST ID    : TC_04_061
-- Category   : EXISTENCE / 1F
-- Description: Verify MEDICORE_AI_READY_DB.DEV_FEATURES schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_AI_READY_DB'
AND SCHEMA_NAME = 'DEV_FEATURES'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_062
-- Category   : EXISTENCE / 1F
-- Description: Verify MEDICORE_AI_READY_DB.DEV_TRAINING schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_AI_READY_DB'
AND SCHEMA_NAME = 'DEV_TRAINING'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_063
-- Category   : EXISTENCE / 1F
-- Description: Verify MEDICORE_AI_READY_DB.DEV_SEMANTIC schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_AI_READY_DB'
AND SCHEMA_NAME = 'DEV_SEMANTIC'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_064
-- Category   : EXISTENCE / 1F
-- Description: Verify MEDICORE_AI_READY_DB.DEV_EMBEDDINGS schema exists
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, CATALOG_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_AI_READY_DB'
AND SCHEMA_NAME = 'DEV_EMBEDDINGS'
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :


-- ------------------------------------------------------------
-- SUBCATEGORY 1G: TRANSIENT SCHEMA VERIFICATION (6 schemas)
-- Transient schemas have no Time Travel or Fail-safe.
-- Expected transient schemas:
--   MEDICORE_RAW_DB:       PROD_AUDIT, QA_AUDIT, DEV_AUDIT
--   MEDICORE_TRANSFORM_DB: PROD_AUDIT, QA_AUDIT, DEV_AUDIT
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_065
-- Category   : EXISTENCE / 1G
-- Description: Verify MEDICORE_RAW_DB has exactly 3 transient schemas
--              (PROD_AUDIT, QA_AUDIT, DEV_AUDIT)
-- Expected   : transient_count = 3
-- ------------------------------------------------------------
SELECT COUNT(*) AS transient_count
FROM MEDICORE_RAW_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE IS_TRANSIENT = 'YES';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_066
-- Category   : EXISTENCE / 1G
-- Description: Verify MEDICORE_RAW_DB.PROD_AUDIT is transient
-- Expected   : IS_TRANSIENT = 'YES'
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, IS_TRANSIENT
FROM MEDICORE_RAW_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME = 'PROD_AUDIT'
AND IS_TRANSIENT = 'YES';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_067
-- Category   : EXISTENCE / 1G
-- Description: Verify MEDICORE_RAW_DB.QA_AUDIT is transient
-- Expected   : IS_TRANSIENT = 'YES'
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, IS_TRANSIENT
FROM MEDICORE_RAW_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME = 'QA_AUDIT'
AND IS_TRANSIENT = 'YES';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_068
-- Category   : EXISTENCE / 1G
-- Description: Verify MEDICORE_RAW_DB.DEV_AUDIT is transient
-- Expected   : IS_TRANSIENT = 'YES'
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, IS_TRANSIENT
FROM MEDICORE_RAW_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME = 'DEV_AUDIT'
AND IS_TRANSIENT = 'YES';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_069
-- Category   : EXISTENCE / 1G
-- Description: Verify MEDICORE_TRANSFORM_DB has exactly 3 transient schemas
--              (PROD_AUDIT, QA_AUDIT, DEV_AUDIT)
-- Expected   : transient_count = 3
-- ------------------------------------------------------------
SELECT COUNT(*) AS transient_count
FROM MEDICORE_TRANSFORM_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE IS_TRANSIENT = 'YES';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_070
-- Category   : EXISTENCE / 1G
-- Description: Verify MEDICORE_TRANSFORM_DB.PROD_AUDIT is transient
-- Expected   : IS_TRANSIENT = 'YES'
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, IS_TRANSIENT
FROM MEDICORE_TRANSFORM_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME = 'PROD_AUDIT'
AND IS_TRANSIENT = 'YES';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_071
-- Category   : EXISTENCE / 1G
-- Description: Verify MEDICORE_TRANSFORM_DB.QA_AUDIT is transient
-- Expected   : IS_TRANSIENT = 'YES'
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, IS_TRANSIENT
FROM MEDICORE_TRANSFORM_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME = 'QA_AUDIT'
AND IS_TRANSIENT = 'YES';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_072
-- Category   : EXISTENCE / 1G
-- Description: Verify MEDICORE_TRANSFORM_DB.DEV_AUDIT is transient
-- Expected   : IS_TRANSIENT = 'YES'
-- ------------------------------------------------------------
SELECT SCHEMA_NAME, IS_TRANSIENT
FROM MEDICORE_TRANSFORM_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME = 'DEV_AUDIT'
AND IS_TRANSIENT = 'YES';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_073
-- Category   : EXISTENCE / 1G
-- Description: Verify MEDICORE_ANALYTICS_DB has ZERO transient schemas
--              (no audit schema exists in ANALYTICS_DB)
-- Expected   : transient_count = 0
-- ------------------------------------------------------------
SELECT COUNT(*) AS transient_count
FROM MEDICORE_ANALYTICS_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE IS_TRANSIENT = 'YES';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_074
-- Category   : EXISTENCE / 1G
-- Description: Verify MEDICORE_AI_READY_DB has ZERO transient schemas
-- Expected   : transient_count = 0
-- ------------------------------------------------------------
SELECT COUNT(*) AS transient_count
FROM MEDICORE_AI_READY_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE IS_TRANSIENT = 'YES';
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :


-- ============================================================
-- CATEGORY 2: CONFIGURATION TESTS
-- Verify retention settings and schema counts per database
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_04_075
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_RAW_DB retention is 90 days
-- Expected   : RETENTION_TIME = 90
-- ------------------------------------------------------------
SELECT DATABASE_NAME, RETENTION_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE DATABASE_NAME = 'MEDICORE_RAW_DB'
AND DELETED IS NULL
AND RETENTION_TIME = 90;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_076
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_TRANSFORM_DB retention is 30 days
-- Expected   : RETENTION_TIME = 30
-- ------------------------------------------------------------
SELECT DATABASE_NAME, RETENTION_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE DATABASE_NAME = 'MEDICORE_TRANSFORM_DB'
AND DELETED IS NULL
AND RETENTION_TIME = 30;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_077
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ANALYTICS_DB retention is 30 days
-- Expected   : RETENTION_TIME = 30
-- ------------------------------------------------------------
SELECT DATABASE_NAME, RETENTION_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE DATABASE_NAME = 'MEDICORE_ANALYTICS_DB'
AND DELETED IS NULL
AND RETENTION_TIME = 30;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_078
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_AI_READY_DB retention is 14 days
-- Expected   : RETENTION_TIME = 14
-- ------------------------------------------------------------
SELECT DATABASE_NAME, RETENTION_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE DATABASE_NAME = 'MEDICORE_AI_READY_DB'
AND DELETED IS NULL
AND RETENTION_TIME = 14;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_079
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_GOVERNANCE_DB has exactly 5 schemas
-- Expected   : schema_count = 5
-- ------------------------------------------------------------
SELECT COUNT(*) AS schema_count
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_GOVERNANCE_DB'
AND SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Expected 5: SECURITY, POLICIES, TAGS, DATA_QUALITY, AUDIT

-- ------------------------------------------------------------
-- TEST ID    : TC_04_080
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_RAW_DB has exactly 12 schemas
-- Expected   : schema_count = 12
-- ------------------------------------------------------------
SELECT COUNT(*) AS schema_count
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_RAW_DB'
AND SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Expected 12: PROD/QA/DEV × CLINICAL/BILLING/REFERENCE/AUDIT

-- ------------------------------------------------------------
-- TEST ID    : TC_04_081
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_TRANSFORM_DB has exactly 15 schemas
-- Expected   : schema_count = 15
-- ------------------------------------------------------------
SELECT COUNT(*) AS schema_count
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_TRANSFORM_DB'
AND SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Expected 15: PROD/QA/DEV × CLINICAL/BILLING/REFERENCE/AUDIT/COMMON

-- ------------------------------------------------------------
-- TEST ID    : TC_04_082
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_ANALYTICS_DB has exactly 15 schemas
-- Expected   : schema_count = 15
-- ------------------------------------------------------------
SELECT COUNT(*) AS schema_count
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_ANALYTICS_DB'
AND SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Expected 15: PROD/QA/DEV × CLINICAL/BILLING/REFERENCE/EXECUTIVE/DEIDENTIFIED

-- ------------------------------------------------------------
-- TEST ID    : TC_04_083
-- Category   : CONFIGURATION
-- Description: Verify MEDICORE_AI_READY_DB has exactly 12 schemas
-- Expected   : schema_count = 12
-- ------------------------------------------------------------
SELECT COUNT(*) AS schema_count
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'MEDICORE_AI_READY_DB'
AND SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
AND DELETED IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Expected 12: PROD/QA/DEV × FEATURES/TRAINING/SEMANTIC/EMBEDDINGS

-- ------------------------------------------------------------
-- TEST ID    : TC_04_084
-- Category   : CONFIGURATION
-- Description: Verify total schema count across all 5 MEDICORE databases is 59
-- Expected   : total_schema_count = 59
-- ------------------------------------------------------------
SELECT SUM(schema_count) AS total_schema_count
FROM (
    SELECT COUNT(*) AS schema_count
    FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
    WHERE CATALOG_NAME IN (
        'MEDICORE_GOVERNANCE_DB',
        'MEDICORE_RAW_DB',
        'MEDICORE_TRANSFORM_DB',
        'MEDICORE_ANALYTICS_DB',
        'MEDICORE_AI_READY_DB'
    )
    AND SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
    AND DELETED IS NULL
);
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Expected 59 (5 + 12 + 15 + 15 + 12)


-- ============================================================
-- CATEGORY 3: DATABASE-LEVEL GRANTS TESTS
-- Verify USAGE grants on each database per role
-- Note: ACCOUNTADMIN retains schema OWNERSHIP — no OWNERSHIP
-- grants to any MEDICORE role should exist (tested in Cat 5)
-- ============================================================

-- ------------------------------------------------------------
-- MEDICORE_RAW_DB DATABASE USAGE GRANTS (5 roles)
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_085
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_RAW_DB granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_RAW_DB'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_086
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_RAW_DB granted to MEDICORE_SVC_ETL_LOADER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_RAW_DB'
AND GRANTEE_NAME = 'MEDICORE_SVC_ETL_LOADER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_087
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_RAW_DB granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_RAW_DB'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_088
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_RAW_DB granted to MEDICORE_COMPLIANCE_OFFICER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_RAW_DB'
AND GRANTEE_NAME = 'MEDICORE_COMPLIANCE_OFFICER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_089
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_RAW_DB granted to MEDICORE_SVC_GITHUB_ACTIONS
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_RAW_DB'
AND GRANTEE_NAME = 'MEDICORE_SVC_GITHUB_ACTIONS'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- MEDICORE_TRANSFORM_DB DATABASE USAGE GRANTS (5 roles)
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_090
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_TRANSFORM_DB granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_TRANSFORM_DB'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_091
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_TRANSFORM_DB granted to MEDICORE_DATA_SCIENTIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_TRANSFORM_DB'
AND GRANTEE_NAME = 'MEDICORE_DATA_SCIENTIST'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_092
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_TRANSFORM_DB granted to MEDICORE_COMPLIANCE_OFFICER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_TRANSFORM_DB'
AND GRANTEE_NAME = 'MEDICORE_COMPLIANCE_OFFICER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_093
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_TRANSFORM_DB granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_TRANSFORM_DB'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_094
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_TRANSFORM_DB granted to MEDICORE_SVC_GITHUB_ACTIONS
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_TRANSFORM_DB'
AND GRANTEE_NAME = 'MEDICORE_SVC_GITHUB_ACTIONS'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- MEDICORE_ANALYTICS_DB DATABASE USAGE GRANTS (16 roles)
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_095
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_096
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB granted to MEDICORE_CLINICAL_PHYSICIAN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_CLINICAL_PHYSICIAN'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_097
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB granted to MEDICORE_CLINICAL_NURSE
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_CLINICAL_NURSE'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_098
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB granted to MEDICORE_CLINICAL_READER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_CLINICAL_READER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_099
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB granted to MEDICORE_BILLING_SPECIALIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_BILLING_SPECIALIST'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_100
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB granted to MEDICORE_BILLING_READER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_BILLING_READER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_101
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB granted to MEDICORE_ANALYST_PHI
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_ANALYST_PHI'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_102
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB granted to MEDICORE_ANALYST_RESTRICTED
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_ANALYST_RESTRICTED'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_103
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB granted to MEDICORE_COMPLIANCE_OFFICER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_COMPLIANCE_OFFICER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_104
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB granted to MEDICORE_EXECUTIVE
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_EXECUTIVE'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_105
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB granted to MEDICORE_EXT_AUDITOR
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_EXT_AUDITOR'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_106
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB granted to MEDICORE_APP_STREAMLIT
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_APP_STREAMLIT'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_107
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB granted to MEDICORE_REFERENCE_READER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_REFERENCE_READER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_108
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB granted to MEDICORE_DATA_SCIENTIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_DATA_SCIENTIST'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_109
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_110
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB granted to MEDICORE_SVC_GITHUB_ACTIONS
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_ANALYTICS_DB'
AND GRANTEE_NAME = 'MEDICORE_SVC_GITHUB_ACTIONS'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- MEDICORE_AI_READY_DB DATABASE USAGE GRANTS (6 roles)
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_111
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_AI_READY_DB granted to MEDICORE_DATA_SCIENTIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_AI_READY_DB'
AND GRANTEE_NAME = 'MEDICORE_DATA_SCIENTIST'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_112
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_AI_READY_DB granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_AI_READY_DB'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_113
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_AI_READY_DB granted to MEDICORE_ANALYST_PHI
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_AI_READY_DB'
AND GRANTEE_NAME = 'MEDICORE_ANALYST_PHI'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_114
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_AI_READY_DB granted to MEDICORE_COMPLIANCE_OFFICER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_AI_READY_DB'
AND GRANTEE_NAME = 'MEDICORE_COMPLIANCE_OFFICER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_115
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_AI_READY_DB granted to MEDICORE_PLATFORM_ADMIN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_AI_READY_DB'
AND GRANTEE_NAME = 'MEDICORE_PLATFORM_ADMIN'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_116
-- Category   : GRANTS / DB
-- Description: Verify USAGE on MEDICORE_AI_READY_DB granted to MEDICORE_SVC_GITHUB_ACTIONS
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_AI_READY_DB'
AND GRANTEE_NAME = 'MEDICORE_SVC_GITHUB_ACTIONS'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :


-- ============================================================
-- CATEGORY 4: SCHEMA-LEVEL GRANTS TESTS
-- Spot-check representative USAGE and CREATE grants per schema.
-- Full grant matrix verified via SHOW FUTURE GRANTS and
-- SHOW GRANTS in the verification section of the main script.
-- ============================================================

-- ------------------------------------------------------------
-- RAW_DB PROD SCHEMA USAGE — representative spot checks
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_117
-- Category   : GRANTS / SCHEMA
-- Description: Verify USAGE on MEDICORE_RAW_DB.PROD_CLINICAL
--              granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_RAW_DB.PROD_CLINICAL'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_118
-- Category   : GRANTS / SCHEMA
-- Description: Verify USAGE on MEDICORE_RAW_DB.PROD_CLINICAL
--              granted to MEDICORE_SVC_ETL_LOADER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_RAW_DB.PROD_CLINICAL'
AND GRANTEE_NAME = 'MEDICORE_SVC_ETL_LOADER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_119
-- Category   : GRANTS / SCHEMA
-- Description: Verify USAGE on MEDICORE_RAW_DB.PROD_BILLING
--              granted to MEDICORE_COMPLIANCE_OFFICER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_RAW_DB.PROD_BILLING'
AND GRANTEE_NAME = 'MEDICORE_COMPLIANCE_OFFICER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_120
-- Category   : GRANTS / SCHEMA
-- Description: Verify CREATE TABLE on MEDICORE_RAW_DB.PROD_CLINICAL
--              granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_RAW_DB.PROD_CLINICAL'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'CREATE TABLE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_121
-- Category   : GRANTS / SCHEMA
-- Description: Verify CREATE TABLE on MEDICORE_RAW_DB.DEV_CLINICAL
--              granted to MEDICORE_SVC_GITHUB_ACTIONS
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_RAW_DB.DEV_CLINICAL'
AND GRANTEE_NAME = 'MEDICORE_SVC_GITHUB_ACTIONS'
AND PRIVILEGE = 'CREATE TABLE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_122
-- Category   : GRANTS / SCHEMA
-- Description: Verify USAGE on MEDICORE_RAW_DB.QA_REFERENCE
--              granted to MEDICORE_SVC_GITHUB_ACTIONS
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_RAW_DB.QA_REFERENCE'
AND GRANTEE_NAME = 'MEDICORE_SVC_GITHUB_ACTIONS'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TRANSFORM_DB SCHEMA GRANTS — representative spot checks
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_123
-- Category   : GRANTS / SCHEMA
-- Description: Verify USAGE on MEDICORE_TRANSFORM_DB.PROD_CLINICAL
--              granted to MEDICORE_DATA_SCIENTIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_TRANSFORM_DB.PROD_CLINICAL'
AND GRANTEE_NAME = 'MEDICORE_DATA_SCIENTIST'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_124
-- Category   : GRANTS / SCHEMA
-- Description: Verify CREATE DYNAMIC TABLE on MEDICORE_TRANSFORM_DB.PROD_CLINICAL
--              granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_TRANSFORM_DB.PROD_CLINICAL'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'CREATE DYNAMIC TABLE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_125
-- Category   : GRANTS / SCHEMA
-- Description: Verify CREATE DYNAMIC TABLE on MEDICORE_TRANSFORM_DB.QA_COMMON
--              granted to MEDICORE_SVC_GITHUB_ACTIONS
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_TRANSFORM_DB.QA_COMMON'
AND GRANTEE_NAME = 'MEDICORE_SVC_GITHUB_ACTIONS'
AND PRIVILEGE = 'CREATE DYNAMIC TABLE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- ANALYTICS_DB SCHEMA GRANTS — representative spot checks
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_126
-- Category   : GRANTS / SCHEMA
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB.PROD_CLINICAL
--              granted to MEDICORE_CLINICAL_PHYSICIAN
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_ANALYTICS_DB.PROD_CLINICAL'
AND GRANTEE_NAME = 'MEDICORE_CLINICAL_PHYSICIAN'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_127
-- Category   : GRANTS / SCHEMA
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB.PROD_BILLING
--              granted to MEDICORE_BILLING_SPECIALIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_ANALYTICS_DB.PROD_BILLING'
AND GRANTEE_NAME = 'MEDICORE_BILLING_SPECIALIST'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_128
-- Category   : GRANTS / SCHEMA
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE
--              granted to MEDICORE_EXECUTIVE
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE'
AND GRANTEE_NAME = 'MEDICORE_EXECUTIVE'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_129
-- Category   : GRANTS / SCHEMA
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED
--              granted to MEDICORE_EXT_AUDITOR
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED'
AND GRANTEE_NAME = 'MEDICORE_EXT_AUDITOR'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_130
-- Category   : GRANTS / SCHEMA
-- Description: Verify USAGE on MEDICORE_ANALYTICS_DB.PROD_REFERENCE
--              granted to MEDICORE_REFERENCE_READER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_ANALYTICS_DB.PROD_REFERENCE'
AND GRANTEE_NAME = 'MEDICORE_REFERENCE_READER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_131
-- Category   : GRANTS / SCHEMA
-- Description: Verify CREATE DYNAMIC TABLE on MEDICORE_ANALYTICS_DB.PROD_CLINICAL
--              granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_ANALYTICS_DB.PROD_CLINICAL'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'CREATE DYNAMIC TABLE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_132
-- Category   : GRANTS / SCHEMA
-- Description: Verify CREATE DYNAMIC TABLE on MEDICORE_ANALYTICS_DB.DEV_BILLING
--              granted to MEDICORE_SVC_GITHUB_ACTIONS
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_ANALYTICS_DB.DEV_BILLING'
AND GRANTEE_NAME = 'MEDICORE_SVC_GITHUB_ACTIONS'
AND PRIVILEGE = 'CREATE DYNAMIC TABLE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- AI_READY_DB SCHEMA GRANTS — representative spot checks
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_133
-- Category   : GRANTS / SCHEMA
-- Description: Verify USAGE on MEDICORE_AI_READY_DB.PROD_FEATURES
--              granted to MEDICORE_DATA_SCIENTIST
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_AI_READY_DB.PROD_FEATURES'
AND GRANTEE_NAME = 'MEDICORE_DATA_SCIENTIST'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_134
-- Category   : GRANTS / SCHEMA
-- Description: Verify USAGE on MEDICORE_AI_READY_DB.PROD_FEATURES
--              granted to MEDICORE_ANALYST_PHI
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_AI_READY_DB.PROD_FEATURES'
AND GRANTEE_NAME = 'MEDICORE_ANALYST_PHI'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_135
-- Category   : GRANTS / SCHEMA
-- Description: Verify USAGE on MEDICORE_AI_READY_DB.PROD_SEMANTIC
--              is NOT granted to MEDICORE_ANALYST_PHI
--              (ANALYST_PHI has no access to SEMANTIC schema)
-- Expected   : 0 rows returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_AI_READY_DB.PROD_SEMANTIC'
AND GRANTEE_NAME = 'MEDICORE_ANALYST_PHI'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Expected 0 rows — ANALYST_PHI has no access to SEMANTIC

-- ------------------------------------------------------------
-- TEST ID    : TC_04_136
-- Category   : GRANTS / SCHEMA
-- Description: Verify CREATE TABLE on MEDICORE_AI_READY_DB.PROD_EMBEDDINGS
--              granted to MEDICORE_DATA_ENGINEER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_AI_READY_DB.PROD_EMBEDDINGS'
AND GRANTEE_NAME = 'MEDICORE_DATA_ENGINEER'
AND PRIVILEGE = 'CREATE TABLE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_137
-- Category   : GRANTS / SCHEMA
-- Description: Verify CREATE TABLE on MEDICORE_AI_READY_DB.DEV_FEATURES
--              granted to MEDICORE_SVC_GITHUB_ACTIONS
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_AI_READY_DB.DEV_FEATURES'
AND GRANTEE_NAME = 'MEDICORE_SVC_GITHUB_ACTIONS'
AND PRIVILEGE = 'CREATE TABLE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- GOVERNANCE_DB SCHEMA GRANTS — spot checks
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- TEST ID    : TC_04_138
-- Category   : GRANTS / SCHEMA
-- Description: Verify USAGE on MEDICORE_GOVERNANCE_DB.POLICIES
--              granted to MEDICORE_COMPLIANCE_OFFICER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_GOVERNANCE_DB.POLICIES'
AND GRANTEE_NAME = 'MEDICORE_COMPLIANCE_OFFICER'
AND PRIVILEGE = 'USAGE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_139
-- Category   : GRANTS / SCHEMA
-- Description: Verify CREATE MASKING POLICY on MEDICORE_GOVERNANCE_DB.POLICIES
--              granted to MEDICORE_COMPLIANCE_OFFICER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_GOVERNANCE_DB.POLICIES'
AND GRANTEE_NAME = 'MEDICORE_COMPLIANCE_OFFICER'
AND PRIVILEGE = 'CREATE MASKING POLICY'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_140
-- Category   : GRANTS / SCHEMA
-- Description: Verify CREATE ROW ACCESS POLICY on MEDICORE_GOVERNANCE_DB.POLICIES
--              granted to MEDICORE_COMPLIANCE_OFFICER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_GOVERNANCE_DB.POLICIES'
AND GRANTEE_NAME = 'MEDICORE_COMPLIANCE_OFFICER'
AND PRIVILEGE = 'CREATE ROW ACCESS POLICY'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_141
-- Category   : GRANTS / SCHEMA
-- Description: Verify CREATE TAG on MEDICORE_GOVERNANCE_DB.TAGS
--              granted to MEDICORE_COMPLIANCE_OFFICER
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_GOVERNANCE_DB.TAGS'
AND GRANTEE_NAME = 'MEDICORE_COMPLIANCE_OFFICER'
AND PRIVILEGE = 'CREATE TAG'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_142
-- Category   : GRANTS / SCHEMA
-- Description: Verify CREATE TABLE on MEDICORE_GOVERNANCE_DB.DATA_QUALITY
--              granted to MEDICORE_SVC_GITHUB_ACTIONS
-- Expected   : 1 row returned
-- ------------------------------------------------------------
SELECT PRIVILEGE, GRANTEE_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_GOVERNANCE_DB.DATA_QUALITY'
AND GRANTEE_NAME = 'MEDICORE_SVC_GITHUB_ACTIONS'
AND PRIVILEGE = 'CREATE TABLE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :


-- ============================================================
-- CATEGORY 5: FUTURE GRANTS TESTS
-- Verify future grants are configured on PROD schemas.
-- Use SHOW FUTURE GRANTS IN SCHEMA and check output.
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_04_143
-- Category   : FUTURE_GRANTS
-- Description: Verify SVC_ETL_LOADER has future INSERT on
--              MEDICORE_RAW_DB.PROD_CLINICAL tables
-- Expected   : Row with privilege=INSERT, grantee=MEDICORE_SVC_ETL_LOADER
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_RAW_DB.PROD_CLINICAL;
-- Look for: PRIVILEGE=INSERT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_SVC_ETL_LOADER
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_144
-- Category   : FUTURE_GRANTS
-- Description: Verify SVC_ETL_LOADER has future INSERT on
--              MEDICORE_RAW_DB.PROD_BILLING tables
-- Expected   : Row with privilege=INSERT, grantee=MEDICORE_SVC_ETL_LOADER
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_RAW_DB.PROD_BILLING;
-- Look for: PRIVILEGE=INSERT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_SVC_ETL_LOADER
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_145
-- Category   : FUTURE_GRANTS
-- Description: Verify COMPLIANCE_OFFICER has future SELECT on
--              MEDICORE_RAW_DB.PROD_CLINICAL tables
-- Expected   : Row with privilege=SELECT, grantee=MEDICORE_COMPLIANCE_OFFICER
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_RAW_DB.PROD_CLINICAL;
-- Look for: PRIVILEGE=SELECT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_COMPLIANCE_OFFICER
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_146
-- Category   : FUTURE_GRANTS
-- Description: Verify COMPLIANCE_OFFICER has future SELECT on
--              MEDICORE_RAW_DB.PROD_AUDIT tables
-- Expected   : Row with privilege=SELECT, grantee=MEDICORE_COMPLIANCE_OFFICER
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_RAW_DB.PROD_AUDIT;
-- Look for: PRIVILEGE=SELECT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_COMPLIANCE_OFFICER
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_147
-- Category   : FUTURE_GRANTS
-- Description: Verify DATA_SCIENTIST has future SELECT on
--              MEDICORE_TRANSFORM_DB.PROD_CLINICAL tables
-- Expected   : Row with privilege=SELECT, grantee=MEDICORE_DATA_SCIENTIST
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_CLINICAL;
-- Look for: PRIVILEGE=SELECT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_DATA_SCIENTIST
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_148
-- Category   : FUTURE_GRANTS
-- Description: Verify DATA_SCIENTIST has future SELECT on
--              MEDICORE_TRANSFORM_DB.PROD_COMMON views
-- Expected   : Row with privilege=SELECT, grantee=MEDICORE_DATA_SCIENTIST
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_COMMON;
-- Look for: PRIVILEGE=SELECT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_DATA_SCIENTIST
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_149
-- Category   : FUTURE_GRANTS
-- Description: Verify COMPLIANCE_OFFICER has future SELECT on
--              MEDICORE_TRANSFORM_DB.PROD_AUDIT tables
-- Expected   : Row with privilege=SELECT, grantee=MEDICORE_COMPLIANCE_OFFICER
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_AUDIT;
-- Look for: PRIVILEGE=SELECT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_COMPLIANCE_OFFICER
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_150
-- Category   : FUTURE_GRANTS
-- Description: Verify CLINICAL_PHYSICIAN has future SELECT on
--              MEDICORE_ANALYTICS_DB.PROD_CLINICAL dynamic tables
-- Expected   : Row with privilege=SELECT, grantee=MEDICORE_CLINICAL_PHYSICIAN
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL;
-- Look for: PRIVILEGE=SELECT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_CLINICAL_PHYSICIAN
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_151
-- Category   : FUTURE_GRANTS
-- Description: Verify CLINICAL_NURSE has future SELECT on
--              MEDICORE_ANALYTICS_DB.PROD_CLINICAL tables
-- Expected   : Row with privilege=SELECT, grantee=MEDICORE_CLINICAL_NURSE
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL;
-- Look for: PRIVILEGE=SELECT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_CLINICAL_NURSE
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_152
-- Category   : FUTURE_GRANTS
-- Description: Verify BILLING_SPECIALIST has future SELECT on
--              MEDICORE_ANALYTICS_DB.PROD_BILLING tables
-- Expected   : Row with privilege=SELECT, grantee=MEDICORE_BILLING_SPECIALIST
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING;
-- Look for: PRIVILEGE=SELECT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_BILLING_SPECIALIST
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_153
-- Category   : FUTURE_GRANTS
-- Description: Verify REFERENCE_READER has future SELECT on
--              MEDICORE_ANALYTICS_DB.PROD_REFERENCE tables
-- Expected   : Row with privilege=SELECT, grantee=MEDICORE_REFERENCE_READER
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_REFERENCE;
-- Look for: PRIVILEGE=SELECT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_REFERENCE_READER
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_154
-- Category   : FUTURE_GRANTS
-- Description: Verify EXECUTIVE has future SELECT on
--              MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE tables
-- Expected   : Row with privilege=SELECT, grantee=MEDICORE_EXECUTIVE
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE;
-- Look for: PRIVILEGE=SELECT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_EXECUTIVE
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_155
-- Category   : FUTURE_GRANTS
-- Description: Verify ANALYST_RESTRICTED has future SELECT on
--              MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE tables
-- Expected   : Row with privilege=SELECT, grantee=MEDICORE_ANALYST_RESTRICTED
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE;
-- Look for: PRIVILEGE=SELECT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_ANALYST_RESTRICTED
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_156
-- Category   : FUTURE_GRANTS
-- Description: Verify EXT_AUDITOR has future SELECT on
--              MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED tables
-- Expected   : Row with privilege=SELECT, grantee=MEDICORE_EXT_AUDITOR
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED;
-- Look for: PRIVILEGE=SELECT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_EXT_AUDITOR
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_157
-- Category   : FUTURE_GRANTS
-- Description: Verify ANALYST_RESTRICTED has future SELECT on
--              MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED tables
-- Expected   : Row with privilege=SELECT, grantee=MEDICORE_ANALYST_RESTRICTED
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED;
-- Look for: PRIVILEGE=SELECT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_ANALYST_RESTRICTED
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_158
-- Category   : FUTURE_GRANTS
-- Description: Verify DATA_SCIENTIST has future SELECT on
--              MEDICORE_AI_READY_DB.PROD_FEATURES tables
-- Expected   : Row with privilege=SELECT, grantee=MEDICORE_DATA_SCIENTIST
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_AI_READY_DB.PROD_FEATURES;
-- Look for: PRIVILEGE=SELECT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_DATA_SCIENTIST
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_159
-- Category   : FUTURE_GRANTS
-- Description: Verify ANALYST_PHI has future SELECT on
--              MEDICORE_AI_READY_DB.PROD_FEATURES tables
-- Expected   : Row with privilege=SELECT, grantee=MEDICORE_ANALYST_PHI
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_AI_READY_DB.PROD_FEATURES;
-- Look for: PRIVILEGE=SELECT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_ANALYST_PHI
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_160
-- Category   : FUTURE_GRANTS
-- Description: Verify ANALYST_PHI has future SELECT on
--              MEDICORE_AI_READY_DB.PROD_TRAINING tables
-- Expected   : Row with privilege=SELECT, grantee=MEDICORE_ANALYST_PHI
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_AI_READY_DB.PROD_TRAINING;
-- Look for: PRIVILEGE=SELECT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_ANALYST_PHI
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :

-- ------------------------------------------------------------
-- TEST ID    : TC_04_161
-- Category   : FUTURE_GRANTS
-- Description: Verify DATA_SCIENTIST has future SELECT on
--              MEDICORE_AI_READY_DB.PROD_SEMANTIC views
-- Expected   : Row with privilege=SELECT, grantee=MEDICORE_DATA_SCIENTIST
-- ------------------------------------------------------------
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_AI_READY_DB.PROD_SEMANTIC;
-- Look for: PRIVILEGE=SELECT, GRANT_TO=ROLE, GRANTEE_NAME=MEDICORE_DATA_SCIENTIST
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES :


-- ============================================================
-- CATEGORY 6: BOUNDARY TESTS
-- Verify access restrictions and PHI isolation boundaries
-- ============================================================

-- ------------------------------------------------------------
-- TEST ID    : TC_04_162
-- Category   : BOUNDARY
-- Description: Verify clinical/billing consumer roles have NO
--              access to MEDICORE_RAW_DB (Bronze layer is
--              engineering-only)
-- Expected   : COUNT = 0
-- ------------------------------------------------------------
SELECT COUNT(*) AS unexpected_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_RAW_DB'
AND GRANTEE_NAME IN (
    'MEDICORE_CLINICAL_PHYSICIAN',
    'MEDICORE_CLINICAL_NURSE',
    'MEDICORE_CLINICAL_READER',
    'MEDICORE_BILLING_SPECIALIST',
    'MEDICORE_BILLING_READER',
    'MEDICORE_EXECUTIVE',
    'MEDICORE_ANALYST_RESTRICTED',
    'MEDICORE_EXT_AUDITOR',
    'MEDICORE_APP_STREAMLIT',
    'MEDICORE_REFERENCE_READER'
)
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Expected COUNT = 0

-- ------------------------------------------------------------
-- TEST ID    : TC_04_163
-- Category   : BOUNDARY
-- Description: Verify consumer/clinical roles have NO access
--              to MEDICORE_TRANSFORM_DB (Silver layer is
--              engineering and data science only)
-- Expected   : COUNT = 0
-- ------------------------------------------------------------
SELECT COUNT(*) AS unexpected_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_TRANSFORM_DB'
AND GRANTEE_NAME IN (
    'MEDICORE_CLINICAL_PHYSICIAN',
    'MEDICORE_CLINICAL_NURSE',
    'MEDICORE_CLINICAL_READER',
    'MEDICORE_BILLING_SPECIALIST',
    'MEDICORE_BILLING_READER',
    'MEDICORE_EXECUTIVE',
    'MEDICORE_ANALYST_RESTRICTED',
    'MEDICORE_EXT_AUDITOR',
    'MEDICORE_APP_STREAMLIT',
    'MEDICORE_REFERENCE_READER'
)
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Expected COUNT = 0

-- ------------------------------------------------------------
-- TEST ID    : TC_04_164
-- Category   : BOUNDARY
-- Description: Verify clinical and billing consumer roles have NO
--              access to MEDICORE_AI_READY_DB (ML layer is
--              restricted to data science and analytics roles)
-- Expected   : COUNT = 0
-- ------------------------------------------------------------
SELECT COUNT(*) AS unexpected_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'DATABASE'
AND NAME = 'MEDICORE_AI_READY_DB'
AND GRANTEE_NAME IN (
    'MEDICORE_CLINICAL_PHYSICIAN',
    'MEDICORE_CLINICAL_NURSE',
    'MEDICORE_CLINICAL_READER',
    'MEDICORE_BILLING_SPECIALIST',
    'MEDICORE_BILLING_READER',
    'MEDICORE_EXECUTIVE',
    'MEDICORE_ANALYST_RESTRICTED',
    'MEDICORE_EXT_AUDITOR',
    'MEDICORE_APP_STREAMLIT',
    'MEDICORE_REFERENCE_READER'
)
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Expected COUNT = 0

-- ------------------------------------------------------------
-- TEST ID    : TC_04_165
-- Category   : BOUNDARY
-- Description: Verify MEDICORE_ANALYST_RESTRICTED has NO access to
--              PHI schemas PROD_CLINICAL and PROD_BILLING in
--              MEDICORE_ANALYTICS_DB
-- Expected   : COUNT = 0
-- ------------------------------------------------------------
SELECT COUNT(*) AS unexpected_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME IN (
    'MEDICORE_ANALYTICS_DB.PROD_CLINICAL',
    'MEDICORE_ANALYTICS_DB.PROD_BILLING'
)
AND GRANTEE_NAME = 'MEDICORE_ANALYST_RESTRICTED'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Expected COUNT = 0

-- ------------------------------------------------------------
-- TEST ID    : TC_04_166
-- Category   : BOUNDARY
-- Description: Verify MEDICORE_EXT_AUDITOR is restricted to
--              PROD_DEIDENTIFIED only — no access to
--              PROD_CLINICAL, PROD_BILLING, PROD_REFERENCE,
--              or PROD_EXECUTIVE
-- Expected   : COUNT = 0
-- ------------------------------------------------------------
SELECT COUNT(*) AS unexpected_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME IN (
    'MEDICORE_ANALYTICS_DB.PROD_CLINICAL',
    'MEDICORE_ANALYTICS_DB.PROD_BILLING',
    'MEDICORE_ANALYTICS_DB.PROD_REFERENCE',
    'MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE'
)
AND GRANTEE_NAME = 'MEDICORE_EXT_AUDITOR'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Expected COUNT = 0

-- ------------------------------------------------------------
-- TEST ID    : TC_04_167
-- Category   : BOUNDARY
-- Description: Verify MEDICORE_EXECUTIVE has NO access to
--              PHI schemas (PROD_CLINICAL, PROD_BILLING,
--              PROD_DEIDENTIFIED)
-- Expected   : COUNT = 0
-- ------------------------------------------------------------
SELECT COUNT(*) AS unexpected_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME IN (
    'MEDICORE_ANALYTICS_DB.PROD_CLINICAL',
    'MEDICORE_ANALYTICS_DB.PROD_BILLING',
    'MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED'
)
AND GRANTEE_NAME = 'MEDICORE_EXECUTIVE'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Expected COUNT = 0

-- ------------------------------------------------------------
-- TEST ID    : TC_04_168
-- Category   : BOUNDARY
-- Description: Verify QA and DEV schemas in MEDICORE_ANALYTICS_DB
--              have NO direct USAGE grants for clinical/billing
--              consumer roles (those roles access PROD only)
-- Expected   : COUNT = 0
-- ------------------------------------------------------------
SELECT COUNT(*) AS unexpected_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME IN (
    'MEDICORE_ANALYTICS_DB.QA_CLINICAL',
    'MEDICORE_ANALYTICS_DB.QA_BILLING',
    'MEDICORE_ANALYTICS_DB.DEV_CLINICAL',
    'MEDICORE_ANALYTICS_DB.DEV_BILLING'
)
AND GRANTEE_NAME IN (
    'MEDICORE_CLINICAL_PHYSICIAN',
    'MEDICORE_CLINICAL_NURSE',
    'MEDICORE_CLINICAL_READER',
    'MEDICORE_BILLING_SPECIALIST',
    'MEDICORE_BILLING_READER',
    'MEDICORE_EXECUTIVE',
    'MEDICORE_EXT_AUDITOR'
)
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Expected COUNT = 0

-- ------------------------------------------------------------
-- TEST ID    : TC_04_169
-- Category   : BOUNDARY
-- Description: Verify no MEDICORE role holds OWNERSHIP on any
--              schema across all 5 databases — ACCOUNTADMIN
--              owns all schemas in v2.0.0
-- Expected   : COUNT = 0
-- ------------------------------------------------------------
SELECT COUNT(*) AS ownership_grants_to_medicore_roles
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE PRIVILEGE = 'OWNERSHIP'
AND GRANTED_ON = 'SCHEMA'
AND GRANTEE_NAME LIKE 'MEDICORE_%'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Expected COUNT = 0. If any rows returned, ownership
--         was incorrectly granted — ACCOUNTADMIN must retain
--         schema ownership for CI/CD compatibility.

-- ------------------------------------------------------------
-- TEST ID    : TC_04_170
-- Category   : BOUNDARY
-- Description: Verify MEDICORE_ANALYST_PHI has NO access to
--              MEDICORE_AI_READY_DB.PROD_SEMANTIC
--              (Semantic schema is for data scientists only)
-- Expected   : COUNT = 0
-- ------------------------------------------------------------
SELECT COUNT(*) AS unexpected_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'SCHEMA'
AND NAME = 'MEDICORE_AI_READY_DB.PROD_SEMANTIC'
AND GRANTEE_NAME = 'MEDICORE_ANALYST_PHI'
AND DELETED_ON IS NULL;
-- RESULT: [ ] PASS  [ ] FAIL
-- NOTES : Expected COUNT = 0


-- ============================================================
-- PHASE 04 TEST SUMMARY
-- ============================================================
-- Total Test Cases : 170
--
-- CATEGORY 1 — EXISTENCE         :  74 tests  (TC_04_001 to TC_04_074)
--   1A  Databases                 :   5 tests  (TC_04_001 to TC_04_005)
--   1B  GOVERNANCE_DB schemas     :   5 tests  (TC_04_006 to TC_04_010)
--   1C  RAW_DB schemas (12)       :  12 tests  (TC_04_011 to TC_04_022)
--   1D  TRANSFORM_DB schemas (15) :  15 tests  (TC_04_023 to TC_04_037)
--   1E  ANALYTICS_DB schemas (15) :  15 tests  (TC_04_038 to TC_04_052)
--   1F  AI_READY_DB schemas (12)  :  12 tests  (TC_04_053 to TC_04_064)
--   1G  Transient schemas         :  10 tests  (TC_04_065 to TC_04_074)
--
-- CATEGORY 2 — CONFIGURATION      :  10 tests  (TC_04_075 to TC_04_084)
--
-- CATEGORY 3 — DATABASE GRANTS    :  32 tests  (TC_04_085 to TC_04_116)
--
-- CATEGORY 4 — SCHEMA GRANTS      :  26 tests  (TC_04_117 to TC_04_142)
--
-- CATEGORY 5 — FUTURE GRANTS      :  19 tests  (TC_04_143 to TC_04_161)
--
-- CATEGORY 6 — BOUNDARY           :   9 tests  (TC_04_162 to TC_04_170)
--
-- Key changes vs v1.0.0:
--   - Database names: all updated to MEDICORE_ prefix
--   - Schema counts: 4/4/5/4 flat → 12/15/15/12 env-isolated
--   - GOVERNANCE_DB tests: added (5 schema tests, 5 grant tests)
--   - OWNERSHIP grant tests: REMOVED entirely (ACCOUNTADMIN owns all)
--   - TC_04_169: NEW boundary — confirms zero OWNERSHIP grants to
--                any MEDICORE role across all schemas
--   - SVC_GITHUB_ACTIONS tests: added throughout Cats 3, 4, 5
--   - CREATE DYNAMIC TABLE tests: added for TRANSFORM and ANALYTICS
--   - QA/DEV consumer isolation boundary: added TC_04_168
--   - Transient schema coverage: expanded from 1 to 10 tests
--
-- OVERALL PHASE 04 RESULT: [ ] PASS  [ ] FAIL
-- Tested By:
-- Test Date:
-- ============================================================
-- END OF PHASE 04 TEST CASES
-- ============================================================