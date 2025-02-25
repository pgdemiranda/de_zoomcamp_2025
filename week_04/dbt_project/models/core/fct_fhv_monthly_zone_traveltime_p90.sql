{{
    config(
        materialized='table'
    )
}}

with fhv_trips_with_duration as (
    select
        year,
        month,
        pickup_location_id,
        dropoff_location_id,
        pickup_zone,
        borough as pickup_borough,
        dropoff_zone,
        trip_duration
    from {{ ref('dim_fhv_trips') }}
),
p90_duration as (
    select
        year,
        month,
        pickup_location_id,
        dropoff_location_id,
        pickup_zone,
        pickup_borough,
        dropoff_zone,
        approx_quantiles(trip_duration, 100)[offset(90)] as p90_trip_duration
    from fhv_trips_with_duration
    group by year, month, pickup_location_id, dropoff_location_id, pickup_zone, pickup_borough, dropoff_zone
)
select *
from p90_duration
order by year, month, pickup_location_id, dropoff_location_id