{{ config(materialized='table') }}

select date_day
from unnest(generate_date_array(date('2020-01-01'), date_add(current_date(), interval 5 year), interval 1 day)) as date_day