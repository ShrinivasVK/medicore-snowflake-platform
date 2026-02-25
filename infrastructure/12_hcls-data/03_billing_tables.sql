-- ============================================================
-- Phase 12 - HCLS Data Model
-- File: 03_billing_tables.sql
-- Purpose: Create DEV Billing Tables
-- ============================================================

USE DATABASE MEDICORE_RAW_DB;
USE SCHEMA DEV_BILLING;

-- MEDICORE_RAW_DB.DEV_BILLING.

-- ============================================================
-- CLAIMS (Depends on ENCOUNTERS, PATIENTS logically)
-- ============================================================

CREATE OR REPLACE TABLE MEDICORE_RAW_DB.DEV_BILLING.CLAIMS (
    CLAIM_ID       NUMBER(38,0)        COMMENT 'Unique claim ID',
    ENCOUNTER_ID   NUMBER              COMMENT 'Encounter reference (logical FK)',
    PATIENT_ID     NUMBER              COMMENT 'Patient reference (logical FK)',
    TOTAL_AMOUNT   NUMBER(10,2)        COMMENT 'Total billed amount',
    CLAIM_STATUS   VARCHAR(50)         COMMENT 'Claim processing status',
    PAYER_TYPE     VARCHAR(50)         COMMENT 'Insurance payer category',
    SERVICE_DATE   DATE                COMMENT 'Service date',
    CREATED_AT     TIMESTAMP_NTZ       COMMENT 'Record creation timestamp'
)
COMMENT = 'Raw claims header table - DEV synthetic data';

-- ============================================================
-- CLAIM_LINE_ITEMS (Depends on CLAIMS)
-- ============================================================

CREATE OR REPLACE TABLE MEDICORE_RAW_DB.DEV_BILLING.CLAIM_LINE_ITEMS (
    LINE_ITEM_ID   NUMBER              COMMENT 'Unique claim line item ID',
    CLAIM_ID       NUMBER              COMMENT 'Claim reference (logical FK)',
    PROCEDURE_CODE VARCHAR(20)         COMMENT 'Procedure or CPT code',
    LINE_AMOUNT    NUMBER(10,2)        COMMENT 'Line item billed amount',
    QUANTITY       NUMBER              COMMENT 'Units billed',
    CREATED_AT     TIMESTAMP_NTZ       COMMENT 'Record creation timestamp'
)
COMMENT = 'Raw claim line items table - DEV synthetic data';