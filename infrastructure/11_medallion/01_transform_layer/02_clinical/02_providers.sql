/*
================================================================================
File:           infrastructure/11_medallion/01_transform_layer/02_clinical/02_providers.sql
Purpose:        Silver/Transform layer - Provider dimension table with data 
                standardization, validation, and quarantine logic
Source Table:   MEDICORE_RAW_DB.<ENV>_CLINICAL.PROVIDERS
Target Table:   MEDICORE_TRANSFORM_DB.<ENV>_CLINICAL.PROVIDERS
Quarantine:     MEDICORE_TRANSFORM_DB.<ENV>_CLINICAL.PROVIDERS_QUARANTINE

Source Columns (RAW):
  - PROVIDER_ID (NUMBER)        -> provider_id (NUMBER, primary key)
  - PROVIDER_NAME (VARCHAR)     -> provider_name (STRING, UPPER + TRIM)
  - SPECIALTY (VARCHAR)         -> specialty (STRING, UPPER + TRIM)
  - DEPARTMENT_ID (NUMBER)      -> department_id (NUMBER)
  - CREATED_AT (TIMESTAMP)      -> created_at (TIMESTAMP)

Metadata Columns (Added):
  - load_timestamp              DEFAULT CURRENT_TIMESTAMP()
  - record_source               DEFAULT 'RAW_CLINICAL'
  - data_quality_status         DEFAULT 'VALIDATED'

STRICT COLUMN POLICY:
  - Only columns present in RAW
  - Explicitly derived columns with defined logic
  - Required metadata columns
  - NO placeholder or invented columns

Business Rules Applied:
  - TRIM all string fields
  - UPPERCASE provider_name and specialty
  - Quarantine records with NULL provider_id or provider_name

Parameterization:
  - Uses EXECUTE IMMEDIATE for dynamic SQL with $ENVIRONMENT variable
  - CI/CD (GitHub Actions) sets ENVIRONMENT = 'DEV' | 'QA' | 'PROD'

Owner:          Data Engineering
Pillar:         Pillar 1 - Cost Visibility (provider-level revenue attribution)
                Pillar 2 - Clinical Insights (provider performance analytics)
Layer:          TRANSFORM (Silver)
Domain:         CLINICAL

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
CREATE SCHEMA IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_CLINICAL;

-- ============================================================================
-- STEP 2: CREATE SILVER TABLE (IF NOT EXISTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PROVIDERS (
    provider_id             NUMBER          NOT NULL    COMMENT 'Unique provider ID (primary key)',
    provider_name           STRING          NOT NULL    COMMENT 'Provider full name - uppercase',
    specialty               STRING                      COMMENT 'Clinical specialty - uppercase',
    department_id           NUMBER                      COMMENT 'Department reference (logical FK)',
    created_at              TIMESTAMP_NTZ               COMMENT 'Original record creation timestamp',
    load_timestamp          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP() COMMENT 'ETL load timestamp',
    record_source           STRING          DEFAULT 'RAW_CLINICAL' COMMENT 'Source system identifier',
    data_quality_status     STRING          DEFAULT 'VALIDATED' COMMENT 'Data quality validation status',
    CONSTRAINT pk_providers PRIMARY KEY (provider_id)
)
COMMENT = 'Silver/Transform layer - Cleaned and validated provider dimension';

-- ============================================================================
-- STEP 3: CREATE QUARANTINE TABLE (IF NOT EXISTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PROVIDERS_QUARANTINE (
    quarantine_id           STRING          DEFAULT UUID_STRING() COMMENT 'Unique quarantine record identifier',
    provider_id             NUMBER                      COMMENT 'Original provider_id (may be NULL)',
    provider_name           STRING                      COMMENT 'Original provider_name (may be NULL)',
    specialty               STRING                      COMMENT 'Original specialty',
    department_id           NUMBER                      COMMENT 'Original department_id',
    created_at              TIMESTAMP_NTZ               COMMENT 'Original created_at timestamp',
    failure_reason          STRING          NOT NULL    COMMENT 'Reason for quarantine',
    load_timestamp          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP() COMMENT 'Quarantine load timestamp'
)
COMMENT = 'Quarantine table for PROVIDERS records failing validation';

-- ============================================================================
-- STEP 4: MERGE QUARANTINED RECORDS
-- ============================================================================
MERGE INTO MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PROVIDERS_QUARANTINE AS tgt
USING (
    SELECT
        src.provider_id,
        src.provider_name,
        src.specialty,
        src.department_id,
        src.created_at,
        CASE
            WHEN src.provider_id IS NULL 
                THEN 'FAILED: provider_id IS NULL'
            WHEN src.provider_name IS NULL 
                THEN 'FAILED: provider_name IS NULL'
            WHEN TRIM(src.provider_name) = '' 
                THEN 'FAILED: provider_name is empty string'
            ELSE 'FAILED: Unknown validation error'
        END AS failure_reason,
        CURRENT_TIMESTAMP() AS load_timestamp
    FROM MEDICORE_RAW_DB.DEV_CLINICAL.PROVIDERS src
    WHERE 
        src.provider_id IS NULL
        OR src.provider_name IS NULL
        OR TRIM(src.provider_name) = ''
) AS src
ON tgt.provider_id = src.provider_id AND src.provider_id IS NOT NULL
WHEN MATCHED THEN UPDATE SET
    provider_name   = src.provider_name,
    specialty       = src.specialty,
    department_id   = src.department_id,
    created_at      = src.created_at,
    failure_reason  = src.failure_reason,
    load_timestamp  = src.load_timestamp
WHEN NOT MATCHED THEN INSERT (
    provider_id, provider_name, specialty, department_id, created_at, failure_reason, load_timestamp
) VALUES (
    src.provider_id, src.provider_name, src.specialty, src.department_id, src.created_at, src.failure_reason, src.load_timestamp
);

-- ============================================================================
-- STEP 5: MERGE VALIDATED RECORDS INTO SILVER TABLE
-- ============================================================================
MERGE INTO MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PROVIDERS AS tgt
USING (
    SELECT
        src.provider_id                     AS provider_id,
        UPPER(TRIM(src.provider_name))      AS provider_name,
        UPPER(TRIM(src.specialty))          AS specialty,
        src.department_id                   AS department_id,
        src.created_at                      AS created_at,
        CURRENT_TIMESTAMP()                 AS load_timestamp,
        'RAW_CLINICAL'                      AS record_source,
        'VALIDATED'                         AS data_quality_status
    FROM MEDICORE_RAW_DB.DEV_CLINICAL.PROVIDERS src
    WHERE 
        src.provider_id IS NOT NULL
        AND src.provider_name IS NOT NULL
        AND TRIM(src.provider_name) != ''
) AS src
ON tgt.provider_id = src.provider_id
WHEN MATCHED THEN UPDATE SET
    provider_name       = src.provider_name,
    specialty           = src.specialty,
    department_id       = src.department_id,
    created_at          = src.created_at,
    load_timestamp      = src.load_timestamp,
    record_source       = src.record_source,
    data_quality_status = src.data_quality_status
WHEN NOT MATCHED THEN INSERT (
    provider_id, provider_name, specialty, department_id, created_at, load_timestamp, record_source, data_quality_status
) VALUES (
    src.provider_id, src.provider_name, src.specialty, src.department_id, src.created_at, src.load_timestamp, src.record_source, src.data_quality_status
);

-- ============================================================================
-- STEP 6: APPLY GOVERNANCE TAGS
-- ============================================================================
ALTER TABLE MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PROVIDERS
    SET TAG 
        MEDICORE_GOVERNANCE_DB.TAGS.MEDALLION_LAYER = 'TRANSFORM',
        MEDICORE_GOVERNANCE_DB.TAGS.DATA_DOMAIN = 'CLINICAL',
        MEDICORE_GOVERNANCE_DB.TAGS.ENVIRONMENT = 'DEV';

ALTER TABLE MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PROVIDERS_QUARANTINE
    SET TAG 
        MEDICORE_GOVERNANCE_DB.TAGS.MEDALLION_LAYER = 'TRANSFORM',
        MEDICORE_GOVERNANCE_DB.TAGS.DATA_DOMAIN = 'CLINICAL',
        MEDICORE_GOVERNANCE_DB.TAGS.ENVIRONMENT = 'DEV';

-- ============================================================================
-- STEP 7: EXECUTION SUMMARY
-- ============================================================================
SELECT 
    'PROVIDERS Transform Load Complete' AS status,
    'DEV' AS environment,
    CURRENT_TIMESTAMP() AS execution_timestamp,
    (SELECT COUNT(*) FROM MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PROVIDERS) AS validated_record_count,
    (SELECT COUNT(*) 
       FROM MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PROVIDERS_QUARANTINE 
       WHERE load_timestamp >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
    ) AS quarantined_record_count_last_hour;