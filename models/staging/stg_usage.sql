with
    source as (select * from {{ source("warm-melody-330414", "raw_usage") }}),

    renamed as (

        select
            cast(usage_id as integer) as usage_id,
            cast(customer_id as string) as customer_id,
            cast(event_date as date) as event_date,
            trim(lower(feature_name)) as feature_name,
            coalesce(cast(usage_count as integer), 0) as usage_count,
            coalesce(duration_seconds, 0) as duration_seconds
        from source

    )

select *
from renamed
