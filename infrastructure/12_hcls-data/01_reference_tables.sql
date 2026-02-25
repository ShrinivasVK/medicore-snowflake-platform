-- ============================================================
-- Phase 12 - HCLS Data Model
-- File: 01_reference_tables.sql
-- Purpose: Create DEV Reference Tables (No Dependencies)
-- ============================================================

USE DATABASE MEDICORE_RAW_DB;
USE SCHEMA DEV_REFERENCE;

-- MEDICORE_RAW_DB.DEV_REFERENCE.

-- ============================================================
-- DIM_DEPARTMENTS
-- ============================================================

CREATE OR REPLACE TABLE MEDICORE_RAW_DB.DEV_REFERENCE.DIM_DEPARTMENTS (
    DEPARTMENT_ID     NUMBER                COMMENT 'Unique department identifier',
    DEPARTMENT_NAME   VARCHAR(100)          COMMENT 'Department display name',
    FACILITY_CODE     VARCHAR(20)           COMMENT 'Facility location code',
    IS_ACTIVE         BOOLEAN               COMMENT 'Department active status flag',
    CREATED_AT        TIMESTAMP_NTZ         COMMENT 'Record creation timestamp'
)
COMMENT = 'Raw reference table for hospital departments - DEV environment (synthetic only)';

-- ============================================================
-- DIM_ICD10_CODES
-- ============================================================

CREATE OR REPLACE TABLE MEDICORE_RAW_DB.DEV_REFERENCE.DIM_ICD10_CODES (
    ICD10_CODE        VARCHAR(10)           COMMENT 'Primary ICD-10 diagnosis code',
    ICD10_DESCRIPTION VARCHAR(255)          COMMENT 'Diagnosis description',
    ICD10_CATEGORY    VARCHAR(100)          COMMENT 'Diagnosis category grouping',
    IS_CHRONIC        BOOLEAN               COMMENT 'Flag for chronic conditions',
    CREATED_AT        TIMESTAMP_NTZ         COMMENT 'Record creation timestamp'
)
COMMENT = 'Raw reference table for ICD-10 codes - DEV environment (synthetic only)';