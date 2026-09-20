# SaaS Analytics Pipeline (dbt + BigQuery + Tableau)

A modular, production-grade data transformation pipeline built with **dbt Core** and **Google BigQuery**, modeling SaaS business operations (MRR rollups, LTV, support health, and daily product engagement).

---

## Live Dashboards

* **[SaaS MRR & Revenue Concentration](https://public.tableau.com/app/profile/federico.roa.rubinstein/viz/SaaSMRRRevenueConcentrationDashboard/Dashboard1)** — monthly MRR bridge (`fct_mrr_movements`) and customer revenue concentration (`dim_customer`).
* **[Product Engagement Overview](https://public.tableau.com/app/profile/federico.roa.rubinstein/viz/ProductEngagementOverview/Dashboard1)** — monthly feature usage trends (`fct_daily_usage`).

---

## Architecture & Lineage

Follows a **Staging → Intermediate → Marts** layered architecture for clean separation of concerns:
* **Staging (`models/staging/`):** Clean 1:1 view layer over raw tables (`customers`, `subscriptions`, `payments`, `usage`, `tickets`). Standardizes column names and types.
* **Intermediate (`models/intermediate/`):** Materialized rollups performing aggregations per customer (MRR, total payments, CSAT, daily usage).
* **Marts (`models/marts/`):** High-performance analytical tables for BI tools (`dim_customer`, `fct_subscriptions`, `fct_daily_usage`, `fct_mrr_movements`).

---

## What Each Mart Answers

| Mart | Grain | Answers |
|---|---|---|
| `dim_customer` | 1 row per customer | Who are our customers, and how healthy/valuable is each one *right now*? (current MRR/ARR, lifetime value, support ticket load, active/churned/prospect status) |
| `fct_subscriptions` | 1 row per subscription contract | What subscription contracts exist, and what are their terms and economics? (plan, billing cycle, MRR/ARR, duration, active flag) |
| `fct_daily_usage` | 1 row per customer/feature/day | How is the product actually being used, day to day? (which features, how often, is engagement growing) |
| `fct_mrr_movements` | 1 row per customer per month | How and why is MRR changing month over month? (New Logo / Expansion / Contraction / Churn / Reactivation attribution, not just the current snapshot) |

---

## Technical Features

* **Incremental Logic:** Configured with `materialized='incremental'`, composite `unique_key`, and `on_schema_change='append_new_columns'` for high-volume event logs.
* **Modular Schema Tests:** Separate `schema.yml` files per directory asserting `unique`, `not_null`, `relationships`, and `accepted_values` constraints.

---

## Quickstart

1. **Clone Repo & Install Dependencies:**
   ```
   git clone https://github.com/federicoroa/saas-dbt.git
   cd saas-dbt
   ```

2. **Configure your BigQuery connection** in `~/.dbt/profiles.yml` (or via dbt Cloud's connection UI), pointing at your own GCP project and dataset.

3. **Build the project:**
   ```
   dbt build
   ```
   This runs all models in dependency order (staging → intermediate → marts) and executes every schema test.

4. **Explore the lineage** with `dbt docs generate && dbt docs serve` to see the full DAG and column-level documentation.
