with 

stg_customers as (

    select
    customer_id,
    trim(company_name) as company_name,
    lower(trim(industry)) as industry,
    lower(trim(country)) as country,
    lower(trim(employee_band)) as employee_band,
    signup_date,
    lower(trim(plan_tier)) as plan_tier,
    is_active 
    from {{ source('warm-melody-330414', 'raw_customers') }}

)

select * from stg_customers