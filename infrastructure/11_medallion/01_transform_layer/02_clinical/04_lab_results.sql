/*
================================================================================
File:           infrastructure/11_medallion/01_transform_layer/02_clinical/04_lab_results.sql
Purpose:        Silver/Transform layer - Lab results fact table with data 
                standardization, validation, and quarantine logic
Source Table:   MEDICORE_RAW_DB.DEV_CLINICAL.LAB_RESULTS
Target Table:   MEDICORE_TRANSFORM_DB.DEV_CLINICAL.LAB_RESULTS
Quarantine:     MEDICORE_TRANSFORM_DB.DEV_CLINICAL.LAB_RESULTS_QUARANTINE

Source Columns (RAW):
  - LAB_RESULT_ID (NUMBER)      -> lab_result_id (NUMBER, primary key)
  - ENCOUNTER_ID (NUMBER)       -> encounter_id (NUMBER, logical FK)
  - TEST_NAME (VARCHAR)         -> test_name (STRING, UPPER + TRIM)
  - RESULT_VALUE (VARCHAR)      -> result_value (STRING, TRIM - preserved as-is)
  - RESULT_UNIT (VARCHAR)       -> result_unit (STRING, TRIM)
  - RESULT_DATE (DATE)          -> result_date (DATE)
  - IS_ABNORMAL (BOOLEAN)       -> is_abnormal (BOOLEAN)
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
  - UPPERCASE test_name for standardization
  - Preserve result_value exactly (mixed numeric/text values)
  - Quarantine records with NULL lab_result_id, encounter_id, or result_date
  - Quarantine records with future result_date

Environment:    DEV (CI/CD will deploy to QA/PROD with schema substitution)

Owner:          Data Engineering
Pillar:         Pillar 2 - Clinical Insights (lab abnormality analysis)
                Future AI readiness - risk prediction, biomarker trends
Layer:          TRANSFORM (Silver)
Domain:         CLINICAL

Change History:
  Date        Author              Description
  ----------  ------------------  -----------------------------------------------
  2026-02-26  Data Engineering    Initial creation
================================================================================
*/

-- ============================================================================
-- SESSION CONFIGURATION
-- ============================================================================
USE ROLE MEDICORE_DATA_ENGINEER;
USE WAREHOUSE MEDICORE_ETL_WH;

-- ============================================================================
-- STEP 1: CREATE SILVER TABLE (Schema assumed to exist) (IF NOT EXISTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_CLINICAL.LAB_RESULTS (
    lab_result_id           NUMBER          NOT NULL    COMMENT 'Unique lab result ID (primary key)',
    encounter_id            NUMBER          NOT NULL    COMMENT 'Encounter reference (logical FK)',
    test_name               STRING                      COMMENT 'Lab test name - uppercase',
    result_value            STRING                      COMMENT 'Measured value (preserved as-is)',
    result_unit             STRING                      COMMENT 'Measurement unit',
    result_date             DATE                        COMMENT 'Test result date',
    is_abnormal             BOOLEAN                     COMMENT 'Abnormal result flag',
    created_at              TIMESTAMP_NTZ               COMMENT 'Original record creation timestamp',
    load_timestamp          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP() COMMENT 'ETL load timestamp',
    record_source           STRING          DEFAULT 'RAW_CLINICAL' COMMENT 'Source system identifier',
    data_quality_status     STRING          DEFAULT 'VALIDATED' COMMENT 'Data quality validation status',
    CONSTRAINT pk_lab_results PRIMARY KEY (lab_result_id)
)
COMMENT = 'Silver/Transform layer - Cleaned and validated lab results fact table';

-- ============================================================================
-- STEP 2: CREATE QUARANTINE TABLE (IF NOT EXISTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_CLINICAL.LAB_RESULTS_QUARANTINE (
    quarantine_id           STRING          DEFAULT UUID_STRING() COMMENT 'Unique quarantine record identifier',
    lab_result_id           NUMBER                      COMMENT 'Original lab_result_id (may be NULL)',
    encounter_id            NUMBER                      COMMENT 'Original encounter_id (may be NULL)',
    test_name               STRING                      COMMENT 'Original test_name',
    result_value            STRING                      COMMENT 'Original result_value',
    result_unit             STRING                      COMMENT 'Original result_unit',
    result_date             DATE                        COMMENT 'Original result_date',
    is_abnormal             BOOLEAN                     COMMENT 'Original is_abnormal flag',
    created_at              TIMESTAMP_NTZ               COMMENT 'Original created_at timestamp',
    failure_reason          STRING          NOT NULL    COMMENT 'Reason for quarantine',
    load_timestamp          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP() COMMENT 'Quarantine load timestamp'
)
COMMENT = 'Quarantine table for LAB_RESULTS records failing validation';

-- ============================================================================
-- STEP 3: MERGE QUARANTINED RECORDS
-- ============================================================================
MERGE INTO MEDICORE_TRANSFORM_DB.DEV_CLINICAL.LAB_RESULTS_QUARANTINE AS tgt
USING (
    SELECT
        src.lab_result_id,
        src.encounter_id,
        src.test_name,
        src.result_value,
        src.result_unit,
        src.result_date,
        src.is_abnormal,
        src.created_at,
        CASE
            WHEN src.lab_result_id IS NULL 
                THEN 'FAILED: lab_result_id IS NULL'
            WHEN src.encounter_id IS NULL 
                THEN 'FAILED: encounter_id IS NULL'
            WHEN src.result_date IS NULL 
                THEN 'FAILED: result_date IS NULL'
            WHEN src.result_date > CURRENT_DATE() 
                THEN 'FAILED: result_date is in future (' || src.result_date::STRING || ')'
            ELSE 'FAILED: Unknown validation error'
        END AS failure_reason,
        CURRENT_TIMESTAMP() AS load_timestamp
    FROM MEDICORE_RAW_DB.DEV_CLINICAL.LAB_RESULTS src
    WHERE 
        src.lab_result_id IS NULL
        OR src.encounter_id IS NULL
        OR src.result_date IS NULL
        OR src.result_date > CURRENT_DATE()
) AS src
ON tgt.lab_result_id = src.lab_result_id AND src.lab_result_id IS NOT NULL
WHEN MATCHED AND (
    tgt.failure_reason != src.failure_reason
    OR COALESCE(tgt.encounter_id, -1) != COALESCE(src.encounter_id, -1)
    OR COALESCE(tgt.result_date::STRING, '') != COALESCE(src.result_date::STRING, '')
) THEN UPDATE SET
    tgt.encounter_id    = src.encounter_id,
    tgt.test_name       = src.test_name,
    tgt.result_value    = src.result_value,
    tgt.result_unit     = src.result_unit,
    tgt.result_date     = src.result_date,
    tgt.is_abnormal     = src.is_abnormal,
    tgt.created_at      = src.created_at,
    tgt.failure_reason  = src.failure_reason,
    tgt.load_timestamp  = src.load_timestamp
WHEN NOT MATCHED THEN INSERT (
    lab_result_id, encounter_id, test_name, result_value, result_unit, 
    result_date, is_abnormal, created_at, failure_reason, load_timestamp
) VALUES (
    src.lab_result_id, src.encounter_id, src.test_name, src.result_value, src.result_unit,
    src.result_date, src.is_abnormal, src.created_at, src.failure_reason, src.load_timestamp
);

-- ============================================================================
-- STEP 4: MERGE VALIDATED RECORDS INTO SILVER TABLE
-- ============================================================================
MERGE INTO MEDICORE_TRANSFORM_DB.DEV_CLINICAL.LAB_RESULTS AS tgt
USING (
    SELECT
        src.lab_result_id                   AS lab_result_id,
        src.encounter_id                    AS encounter_id,
        UPPER(TRIM(src.test_name))          AS test_name,
        TRIM(src.result_value)              AS result_value,
        TRIM(src.result_unit)               AS result_unit,
        src.result_date                     AS result_date,
        src.is_abnormal                     AS is_abnormal,
        src.created_at                      AS created_at,
        CURRENT_TIMESTAMP()                 AS load_timestamp,
        'RAW_CLINICAL'                      AS record_source,
        'VALIDATED'                         AS data_quality_status
    FROM MEDICORE_RAW_DB.DEV_CLINICAL.LAB_RESULTS src
    WHERE 
        src.lab_result_id IS NOT NULL
        AND src.encounter_id IS NOT NULL
        AND src.result_date IS NOT NULL
        AND src.result_date <= CURRENT_DATE()
) AS src
ON tgt.lab_result_id = src.lab_result_id
WHEN MATCHED AND (
    tgt.encounter_id != src.encounter_id
    OR COALESCE(tgt.test_name, '') != COALESCE(src.test_name, '')
    OR COALESCE(tgt.result_value, '') != COALESCE(src.result_value, '')
    OR COALESCE(tgt.result_unit, '') != COALESCE(src.result_unit, '')
    OR COALESCE(tgt.result_date::STRING, '') != COALESCE(src.result_date::STRING, '')
    OR COALESCE(tgt.is_abnormal::STRING, '') != COALESCE(src.is_abnormal::STRING, '')
    OR COALESCE(tgt.created_at::STRING, '') != COALESCE(src.created_at::STRING, '')
) THEN UPDATE SET
    tgt.encounter_id        = src.encounter_id,
    tgt.test_name           = src.test_name,
    tgt.result_value        = src.result_value,
    tgt.result_unit         = src.result_unit,
    tgt.result_date         = src.result_date,
    tgt.is_abnormal         = src.is_abnormal,
    tgt.created_at          = src.created_at,
    tgt.load_timestamp      = src.load_timestamp,
    tgt.record_source       = src.record_source,
    tgt.data_quality_status = src.data_quality_status
WHEN NOT MATCHED THEN INSERT (
    lab_result_id, encounter_id, test_name, result_value, result_unit, 
    result_date, is_abnormal, created_at, load_timestamp, record_source, data_quality_status
) VALUES (
    src.lab_result_id, src.encounter_id, src.test_name, src.result_value, src.result_unit,
    src.result_date, src.is_abnormal, src.created_at, src.load_timestamp, src.record_source, src.data_quality_status
);

-- ============================================================================
-- STEP 5: APPLY GOVERNANCE TAGS
-- ============================================================================
ALTER TABLE MEDICORE_TRANSFORM_DB.DEV_CLINICAL.LAB_RESULTS
    SET TAG 
        MEDICORE_GOVERNANCE_DB.TAGS.MEDALLION_LAYER = 'TRANSFORM',
        MEDICORE_GOVERNANCE_DB.TAGS.DATA_DOMAIN = 'CLINICAL',
        MEDICORE_GOVERNANCE_DB.TAGS.ENVIRONMENT = 'DEV';

ALTER TABLE MEDICORE_TRANSFORM_DB.DEV_CLINICAL.LAB_RESULTS_QUARANTINE
    SET TAG 
        MEDICORE_GOVERNANCE_DB.TAGS.MEDALLION_LAYER = 'TRANSFORM',
        MEDICORE_GOVERNANCE_DB.TAGS.DATA_DOMAIN = 'CLINICAL',
        MEDICORE_GOVERNANCE_DB.TAGS.ENVIRONMENT = 'DEV';

-- ============================================================================
-- STEP 6: EXECUTION SUMMARY
-- ============================================================================
SELECT 
    'LAB_RESULTS Transform Load Complete' AS status,
    'DEV' AS environment,
    CURRENT_TIMESTAMP() AS execution_timestamp,
    (SELECT COUNT(*) FROM MEDICORE_TRANSFORM_DB.DEV_CLINICAL.LAB_RESULTS) AS validated_record_count,
    (SELECT COUNT(*) FROM MEDICORE_TRANSFORM_DB.DEV_CLINICAL.LAB_RESULTS_QUARANTINE 
     WHERE load_timestamp >= DATEADD('hour', -1, CURRENT_TIMESTAMP())) AS quarantined_record_count_last_hour;
