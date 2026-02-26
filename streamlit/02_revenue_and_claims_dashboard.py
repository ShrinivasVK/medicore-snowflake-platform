import streamlit as st
from snowflake.snowpark.context import get_active_session
import pandas as pd

st.set_page_config(layout="wide")

session = get_active_session()

@st.cache_data
def load_revenue_kpis(_session, start_date, end_date, payers, departments, statuses):
    payer_filter = ""
    if payers:
        payer_list = ",".join([f"'{p}'" for p in payers])
        payer_filter = f"AND c.PAYER_TYPE IN ({payer_list})"
    
    dept_filter = ""
    if departments:
        dept_list = ",".join([f"'{d}'" for d in departments])
        dept_filter = f"AND d.DEPARTMENT_NAME IN ({dept_list})"
    
    status_filter = ""
    if statuses:
        status_list = ",".join([f"'{s}'" for s in statuses])
        status_filter = f"AND c.CLAIM_STATUS IN ({status_list})"
    
    sql = f"""
    SELECT 
        COALESCE(SUM(cli.LINE_BILLED_AMOUNT), 0) AS TOTAL_BILLED,
        COALESCE(SUM(cli.LINE_NET_REVENUE), 0) AS TOTAL_PAID,
        COALESCE(SUM(cli.LINE_NET_REVENUE), 0) AS NET_REVENUE,
        COALESCE(SUM(cli.DENIAL_FLAG_NUMERIC) * 100.0 / NULLIF(COUNT(*), 0), 0) AS DENIAL_RATE
    FROM MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIM_LINE_ITEMS cli
    LEFT JOIN MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIMS c ON cli.CLAIM_ID = c.CLAIM_ID
    LEFT JOIN MEDICORE_ANALYTICS_DB.DEV_REFERENCE.DIM_DEPARTMENTS d ON cli.DEPARTMENT_ID = d.DEPARTMENT_ID
    WHERE cli.SERVICE_DATE >= '{start_date}'
      AND cli.SERVICE_DATE <= '{end_date}'
      {payer_filter}
      {dept_filter}
      {status_filter}
    """
    return _session.sql(sql).to_pandas()

@st.cache_data
def load_revenue_trend(_session, start_date, end_date, payers, departments, statuses):
    payer_filter = ""
    if payers:
        payer_list = ",".join([f"'{p}'" for p in payers])
        payer_filter = f"AND c.PAYER_TYPE IN ({payer_list})"
    
    dept_filter = ""
    if departments:
        dept_list = ",".join([f"'{d}'" for d in departments])
        dept_filter = f"AND d.DEPARTMENT_NAME IN ({dept_list})"
    
    status_filter = ""
    if statuses:
        status_list = ",".join([f"'{s}'" for s in statuses])
        status_filter = f"AND c.CLAIM_STATUS IN ({status_list})"
    
    sql = f"""
    SELECT 
        cli.SERVICE_MONTH AS MONTH_KEY,
        COALESCE(SUM(cli.LINE_BILLED_AMOUNT), 0) AS BILLED_AMOUNT,
        COALESCE(SUM(cli.LINE_NET_REVENUE), 0) AS NET_REVENUE
    FROM MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIM_LINE_ITEMS cli
    LEFT JOIN MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIMS c ON cli.CLAIM_ID = c.CLAIM_ID
    LEFT JOIN MEDICORE_ANALYTICS_DB.DEV_REFERENCE.DIM_DEPARTMENTS d ON cli.DEPARTMENT_ID = d.DEPARTMENT_ID
    WHERE cli.SERVICE_DATE >= '{start_date}'
      AND cli.SERVICE_DATE <= '{end_date}'
      {payer_filter}
      {dept_filter}
      {status_filter}
    GROUP BY cli.SERVICE_MONTH
    ORDER BY MONTH_KEY
    """
    return _session.sql(sql).to_pandas()

@st.cache_data
def load_denial_trend(_session, start_date, end_date, payers, departments, statuses):
    payer_filter = ""
    if payers:
        payer_list = ",".join([f"'{p}'" for p in payers])
        payer_filter = f"AND c.PAYER_TYPE IN ({payer_list})"
    
    dept_filter = ""
    if departments:
        dept_list = ",".join([f"'{d}'" for d in departments])
        dept_filter = f"AND d.DEPARTMENT_NAME IN ({dept_list})"
    
    status_filter = ""
    if statuses:
        status_list = ",".join([f"'{s}'" for s in statuses])
        status_filter = f"AND c.CLAIM_STATUS IN ({status_list})"
    
    sql = f"""
    SELECT 
        cli.SERVICE_MONTH AS MONTH_KEY,
        COALESCE(SUM(cli.DENIAL_FLAG_NUMERIC) * 100.0 / NULLIF(COUNT(*), 0), 0) AS DENIAL_RATE
    FROM MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIM_LINE_ITEMS cli
    LEFT JOIN MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIMS c ON cli.CLAIM_ID = c.CLAIM_ID
    LEFT JOIN MEDICORE_ANALYTICS_DB.DEV_REFERENCE.DIM_DEPARTMENTS d ON cli.DEPARTMENT_ID = d.DEPARTMENT_ID
    WHERE cli.SERVICE_DATE >= '{start_date}'
      AND cli.SERVICE_DATE <= '{end_date}'
      {payer_filter}
      {dept_filter}
      {status_filter}
    GROUP BY cli.SERVICE_MONTH
    ORDER BY MONTH_KEY
    """
    return _session.sql(sql).to_pandas()

@st.cache_data
def load_denials_by_payer(_session, start_date, end_date, departments, statuses):
    dept_filter = ""
    if departments:
        dept_list = ",".join([f"'{d}'" for d in departments])
        dept_filter = f"AND d.DEPARTMENT_NAME IN ({dept_list})"
    
    status_filter = ""
    if statuses:
        status_list = ",".join([f"'{s}'" for s in statuses])
        status_filter = f"AND c.CLAIM_STATUS IN ({status_list})"
    
    sql = f"""
    SELECT 
        COALESCE(c.PAYER_TYPE, 'Unknown') AS PAYER_TYPE,
        SUM(cli.DENIAL_FLAG_NUMERIC) AS DENIED_COUNT
    FROM MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIM_LINE_ITEMS cli
    LEFT JOIN MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIMS c ON cli.CLAIM_ID = c.CLAIM_ID
    LEFT JOIN MEDICORE_ANALYTICS_DB.DEV_REFERENCE.DIM_DEPARTMENTS d ON cli.DEPARTMENT_ID = d.DEPARTMENT_ID
    WHERE cli.SERVICE_DATE >= '{start_date}'
      AND cli.SERVICE_DATE <= '{end_date}'
      {dept_filter}
      {status_filter}
    GROUP BY c.PAYER_TYPE
    ORDER BY DENIED_COUNT DESC
    """
    return _session.sql(sql).to_pandas()

@st.cache_data
def load_payer_mix(_session, start_date, end_date, departments, statuses):
    dept_filter = ""
    if departments:
        dept_list = ",".join([f"'{d}'" for d in departments])
        dept_filter = f"AND d.DEPARTMENT_NAME IN ({dept_list})"
    
    status_filter = ""
    if statuses:
        status_list = ",".join([f"'{s}'" for s in statuses])
        status_filter = f"AND c.CLAIM_STATUS IN ({status_list})"
    
    sql = f"""
    SELECT 
        COALESCE(c.PAYER_TYPE, 'Unknown') AS PAYER_TYPE,
        COALESCE(SUM(cli.LINE_NET_REVENUE), 0) AS REVENUE
    FROM MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIM_LINE_ITEMS cli
    LEFT JOIN MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIMS c ON cli.CLAIM_ID = c.CLAIM_ID
    LEFT JOIN MEDICORE_ANALYTICS_DB.DEV_REFERENCE.DIM_DEPARTMENTS d ON cli.DEPARTMENT_ID = d.DEPARTMENT_ID
    WHERE cli.SERVICE_DATE >= '{start_date}'
      AND cli.SERVICE_DATE <= '{end_date}'
      {dept_filter}
      {status_filter}
    GROUP BY c.PAYER_TYPE
    ORDER BY REVENUE DESC
    """
    return _session.sql(sql).to_pandas()

@st.cache_data
def load_top_procedures(_session, start_date, end_date, payers, departments, statuses):
    payer_filter = ""
    if payers:
        payer_list = ",".join([f"'{p}'" for p in payers])
        payer_filter = f"AND c.PAYER_TYPE IN ({payer_list})"
    
    dept_filter = ""
    if departments:
        dept_list = ",".join([f"'{d}'" for d in departments])
        dept_filter = f"AND d.DEPARTMENT_NAME IN ({dept_list})"
    
    status_filter = ""
    if statuses:
        status_list = ",".join([f"'{s}'" for s in statuses])
        status_filter = f"AND c.CLAIM_STATUS IN ({status_list})"
    
    sql = f"""
    SELECT 
        cli.PROCEDURE_CODE,
        COALESCE(SUM(cli.LINE_NET_REVENUE), 0) AS TOTAL_REVENUE
    FROM MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIM_LINE_ITEMS cli
    LEFT JOIN MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIMS c ON cli.CLAIM_ID = c.CLAIM_ID
    LEFT JOIN MEDICORE_ANALYTICS_DB.DEV_REFERENCE.DIM_DEPARTMENTS d ON cli.DEPARTMENT_ID = d.DEPARTMENT_ID
    WHERE cli.SERVICE_DATE >= '{start_date}'
      AND cli.SERVICE_DATE <= '{end_date}'
      AND cli.PROCEDURE_CODE IS NOT NULL
      {payer_filter}
      {dept_filter}
      {status_filter}
    GROUP BY cli.PROCEDURE_CODE
    ORDER BY TOTAL_REVENUE DESC
    LIMIT 10
    """
    return _session.sql(sql).to_pandas()

@st.cache_data
def load_payers(_session):
    sql = """
    SELECT DISTINCT PAYER_TYPE 
    FROM MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIMS 
    WHERE PAYER_TYPE IS NOT NULL
    ORDER BY PAYER_TYPE
    """
    return _session.sql(sql).to_pandas()["PAYER_TYPE"].tolist()

@st.cache_data
def load_departments(_session):
    sql = """
    SELECT DISTINCT DEPARTMENT_NAME 
    FROM MEDICORE_ANALYTICS_DB.DEV_REFERENCE.DIM_DEPARTMENTS 
    WHERE DEPARTMENT_NAME IS NOT NULL
    ORDER BY DEPARTMENT_NAME
    """
    return _session.sql(sql).to_pandas()["DEPARTMENT_NAME"].tolist()

@st.cache_data
def load_claim_statuses(_session):
    sql = """
    SELECT DISTINCT CLAIM_STATUS 
    FROM MEDICORE_ANALYTICS_DB.DEV_BILLING.CLAIMS 
    WHERE CLAIM_STATUS IS NOT NULL
    ORDER BY CLAIM_STATUS
    """
    return _session.sql(sql).to_pandas()["CLAIM_STATUS"].tolist()

st.title("MediCore Revenue & Claims Dashboard")

st.sidebar.header("Filters")

payers_list = load_payers(session)
departments_list = load_departments(session)
statuses_list = load_claim_statuses(session)

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

selected_payers = st.sidebar.multiselect(
    "Payer Type",
    options=payers_list,
    default=[],
    key="payers"
)

selected_departments = st.sidebar.multiselect(
    "Departments",
    options=departments_list,
    default=[],
    key="departments"
)

selected_statuses = st.sidebar.multiselect(
    "Claim Status",
    options=statuses_list,
    default=[],
    key="statuses"
)

kpis = load_revenue_kpis(session, start_date, end_date, selected_payers, selected_departments, selected_statuses)

st.subheader("Key Performance Indicators")
col1, col2, col3, col4 = st.columns(4)

with col1:
    total_billed = int(kpis["TOTAL_BILLED"].iloc[0]) if not kpis.empty else 0
    st.metric("Total Billed", f"${total_billed:,}")

with col2:
    total_paid = int(kpis["TOTAL_PAID"].iloc[0]) if not kpis.empty else 0
    st.metric("Total Paid", f"${total_paid:,}")

with col3:
    net_revenue = int(kpis["NET_REVENUE"].iloc[0]) if not kpis.empty else 0
    st.metric("Net Revenue", f"${net_revenue:,}")

with col4:
    denial_rate = float(kpis["DENIAL_RATE"].iloc[0]) if not kpis.empty else 0.0
    st.metric("Denial Rate", f"{denial_rate:.2f}%")

st.divider()

st.subheader("Revenue Trend")
revenue_trend = load_revenue_trend(session, start_date, end_date, selected_payers, selected_departments, selected_statuses)

if not revenue_trend.empty:
    revenue_trend["MONTH_KEY"] = pd.to_datetime(revenue_trend["MONTH_KEY"])
    st.area_chart(revenue_trend, x="MONTH_KEY", y=["BILLED_AMOUNT", "NET_REVENUE"])
else:
    st.info("No revenue trend data available for the selected filters.")

st.divider()

st.subheader("Denial Analysis")
col_denial_trend, col_denial_payer = st.columns(2)

with col_denial_trend:
    st.caption("Denial Rate Trend (%)")
    denial_trend = load_denial_trend(session, start_date, end_date, selected_payers, selected_departments, selected_statuses)
    if not denial_trend.empty:
        denial_trend["MONTH_KEY"] = pd.to_datetime(denial_trend["MONTH_KEY"])
        st.line_chart(denial_trend, x="MONTH_KEY", y="DENIAL_RATE")
    else:
        st.info("No denial trend data available.")

with col_denial_payer:
    st.caption("Denials by Payer")
    denials_by_payer = load_denials_by_payer(session, start_date, end_date, selected_departments, selected_statuses)
    if not denials_by_payer.empty:
        st.bar_chart(denials_by_payer, x="PAYER_TYPE", y="DENIED_COUNT")
    else:
        st.info("No denial data by payer available.")

st.divider()

st.subheader("Payer Mix - Revenue by Payer Type")
payer_mix = load_payer_mix(session, start_date, end_date, selected_departments, selected_statuses)

if not payer_mix.empty:
    st.bar_chart(payer_mix, x="PAYER_TYPE", y="REVENUE", horizontal=True)
else:
    st.info("No payer mix data available for the selected filters.")

st.divider()

st.subheader("Top 10 Procedures by Revenue")
top_procedures = load_top_procedures(session, start_date, end_date, selected_payers, selected_departments, selected_statuses)

if not top_procedures.empty:
    st.bar_chart(top_procedures, x="PROCEDURE_CODE", y="TOTAL_REVENUE")
else:
    st.info("No procedure revenue data available for the selected filters.")