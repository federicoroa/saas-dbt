{{ config(
    materialized='incremental',
    unique_key='daily_usage_id',
    on_schema_change='append_new_columns'
) }}

with usage as (

    select * from {{ ref('stg_usage') }}

),

daily_aggregated as (

    select
        -- composite unique key for incremental updates
        concat(cast(customer_id as string), '-', cast(event_date as string), '-', feature_name) as daily_usage_id,
        customer_id,
        event_date,
        feature_name,

        sum(usage_count) as total_usage_count,
        sum(duration_seconds) as total_duration_seconds,
        count(usage_id) as total_events_count

    from usage

    {% if is_incremental() %}
        -- Only scan raw records newer than the max date already in our target table
        where event_date > (select max(event_date) from {{ this }})
    {% endif %}

    group by 1, 2, 3, 4

)

select * from daily_aggregated