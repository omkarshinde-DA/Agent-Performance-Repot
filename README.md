# Agent Performance Report Analytics

## Overview
An end-to-end ETL and Business Intelligence reporting project built for the 
Insurance Distribution Business at Bajaj Finserv Ltd. The system automates 
data ingestion, transformation, and dashboard delivery to track insurance 
agent performance across attendance, call efficiency, and follow-up metrics.

## Tech Stack
| Layer | Tools Used |
|-------|-----------|
| Data Extraction | SQL (SSMS), Advanced Excel |
| Transformation | Azure Databricks (PySpark), Python (pandas) |
| Storage | Azure SQL, Delta Lake |
| Reporting | Power BI (DAX, Power Query) |
| Orchestration | Automated ETL Workflows |

## Key Features
- Extracts call logs and login data from operational source systems
- Applies business rules in Databricks to clean and validate raw data
- Produces structured, report-ready tables for downstream BI consumption
- Power BI dashboards tracking KPIs for 500+ agents across regions
- Automated daily and weekly data refresh — reduced manual effort by ~40%

## Metrics Delivered
- Agent attendance rate
- Call efficiency score
- Follow-up completion rate
- Regional performance comparison

## Project Structure
insurance-agent-performance-analytics/
├── sql/               # Extraction & transformation queries
├── databricks/        # PySpark notebooks for ETL
├── excel/             # Business rule templates
├── powerbi/           # Dashboard screenshots
└── README.md

## Results
- Recognized as Employee of the Month (March 2025) for impact of this project
- Dashboards adopted by operations leadership for weekly performance reviews
