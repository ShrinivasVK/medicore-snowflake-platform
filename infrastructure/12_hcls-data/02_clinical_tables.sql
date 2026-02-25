-- ============================================================
-- Phase 12 - HCLS Data Model
-- File: 02_clinical_tables.sql
-- Purpose: Create DEV Clinical Tables
-- ============================================================

USE DATABASE MEDICORE_RAW_DB;
USE SCHEMA DEV_CLINICAL;

-- MEDICORE_RAW_DB.DEV_CLINICAL.

-- ============================================================
-- PATIENTS (No Dependencies)
-- ============================================================

CREATE OR REPLACE TABLE MEDICORE_RAW_DB.DEV_CLINICAL.PATIENTS (
    PATIENT_ID     NUMBER              COMMENT 'Unique patient surrogate ID',
    MRN            VARCHAR(50)         COMMENT 'Medical Record Number',
    FIRST_NAME     VARCHAR(100)        COMMENT 'Patient first name',
    LAST_NAME      VARCHAR(100)        COMMENT 'Patient last name',
    DATE_OF_BIRTH  DATE                COMMENT 'Date of birth',
    GENDER         VARCHAR(10)         COMMENT 'Gender value',
    PHONE_NUMBER   VARCHAR(20)         COMMENT 'Contact phone number',
    ZIP_CODE       VARCHAR(10)         COMMENT 'Postal code',
    CREATED_AT     TIMESTAMP_NTZ       COMMENT 'Record creation timestamp'
)
COMMENT = 'Raw patient demographic table - DEV synthetic data';

-- ============================================================
-- PROVIDERS (Depends on DIM_DEPARTMENTS logically)
-- ============================================================

CREATE OR REPLACE TABLE MEDICORE_RAW_DB.DEV_CLINICAL.PROVIDERS (
    PROVIDER_ID    NUMBER              COMMENT 'Unique provider ID',
    PROVIDER_NAME  VARCHAR(150)        COMMENT 'Provider full name',
    SPECIALTY      VARCHAR(100)        COMMENT 'Clinical specialty',
    DEPARTMENT_ID  NUMBER              COMMENT 'Department reference (logical FK)',
    CREATED_AT     TIMESTAMP_NTZ       COMMENT 'Record creation timestamp'
)
COMMENT = 'Raw provider master table - DEV synthetic data';

-- ============================================================
-- ENCOUNTERS (Depends on PATIENTS, PROVIDERS, DIM tables)
-- ============================================================

CREATE OR REPLACE TABLE MEDICORE_RAW_DB.DEV_CLINICAL.ENCOUNTERS (
    ENCOUNTER_ID       NUMBER          COMMENT 'Unique encounter ID',
    PATIENT_ID         NUMBER          COMMENT 'Patient reference (logical FK)',
    PROVIDER_ID        NUMBER          COMMENT 'Provider reference (logical FK)',
    DEPARTMENT_ID      NUMBER          COMMENT 'Department reference (logical FK)',
    ADMISSION_DATE     DATE            COMMENT 'Admission date',
    DISCHARGE_DATE     DATE            COMMENT 'Discharge date',
    ENCOUNTER_TYPE     VARCHAR(50)     COMMENT 'Encounter classification',
    PRIMARY_ICD10_CODE VARCHAR(10)     COMMENT 'Primary diagnosis code (logical FK)',
    CREATED_AT         TIMESTAMP_NTZ   COMMENT 'Record creation timestamp'
)
COMMENT = 'Raw encounter events table - DEV synthetic data';

-- ============================================================
-- LAB_RESULTS (Depends on ENCOUNTERS)
-- ============================================================

CREATE OR REPLACE TABLE MEDICORE_RAW_DB.DEV_CLINICAL.LAB_RESULTS (
    LAB_RESULT_ID   NUMBER             COMMENT 'Unique lab result ID',
    ENCOUNTER_ID    NUMBER             COMMENT 'Encounter reference (logical FK)',
    TEST_NAME       VARCHAR(100)       COMMENT 'Lab test name',
    RESULT_VALUE    VARCHAR(100)       COMMENT 'Measured value (raw format)',
    RESULT_UNIT     VARCHAR(20)        COMMENT 'Measurement unit',
    RESULT_DATE     DATE               COMMENT 'Test result date',
    IS_ABNORMAL     BOOLEAN            COMMENT 'Abnormal result flag',
    CREATED_AT      TIMESTAMP_NTZ      COMMENT 'Record creation timestamp'
)
COMMENT = 'Raw laboratory results table - DEV synthetic data';