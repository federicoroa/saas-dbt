with subscriptions as (

    select * from {{ ref('stg_subscriptions') }}

),

aggregated as (

    select
        customer_id,

        -- MRR metrics
        sum(case when status = 'active' then mrr else 0 end) as current_mrr,
        count(case when status = 'active' then subscription_id end) as active_subscriptions_count,

        -- lifecycle dates
        min(start_date) as first_subscription_date,
        max(start_date) as latest_subscription_start_date,
        max(end_date) as latest_subscription_end_date,

        -- status flags
        max(case when status = 'active' then true else false end) as has_active_subscription

    from subscriptions
    group by 1

)

select * from aggregated