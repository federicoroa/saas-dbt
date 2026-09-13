with customers as (

    select * from {{ ref('stg_customers') }}

),

mrr_summary as (

    select * from {{ ref('int_customer_mrr_summary') }}

),

support_summary as (

    select * from {{ ref('int_customer_support_summary') }}

),

payments_summary as (

    select * from {{ ref('int_customer_payments_summary') }}

),

final as (

    select
        -- primary key
        c.customer_id,

        -- profile attributes
        c.company_name,
        c.industry,
        c.country,
        c.employee_band,
        c.plan_tier,
        c.signup_date,
        c.is_active as is_account_active,

        -- current financial metrics
        coalesce(m.current_mrr, 0) as current_mrr,
        coalesce(m.current_mrr, 0) * 12 as current_arr,
        coalesce(m.active_subscriptions_count, 0) as active_subscriptions_count,
        coalesce(m.has_active_subscription, false) as has_active_subscription,

        -- lifetime payment metrics (LTV)
        coalesce(p.lifetime_value, 0) as lifetime_value,
        coalesce(p.total_successful_payments, 0) as total_successful_payments,
        p.first_payment_date,
        p.last_payment_date,

        -- support metrics
        coalesce(s.total_tickets_count, 0) as total_tickets_count,
        coalesce(s.open_tickets_count, 0) as open_tickets_count,
        coalesce(s.high_priority_tickets_count, 0) as high_priority_tickets_count,
        s.avg_csat_score,

        -- derived status / health flag
        case
            when coalesce(m.current_mrr, 0) > 0 then 'paying'
            when coalesce(p.lifetime_value, 0) > 0 then 'churned'
            else 'prospect_or_free'
        end as customer_status

    from customers c
    left join mrr_summary m
        on c.customer_id = m.customer_id
    left join support_summary s
        on c.customer_id = s.customer_id
    left join payments_summary p
        on c.customer_id = p.customer_id

)

select * from final