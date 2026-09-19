with customer_bounds as (

    select
        customer_id,
        date_trunc(min(start_date), month) as first_month,
        date_trunc(max(coalesce(end_date, current_date())), month) as last_month
    from {{ ref('stg_subscriptions') }}
    group by 1

),

customer_months as (

    select
        customer_id,
        month
    from customer_bounds,
    unnest(generate_date_array(first_month, last_month, interval 1 month)) as month

),

monthly_mrr as (

    select
        cm.customer_id,
        cm.month,
        coalesce(sum(s.mrr), 0) as mrr
    from customer_months cm
    left join {{ ref('stg_subscriptions') }} s
        on cm.customer_id = s.customer_id
        and s.status != 'trial'
        and s.start_date <= last_day(cm.month)
        and coalesce(s.end_date, current_date()) >= cm.month
    group by 1, 2

)

select *
from monthly_mrr
where mrr > 0