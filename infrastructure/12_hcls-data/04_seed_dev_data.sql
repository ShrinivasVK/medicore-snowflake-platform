-- ============================================================
-- Phase 12 - HCLS Data Model
-- File: 04_seed_dev_data.sql
-- Purpose: Populate DEV RAW tables with synthetic messy data
-- ============================================================

USE DATABASE MEDICORE_RAW_DB;

-- ============================================================
-- 1️⃣ REFERENCE TABLES (NO DEPENDENCIES)
-- ============================================================

USE SCHEMA DEV_REFERENCE;

-- ------------------------
-- DIM_DEPARTMENTS
-- ------------------------

INSERT INTO MEDICORE_RAW_DB.DEV_REFERENCE.DIM_DEPARTMENTS
SELECT
    SEQ4() + 1,
    CASE 
        WHEN UNIFORM(1,10,RANDOM()) < 3 THEN NULL
        ELSE ARRAY_CONSTRUCT(
            'Emergency Department', 'Cardiology', 'Oncology', 'Pediatrics', 
            'Orthopedics', 'Neurology', 'Radiology', 'Pathology',
            'Internal Medicine', 'General Surgery', 'ICU', 'Labor & Delivery',
            'Pharmacy', 'Physical Therapy', 'Psychiatry'
        )[MOD(SEQ4(), 15)]::STRING
    END,
    CASE 
        WHEN UNIFORM(1,10,RANDOM()) < 4 THEN LOWER('fac_' || UNIFORM(1,5,RANDOM()))
        ELSE 'FAC-' || UNIFORM(1,5,RANDOM())
    END,
    UNIFORM(0,1,RANDOM())::BOOLEAN,
    DATEADD(DAY, -UNIFORM(1,365,RANDOM()), CURRENT_TIMESTAMP())
FROM TABLE(GENERATOR(ROWCOUNT => 15));


-- ------------------------
-- DIM_ICD10_CODES
-- ------------------------

INSERT INTO MEDICORE_RAW_DB.DEV_REFERENCE.DIM_ICD10_CODES
SELECT
    CONCAT('A', LPAD(SEQ4()::VARCHAR,3,'0')),
    CASE 
        WHEN UNIFORM(1,10,RANDOM()) < 3 THEN NULL
        ELSE ARRAY_CONSTRUCT(
            'Acute myocardial infarction', 'Type 2 diabetes mellitus', 'Essential hypertension',
            'Chronic kidney disease', 'Congestive heart failure', 'Atrial fibrillation',
            'Pneumonia', 'Urinary tract infection', 'Sepsis', 'Acute bronchitis',
            'Osteoarthritis', 'COPD exacerbation', 'Anemia', 'Hypothyroidism', 'Hyperlipidemia',
            'Chest pain', 'Shortness of breath', 'Abdominal pain', 'Back pain', 'Headache'
        )[MOD(SEQ4(), 20)]::STRING
    END,
    CASE 
        WHEN UNIFORM(1,10,RANDOM()) < 4 THEN 'cardiology'
        ELSE 'General'
    END,
    UNIFORM(0,1,RANDOM())::BOOLEAN,
    CURRENT_TIMESTAMP()
FROM TABLE(GENERATOR(ROWCOUNT => 200));


-- ============================================================
-- 2️⃣ CLINICAL PARENT TABLES
-- ============================================================

USE SCHEMA DEV_CLINICAL;

-- ------------------------
-- PATIENTS
-- ------------------------

INSERT INTO MEDICORE_RAW_DB.DEV_CLINICAL.PATIENTS
SELECT
    SEQ4() + 1,
    CASE 
        WHEN UNIFORM(1,10,RANDOM()) < 2 THEN NULL
        ELSE CONCAT('MRN', UNIFORM(10000,99999,RANDOM()))
    END,
    ARRAY_CONSTRUCT(
        'James', 'Mary', 'Robert', 'Patricia', 'John', 'Jennifer', 'Michael', 'Linda',
        'David', 'Elizabeth', 'William', 'Barbara', 'Richard', 'Susan', 'Joseph', 'Jessica',
        'Thomas', 'Sarah', 'Christopher', 'Karen', 'Charles', 'Lisa', 'Daniel', 'Nancy',
        'Matthew', 'Betty', 'Anthony', 'Margaret', 'Mark', 'Sandra', 'Donald', 'Ashley',
        'Steven', 'Kimberly', 'Paul', 'Emily', 'Andrew', 'Donna', 'Joshua', 'Michelle'
    )[MOD(SEQ4(), 40)]::STRING,
    ARRAY_CONSTRUCT(
        'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis',
        'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson',
        'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Perez', 'Thompson',
        'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson', 'Walker',
        'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores'
    )[MOD(SEQ4(), 40)]::STRING,
    DATEADD(YEAR, -UNIFORM(1,90,RANDOM()), CURRENT_DATE()),
    CASE 
        WHEN UNIFORM(1,10,RANDOM()) < 4 THEN 'M'
        WHEN UNIFORM(1,10,RANDOM()) < 7 THEN 'F'
        ELSE 'unknown'
    END,
    CASE 
        WHEN UNIFORM(1,10,RANDOM()) < 3 THEN '123-456'
        ELSE CONCAT('98', UNIFORM(10000000,99999999,RANDOM()))
    END,
    CASE 
        WHEN UNIFORM(1,10,RANDOM()) < 3 THEN '123'
        ELSE LPAD(UNIFORM(10000,99999,RANDOM())::VARCHAR,5,'0')
    END,
    CURRENT_TIMESTAMP()
FROM TABLE(GENERATOR(ROWCOUNT => 5000));


-- ------------------------
-- PROVIDERS
-- ------------------------

INSERT INTO MEDICORE_RAW_DB.DEV_CLINICAL.PROVIDERS
SELECT
    SEQ4() + 1,
    CONCAT(
        ARRAY_CONSTRUCT('Dr. ', 'Dr. ', 'Dr. ', '')[MOD(SEQ4(), 4)]::STRING,
        ARRAY_CONSTRUCT(
            'James', 'Mary', 'Robert', 'Patricia', 'John', 'Jennifer', 'Michael', 'Linda',
            'David', 'Elizabeth', 'William', 'Barbara', 'Richard', 'Susan', 'Joseph', 'Jessica',
            'Thomas', 'Sarah', 'Christopher', 'Karen', 'Charles', 'Lisa', 'Daniel', 'Nancy',
            'Matthew', 'Betty', 'Anthony', 'Margaret', 'Mark', 'Sandra', 'Donald', 'Ashley',
            'Steven', 'Kimberly', 'Paul', 'Emily', 'Andrew', 'Donna', 'Joshua', 'Michelle'
        )[MOD(SEQ4(), 40)]::STRING,
        ' ',
        ARRAY_CONSTRUCT(
            'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis',
            'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson',
            'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Perez', 'Thompson',
            'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson', 'Walker',
            'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores'
        )[MOD(SEQ4() + 7, 40)]::STRING,
        ARRAY_CONSTRUCT(', MD', ', DO', ', MD, PhD', ', MD')[MOD(SEQ4(), 4)]::STRING
    ),
    CASE 
        WHEN UNIFORM(1,10,RANDOM()) < 5 THEN 'Cardiology'
        ELSE 'internal medicine'
    END,
    UNIFORM(1,15,RANDOM()),
    CURRENT_TIMESTAMP()
FROM TABLE(GENERATOR(ROWCOUNT => 100));


-- ------------------------
--  ENCOUNTERS
-- ------------------------

INSERT INTO MEDICORE_RAW_DB.DEV_CLINICAL.ENCOUNTERS
SELECT
    SEQ4() + 1,
    UNIFORM(1,5000,RANDOM()),      -- some invalid possible
    UNIFORM(1,100,RANDOM()),
    UNIFORM(1,15,RANDOM()),
    DATEADD(DAY, -UNIFORM(1,1000,RANDOM()), CURRENT_DATE()),
    DATEADD(DAY, UNIFORM(0,10,RANDOM()), CURRENT_DATE()),
    CASE 
        WHEN UNIFORM(1,10,RANDOM()) < 5 THEN 'INPATIENT'
        ELSE 'outpatient'
    END,
    CONCAT('A', LPAD(UNIFORM(1,200,RANDOM())::VARCHAR,3,'0')),
    CURRENT_TIMESTAMP()
FROM TABLE(GENERATOR(ROWCOUNT => 20000));


-- ------------------------
-- LAB RESULTS
-- ------------------------

INSERT INTO MEDICORE_RAW_DB.DEV_CLINICAL.LAB_RESULTS
SELECT
    SEQ4() + 1,
    UNIFORM(1,20000,RANDOM()),
    CASE 
        WHEN UNIFORM(1,10,RANDOM()) < 5 THEN 'HbA1c'
        ELSE 'Glucose'
    END,
    CASE 
        WHEN UNIFORM(1,10,RANDOM()) < 3 THEN '??'
        ELSE UNIFORM(70,200,RANDOM())::VARCHAR
    END,
    CASE 
        WHEN UNIFORM(1,10,RANDOM()) < 4 THEN NULL
        ELSE 'mg/dL'
    END,
    DATEADD(DAY, -UNIFORM(1,365,RANDOM()), CURRENT_DATE()),
    UNIFORM(0,1,RANDOM())::BOOLEAN,
    CURRENT_TIMESTAMP()
FROM TABLE(GENERATOR(ROWCOUNT => 50000));


-- ============================================================
-- 3️⃣ BILLING
-- ============================================================

USE SCHEMA DEV_BILLING;

-- ------------------------
-- CLAIMS
-- ------------------------

INSERT INTO MEDICORE_RAW_DB.DEV_BILLING.CLAIMS
SELECT
    SEQ4() + 1,
    UNIFORM(1,20000,RANDOM()),
    UNIFORM(1,5000,RANDOM()),
    UNIFORM(100,10000,RANDOM()),
    CASE 
        WHEN UNIFORM(1,10,RANDOM()) < 3 THEN 'denied'
        WHEN UNIFORM(1,10,RANDOM()) < 6 THEN 'APPROVED'
        ELSE 'submitted'
    END,
    CASE 
        WHEN UNIFORM(1,10,RANDOM()) < 5 THEN 'COMMERCIAL'
        ELSE 'medicare'
    END,
    DATEADD(DAY, -UNIFORM(1,365,RANDOM()), CURRENT_DATE()),
    CURRENT_TIMESTAMP()
FROM TABLE(GENERATOR(ROWCOUNT => 15000));


-- ------------------------
-- CLAIM_LINE_ITEMS
-- ------------------------

INSERT INTO MEDICORE_RAW_DB.DEV_BILLING.CLAIM_LINE_ITEMS
SELECT
    SEQ4() + 1,
    UNIFORM(1,15000,RANDOM()),
    CONCAT('PROC_', UNIFORM(100,999,RANDOM())),
    UNIFORM(50,2000,RANDOM()),
    UNIFORM(1,5,RANDOM()),
    CURRENT_TIMESTAMP()
FROM TABLE(GENERATOR(ROWCOUNT => 40000));