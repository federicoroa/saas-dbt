with
    source as (select * from {{ source("warm-melody-330414", "raw_subscriptions") }}),

    renamed as (

    select
        cast(subscription_id as string) as subscription_id,
        cast(customer_id as string) as customer_id,
        trim(lower(plan_name)) as plan_name,
        trim(lower(billing_cycle)) as billing_cycle,
        trim(lower(status)) as status,
        coalesce(cast(mrr as numeric), 0) as mrr,
        cast(start_date as date) as start_date,
        cast(end_date as date) as end_date
    from source

)

select * from renamed