with
    source as (select * from {{ source("warm-melody-330414", "raw_payments") }}),

    renamed as (

        select
            cast(payment_id as string) as payment_id,
            cast(subscription_id as string) as subscription_id,
            cast(customer_id as string) as customer_id,
            cast(payment_date as date) as payment_date,
            cast(amount as numeric) as amount,
            trim(currency) as currency,
            trim(payment_method) as payment_method,
            trim(status) as status
        from source

    )

select *
from renamed
