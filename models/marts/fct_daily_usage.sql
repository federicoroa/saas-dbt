{{ config(
    materialized='incremental',
    unique_key='daily_usage_id',
    on_schema_change='append_new_columns'
) }}

with daily_usage as (

    select * from {{ ref('int_customer_usage_daily') }}

    {% if is_incremental() %}
        -- Only process new dates on incremental runs
        where event_date >= (select max(event_date) from {{ this }})
    {% endif %}

)

select
    daily_usage_id,
    customer_id,
    event_date,
    feature_name,
    total_usage_count,
    total_duration_seconds
from daily_usage