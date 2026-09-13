# SaaS Analytics Pipeline (dbt + BigQuery)

A modular, production-grade data transformation pipeline built with **dbt Core** and **Google BigQuery**, modeling SaaS business operations (MRR rollups, LTV, support health, and daily product engagement).

---

## Architecture & Lineage

Follows the **Medallion Architecture** (Staging → Intermediate → Marts) for clean separation of concerns:
