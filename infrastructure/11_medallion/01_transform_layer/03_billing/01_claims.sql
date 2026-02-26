/*
================================================================================
FILE: infrastructure/11_medallion/01_transform_layer/03_billing/01_claims.sql
PURPOSE: Silver Layer transformation for CLAIMS data - Revenue & Billing Domain
LAYER: TRANSFORM (Silver)
DOMAIN: BILLING

================================================================================
BUSINESS ALIGNMENT
================================================================================
Pillar 1 — Cost Visibility (Revenue, Denials, Collection Rate, Payer Mix)
Foundation for Executive KPI dashboards

================================================================================
RAW COLUMN MAPPING
================================================================================
RAW Column          -> TRANSFORM Column         Transformation
--------------------------------------------------------------------------------
CLAIM_ID            -> CLAIM_ID                 Direct (PK)
ENCOUNTER_ID        -> ENCOUNTER_ID             Direct
PATIENT_ID          -> PATIENT_ID               Direct
TOTAL_AMOUNT        -> CLAIM_BILLED_AMOUNT      Cast to NUMBER(12,2)
CLAIM_STATUS        -> CLAIM_STATUS             UPPERCASE, Standardized
PAYER_TYPE          -> PAYER_TYPE               UPPERCASE, TRIM
SERVICE_DATE        -> SERVICE_DATE             Direct (DATE)
CREATED_AT          -> RAW_CREATED_AT           Preserved original timestamp

================================================================================
METADATA COLUMNS ADDED
================================================================================
- LOAD_TIMESTAMP        : Record load time (DEFAULT CURRENT_TIMESTAMP)
- RECORD_SOURCE         : Source system identifier (DEFAULT 'RAW_BILLING')
- DATA_QUALITY_STATUS   : Validation status (DEFAULT 'VALIDATED')

================================================================================
DERIVED COLUMNS
================================================================================
- SERVICE_YEAR          : YEAR(SERVICE_DATE)
- SERVICE_MONTH         : MONTH(SERVICE_DATE)
- DENIAL_FLAG           : 1 if CLAIM_STATUS = 'DENIED', else 0

================================================================================
STRICT COLUMN POLICY
================================================================================
This script adheres to STRICT COLUMN POLICY:
- Only RAW columns are included (no invented attributes)
- Only explicitly derived columns with defined logic
- No surrogate keys
- No placeholder columns
- No financial metrics not derivable from RAW

================================================================================
CHANGE HISTORY
================================================================================
Date        Author              Description
--------------------------------------------------------------------------------
2026-02-26  Data Engineering    Initial Silver layer implementation
================================================================================
*/

-- ============================================================================
-- EXECUTION CONTEXT
-- ============================================================================
USE ROLE MEDICORE_DATA_ENGINEER;
USE WAREHOUSE MEDICORE_ETL_WH;
USE DATABASE MEDICORE_TRANSFORM_DB;
USE SCHEMA DEV_BILLING;

-- ============================================================================
-- STEP 1: CREATE SILVER CLAIMS TABLE (IF NOT EXISTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIMS (
    CLAIM_ID                NUMBER(38,0)    NOT NULL    COMMENT 'Primary claim identifier',
    ENCOUNTER_ID            NUMBER(38,0)                COMMENT 'Encounter reference (logical FK)',
    PATIENT_ID              NUMBER(38,0)                COMMENT 'Patient reference (logical FK)',
    CLAIM_BILLED_AMOUNT     NUMBER(12,2)                COMMENT 'Total billed amount (standardized precision)',
    CLAIM_STATUS            VARCHAR(50)                 COMMENT 'Standardized claim status: PAID/DENIED/PENDING/ADJUSTED/UNKNOWN',
    PAYER_TYPE              VARCHAR(50)                 COMMENT 'Insurance payer category (uppercase)',
    SERVICE_DATE            DATE                        COMMENT 'Date of service',
    RAW_CREATED_AT          TIMESTAMP_NTZ               COMMENT 'Original record creation timestamp from RAW',
    SERVICE_YEAR            NUMBER(4,0)                 COMMENT 'Derived: Year of service',
    SERVICE_MONTH           NUMBER(2,0)                 COMMENT 'Derived: Month of service',
    DENIAL_FLAG             NUMBER(1,0)                 COMMENT 'Derived: 1 if DENIED, else 0',
    LOAD_TIMESTAMP          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP()   COMMENT 'Record load timestamp',
    RECORD_SOURCE           VARCHAR(50)     DEFAULT 'RAW_BILLING'         COMMENT 'Source system identifier',
    DATA_QUALITY_STATUS     VARCHAR(20)     DEFAULT 'VALIDATED'           COMMENT 'Data quality validation status',
    
    CONSTRAINT PK_CLAIMS PRIMARY KEY (CLAIM_ID)
)
COMMENT = 'Silver layer CLAIMS table - Validated and standardized billing claims data';

-- ============================================================================
-- STEP 2: CREATE QUARANTINE TABLE (IF NOT EXISTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIMS_QUARANTINE (
    CLAIM_ID                NUMBER(38,0)                COMMENT 'Primary claim identifier (may be NULL)',
    ENCOUNTER_ID            NUMBER(38,0)                COMMENT 'Encounter reference',
    PATIENT_ID              NUMBER(38,0)                COMMENT 'Patient reference',
    TOTAL_AMOUNT            NUMBER(10,2)                COMMENT 'Original total amount from RAW',
    CLAIM_STATUS            VARCHAR(50)                 COMMENT 'Original claim status from RAW',
    PAYER_TYPE              VARCHAR(50)                 COMMENT 'Original payer type from RAW',
    SERVICE_DATE            DATE                        COMMENT 'Date of service',
    CREATED_AT              TIMESTAMP_NTZ               COMMENT 'Original creation timestamp from RAW',
    FAILURE_REASON          VARCHAR(500)    NOT NULL    COMMENT 'Reason for quarantine',
    LOAD_TIMESTAMP          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP()   COMMENT 'Quarantine load timestamp'
)
COMMENT = 'Quarantine table for CLAIMS records failing validation';

-- ============================================================================
-- STEP 3: QUARANTINE INVALID RECORDS (MERGE - IDEMPOTENT)
-- ============================================================================
MERGE INTO MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIMS_QUARANTINE AS tgt
USING (
    SELECT
        CLAIM_ID,
        ENCOUNTER_ID,
        PATIENT_ID,
        TOTAL_AMOUNT,
        CLAIM_STATUS,
        PAYER_TYPE,
        SERVICE_DATE,
        CREATED_AT,
        CASE
            WHEN CLAIM_ID IS NULL THEN 'CLAIM_ID is NULL'
            WHEN PATIENT_ID IS NULL THEN 'PATIENT_ID is NULL'
            WHEN ENCOUNTER_ID IS NULL THEN 'ENCOUNTER_ID is NULL'
            WHEN SERVICE_DATE IS NULL THEN 'SERVICE_DATE is NULL'
            WHEN SERVICE_DATE > CURRENT_DATE() THEN 'SERVICE_DATE is in the future'
            WHEN TOTAL_AMOUNT < 0 THEN 'TOTAL_AMOUNT is negative'
            ELSE 'UNKNOWN_VALIDATION_FAILURE'
        END AS FAILURE_REASON
    FROM MEDICORE_RAW_DB.DEV_BILLING.CLAIMS
    WHERE CLAIM_ID IS NULL
       OR PATIENT_ID IS NULL
       OR ENCOUNTER_ID IS NULL
       OR SERVICE_DATE IS NULL
       OR SERVICE_DATE > CURRENT_DATE()
       OR TOTAL_AMOUNT < 0
) AS src
ON tgt.CLAIM_ID = src.CLAIM_ID
   AND tgt.FAILURE_REASON = src.FAILURE_REASON
WHEN NOT MATCHED THEN
    INSERT (
        CLAIM_ID,
        ENCOUNTER_ID,
        PATIENT_ID,
        TOTAL_AMOUNT,
        CLAIM_STATUS,
        PAYER_TYPE,
        SERVICE_DATE,
        CREATED_AT,
        FAILURE_REASON,
        LOAD_TIMESTAMP
    )
    VALUES (
        src.CLAIM_ID,
        src.ENCOUNTER_ID,
        src.PATIENT_ID,
        src.TOTAL_AMOUNT,
        src.CLAIM_STATUS,
        src.PAYER_TYPE,
        src.SERVICE_DATE,
        src.CREATED_AT,
        src.FAILURE_REASON,
        CURRENT_TIMESTAMP()
    );

-- ============================================================================
-- STEP 4: MERGE VALIDATED RECORDS INTO SILVER (IDEMPOTENT)
-- ============================================================================
MERGE INTO MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIMS AS tgt
USING (
    SELECT
        CLAIM_ID,
        ENCOUNTER_ID,
        PATIENT_ID,
        CAST(TOTAL_AMOUNT AS NUMBER(12,2)) AS CLAIM_BILLED_AMOUNT,
        CASE UPPER(TRIM(CLAIM_STATUS))
            WHEN 'PAID' THEN 'PAID'
            WHEN 'DENIED' THEN 'DENIED'
            WHEN 'PENDING' THEN 'PENDING'
            WHEN 'ADJUSTED' THEN 'ADJUSTED'
            WHEN 'APPROVED' THEN 'PAID'
            WHEN 'REJECTED' THEN 'DENIED'
            WHEN 'IN_PROGRESS' THEN 'PENDING'
            WHEN 'IN PROGRESS' THEN 'PENDING'
            WHEN 'SUBMITTED' THEN 'PENDING'
            ELSE 'UNKNOWN'
        END AS CLAIM_STATUS,
        UPPER(TRIM(PAYER_TYPE)) AS PAYER_TYPE,
        SERVICE_DATE,
        CREATED_AT AS RAW_CREATED_AT,
        YEAR(SERVICE_DATE) AS SERVICE_YEAR,
        MONTH(SERVICE_DATE) AS SERVICE_MONTH,
        CASE 
            WHEN UPPER(TRIM(CLAIM_STATUS)) IN ('DENIED', 'REJECTED') THEN 1 
            ELSE 0 
        END AS DENIAL_FLAG
    FROM MEDICORE_RAW_DB.DEV_BILLING.CLAIMS
    WHERE CLAIM_ID IS NOT NULL
      AND PATIENT_ID IS NOT NULL
      AND ENCOUNTER_ID IS NOT NULL
      AND SERVICE_DATE IS NOT NULL
      AND SERVICE_DATE <= CURRENT_DATE()
      AND TOTAL_AMOUNT >= 0
) AS src
ON tgt.CLAIM_ID = src.CLAIM_ID
WHEN MATCHED AND (
    COALESCE(tgt.ENCOUNTER_ID, -1) <> COALESCE(src.ENCOUNTER_ID, -1)
    OR COALESCE(tgt.PATIENT_ID, -1) <> COALESCE(src.PATIENT_ID, -1)
    OR COALESCE(tgt.CLAIM_BILLED_AMOUNT, -1) <> COALESCE(src.CLAIM_BILLED_AMOUNT, -1)
    OR COALESCE(tgt.CLAIM_STATUS, '') <> COALESCE(src.CLAIM_STATUS, '')
    OR COALESCE(tgt.PAYER_TYPE, '') <> COALESCE(src.PAYER_TYPE, '')
    OR COALESCE(tgt.SERVICE_DATE, '1900-01-01') <> COALESCE(src.SERVICE_DATE, '1900-01-01')
    OR COALESCE(tgt.RAW_CREATED_AT, '1900-01-01'::TIMESTAMP_NTZ) <> COALESCE(src.RAW_CREATED_AT, '1900-01-01'::TIMESTAMP_NTZ)
) THEN
    UPDATE SET
        tgt.ENCOUNTER_ID = src.ENCOUNTER_ID,
        tgt.PATIENT_ID = src.PATIENT_ID,
        tgt.CLAIM_BILLED_AMOUNT = src.CLAIM_BILLED_AMOUNT,
        tgt.CLAIM_STATUS = src.CLAIM_STATUS,
        tgt.PAYER_TYPE = src.PAYER_TYPE,
        tgt.SERVICE_DATE = src.SERVICE_DATE,
        tgt.RAW_CREATED_AT = src.RAW_CREATED_AT,
        tgt.SERVICE_YEAR = src.SERVICE_YEAR,
        tgt.SERVICE_MONTH = src.SERVICE_MONTH,
        tgt.DENIAL_FLAG = src.DENIAL_FLAG,
        tgt.LOAD_TIMESTAMP = CURRENT_TIMESTAMP(),
        tgt.DATA_QUALITY_STATUS = 'VALIDATED'
WHEN NOT MATCHED THEN
    INSERT (
        CLAIM_ID,
        ENCOUNTER_ID,
        PATIENT_ID,
        CLAIM_BILLED_AMOUNT,
        CLAIM_STATUS,
        PAYER_TYPE,
        SERVICE_DATE,
        RAW_CREATED_AT,
        SERVICE_YEAR,
        SERVICE_MONTH,
        DENIAL_FLAG,
        LOAD_TIMESTAMP,
        RECORD_SOURCE,
        DATA_QUALITY_STATUS
    )
    VALUES (
        src.CLAIM_ID,
        src.ENCOUNTER_ID,
        src.PATIENT_ID,
        src.CLAIM_BILLED_AMOUNT,
        src.CLAIM_STATUS,
        src.PAYER_TYPE,
        src.SERVICE_DATE,
        src.RAW_CREATED_AT,
        src.SERVICE_YEAR,
        src.SERVICE_MONTH,
        src.DENIAL_FLAG,
        CURRENT_TIMESTAMP(),
        'RAW_BILLING',
        'VALIDATED'
    );

-- ============================================================================
-- STEP 5: APPLY GOVERNANCE TAGS - CLAIMS TABLE
-- ============================================================================
ALTER TABLE MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIMS
SET TAG
    MEDICORE_GOVERNANCE_DB.TAGS.MEDALLION_LAYER = 'TRANSFORM',
    MEDICORE_GOVERNANCE_DB.TAGS.DATA_DOMAIN = 'BILLING',
    MEDICORE_GOVERNANCE_DB.TAGS.ENVIRONMENT = 'DEV';

-- ============================================================================
-- STEP 6: APPLY GOVERNANCE TAGS - QUARANTINE TABLE
-- ============================================================================
ALTER TABLE MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIMS_QUARANTINE
SET TAG
    MEDICORE_GOVERNANCE_DB.TAGS.MEDALLION_LAYER = 'TRANSFORM',
    MEDICORE_GOVERNANCE_DB.TAGS.DATA_DOMAIN = 'BILLING',
    MEDICORE_GOVERNANCE_DB.TAGS.ENVIRONMENT = 'DEV';

-- ============================================================================
-- STEP 7: EXECUTION SUMMARY
-- ============================================================================
SELECT
    'CLAIMS Transform Load Complete' AS STATUS,
    CURRENT_TIMESTAMP() AS EXECUTION_TIMESTAMP,
    (SELECT COUNT(*) FROM MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIMS) AS VALIDATED_RECORD_COUNT,
    (SELECT COUNT(*) FROM MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIMS_QUARANTINE
        WHERE LOAD_TIMESTAMP >= DATEADD('hour', -1, CURRENT_TIMESTAMP())
    ) AS QUARANTINED_RECORD_COUNT_LAST_HOUR;
