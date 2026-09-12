SaaS B2B Analytics Engine (saas-dbt)A production-grade, modular Analytics Engineering data pipeline built with dbt (data build tool) and Google BigQuery. This repository models core SaaS B2B business domain entities—including subscriptions, payment ledger transactions, product feature usage logs, and customer support ticket interactions—into a clean, tested, and fully documented Customer 360 reporting layer.🏗 Pipeline Architecture & Medallion DesignThis project follows the Medallion (Bronze $\rightarrow$ Silver $\rightarrow$ Gold) architecture pattern to guarantee strict decoupling between raw data ingestion, transformation logic, and downstream consumption layers.                    +------------------------------------+
                    |  Raw Data Sources (saas_raw)       |
                    |  - raw_customers                   |
                    |  - raw_subscriptions               |
                    |  - raw_payments                    |
                    |  - raw_usage                       |
                    |  - raw_support_tickets             |
                    +-----------------+------------------+
                                      |
                                      v
+----------------------------------------------------------------------------+
| STAGING LAYER (stg_)                                                       |
| - Standardizes data types, renames keys, handles Nulls                     |
| - Materialized as Views to avoid unnecessary raw storage costs             |
+-------------------------------------+--------------------------------------+
                                      |
                                      v
+----------------------------------------------------------------------------+
| INTERMEDIATE LAYER (int_)                                                  |
| - Encapsulates domain-specific business logic & rollups                    |
| - Pre-aggregates daily metrics, payments, & support health per customer    |
| - Materialized Incrementally where high volumes exist                      |
+-------------------------------------+--------------------------------------+
                                      |
                                      v
+----------------------------------------------------------------------------+
| MARTS LAYER (dim_ / fct_)                                                  |
| - Wide Customer 360 dimensions and Finance/Usage Fact tables              |
| - Materialized as Tables / Incremental for ultra-fast BI query performance |
+----------------------------------------------------------------------------+
🛠 Tech Stack & Key Modeling FeaturesData Warehouse: Google BigQueryTransformation: dbt (dbt-core / dbt Cloud Studio)Design Pattern: Medallion Architecture (Staging $\rightarrow$ Intermediate $\rightarrow$ Marts)SCD Type 2 Tracking: Native dbt snapshots strategy tracking customer record profile changes (plan_tier, employee_band) over time with automated dbt_valid_from / dbt_valid_to validity windows.Incremental Processing: Configured on high-volume usage models using materialized='incremental' with unique_key merging and on_schema_change='append_new_columns' to optimize query costs and BigQuery byte scanning.Data Quality & Testing: Automated primary key uniqueness, foreign key relationship integrity, and column value acceptance tests enforced at every layer.📁 Repository Structuresaas-dbt/
├── dbt_project.yml          # Top-level project configuration & model settings
├── models/
│   ├── staging/             # Cleaned & standardized views over raw tables
│   │   ├── stg_customers.sql
│   │   ├── stg_payments.sql
│   │   ├── stg_subscriptions.sql
│   │   ├── stg_support_tickets.sql
│   │   ├── stg_usage.sql
│   │   └── schema.yml       # Source definitions & staging tests
│   ├── intermediate/        # Reusable domain rollups & business metrics
│   │   ├── int_customer_mrr_summary.sql
│   │   ├── int_customer_payments_summary.sql
│   │   ├── int_customer_support_summary.sql
│   │   ├── int_customer_usage_daily.sql
│   │   └── schema.yml       # Intermediate tests & column docs
│   └── marts/               # Final dimensional & fact models for BI
│       ├── dim_customers.sql
│       ├── fct_subscriptions.sql
│       └── schema.yml       # Marts testing & metadata specs
├── snapshots/               # SCD2 point-in-time tracking
│   └── snp_customers.sql
└── README.md
📊 Core Data Marts1. dim_customers (Customer 360)A single-row-per-customer dimensional model providing a 360-degree view of every SaaS customer:Profile Attributes: company_name, industry, plan_tier, created_atFinancial Metrics: total_mrr, total_paid_amount, active_subscriptions_countHealth & Support: total_tickets_count, open_tickets_count, avg_csat_score2. fct_subscriptions (Financial & Commercial Mart)Tracks subscription lifecycles, contract values, status transitions (active, cancelled, paused), and recurring revenue streams for ARR/MRR cohort analysis.⚡ Setup & Local DevelopmentPrerequisitesPython 3.9+BigQuery project with BigQuery Admin or Data Editor permissionsService Account JSON Key or GCP OAuth login1. InstallationClone the repository and install required dbt packages:git clone https://github.com/federicoroa/saas-dbt.git
cd saas-dbt
pip install dbt-bigquery
2. Configure profiles.ymlCreate or update your local ~/.dbt/profiles.yml:saas_dbt:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: your-gcp-project-id
      dataset: saas_dbt_dev
      threads: 4
      keyfile: /path/to/your/bigquery-key.json
🚀 Execution & Operational WorkflowsBuild the Full PipelineRun all models, seeds, and snapshots while executing all quality tests:dbt build
Run Models Layer-by-Layer# Materialize Staging Layer Views
dbt run --select staging

# Materialize Intermediate Aggregations
dbt run --select intermediate

# Materialize Production Marts
dbt run --select marts
Execute Quality & Integrity TestsValidate primary keys (unique, not_null) and foreign key references (relationships):dbt test
Run SCD2 SnapshotsCapture historical profile record updates for customer attributes:dbt snapshot
🛡 Data Quality & Testing StrategyEvery layer in the transformation engine contains dedicated schema.yml assertions:Uniqueness & Non-Null Integrity: Enforced across primary keys (customer_id, subscription_id, daily_usage_id).Referential Integrity: Relationship assertions guarantee that all foreign keys in intermediate rollups and fact tables resolve back to valid staging entities.Value Assertions: Enum validation on subscription states (active, cancelled, paused, expired).📄 DocumentationGenerate and serve the interactive dbt lineage graph and column dictionary locally:dbt docs generate
dbt docs serve
