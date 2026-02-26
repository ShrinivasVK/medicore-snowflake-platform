MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PATIENTS

Key Findings
- Single root cause — All 450 failures are due to missing MRN
- Uniform distribution (~6-11%) across all patient_id ranges — not a batch issue
- No secondary issues — All quarantined records have valid names, DOB within range
- Gender skew — Slightly higher quarantine rate for Female and Unknown gender

Recommendation

The ~9% NULL MRN rate is systemic across the entire dataset, suggesting:

- Patient registration workflow allows MRN-less records
- Possible pre-registration or incomplete intake records
- Recommend upstream validation at point of entry or MRN generation process review
