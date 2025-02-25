{{
    config(
        materialized='view'
    )
}}

with tripdata as (
    select *
    from {{ source('staging', 'fhv_data') }}
    where dispatching_base_num is not null
)

select * from tripdata