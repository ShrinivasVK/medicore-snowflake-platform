/*
================================================================================
FILE: infrastructure/11_medallion/01_transform_layer/03_billing/02_claim_line_items.sql
PURPOSE: Silver Layer transformation for CLAIM_LINE_ITEMS - Procedure-level Billing
LAYER: TRANSFORM (Silver)
DOMAIN: BILLING

================================================================================
BUSINESS ALIGNMENT
================================================================================
Pillar 1 — Cost Visibility (Procedure-level revenue & denial analytics)
Executive drill-down revenue reporting foundation

================================================================================
RAW COLUMN MAPPING
================================================================================
RAW Column          -> TRANSFORM Column         Transformation
--------------------------------------------------------------------------------
LINE_ITEM_ID        -> LINE_ITEM_ID             Direct (PK)
CLAIM_ID            -> CLAIM_ID                 Direct (FK to CLAIMS)
PROCEDURE_CODE      -> PROCEDURE_CODE           UPPERCASE, TRIM
LINE_AMOUNT         -> LINE_BILLED_AMOUNT       Cast to NUMBER(12,2)
QUANTITY            -> QUANTITY                 Direct
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
- UNIT_CHARGE_AMOUNT    : LINE_BILLED_AMOUNT / NULLIF(QUANTITY, 0)

================================================================================
STRICT COLUMN POLICY
================================================================================
This script adheres to STRICT COLUMN POLICY:
- Only RAW columns are included (no invented attributes)
- Only explicitly derived columns with defined logic
- No surrogate keys
- No placeholder columns
- No aggregated revenue metrics

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
-- STEP 1: CREATE SILVER CLAIM_LINE_ITEMS TABLE (IF NOT EXISTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIM_LINE_ITEMS (
    LINE_ITEM_ID            NUMBER(38,0)    NOT NULL    COMMENT 'Primary line item identifier',
    CLAIM_ID                NUMBER(38,0)                COMMENT 'Claim reference (logical FK to CLAIMS)',
    PROCEDURE_CODE          VARCHAR(20)                 COMMENT 'Procedure or CPT code (uppercase)',
    LINE_BILLED_AMOUNT      NUMBER(12,2)                COMMENT 'Line item billed amount (standardized precision)',
    QUANTITY                NUMBER(38,0)                COMMENT 'Units billed',
    RAW_CREATED_AT          TIMESTAMP_NTZ               COMMENT 'Original record creation timestamp from RAW',
    UNIT_CHARGE_AMOUNT      NUMBER(12,4)                COMMENT 'Derived: LINE_BILLED_AMOUNT / QUANTITY',
    LOAD_TIMESTAMP          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP()   COMMENT 'Record load timestamp',
    RECORD_SOURCE           VARCHAR(50)     DEFAULT 'RAW_BILLING'         COMMENT 'Source system identifier',
    DATA_QUALITY_STATUS     VARCHAR(20)     DEFAULT 'VALIDATED'           COMMENT 'Data quality validation status',
    
    CONSTRAINT PK_CLAIM_LINE_ITEMS PRIMARY KEY (LINE_ITEM_ID)
)
COMMENT = 'Silver layer CLAIM_LINE_ITEMS table - Validated procedure-level billing data';

-- ============================================================================
-- STEP 2: CREATE QUARANTINE TABLE (IF NOT EXISTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIM_LINE_ITEMS_QUARANTINE (
    LINE_ITEM_ID            NUMBER(38,0)                COMMENT 'Primary line item identifier (may be NULL)',
    CLAIM_ID                NUMBER(38,0)                COMMENT 'Claim reference',
    PROCEDURE_CODE          VARCHAR(20)                 COMMENT 'Original procedure code from RAW',
    LINE_AMOUNT             NUMBER(10,2)                COMMENT 'Original line amount from RAW',
    QUANTITY                NUMBER(38,0)                COMMENT 'Original quantity from RAW',
    CREATED_AT              TIMESTAMP_NTZ               COMMENT 'Original creation timestamp from RAW',
    FAILURE_REASON          VARCHAR(500)    NOT NULL    COMMENT 'Reason for quarantine',
    LOAD_TIMESTAMP          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP()   COMMENT 'Quarantine load timestamp'
)
COMMENT = 'Quarantine table for CLAIM_LINE_ITEMS records failing validation';

-- ============================================================================
-- STEP 3: QUARANTINE INVALID RECORDS (MERGE - IDEMPOTENT)
-- ============================================================================
MERGE INTO MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIM_LINE_ITEMS_QUARANTINE AS tgt
USING (
    SELECT
        LINE_ITEM_ID,
        CLAIM_ID,
        PROCEDURE_CODE,
        LINE_AMOUNT,
        QUANTITY,
        CREATED_AT,
        CASE
            WHEN LINE_ITEM_ID IS NULL THEN 'LINE_ITEM_ID is NULL'
            WHEN CLAIM_ID IS NULL THEN 'CLAIM_ID is NULL'
            WHEN LINE_AMOUNT < 0 THEN 'LINE_AMOUNT is negative'
            WHEN QUANTITY IS NULL THEN 'QUANTITY is NULL'
            WHEN QUANTITY <= 0 THEN 'QUANTITY must be greater than zero'
            ELSE 'UNKNOWN_VALIDATION_FAILURE'
        END AS FAILURE_REASON
    FROM MEDICORE_RAW_DB.DEV_BILLING.CLAIM_LINE_ITEMS
    WHERE LINE_ITEM_ID IS NULL
       OR CLAIM_ID IS NULL
       OR LINE_AMOUNT < 0
       OR QUANTITY IS NULL
       OR QUANTITY <= 0
) AS src
ON tgt.LINE_ITEM_ID = src.LINE_ITEM_ID
   AND tgt.FAILURE_REASON = src.FAILURE_REASON
WHEN NOT MATCHED THEN
    INSERT (
        LINE_ITEM_ID,
        CLAIM_ID,
        PROCEDURE_CODE,
        LINE_AMOUNT,
        QUANTITY,
        CREATED_AT,
        FAILURE_REASON,
        LOAD_TIMESTAMP
    )
    VALUES (
        src.LINE_ITEM_ID,
        src.CLAIM_ID,
        src.PROCEDURE_CODE,
        src.LINE_AMOUNT,
        src.QUANTITY,
        src.CREATED_AT,
        src.FAILURE_REASON,
        CURRENT_TIMESTAMP()
    );

-- ============================================================================
-- STEP 4: MERGE VALIDATED RECORDS INTO SILVER (IDEMPOTENT)
-- ============================================================================
MERGE INTO MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIM_LINE_ITEMS AS tgt
USING (
    SELECT
        LINE_ITEM_ID,
        CLAIM_ID,
        UPPER(TRIM(PROCEDURE_CODE)) AS PROCEDURE_CODE,
        CAST(LINE_AMOUNT AS NUMBER(12,2)) AS LINE_BILLED_AMOUNT,
        QUANTITY,
        CREATED_AT AS RAW_CREATED_AT,
        CAST(LINE_AMOUNT AS NUMBER(12,4)) / NULLIF(QUANTITY, 0) AS UNIT_CHARGE_AMOUNT
    FROM MEDICORE_RAW_DB.DEV_BILLING.CLAIM_LINE_ITEMS
    WHERE LINE_ITEM_ID IS NOT NULL
      AND CLAIM_ID IS NOT NULL
      AND LINE_AMOUNT >= 0
      AND QUANTITY IS NOT NULL
      AND QUANTITY > 0
) AS src
ON tgt.LINE_ITEM_ID = src.LINE_ITEM_ID
WHEN MATCHED AND (
    COALESCE(tgt.CLAIM_ID, -1) <> COALESCE(src.CLAIM_ID, -1)
    OR COALESCE(tgt.PROCEDURE_CODE, '') <> COALESCE(src.PROCEDURE_CODE, '')
    OR COALESCE(tgt.LINE_BILLED_AMOUNT, -1) <> COALESCE(src.LINE_BILLED_AMOUNT, -1)
    OR COALESCE(tgt.QUANTITY, -1) <> COALESCE(src.QUANTITY, -1)
    OR COALESCE(tgt.RAW_CREATED_AT, '1900-01-01'::TIMESTAMP_NTZ) <> COALESCE(src.RAW_CREATED_AT, '1900-01-01'::TIMESTAMP_NTZ)
) THEN
    UPDATE SET
        tgt.CLAIM_ID = src.CLAIM_ID,
        tgt.PROCEDURE_CODE = src.PROCEDURE_CODE,
        tgt.LINE_BILLED_AMOUNT = src.LINE_BILLED_AMOUNT,
        tgt.QUANTITY = src.QUANTITY,
        tgt.RAW_CREATED_AT = src.RAW_CREATED_AT,
        tgt.UNIT_CHARGE_AMOUNT = src.UNIT_CHARGE_AMOUNT,
        tgt.LOAD_TIMESTAMP = CURRENT_TIMESTAMP(),
        tgt.DATA_QUALITY_STATUS = 'VALIDATED'
WHEN NOT MATCHED THEN
    INSERT (
        LINE_ITEM_ID,
        CLAIM_ID,
        PROCEDURE_CODE,
        LINE_BILLED_AMOUNT,
        QUANTITY,
        RAW_CREATED_AT,
        UNIT_CHARGE_AMOUNT,
        LOAD_TIMESTAMP,
        RECORD_SOURCE,
        DATA_QUALITY_STATUS
    )
    VALUES (
        src.LINE_ITEM_ID,
        src.CLAIM_ID,
        src.PROCEDURE_CODE,
        src.LINE_BILLED_AMOUNT,
        src.QUANTITY,
        src.RAW_CREATED_AT,
        src.UNIT_CHARGE_AMOUNT,
        CURRENT_TIMESTAMP(),
        'RAW_BILLING',
        'VALIDATED'
    );

-- ============================================================================
-- STEP 5: APPLY GOVERNANCE TAGS - CLAIM_LINE_ITEMS TABLE
-- ============================================================================
ALTER TABLE MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIM_LINE_ITEMS
SET TAG
    MEDICORE_GOVERNANCE_DB.TAGS.MEDALLION_LAYER = 'TRANSFORM',
    MEDICORE_GOVERNANCE_DB.TAGS.DATA_DOMAIN = 'BILLING',
    MEDICORE_GOVERNANCE_DB.TAGS.ENVIRONMENT = 'DEV';

-- ============================================================================
-- STEP 6: APPLY GOVERNANCE TAGS - QUARANTINE TABLE
-- ============================================================================
ALTER TABLE MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIM_LINE_ITEMS_QUARANTINE
SET TAG
    MEDICORE_GOVERNANCE_DB.TAGS.MEDALLION_LAYER = 'TRANSFORM',
    MEDICORE_GOVERNANCE_DB.TAGS.DATA_DOMAIN = 'BILLING',
    MEDICORE_GOVERNANCE_DB.TAGS.ENVIRONMENT = 'DEV';

-- ============================================================================
-- STEP 7: EXECUTION SUMMARY
-- ============================================================================
SELECT
    'CLAIM_LINE_ITEMS Transform Load Complete' AS STATUS,
    CURRENT_TIMESTAMP() AS EXECUTION_TIMESTAMP,
    (SELECT COUNT(*) FROM MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIM_LINE_ITEMS) AS VALIDATED_RECORD_COUNT,
    (SELECT COUNT(*) FROM MEDICORE_TRANSFORM_DB.DEV_BILLING.CLAIM_LINE_ITEMS_QUARANTINE
        WHERE LOAD_TIMESTAMP >= DATEADD('hour', -1, CURRENT_TIMESTAMP())
    ) AS QUARANTINED_RECORD_COUNT_LAST_HOUR;
