# MediCore Health Systems — Role Hierarchy Design  
Version: 1.0  
Date: February 2026  
Status: Draft — Pending Review  

---

# PART 2 — ROLE HIERARCHY DESIGN

## Overview

MediCore's RBAC model implements least-privilege with role inheritance.  
The hierarchy separates:

- Data access roles
- Administrative system roles

PHI access is strictly controlled via hierarchy + masking + row policies.

---

# 2.1 Role Naming Convention

## Standard Format

MEDICORE_<FUNCTION>_<ACCESS_LEVEL>

Example:

MEDICORE_CLINICAL_PHYSICIAN  
MEDICORE_ANALYST_RESTRICTED  

---

## Special Prefixes

| Prefix | Purpose | Example |
|---|---|---|
| MEDICORE_SVC_ | Service accounts | MEDICORE_SVC_ETL_LOADER |
| MEDICORE_EXT_ | External temporary | MEDICORE_EXT_AUDITOR |
| MEDICORE_APP_ | Application roles | MEDICORE_APP_STREAMLIT |

---

# 2.2 Complete Role Indices

## Tier 1 — Administrative

- MEDICORE_PLATFORM_ADMIN  
- MEDICORE_SECURITY_ADMIN  

Platform → Account management only  
Security → tags, masking, audit only  

Neither can directly query PHI.

---

## Tier 2 — Data Engineering

- MEDICORE_DATA_ENGINEER  
- MEDICORE_SVC_ETL_LOADER  

Engineers:

- Full RAW + TRANSFORM
- Read analytics
- Cannot manage security policies

Service loader:

- Write only to pipeline schemas
- No interactive access

---

## Tier 3 — Clinical Roles

- MEDICORE_CLINICAL_PHYSICIAN  
- MEDICORE_CLINICAL_NURSE  
- MEDICORE_CLINICAL_READER  

Hierarchy:

PHYSICIAN → NURSE → READER → REFERENCE  

Physician:

- Full clinical PHI

Nurse:

- Unit-restricted
- Financial identifiers masked

Reader:

- Name + MRN only

---

## Tier 4 — Revenue Cycle

- MEDICORE_BILLING_SPECIALIST  
- MEDICORE_BILLING_READER  

Specialist:

- Diagnosis codes visible
- Notes masked

Reader:

- Aggregates only

---

## Tier 5 — Analytics

- MEDICORE_ANALYST_PHI  
- MEDICORE_ANALYST_RESTRICTED  
- MEDICORE_DATA_SCIENTIST  

Restricted:

- Only de-identified datasets

PHI Analyst:

- Patient-level data allowed

Data Scientist:

- Full AI_READY_DB
- Read analytics + transform

---

## Tier 6 — Compliance & Audit

- MEDICORE_COMPLIANCE_OFFICER  
- MEDICORE_EXT_AUDITOR  

Compliance:

- Full read everywhere
- Audit logs access

External auditor:

- Pre-staged extracts only
- All PHI masked
- Time-limited

---

## Tier 7 — Executive & Base

- MEDICORE_EXECUTIVE  
- MEDICORE_REFERENCE_READER  

Executive:

- KPI dashboards only

Reference:

- Lookup tables only

---

## Tier 8 — Application Roles

- MEDICORE_APP_STREAMLIT  

Uses invoking user role OR fixed deployment role.

---

# 2.3 Logical Hierarchy (Simplified)

ACCOUNTADMIN  
→ PLATFORM_ADMIN  

SECURITYADMIN  
→ SECURITY_ADMIN  

DATA_ACCESS_TREE:

REFERENCE_READER  
→ ANALYST_RESTRICTED  
→ ANALYST_PHI  
→ DATA_ENGINEER  

REFERENCE_READER  
→ CLINICAL_READER  
→ CLINICAL_NURSE  
→ CLINICAL_PHYSICIAN  

REFERENCE_READER  
→ BILLING_READER  
→ BILLING_SPECIALIST  

Standalone:

- SVC_ETL_LOADER  
- EXT_AUDITOR  
- APP_STREAMLIT  

---

# 2.4 Role → Warehouse Mapping

| Role Group | Warehouse |
|---|---|
| Admin | ADMIN_WH |
| Engineers | ETL_WH |
| Analysts / Clinical / Billing | ANALYTICS_WH |
| Data Scientists | ML_WH |

---

# 2.5 Role Summary Highlights

| Role | PHI | RAW | TRANSFORM | ANALYTICS | AI_READY |
|---|---|---|---|---|---|
| DATA_ENGINEER | Full | Yes | Yes | Read | Read |
| CLINICAL_PHYSICIAN | Full | No | No | Yes | No |
| ANALYST_RESTRICTED | None | No | No | DeID | No |
| DATA_SCIENTIST | Full | No | Read | Yes | Full |
| EXECUTIVE | None | No | No | Aggregate | No |

---

# 2.6 Role Count

| Category | Count |
|---|---|
| Administrative | 2 |
| Engineering | 2 |
| Clinical | 3 |
| Revenue Cycle | 2 |
| Analytics | 3 |
| Compliance | 2 |
| Executive/Base | 2 |
| Application | 1 |

**Total Roles: 17**

---

# Appendix A — Design Decisions

- No tag prefix required
- All roles use MEDICORE_ prefix
- Admin roles separated for HIPAA segregation
- Service accounts isolated
- 42 CFR Part 2 handled via subdomain tagging
- Executives restricted to aggregates

---

# Appendix B — Next Steps

- Approve taxonomy  
- Approve hierarchy  
- Define masking policy SQL  
- Define row access SQL  
- Begin Phase-1 Snowflake implementation  

---