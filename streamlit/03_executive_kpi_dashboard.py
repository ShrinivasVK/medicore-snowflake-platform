import streamlit as st
from snowflake.snowpark.context import get_active_session
import pandas as pd

st.set_page_config(layout="wide", page_title="MediCore Executive Dashboard")

session = get_active_session()

@st.cache_data
def load_executive_snapshot(_session, start_date, end_date):
    sql = f"""
    WITH patient_data AS (
        SELECT 
            COALESCE(SUM(TOTAL_DISTINCT_PATIENTS), 0) AS TOTAL_PATIENTS,
            COALESCE(SUM(TOTAL_ENCOUNTERS), 0) AS TOTAL_ENCOUNTERS
        FROM MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.KPI_PATIENT_VOLUME
        WHERE MONTH_KEY >= '{start_date}' AND MONTH_KEY <= '{end_date}'
    ),
    revenue_data AS (
        SELECT 
            COALESCE(SUM(TOTAL_NET_REVENUE), 0) AS TOTAL_NET_REVENUE,
            COALESCE(AVG(DENIAL_RATE_PERCENT), 0) AS AVG_DENIAL_RATE
        FROM MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.KPI_REVENUE_SUMMARY
        WHERE MONTH_KEY >= '{start_date}' AND MONTH_KEY <= '{end_date}'
    ),
    clinical_data AS (
        SELECT 
            COALESCE(AVG(READMISSION_RATE_PERCENT), 0) AS AVG_READMISSION_RATE,
            COALESCE(AVG(AVERAGE_LENGTH_OF_STAY), 0) AS AVG_LOS
        FROM MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.KPI_CLINICAL_OUTCOMES
        WHERE MONTH_KEY >= '{start_date}' AND MONTH_KEY <= '{end_date}'
    )
    SELECT 
        p.TOTAL_PATIENTS,
        p.TOTAL_ENCOUNTERS,
        r.TOTAL_NET_REVENUE,
        r.AVG_DENIAL_RATE,
        c.AVG_READMISSION_RATE,
        c.AVG_LOS
    FROM patient_data p, revenue_data r, clinical_data c
    """
    return _session.sql(sql).to_pandas()

@st.cache_data
def load_patient_trend(_session, start_date, end_date, show_growth):
    growth_col = ""
    if show_growth:
        growth_col = """,
            COALESCE(
                (TOTAL_DISTINCT_PATIENTS - LAG(TOTAL_DISTINCT_PATIENTS) OVER (ORDER BY MONTH_KEY)) 
                * 100.0 / NULLIF(LAG(TOTAL_DISTINCT_PATIENTS) OVER (ORDER BY MONTH_KEY), 0), 
                0
            ) AS PATIENT_GROWTH_PCT"""
    
    sql = f"""
    SELECT 
        MONTH_KEY,
        COALESCE(TOTAL_DISTINCT_PATIENTS, 0) AS TOTAL_PATIENTS,
        COALESCE(TOTAL_ENCOUNTERS, 0) AS TOTAL_ENCOUNTERS{growth_col}
    FROM MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.KPI_PATIENT_VOLUME
    WHERE MONTH_KEY >= '{start_date}' AND MONTH_KEY <= '{end_date}'
    ORDER BY MONTH_KEY
    """
    return _session.sql(sql).to_pandas()

@st.cache_data
def load_revenue_trend(_session, start_date, end_date, show_growth):
    growth_col = ""
    if show_growth:
        growth_col = """,
            COALESCE(
                (TOTAL_NET_REVENUE - LAG(TOTAL_NET_REVENUE) OVER (ORDER BY MONTH_KEY)) 
                * 100.0 / NULLIF(LAG(TOTAL_NET_REVENUE) OVER (ORDER BY MONTH_KEY), 0), 
                0
            ) AS REVENUE_GROWTH_PCT"""
    
    sql = f"""
    SELECT 
        MONTH_KEY,
        COALESCE(TOTAL_BILLED_AMOUNT, 0) AS BILLED,
        COALESCE(TOTAL_PAID_AMOUNT, 0) AS PAID,
        COALESCE(TOTAL_NET_REVENUE, 0) AS NET_REVENUE{growth_col}
    FROM MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.KPI_REVENUE_SUMMARY
    WHERE MONTH_KEY >= '{start_date}' AND MONTH_KEY <= '{end_date}'
    ORDER BY MONTH_KEY
    """
    return _session.sql(sql).to_pandas()

@st.cache_data
def load_clinical_trend(_session, start_date, end_date):
    sql = f"""
    SELECT 
        MONTH_KEY,
        COALESCE(AVERAGE_LENGTH_OF_STAY, 0) AS AVG_LOS,
        COALESCE(READMISSION_RATE_PERCENT, 0) AS READMISSION_RATE
    FROM MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.KPI_CLINICAL_OUTCOMES
    WHERE MONTH_KEY >= '{start_date}' AND MONTH_KEY <= '{end_date}'
    ORDER BY MONTH_KEY
    """
    return _session.sql(sql).to_pandas()

st.title("MediCore Executive Dashboard")

st.sidebar.header("Filters")

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

show_growth = st.sidebar.toggle("Show Growth Metrics", value=False)

snapshot = load_executive_snapshot(session, start_date, end_date)

st.subheader("Executive Snapshot")

row1_col1, row1_col2, row1_col3 = st.columns(3)

with row1_col1:
    total_patients = int(snapshot["TOTAL_PATIENTS"].iloc[0]) if not snapshot.empty else 0
    st.metric("Total Patients", f"{total_patients:,}")

with row1_col2:
    total_encounters = int(snapshot["TOTAL_ENCOUNTERS"].iloc[0]) if not snapshot.empty else 0
    st.metric("Total Encounters", f"{total_encounters:,}")

with row1_col3:
    net_revenue = int(snapshot["TOTAL_NET_REVENUE"].iloc[0]) if not snapshot.empty else 0
    st.metric("Total Net Revenue", f"${net_revenue:,}")

row2_col1, row2_col2, row2_col3 = st.columns(3)

with row2_col1:
    denial_rate = float(snapshot["AVG_DENIAL_RATE"].iloc[0]) if not snapshot.empty else 0.0
    st.metric("Denial Rate", f"{denial_rate:.2f}%")

with row2_col2:
    readmission_rate = float(snapshot["AVG_READMISSION_RATE"].iloc[0]) if not snapshot.empty else 0.0
    st.metric("Readmission Rate", f"{readmission_rate:.2f}%")

with row2_col3:
    avg_los = float(snapshot["AVG_LOS"].iloc[0]) if not snapshot.empty else 0.0
    st.metric("Avg Length of Stay", f"{avg_los:.1f} days")

st.divider()

st.subheader("Growth Trends")
col_patient, col_revenue = st.columns(2)

with col_patient:
    st.caption("Monthly Patient Volume")
    patient_trend = load_patient_trend(session, start_date, end_date, show_growth)
    if not patient_trend.empty:
        patient_trend["MONTH_KEY"] = pd.to_datetime(patient_trend["MONTH_KEY"])
        st.line_chart(patient_trend, x="MONTH_KEY", y="TOTAL_PATIENTS")
        if show_growth and "PATIENT_GROWTH_PCT" in patient_trend.columns:
            st.caption("Patient Growth % (MoM)")
            st.line_chart(patient_trend, x="MONTH_KEY", y="PATIENT_GROWTH_PCT")
    else:
        st.info("No patient data available.")

with col_revenue:
    st.caption("Monthly Net Revenue")
    revenue_trend = load_revenue_trend(session, start_date, end_date, show_growth)
    if not revenue_trend.empty:
        revenue_trend["MONTH_KEY"] = pd.to_datetime(revenue_trend["MONTH_KEY"])
        st.area_chart(revenue_trend, x="MONTH_KEY", y="NET_REVENUE")
        if show_growth and "REVENUE_GROWTH_PCT" in revenue_trend.columns:
            st.caption("Revenue Growth % (MoM)")
            st.line_chart(revenue_trend, x="MONTH_KEY", y="REVENUE_GROWTH_PCT")
    else:
        st.info("No revenue data available.")

st.divider()

st.subheader("Efficiency Indicators")
clinical_trend = load_clinical_trend(session, start_date, end_date)

if not clinical_trend.empty:
    clinical_trend["MONTH_KEY"] = pd.to_datetime(clinical_trend["MONTH_KEY"])
    col_los, col_readmit = st.columns(2)
    
    with col_los:
        st.caption("Average Length of Stay (Days)")
        st.line_chart(clinical_trend, x="MONTH_KEY", y="AVG_LOS")
    
    with col_readmit:
        st.caption("Readmission Rate (%)")
        st.line_chart(clinical_trend, x="MONTH_KEY", y="READMISSION_RATE")
else:
    st.info("No clinical efficiency data available.")

st.divider()

st.subheader("Financial Health")
if not revenue_trend.empty:
    revenue_trend["MONTH_KEY"] = pd.to_datetime(revenue_trend["MONTH_KEY"])
    revenue_melted = revenue_trend.melt(
        id_vars=["MONTH_KEY"],
        value_vars=["BILLED", "PAID", "NET_REVENUE"],
        var_name="Type",
        value_name="Amount"
    )
    st.bar_chart(revenue_melted, x="MONTH_KEY", y="Amount", color="Type")
else:
    st.info("No financial data available.")