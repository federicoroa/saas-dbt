with payments as (

    select * from {{ ref('stg_payments') }}

),

aggregated as (

    select
        customer_id,

        -- lifetime financial metrics (LTV)
        sum(case when status = 'paid' or status = 'succeeded' then amount else 0 end) as lifetime_value,
        count(case when status = 'paid' or status = 'succeeded' then payment_id end) as total_successful_payments,

        -- payment activity timeline
        min(case when status = 'paid' or status = 'succeeded' then payment_date end) as first_payment_date,
        max(case when status = 'paid' or status = 'succeeded' then payment_date end) as last_payment_date

    from payments
    group by 1

)

select * from aggregated