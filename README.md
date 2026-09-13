# SaaS Analytics Pipeline (dbt + BigQuery)

A modular, production-grade data transformation pipeline built with **dbt Core** and **Google BigQuery**, modeling SaaS business operations (MRR rollups, LTV, support health, and daily product engagement).

---

## Architecture & Lineage

Follows the **Medallion Architecture** (Staging → Intermediate → Marts) for clean separation of concerns:
* **Staging (`models/staging/`):** Clean 1:1 view layer over raw tables (`customers`, `subscriptions`, `payments`, `usage`, `tickets`). Standardizes column names and types.
* **Intermediate (`models/intermediate/`):** Materialized rollups performing aggregations per customer (MRR, total payments, CSAT, daily usage).
* **Marts (`models/marts/`):** High-performance analytical tables for BI tools (`dim_customers`, `fct_subscriptions`, `fct_daily_usage`).

---

## Technical Features

* **Incremental Logic:** Configured with `materialized='incremental'`, composite `unique_key`, and `on_schema_change='append_new_columns'` for high-volume event logs.
* **Modular Schema Tests:** Separate `schema.yml` files per directory asserting `unique`, `not_null`, `relationships`, and `accepted_values` constraints.

---

## Quickstart

1. **Clone Repo & Install Dependencies:**
   git clone https://github.com/federicoroa/saas-dbt.git

