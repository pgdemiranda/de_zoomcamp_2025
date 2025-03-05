## Module 4 Homework

For this homework, you will need the following datasets:
* [Green Taxi dataset (2019 and 2020)](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/green)
* [Yellow Taxi dataset (2019 and 2020)](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/yellow)
* [For Hire Vehicle dataset (2019)](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/fhv)

### Before you start

1. Make sure you, **at least**, have them in GCS with a External Table **OR** a Native Table - use whichever method you prefer to accomplish that (Workflow Orchestration with [pandas-gbq](https://cloud.google.com/bigquery/docs/samples/bigquery-pandas-gbq-to-gbq-simple), [dlt for gcs](https://dlthub.com/docs/dlt-ecosystem/destinations/filesystem), [dlt for BigQuery](https://dlthub.com/docs/dlt-ecosystem/destinations/bigquery), [gsutil](https://cloud.google.com/storage/docs/gsutil), etc)
2. You should have exactly `7,778,101` records in your Green Taxi table
3. You should have exactly `109,047,518` records in your Yellow Taxi table
4. You should have exactly `43,244,696` records in your FHV table
5. Build the staging models for green/yellow as shown in [here](../../../04-analytics-engineering/taxi_rides_ny/models/staging/)
6. Build the dimension/fact for taxi_trips joining with `dim_zones`  as shown in [here](../../../04-analytics-engineering/taxi_rides_ny/models/core/fact_trips.sql)

**Note**: If you don't have access to GCP, you can spin up a local Postgres instance and ingest the datasets above


### Question 1: Understanding dbt model resolution

Provided you've got the following sources.yaml
```yaml
version: 2

sources:
  - name: raw_nyc_tripdata
    database: "{{ env_var('DBT_BIGQUERY_PROJECT', 'dtc_zoomcamp_2025') }}"
    schema:   "{{ env_var('DBT_BIGQUERY_SOURCE_DATASET', 'raw_nyc_tripdata') }}"
    tables:
      - name: ext_green_taxi
      - name: ext_yellow_taxi
```

with the following env variables setup where `dbt` runs:
```shell
export DBT_BIGQUERY_PROJECT=myproject
export DBT_BIGQUERY_DATASET=my_nyc_tripdata
```

What does this .sql model compile to?
```sql
select * 
from {{ source('raw_nyc_tripdata', 'ext_green_taxi' ) }}
```

`select * from myproject.my_nyc_tripdata.ext_green_taxi`

- `select * from dtc_zoomcamp_2025.raw_nyc_tripdata.ext_green_taxi`
- `select * from dtc_zoomcamp_2025.my_nyc_tripdata.ext_green_taxi`
- `select * from myproject.raw_nyc_tripdata.ext_green_taxi`
- **`select * from myproject.my_nyc_tripdata.ext_green_taxi`** <-
- `select * from dtc_zoomcamp_2025.raw_nyc_tripdata.green_taxi`


### Question 2: dbt Variables & Dynamic Models

Say you have to modify the following dbt_model (`fct_recent_taxi_trips.sql`) to enable Analytics Engineers to dynamically control the date range. 

- In development, you want to process only **the last 7 days of trips**
- In production, you need to process **the last 30 days** for analytics

```sql
select *
from {{ ref('fact_taxi_trips') }}
where pickup_datetime >= CURRENT_DATE - INTERVAL '30' DAY
```

What would you change to accomplish that in a such way that command line arguments takes precedence over ENV_VARs, which takes precedence over DEFAULT value?

- Add `ORDER BY pickup_datetime DESC` and `LIMIT {{ var("days_back", 30) }}`
- Update the WHERE clause to `pickup_datetime >= CURRENT_DATE - INTERVAL '{{ var("days_back", 30) }}' DAY`
- Update the WHERE clause to `pickup_datetime >= CURRENT_DATE - INTERVAL '{{ env_var("DAYS_BACK", "30") }}' DAY`
- **Update the WHERE clause to `pickup_datetime >= CURRENT_DATE - INTERVAL '{{ var("days_back", env_var("DAYS_BACK", "30")) }}' DAY`** <-
- Update the WHERE clause to `pickup_datetime >= CURRENT_DATE - INTERVAL '{{ env_var("DAYS_BACK", var("days_back", "30")) }}' DAY`

### Question 3: dbt Data Lineage and Execution

Considering the data lineage below **and** that taxi_zone_lookup is the **only** materialization build (from a .csv seed file):

![image](./homework_q2.png)

Select the option that does **NOT** apply for materializing `fct_taxi_monthly_zone_revenue`:

`dbt run --select models/staging/+`

- `dbt run`
- `dbt run --select +models/core/dim_taxi_trips.sql+ --target prod`
- `dbt run --select +models/core/fct_taxi_monthly_zone_revenue.sql`
- `dbt run --select +models/core/`
- **`dbt run --select models/staging/+`** <-


### Question 4: dbt Macros and Jinja

Consider you're dealing with sensitive data (e.g.: [PII](https://en.wikipedia.org/wiki/Personal_data)), that is **only available to your team and very selected few individuals**, in the `raw layer` of your DWH (e.g: a specific BigQuery dataset or PostgreSQL schema), 

 - Among other things, you decide to obfuscate/masquerade that data through your staging models, and make it available in a different schema (a `staging layer`) for other Data/Analytics Engineers to explore

- And **optionally**, yet  another layer (`service layer`), where you'll build your dimension (`dim_`) and fact (`fct_`) tables (assuming the [Star Schema dimensional modeling](https://www.databricks.com/glossary/star-schema)) for Dashboarding and for Tech Product Owners/Managers

You decide to make a macro to wrap a logic around it:

```sql
{% macro resolve_schema_for(model_type) -%}

    {%- set target_env_var = 'DBT_BIGQUERY_TARGET_DATASET'  -%}
    {%- set stging_env_var = 'DBT_BIGQUERY_STAGING_DATASET' -%}

    {%- if model_type == 'core' -%} {{- env_var(target_env_var) -}}
    {%- else -%}                    {{- env_var(stging_env_var, env_var(target_env_var)) -}}
    {%- endif -%}

{%- endmacro %}
```

And use on your staging, dim_ and fact_ models as:
```sql
{{ config(
    schema=resolve_schema_for('core'), 
) }}
```

That all being said, regarding macro above, **select all statements that are true to the models using it**:
- Setting a value for  `DBT_BIGQUERY_TARGET_DATASET` env var is mandatory, or it'll fail to compile <-
- Setting a value for `DBT_BIGQUERY_STAGING_DATASET` env var is mandatory, or it'll fail to compile
- When using `core`, it materializes in the dataset defined in `DBT_BIGQUERY_TARGET_DATASET` <-
- When using `stg`, it materializes in the dataset defined in `DBT_BIGQUERY_STAGING_DATASET`, or defaults to `DBT_BIGQUERY_TARGET_DATASET` <-
- When using `staging`, it materializes in the dataset defined in `DBT_BIGQUERY_STAGING_DATASET`, or defaults to `DBT_BIGQUERY_TARGET_DATASET` <-


## Serious SQL

Alright, in module 1, you had a SQL refresher, so now let's build on top of that with some serious SQL.

These are not meant to be easy - but they'll boost your SQL and Analytics skills to the next level.  
So, without any further do, let's get started...

You might want to add some new dimensions `year` (e.g.: 2019, 2020), `quarter` (1, 2, 3, 4), `year_quarter` (e.g.: `2019/Q1`, `2019-Q2`), and `month` (e.g.: 1, 2, ..., 12), **extracted from pickup_datetime**, to your `fct_taxi_trips` OR `dim_taxi_trips.sql` models to facilitate filtering your queries

```
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
    where borough != 'Unknown'
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
    -- new dimensions: year, quarter and month
    extract(year from trips_unioned.pickup_datetime) as year,
    extract(quarter from trips_unioned.pickup_datetime) as quarter,
    extract(month from trips_unioned.pickup_datetime) as month,
    -- concat
    concat(extract(year from trips_unioned.pickup_datetime), '/Q', extract(quarter from trips_unioned.pickup_datetime)) as year_quarter
from trips_unioned
inner join dim_zones as pickup_zone
on trips_unioned.pickup_location_id = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on trips_unioned.dropoff_location_id = dropoff_zone.locationid)

select * 
from trips_filtered
where year = 2019 or year = 2020
```


### Question 5: Taxi Quarterly Revenue Growth

1. Create a new model `fct_taxi_trips_quarterly_revenue.sql`
2. Compute the Quarterly Revenues for each year for based on `total_amount`
3. Compute the Quarterly YoY (Year-over-Year) revenue growth 
  * e.g.: In 2020/Q1, Green Taxi had -12.34% revenue growth compared to 2019/Q1
  * e.g.: In 2020/Q4, Yellow Taxi had +34.56% revenue growth compared to 2019/Q4

```SQL
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
```

Considering the YoY Growth in 2020, which were the yearly quarters with the best (or less worse) and worst results for green, and yellow

- green: {best: 2020/Q2, worst: 2020/Q1}, yellow: {best: 2020/Q2, worst: 2020/Q1}
- green: {best: 2020/Q2, worst: 2020/Q1}, yellow: {best: 2020/Q3, worst: 2020/Q4}
- green: {best: 2020/Q1, worst: 2020/Q2}, yellow: {best: 2020/Q2, worst: 2020/Q1}
- **green: {best: 2020/Q1, worst: 2020/Q2}, yellow: {best: 2020/Q1, worst: 2020/Q2}** <-
- green: {best: 2020/Q1, worst: 2020/Q2}, yellow: {best: 2020/Q3, worst: 2020/Q4}


### Question 6: P97/P95/P90 Taxi Monthly Fare

1. Create a new model `fct_taxi_trips_monthly_fare_p95.sql`
2. Filter out invalid entries (`fare_amount > 0`, `trip_distance > 0`, and `payment_type_description in ('Cash', 'Credit Card')`)
3. Compute the **continous percentile** of `fare_amount` partitioning by service_type, year and and month

```SQL
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
```

Now, what are the values of `p97`, `p95`, `p90` for Green Taxi and Yellow Taxi, in April 2020?

```SQL
SELECT 
    service_type, 
    p90, 
    p95, 
    p97 
FROM `ny-taxi-448414.trips_data_all.fct_taxi_trips_monthly_fare_p95` 
WHERE year = 2020 AND month = 4
```

- green: {p97: 55.0, p95: 45.0, p90: 26.5}, yellow: {p97: 52.0, p95: 37.0, p90: 25.5}
- green: {p97: 55.0, p95: 45.0, p90: 26.5}, yellow: {p97: 31.5, p95: 25.5, p90: 19.0}
- green: {p97: 40.0, p95: 33.0, p90: 24.5}, yellow: {p97: 52.0, p95: 37.0, p90: 25.5}
- **green: {p97: 40.0, p95: 33.0, p90: 24.5}, yellow: {p97: 31.5, p95: 25.5, p90: 19.0}** <-
- green: {p97: 55.0, p95: 45.0, p90: 26.5}, yellow: {p97: 52.0, p95: 25.5, p90: 19.0}


### Question 7: Top #Nth longest P90 travel time Location for FHV

Prerequisites:
* Create a staging model for FHV Data (2019), and **DO NOT** add a deduplication step, just filter out the entries where `where dispatching_base_num is not null`
* Create a core model for FHV Data (`dim_fhv_trips.sql`) joining with `dim_zones`. Similar to what has been done [here](../../../04-analytics-engineering/taxi_rides_ny/models/core/fact_trips.sql)
* Add some new dimensions `year` (e.g.: 2019) and `month` (e.g.: 1, 2, ..., 12), based on `pickup_datetime`, to the core model to facilitate filtering for your queries

Now...
1. Create a new model `fct_fhv_monthly_zone_traveltime_p90.sql`
2. For each record in `dim_fhv_trips.sql`, compute the [timestamp_diff](https://cloud.google.com/bigquery/docs/reference/standard-sql/timestamp_functions#timestamp_diff) in seconds between dropoff_datetime and pickup_datetime - we'll call it `trip_duration` for this exercise
3. Compute the **continous** `p90` of `trip_duration` partitioning by year, month, pickup_location_id, and dropoff_location_id

For the Trips that **respectively** started from `Newark Airport`, `SoHo`, and `Yorkville East`, in November 2019, what are **dropoff_zones** with the 2nd longest p90 trip_duration ?

```SQL
-- Newark Airport -> LaGuardia Airport
SELECT * 
FROM `ny-taxi-448414.trips_data_all.fct_fhv_monthly_zone_traveltime_p90` 
WHERE month = 11 and year = 2019 and pickup_zone in ('Newark Airport')
ORDER BY p90_trip_duration DESC
LIMIT 2

-- SoHo -> Greenwich Village South
SELECT * 
FROM `ny-taxi-448414.trips_data_all.fct_fhv_monthly_zone_traveltime_p90` 
WHERE month = 11 and year = 2019 and pickup_zone in ('SoHo')
ORDER BY p90_trip_duration DESC
LIMIT 2

-- Yorkville East -> Garment Disctrict
SELECT * 
FROM `ny-taxi-448414.trips_data_all.fct_fhv_monthly_zone_traveltime_p90` 
WHERE month = 11 and year = 2019 and pickup_zone in ('Yorkville East')
ORDER BY p90_trip_duration DESC
LIMIT 2
```

- **LaGuardia Airport, Chinatown, Garment District** <-
- LaGuardia Airport, Park Slope, Clinton East
- LaGuardia Airport, Saint Albans, Howard Beach
- LaGuardia Airport, Rosedale, Bath Beach
- LaGuardia Airport, Yorkville East, Greenpoint