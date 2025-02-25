{{
    config(
        materialized='table'
    )
}}

with fhv_trips as (
    select * from {{ ref('stg_fhv_data') }}
),
dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)
select
    ft.dispatching_base_num,
    ft.pickup_datetime,
    ft.dropoff_datetime,
    ft.PUlocationID as pickup_location_id,
    ft.DOlocationID as dropoff_location_id,
    ft.SR_Flag,
    ft.Affiliated_base_number,
    dz.zone as pickup_zone,
    dz.borough,
    dz2.zone as dropoff_zone,
    extract(year from ft.pickup_datetime) as year,
    extract(month from ft.pickup_datetime) as month,
    -- Calcula a duração da viagem em segundos
    timestamp_diff(ft.dropoff_datetime, ft.pickup_datetime, second) as trip_duration
from fhv_trips as ft
inner join dim_zones as dz on ft.PUlocationID = dz.locationid
inner join dim_zones as dz2 on ft.DOlocationID = dz2.locationid