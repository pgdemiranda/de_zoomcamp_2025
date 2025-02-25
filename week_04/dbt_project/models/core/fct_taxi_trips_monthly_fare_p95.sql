{{
    config(
        materialized='table'
    )
}}

with green_tripdata as (
    select *, 
        'Green' as service_type
    from {{ ref('stg_green_tripdata') }}
), 
yellow_tripdata as (
    select *, 
        'Yellow' as service_type
    from {{ ref('stg_yellow_tripdata') }}
), 
trips_unioned as (
    select * from green_tripdata
    union all 
    select * from yellow_tripdata
), 
dim_zones as (
    select * from {{ ref('dim_zones') }}
    -- where borough != 'Unknown'
),
trips_filtered as (
    select 
        trips_unioned.tripid, 
        trips_unioned.vendorid, 
        trips_unioned.service_type,
        trips_unioned.ratecodeid, 
        trips_unioned.pickup_location_id, 
        pickup_zone.borough as pickup_borough, 
        pickup_zone.zone as pickup_zone, 
        trips_unioned.dropoff_location_id,
        dropoff_zone.borough as dropoff_borough, 
        dropoff_zone.zone as dropoff_zone,  
        trips_unioned.pickup_datetime, 
        trips_unioned.dropoff_datetime, 
        trips_unioned.store_and_fwd_flag, 
        trips_unioned.passenger_count, 
        trips_unioned.trip_distance, 
        trips_unioned.trip_type, 
        trips_unioned.fare_amount, 
        trips_unioned.extra, 
        trips_unioned.mta_tax, 
        trips_unioned.tip_amount, 
        trips_unioned.tolls_amount, 
        trips_unioned.ehail_fee, 
        trips_unioned.imp_surcharge, 
        trips_unioned.total_amount, 
        trips_unioned.payment_type, 
        trips_unioned.payment_type_description,
        extract(year from trips_unioned.pickup_datetime) as year,
        extract(quarter from trips_unioned.pickup_datetime) as quarter,
        extract(month from trips_unioned.pickup_datetime) as month,
        -- concat
        concat(extract(year from trips_unioned.pickup_datetime), '/Q', extract(quarter from trips_unioned.pickup_datetime)) as year_quarter
    from trips_unioned
    inner join dim_zones as pickup_zone
    on trips_unioned.pickup_location_id = pickup_zone.locationid
    inner join dim_zones as dropoff_zone
    on trips_unioned.dropoff_location_id = dropoff_zone.locationid
    where fare_amount > 0 
      and trip_distance > 0 
      and payment_type_description in ('Cash', 'Credit Card')
),
percentiles as (
    select
        service_type,
        year,
        month,
        approx_quantiles(fare_amount, 100)[offset(97)] as p97,
        approx_quantiles(fare_amount, 100)[offset(95)] as p95,
        approx_quantiles(fare_amount, 100)[offset(90)] as p90
    from trips_filtered
    group by service_type, year, month
)

select *
from percentiles
order by service_type, year, month