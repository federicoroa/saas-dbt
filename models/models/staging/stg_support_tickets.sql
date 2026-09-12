with
    source as (select * from {{ source("warm-melody-330414", "raw_support_tickets") }}),

    renamed as (

        select
            cast(ticket_id as string) as ticket_id,
            cast(customer_id as string) as customer_id,
            trim(lower(priority)) as priority,
            trim(lower(category)) as category,
            trim(lower(status)) as status,
            cast(created_date as date) as created_date,
            cast(resolved_date as date) as resolved_date,
            cast(csat_score as numeric) as csat_score
        from source

    )

select *
from renamed
