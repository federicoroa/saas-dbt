with usage as (

    select * from {{ ref('stg_usage') }}

),

daily_aggregated as (

    select
        customer_id,
        event_date,
        feature_name,

        -- daily engagement aggregates
        sum(usage_count) as total_usage_count,
        sum(duration_seconds) as total_duration_seconds,
        count(usage_id) as total_events_count

    from usage
    group by 1, 2, 3

)

select * from daily_aggregated