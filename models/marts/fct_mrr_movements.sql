with monthly_mrr as (

    select * from {{ ref('int_customer_monthly_mrr') }}

),

customer_last_month as (

    select
        customer_id,
        max(month) as last_paid_month
    from monthly_mrr
    group by 1

),

churn_rows as (

    select
        customer_id,
        date_add(last_paid_month, interval 1 month) as month,
        0 as mrr
    from customer_last_month
    where last_paid_month < date_trunc(current_date(), month)

),

combined as (

    select customer_id, month, mrr from monthly_mrr
    union all
    select customer_id, month, mrr from churn_rows

),

with_lag as (

    select
        customer_id,
        month,
        mrr,
        lag(month) over (partition by customer_id order by month) as prev_month,
        lag(mrr) over (partition by customer_id order by month) as prev_mrr
    from combined

)

select
    customer_id,
    month,
    mrr,
    coalesce(prev_mrr, 0) as prev_mrr,
    mrr - coalesce(prev_mrr, 0) as mrr_movement_amount,
    case
        when prev_month is null then 'new_logo'
        when prev_month != date_sub(month, interval 1 month) then 'reactivation'
        when mrr = 0 then 'churn'
        when mrr > prev_mrr then 'expansion'
        when mrr < prev_mrr then 'contraction'
        else 'unchanged'
    end as movement_type
from with_lag