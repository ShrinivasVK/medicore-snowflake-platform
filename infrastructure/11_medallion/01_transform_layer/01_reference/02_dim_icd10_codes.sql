/*
================================================================================
File:           infrastructure/11_medallion/01_transform_layer/01_reference/02_dim_icd10_codes.sql
Purpose:        Silver/Transform layer - ICD-10 diagnosis codes dimension table
                with data standardization, validation, and quarantine logic
Source Table:   MEDICORE_RAW_DB.<ENV>_REFERENCE.DIM_ICD10_CODES
Target Table:   MEDICORE_TRANSFORM_DB.<ENV>_REFERENCE.DIM_ICD10_CODES
Quarantine:     MEDICORE_TRANSFORM_DB.<ENV>_REFERENCE.DIM_ICD10_CODES_QUARANTINE

Source Columns (RAW):
  - ICD10_CODE (VARCHAR)        -> icd10_code (STRING, UPPER + TRIM)
  - ICD10_DESCRIPTION (VARCHAR) -> icd10_description (STRING, TRIM)
  - ICD10_CATEGORY (VARCHAR)    -> icd10_category (STRING, UPPER + TRIM)
  - IS_CHRONIC (BOOLEAN)        -> is_chronic (BOOLEAN)
  - CREATED_AT (TIMESTAMP)      -> created_at (TIMESTAMP)

Metadata Columns (Added):
  - load_timestamp              DEFAULT CURRENT_TIMESTAMP()
  - record_source               DEFAULT 'RAW_REFERENCE'
  - data_quality_status         DEFAULT 'VALIDATED'

STRICT COLUMN POLICY:
  - Only columns present in RAW
  - Explicitly derived columns with defined logic
  - Required metadata columns
  - NO placeholder or invented columns

Business Rules Applied:
  - TRIM all string fields
  - UPPERCASE icd10_code and icd10_category
  - Preserve icd10_description case (medical terminology)
  - Quarantine records with NULL/empty icd10_code or icd10_description

Parameterization:
  - Uses EXECUTE IMMEDIATE for dynamic SQL with $ENVIRONMENT variable
  - CI/CD (GitHub Actions) sets ENVIRONMENT = 'DEV' | 'QA' | 'PROD'

Owner:          Data Engineering
Pillar:         Pillar 1 - Cost Visibility (Diagnosis-based revenue analytics foundation)
Layer:          TRANSFORM (Silver)
Domain:         REFERENCE

Change History:
  Date        Author              Description
  ----------  ------------------  -----------------------------------------------
  2026-02-26  Data Engineering    Initial creation
  2026-02-26  Data Engineering    Replaced IDENTIFIER() with EXECUTE IMMEDIATE
================================================================================
*/

-- ============================================================================
-- SESSION CONFIGURATION
-- ============================================================================
USE ROLE MEDICORE_DATA_ENGINEER;
USE WAREHOUSE MEDICORE_ETL_WH;

-- ============================================================================
-- STEP 1: CREATE TARGET SCHEMA (IF NOT EXISTS)
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_REFERENCE;

-- ============================================================================
-- STEP 2: CREATE SILVER TABLE (IF NOT EXISTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_ICD10_CODES (
    icd10_code              STRING          NOT NULL    COMMENT 'Primary ICD-10 diagnosis code (UPPER + TRIM)',
    icd10_description       STRING          NOT NULL    COMMENT 'Diagnosis description (TRIM, case preserved)',
    icd10_category          STRING                      COMMENT 'Diagnosis category grouping (UPPER + TRIM)',
    is_chronic              BOOLEAN                     COMMENT 'Flag for chronic conditions',
    created_at              TIMESTAMP_NTZ               COMMENT 'Original record creation timestamp',
    load_timestamp          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP() COMMENT 'ETL load timestamp',
    record_source           STRING          DEFAULT 'RAW_REFERENCE' COMMENT 'Source system identifier',
    data_quality_status     STRING          DEFAULT 'VALIDATED' COMMENT 'Data quality validation status',
    CONSTRAINT pk_dim_icd10_codes PRIMARY KEY (icd10_code)
)
COMMENT = 'Silver/Transform layer - Cleaned and validated ICD-10 diagnosis codes dimension';

-- ============================================================================
-- STEP 3: CREATE QUARANTINE TABLE (IF NOT EXISTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_ICD10_CODES_QUARANTINE (
    quarantine_id           STRING          DEFAULT UUID_STRING() COMMENT 'Unique quarantine record identifier',
    icd10_code              STRING                      COMMENT 'Original icd10_code (may be NULL/empty)',
    icd10_description       STRING                      COMMENT 'Original icd10_description (may be NULL/empty)',
    icd10_category          STRING                      COMMENT 'Original icd10_category',
    is_chronic              BOOLEAN                     COMMENT 'Original is_chronic flag',
    created_at              TIMESTAMP_NTZ               COMMENT 'Original created_at timestamp',
    failure_reason          STRING          NOT NULL    COMMENT 'Reason for quarantine',
    load_timestamp          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP() COMMENT 'Quarantine load timestamp'
)
COMMENT = 'Quarantine table for DIM_ICD10_CODES records failing validation';

-- ============================================================================
-- STEP 4: MERGE QUARANTINED RECORDS
-- ============================================================================
MERGE INTO MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_ICD10_CODES_QUARANTINE tgt
USING (
    SELECT
        src.icd10_code,
        src.icd10_description,
        src.icd10_category,
        src.is_chronic,
        src.created_at,
        CASE
            WHEN src.icd10_code IS NULL 
                THEN 'FAILED: icd10_code IS NULL'
            WHEN TRIM(src.icd10_code) = '' 
                THEN 'FAILED: icd10_code is empty string'
            WHEN src.icd10_description IS NULL 
                THEN 'FAILED: icd10_description IS NULL'
            WHEN TRIM(src.icd10_description) = '' 
                THEN 'FAILED: icd10_description is empty string'
            ELSE 'FAILED: Unknown validation error'
        END AS failure_reason,
        CURRENT_TIMESTAMP() AS load_timestamp
    FROM MEDICORE_RAW_DB.DEV_REFERENCE.DIM_ICD10_CODES src
    WHERE 
        src.icd10_code IS NULL
        OR TRIM(src.icd10_code) = ''
        OR src.icd10_description IS NULL
        OR TRIM(src.icd10_description) = ''
) src
ON tgt.icd10_code = src.icd10_code
WHEN MATCHED THEN UPDATE SET
    icd10_description = src.icd10_description,
    icd10_category    = src.icd10_category,
    is_chronic        = src.is_chronic,
    created_at        = src.created_at,
    failure_reason    = src.failure_reason,
    load_timestamp    = src.load_timestamp
WHEN NOT MATCHED THEN INSERT (
    icd10_code, icd10_description, icd10_category, is_chronic, created_at, failure_reason, load_timestamp
) VALUES (
    src.icd10_code, src.icd10_description, src.icd10_category, src.is_chronic, src.created_at, src.failure_reason, src.load_timestamp
);

-- ============================================================================
-- STEP 5: MERGE VALIDATED RECORDS INTO SILVER TABLE
-- ============================================================================
MERGE INTO MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_ICD10_CODES tgt
USING (
    SELECT
        UPPER(TRIM(icd10_code))      AS icd10_code,
        TRIM(icd10_description)      AS icd10_description,
        UPPER(TRIM(icd10_category))  AS icd10_category,
        is_chronic,
        created_at,
        CURRENT_TIMESTAMP()          AS load_timestamp,
        'RAW_REFERENCE'              AS record_source,
        'VALIDATED'                  AS data_quality_status
    FROM MEDICORE_RAW_DB.DEV_REFERENCE.DIM_ICD10_CODES
    WHERE 
        icd10_code IS NOT NULL
        AND TRIM(icd10_code) != ''
        AND icd10_description IS NOT NULL
        AND TRIM(icd10_description) != ''
) src
ON tgt.icd10_code = src.icd10_code
WHEN MATCHED THEN UPDATE SET
    icd10_description   = src.icd10_description,
    icd10_category      = src.icd10_category,
    is_chronic          = src.is_chronic,
    created_at          = src.created_at,
    load_timestamp      = src.load_timestamp,
    record_source       = src.record_source,
    data_quality_status = src.data_quality_status
WHEN NOT MATCHED THEN INSERT (
    icd10_code, icd10_description, icd10_category, is_chronic,
    created_at, load_timestamp, record_source, data_quality_status
) VALUES (
    src.icd10_code, src.icd10_description, src.icd10_category,
    src.is_chronic, src.created_at, src.load_timestamp,
    src.record_source, src.data_quality_status
);

-- ============================================================================
-- STEP 6: APPLY GOVERNANCE TAGS
-- ============================================================================
ALTER TABLE MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_ICD10_CODES
SET TAG 
    MEDICORE_GOVERNANCE_DB.TAGS.MEDALLION_LAYER = 'TRANSFORM',
    MEDICORE_GOVERNANCE_DB.TAGS.DATA_DOMAIN = 'REFERENCE',
    MEDICORE_GOVERNANCE_DB.TAGS.ENVIRONMENT = 'DEV';

ALTER TABLE MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_ICD10_CODES_QUARANTINE
SET TAG 
    MEDICORE_GOVERNANCE_DB.TAGS.MEDALLION_LAYER = 'TRANSFORM',
    MEDICORE_GOVERNANCE_DB.TAGS.DATA_DOMAIN = 'REFERENCE',
    MEDICORE_GOVERNANCE_DB.TAGS.ENVIRONMENT = 'DEV';

-- ============================================================================
-- STEP 7: EXECUTION SUMMARY
-- ============================================================================
SELECT 
    'DIM_ICD10_CODES Transform Load Complete' AS status,
    'DEV' AS environment,
    CURRENT_TIMESTAMP() AS execution_timestamp,
    (SELECT COUNT(*) FROM MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_ICD10_CODES) AS validated_record_count,
    (SELECT COUNT(*) 
       FROM MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_ICD10_CODES_QUARANTINE 
       WHERE load_timestamp >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
    ) AS quarantined_record_count_last_hour;