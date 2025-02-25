{{
    config(
        materialized='table'
    )
}}

with quarterly_revenue as (
    select 
        service_type,
        year,
        quarter,
        year_quarter,
        sum(total_amount) as quarterly_revenue
    from {{ ref('fct_taxi_trips') }}
    group by service_type, year, quarter, year_quarter
),
yoy_growth as (
    select 
        curr.service_type,
        curr.year,
        curr.quarter,
        curr.year_quarter,
        curr.quarterly_revenue as current_quarter_revenue,
        prev.quarterly_revenue as previous_quarter_revenue,
        (curr.quarterly_revenue - prev.quarterly_revenue) / prev.quarterly_revenue * 100 as yoy_growth_percent
    from quarterly_revenue curr
    left join quarterly_revenue prev
    on curr.service_type = prev.service_type
    and curr.quarter = prev.quarter
    and curr.year = prev.year + 1
)
select 
    service_type,
    year,
    quarter,
    year_quarter,
    current_quarter_revenue,
    previous_quarter_revenue,
    yoy_growth_percent
from yoy_growth
order by service_type, year, quarter