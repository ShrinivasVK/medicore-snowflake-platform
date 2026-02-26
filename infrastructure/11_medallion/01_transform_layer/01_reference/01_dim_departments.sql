/*
================================================================================
File:           infrastructure/11_medallion/01_transform_layer/01_reference/01_dim_departments.sql
Purpose:        Silver/Transform layer - Department dimension table with data 
                standardization, validation, and quarantine logic
Source Table:   MEDICORE_RAW_DB.<ENV>_REFERENCE.DIM_DEPARTMENTS
Target Table:   MEDICORE_TRANSFORM_DB.<ENV>_REFERENCE.DIM_DEPARTMENTS
Quarantine:     MEDICORE_TRANSFORM_DB.<ENV>_REFERENCE.DIM_DEPARTMENTS_QUARANTINE

Source Columns (RAW):
  - DEPARTMENT_ID (NUMBER)      -> department_id (STRING)
  - DEPARTMENT_NAME (VARCHAR)   -> department_name (STRING, UPPER + TRIM)
  - FACILITY_CODE (VARCHAR)     -> facility_code (STRING, TRIM)
  - IS_ACTIVE (BOOLEAN)         -> active_flag (BOOLEAN)
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
  - UPPERCASE department_name
  - Cast department_id from NUMBER to STRING
  - Quarantine records with NULL/empty department_id or department_name

Parameterization:
  - Uses EXECUTE IMMEDIATE for dynamic SQL with $ENVIRONMENT variable
  - CI/CD (GitHub Actions) sets ENVIRONMENT = 'DEV' | 'QA' | 'PROD'

Owner:          Data Engineering
Pillar:         Pillar 1 - Cost Visibility Foundation
Layer:          TRANSFORM (Silver)
Domain:         REFERENCE

Change History:
  Date        Author              Description
  ----------  ------------------  -----------------------------------------------
  2026-02-26  Data Engineering    Initial creation
  2026-02-26  Data Engineering    Aligned to strict RAW column policy
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
CREATE TABLE IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_DEPARTMENTS (
    department_id           STRING          NOT NULL    COMMENT 'Primary business key (cast from NUMBER)',
    department_name         STRING          NOT NULL    COMMENT 'Standardized department name (UPPER + TRIM)',
    facility_code           STRING                      COMMENT 'Facility location code (TRIM)',
    active_flag             BOOLEAN                     COMMENT 'Department active status',
    created_at              TIMESTAMP_NTZ               COMMENT 'Original record creation timestamp',
    load_timestamp          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP() COMMENT 'ETL load timestamp',
    record_source           STRING          DEFAULT 'RAW_REFERENCE' COMMENT 'Source system identifier',
    data_quality_status     STRING          DEFAULT 'VALIDATED' COMMENT 'Data quality validation status',
    CONSTRAINT pk_dim_departments PRIMARY KEY (department_id)
)
COMMENT = 'Silver/Transform layer - Cleaned and validated department dimension';

-- ============================================================================
-- STEP 3: CREATE QUARANTINE TABLE (IF NOT EXISTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_DEPARTMENTS_QUARANTINE (
    quarantine_id           STRING          DEFAULT UUID_STRING() COMMENT 'Unique quarantine record identifier',
    department_id           NUMBER                      COMMENT 'Original department_id (may be NULL)',
    department_name         STRING                      COMMENT 'Original department_name (may be NULL/empty)',
    facility_code           STRING                      COMMENT 'Original facility_code',
    is_active               BOOLEAN                     COMMENT 'Original is_active flag',
    created_at              TIMESTAMP_NTZ               COMMENT 'Original created_at timestamp',
    failure_reason          STRING          NOT NULL    COMMENT 'Reason for quarantine',
    load_timestamp          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP() COMMENT 'Quarantine load timestamp'
)
COMMENT = 'Quarantine table for DIM_DEPARTMENTS records failing validation';

-- ============================================================================
-- STEP 4: MERGE QUARANTINED RECORDS
-- ============================================================================
MERGE INTO MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_DEPARTMENTS_QUARANTINE tgt
USING (
    SELECT
        src.department_id,
        src.department_name,
        src.facility_code,
        src.is_active,
        src.created_at,
        CASE
            WHEN src.department_id IS NULL 
                THEN 'FAILED: department_id IS NULL'
            WHEN src.department_name IS NULL 
                THEN 'FAILED: department_name IS NULL'
            WHEN TRIM(src.department_name) = '' 
                THEN 'FAILED: department_name is empty string'
            ELSE 'FAILED: Unknown validation error'
        END AS failure_reason,
        CURRENT_TIMESTAMP() AS load_timestamp
    FROM MEDICORE_RAW_DB.DEV_REFERENCE.DIM_DEPARTMENTS src
    WHERE 
        src.department_id IS NULL
        OR src.department_name IS NULL
        OR TRIM(src.department_name) = ''
) src
ON tgt.department_id = src.department_id
WHEN MATCHED THEN UPDATE SET
    department_name = src.department_name,
    facility_code   = src.facility_code,
    is_active       = src.is_active,
    created_at      = src.created_at,
    failure_reason  = src.failure_reason,
    load_timestamp  = src.load_timestamp
WHEN NOT MATCHED THEN INSERT (
    department_id, department_name, facility_code, is_active, created_at, failure_reason, load_timestamp
) VALUES (
    src.department_id, src.department_name, src.facility_code, src.is_active, src.created_at, src.failure_reason, src.load_timestamp
);

-- ============================================================================
-- STEP 5: MERGE VALIDATED RECORDS INTO SILVER TABLE
-- ============================================================================
MERGE INTO MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_DEPARTMENTS tgt
USING (
    SELECT
        TRIM(department_id::STRING)  AS department_id,
        UPPER(TRIM(department_name)) AS department_name,
        TRIM(facility_code)          AS facility_code,
        is_active                    AS active_flag,
        created_at,
        CURRENT_TIMESTAMP()          AS load_timestamp,
        'RAW_REFERENCE'              AS record_source,
        'VALIDATED'                  AS data_quality_status
    FROM MEDICORE_RAW_DB.DEV_REFERENCE.DIM_DEPARTMENTS
    WHERE 
        department_id IS NOT NULL
        AND department_name IS NOT NULL
        AND TRIM(department_name) != ''
) src
ON tgt.department_id = src.department_id
WHEN MATCHED THEN UPDATE SET
    department_name     = src.department_name,
    facility_code       = src.facility_code,
    active_flag         = src.active_flag,
    created_at          = src.created_at,
    load_timestamp      = src.load_timestamp,
    record_source       = src.record_source,
    data_quality_status = src.data_quality_status
WHEN NOT MATCHED THEN INSERT (
    department_id, department_name, facility_code, active_flag,
    created_at, load_timestamp, record_source, data_quality_status
) VALUES (
    src.department_id, src.department_name, src.facility_code,
    src.active_flag, src.created_at, src.load_timestamp,
    src.record_source, src.data_quality_status
);

-- ============================================================================
-- STEP 6: APPLY GOVERNANCE TAGS
-- ============================================================================
ALTER TABLE MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_DEPARTMENTS
SET TAG 
    MEDICORE_GOVERNANCE_DB.TAGS.MEDALLION_LAYER = 'TRANSFORM',
    MEDICORE_GOVERNANCE_DB.TAGS.DATA_DOMAIN = 'REFERENCE',
    MEDICORE_GOVERNANCE_DB.TAGS.ENVIRONMENT = 'DEV';

ALTER TABLE MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_DEPARTMENTS_QUARANTINE
SET TAG 
    MEDICORE_GOVERNANCE_DB.TAGS.MEDALLION_LAYER = 'TRANSFORM',
    MEDICORE_GOVERNANCE_DB.TAGS.DATA_DOMAIN = 'REFERENCE',
    MEDICORE_GOVERNANCE_DB.TAGS.ENVIRONMENT = 'DEV';

-- ============================================================================
-- STEP 7: EXECUTION SUMMARY
-- ============================================================================
SELECT 
    'DIM_DEPARTMENTS Transform Load Complete' AS status,
    'DEV' AS environment,
    CURRENT_TIMESTAMP() AS execution_timestamp,
    (SELECT COUNT(*) FROM MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_DEPARTMENTS) AS validated_record_count,
    (SELECT COUNT(*) 
       FROM MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_DEPARTMENTS_QUARANTINE 
       WHERE load_timestamp >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
    ) AS quarantined_record_count_last_hour;