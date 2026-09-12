with
    subscriptions as (select * from {{ ref("stg_subscriptions") }}),

    customers as (

        select customer_id, company_name, industry, country, plan_tier
        from {{ ref("stg_customers") }}

    ),

    joined as (

        select
            -- primary key
            s.subscription_id,

            -- foreign keys
            s.customer_id,

            -- customer attributes
            c.company_name,
            c.industry,
            c.country,

            -- subscription details
            s.plan_name,
            s.billing_cycle,
            s.status,

            -- financials
            s.mrr,
            s.mrr * 12 as arr,

            -- dates & lifecycle
            s.start_date,
            s.end_date,
            case
                when s.end_date is not null
                then date_diff(s.end_date, s.start_date, day)
                else date_diff(current_date(), s.start_date, day)
            end as subscription_duration_days,

            -- status flag
            case when s.status = 'active' then true else false end as is_active

        from subscriptions s
        left join customers c on s.customer_id = c.customer_id

    )

select *
from joined
