import streamlit as st
from snowflake.snowpark.context import get_active_session
import pandas as pd

st.set_page_config(layout="wide")

session = get_active_session()

@st.cache_data
def load_encounter_kpis(_session, start_date, end_date, departments, encounter_types):
    dept_filter = ""
    if departments:
        dept_list = ",".join([f"'{d}'" for d in departments])
        dept_filter = f"AND e.DEPARTMENT_NAME IN ({dept_list})"
    
    type_filter = ""
    if encounter_types:
        type_list = ",".join([f"'{t}'" for t in encounter_types])
        type_filter = f"AND e.ENCOUNTER_TYPE IN ({type_list})"
    
    sql = f"""
    SELECT 
        COUNT(*) AS TOTAL_ENCOUNTERS,
        SUM(CASE WHEN e.IS_INPATIENT_FLAG = TRUE THEN 1 ELSE 0 END) AS INPATIENT_ENCOUNTERS,
        COALESCE(AVG(e.LENGTH_OF_STAY_DAYS), 0) AS AVG_LOS
    FROM MEDICORE_ANALYTICS_DB.DEV_CLINICAL.ENCOUNTERS e
    WHERE e.ADMISSION_DATE >= '{start_date}'
      AND e.ADMISSION_DATE <= '{end_date}'
      {dept_filter}
      {type_filter}
    """
    return _session.sql(sql).to_pandas()

@st.cache_data
def load_encounter_trend(_session, start_date, end_date, departments, encounter_types):
    dept_filter = ""
    if departments:
        dept_list = ",".join([f"'{d}'" for d in departments])
        dept_filter = f"AND e.DEPARTMENT_NAME IN ({dept_list})"
    
    type_filter = ""
    if encounter_types:
        type_list = ",".join([f"'{t}'" for t in encounter_types])
        type_filter = f"AND e.ENCOUNTER_TYPE IN ({type_list})"
    
    sql = f"""
    SELECT 
        e.ENCOUNTER_MONTH AS MONTH_KEY,
        COUNT(*) AS TOTAL_ENCOUNTERS,
        SUM(CASE WHEN e.IS_INPATIENT_FLAG = TRUE THEN 1 ELSE 0 END) AS INPATIENT,
        SUM(CASE WHEN e.IS_OUTPATIENT_FLAG = TRUE THEN 1 ELSE 0 END) AS OUTPATIENT
    FROM MEDICORE_ANALYTICS_DB.DEV_CLINICAL.ENCOUNTERS e
    WHERE e.ADMISSION_DATE >= '{start_date}'
      AND e.ADMISSION_DATE <= '{end_date}'
      {dept_filter}
      {type_filter}
    GROUP BY e.ENCOUNTER_MONTH
    ORDER BY MONTH_KEY
    """
    return _session.sql(sql).to_pandas()

@st.cache_data
def load_department_workload(_session, start_date, end_date, departments, encounter_types):
    dept_filter = ""
    if departments:
        dept_list = ",".join([f"'{d}'" for d in departments])
        dept_filter = f"AND e.DEPARTMENT_NAME IN ({dept_list})"
    
    type_filter = ""
    if encounter_types:
        type_list = ",".join([f"'{t}'" for t in encounter_types])
        type_filter = f"AND e.ENCOUNTER_TYPE IN ({type_list})"
    
    sql = f"""
    SELECT 
        COALESCE(e.DEPARTMENT_NAME, 'Unknown') AS DEPARTMENT_NAME,
        COUNT(*) AS ENCOUNTER_COUNT
    FROM MEDICORE_ANALYTICS_DB.DEV_CLINICAL.ENCOUNTERS e
    WHERE e.ADMISSION_DATE >= '{start_date}'
      AND e.ADMISSION_DATE <= '{end_date}'
      {dept_filter}
      {type_filter}
    GROUP BY e.DEPARTMENT_NAME
    ORDER BY ENCOUNTER_COUNT DESC
    LIMIT 10
    """
    return _session.sql(sql).to_pandas()

@st.cache_data
def load_clinical_quality_trend(_session, start_date, end_date, departments, encounter_types):
    dept_filter = ""
    if departments:
        dept_list = ",".join([f"'{d}'" for d in departments])
        dept_filter = f"AND e.DEPARTMENT_NAME IN ({dept_list})"
    
    type_filter = ""
    if encounter_types:
        type_list = ",".join([f"'{t}'" for t in encounter_types])
        type_filter = f"AND e.ENCOUNTER_TYPE IN ({type_list})"
    
    sql = f"""
    SELECT 
        e.ENCOUNTER_MONTH AS MONTH_KEY,
        COALESCE(AVG(e.LENGTH_OF_STAY_DAYS), 0) AS AVG_LOS
    FROM MEDICORE_ANALYTICS_DB.DEV_CLINICAL.ENCOUNTERS e
    WHERE e.ADMISSION_DATE >= '{start_date}'
      AND e.ADMISSION_DATE <= '{end_date}'
      {dept_filter}
      {type_filter}
    GROUP BY e.ENCOUNTER_MONTH
    ORDER BY MONTH_KEY
    """
    return _session.sql(sql).to_pandas()

@st.cache_data
def load_abnormal_lab_trend(_session, start_date, end_date, departments):
    dept_filter = ""
    if departments:
        dept_list = ",".join([f"'{d}'" for d in departments])
        dept_filter = f"AND e.DEPARTMENT_NAME IN ({dept_list})"
    
    sql = f"""
    SELECT 
        lr.RESULT_MONTH AS MONTH_KEY,
        COALESCE(SUM(CASE WHEN lr.IS_ABNORMAL = TRUE THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 0) AS ABNORMAL_RATE
    FROM MEDICORE_ANALYTICS_DB.DEV_CLINICAL.LAB_RESULTS lr
    LEFT JOIN MEDICORE_ANALYTICS_DB.DEV_CLINICAL.ENCOUNTERS e 
        ON lr.ENCOUNTER_ID = e.ENCOUNTER_ID
    WHERE lr.RESULT_DATE >= '{start_date}'
      AND lr.RESULT_DATE <= '{end_date}'
      {dept_filter}
    GROUP BY lr.RESULT_MONTH
    ORDER BY MONTH_KEY
    """
    return _session.sql(sql).to_pandas()

@st.cache_data
def load_departments(_session):
    sql = """
    SELECT DISTINCT DEPARTMENT_NAME 
    FROM MEDICORE_ANALYTICS_DB.DEV_CLINICAL.ENCOUNTERS 
    WHERE DEPARTMENT_NAME IS NOT NULL
    ORDER BY DEPARTMENT_NAME
    """
    return _session.sql(sql).to_pandas()["DEPARTMENT_NAME"].tolist()

@st.cache_data
def load_encounter_types(_session):
    sql = """
    SELECT DISTINCT ENCOUNTER_TYPE 
    FROM MEDICORE_ANALYTICS_DB.DEV_CLINICAL.ENCOUNTERS 
    WHERE ENCOUNTER_TYPE IS NOT NULL
    ORDER BY ENCOUNTER_TYPE
    """
    return _session.sql(sql).to_pandas()["ENCOUNTER_TYPE"].tolist()

st.title("MediCore Clinical Operations Dashboard")

st.sidebar.header("Filters")

departments_list = load_departments(session)
encounter_types_list = load_encounter_types(session)

date_range = st.sidebar.date_input(
    "Date Range",
    value=(pd.to_datetime("2025-01-01"), pd.to_datetime("2025-12-31")),
    key="date_range"
)

if isinstance(date_range, tuple) and len(date_range) == 2:
    start_date = date_range[0].strftime("%Y-%m-%d")
    end_date = date_range[1].strftime("%Y-%m-%d")
else:
    start_date = "2025-01-01"
    end_date = "2025-12-31"

selected_departments = st.sidebar.multiselect(
    "Departments",
    options=departments_list,
    default=[],
    key="departments"
)

selected_encounter_types = st.sidebar.multiselect(
    "Encounter Types",
    options=encounter_types_list,
    default=[],
    key="encounter_types"
)

kpis = load_encounter_kpis(session, start_date, end_date, selected_departments, selected_encounter_types)

st.subheader("Key Performance Indicators")
col1, col2, col3 = st.columns(3)

with col1:
    total_enc = int(kpis["TOTAL_ENCOUNTERS"].iloc[0]) if not kpis.empty else 0
    st.metric("Total Encounters", f"{total_enc:,}")

with col2:
    inpatient_enc = int(kpis["INPATIENT_ENCOUNTERS"].iloc[0]) if not kpis.empty else 0
    st.metric("Inpatient Encounters", f"{inpatient_enc:,}")

with col3:
    avg_los = float(kpis["AVG_LOS"].iloc[0]) if not kpis.empty else 0.0
    st.metric("Avg Length of Stay", f"{avg_los:.1f} days")

st.divider()

st.subheader("Encounter Trend")
encounter_trend = load_encounter_trend(session, start_date, end_date, selected_departments, selected_encounter_types)

if not encounter_trend.empty:
    encounter_trend["MONTH_KEY"] = pd.to_datetime(encounter_trend["MONTH_KEY"])
    trend_melted = encounter_trend.melt(
        id_vars=["MONTH_KEY"],
        value_vars=["INPATIENT", "OUTPATIENT"],
        var_name="Type",
        value_name="Count"
    )
    st.line_chart(trend_melted, x="MONTH_KEY", y="Count", color="Type")
else:
    st.info("No encounter trend data available for the selected filters.")

st.divider()

st.subheader("Department Workload (Top 10)")
dept_workload = load_department_workload(session, start_date, end_date, selected_departments, selected_encounter_types)

if not dept_workload.empty:
    st.bar_chart(dept_workload, x="DEPARTMENT_NAME", y="ENCOUNTER_COUNT")
else:
    st.info("No department workload data available for the selected filters.")

st.divider()

st.subheader("Clinical Quality Trends - Average Length of Stay")
quality_trend = load_clinical_quality_trend(session, start_date, end_date, selected_departments, selected_encounter_types)

if not quality_trend.empty:
    quality_trend["MONTH_KEY"] = pd.to_datetime(quality_trend["MONTH_KEY"])
    st.line_chart(quality_trend, x="MONTH_KEY", y="AVG_LOS")
else:
    st.info("No clinical quality data available for the selected filters.")

st.divider()

st.subheader("Lab Monitoring - Abnormal Results Rate (%)")
lab_trend = load_abnormal_lab_trend(session, start_date, end_date, selected_departments)

if not lab_trend.empty:
    lab_trend["MONTH_KEY"] = pd.to_datetime(lab_trend["MONTH_KEY"])
    st.line_chart(lab_trend, x="MONTH_KEY", y="ABNORMAL_RATE")
else:
    st.info("No lab monitoring data available for the selected filters.")