with support_tickets as (

    select * from {{ ref('stg_support_tickets') }}

),

aggregated as (

    select
        customer_id,

        -- ticket volume metrics
        count(ticket_id) as total_tickets_count,
        count(case when status != 'closed' then ticket_id end) as open_tickets_count,
        count(case when priority = 'high' or priority = 'urgent' then ticket_id end) as high_priority_tickets_count,

        -- SLA & customer satisfaction metrics
        round(avg(csat_score), 2) as avg_csat_score

    from support_tickets
    group by 1

)

select * from aggregated