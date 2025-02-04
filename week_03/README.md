# 3 - Data Warehouse

## 3.1.1 Data Warehouse and BigQuery

 - OLAP vs OLTP
    - OLTP
        - Purpose: Control and run essential business operations in real time
        - Data Updates: Short, fast updates initiated by user
        - Database design: Normalized databases for efficiency
        - Space Requirements: generally small if historical data is archived
        - Backup and recovery: regular backups required to ensure business continuity and meet legal and governance requirements
        - Productivity: increase productivity of end users
        - Data view: lists day-to-day business transactions
        - User examples: customer-facing personnnel, clerks, online shoppers
    - OLAP
        - Purpose: Plan, solve problems, support decisions, discover hidden insights
        - Data Updates: Data periodically refreshed with scheduled, long-running batch jobs
        - Database design: Denormalized databases for analysis
        - Space Requirements: generally large due to aggregating large datasets
        - Backup and recovery: Lost data can be reloaded from OLTP database as needed in lieu of regular backups
        - Productivity: increase productivity of business managers, data analysts, and executives
        - Data view: Multi-dimensional view of enterprise data
        - User examples: Knowledge workers such as data analysts, business analysts, and executives
 
- What is a DW?
    - OLAP solution
    - Used for reporting and data analysis
    - BigQuery
        - Serverless Data Warehouse
        - Software as well as Infrastructure including
        - Built-in features like (Machine Learning, Geospatial analysis, BI)
        - BigQuery maximizes flexibility by separating the compute engine that analyzes your data from your storage

 - BigQuery
    - Cost
    - Partitions and CLustering
    - Best Practices
    - Internals
    - ML in BQ

BigQuery is serverless, scalable, and highly available, allowing for machine learning, geospatial analysis, and BI work. It is flexible because it separates the computational engine that performs the analyses from the data.  

**Cache:** we can disable the cache in the settings to get precise results, but usually, We can leave it turned off.  

**Testing:** We can experiment with publicly available datasets.  

**Results:** They can be downloaded as CSV files or analyzed with Data Studio.  

**Cost:**  
- **On-demand pricing:** $5 per terabyte.  
- **Flat rate pricing:** Reservation of slots for a fixed number of queries.  

**Creating a new table with OPTIONS:**  
We followed the usual process:  

```sql
CREATE OR REPLACE EXTERNAL TABLE `table_name`
OPTIONS (format = 'CSV', uris = ['table_address_1', 'table_address_2']);
```

### **Partitioning in BigQuery**  
To partition a table, all I need to do is run the following command:  

```sql
CREATE OR REPLACE TABLE <table_name>
PARTITION BY <column_name> (e.g., DATE(tpep_pickup_datetime))
AS <query>
```

Partitioning helps save memory and reduce costs, as querying partitioned tables optimizes both in BigQuery.  

### **Clustering in BigQuery**  
To cluster a table, I first partition it, then apply clustering, and finally use:  
```sql
AS <query>
```

This also helps reduce memory usage and costs!

## 3.1.2 - Partitioning and Clustering
Repository for Partitioning and Clustering: https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/03-data-warehouse/big_query.sql

### Partitioning
- Time-unit columns
- Ingestion time (_PARTITIONTIME)
- Integer partitioning

**Using the Time Unit:**
- Daily (default)
- Hourly
- Monthly or yearly

**Partition limit: 4000**

### Clustering
- Column order is important
- The order determines how the data will be organized
- **Improvements with clustering:** Filtering and aggregations
- Tables smaller than 1GB do not significantly benefit from partitioning and clustering

**Which columns can be used for clustering?**
- DATE
- BOOL
- GEOGRAPHY
- INT64
- NUMERIC
- BIGNUMERIC
- STRING
- TIMESTAMP
- DATETIME

### Partitioning vs Clustering
- Clustering:
1. Cost benefit unknown
2. You need more granularity than partitioning alone allows
3. Your queries commonly use filters or aggregation against multiple particular columns
4. The cardinality of the number of values in a column or group of columns is large

- Partitioning:
1. Cost known upfront
2. you need partition-level management
3. Filter or aggregate on single column

## 3.2.1 BigQuery Best Practices
### Cost Reduction:
- Avoid `SELECT *`
- Price your queries before running them
- Use clustered or partitioned tables
- Use streaming inserts with caution
- Materialize query results in stages

### Query Performance:
- Filter on partitioned columns
- Denormalize data
- Use nested or repeated columns
- Use external data sources appropriately
- Do not use external data sources if you need high query performance
- Reduce data before using a JOIN
- Do not treat `WITH` clauses as prepared statements
- Avoid oversharding tables
- Avoid JavaScript user-defined functions
- Use approximate aggregation functions (e.g., HyperLogLog++)
- **Order Last** for query operations to maximize performance
- **Optimize Join Patterns:**
  - Place the table with the largest number of rows first
  - Follow with the table with the fewest rows
  - Arrange remaining tables in decreasing size order

## 3.3.1 - BigQuery Machine Learning
### Logistic Regression in BigQuery ML

Full query link: [BigQuery ML Logistic Regression](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/03-data-warehouse/big_query_ml.sql)

### Advantages:
- No need for Python or Java knowledge
- No need to export data into a different system

### Free Tier:
- 10 GB per month of storage
- 1 TB per month of processed queries
- ML model creation step: first 10 GB per month is free
- Different models have different pricing

### Step-by-Step Process (see full documentation above):
1. **Basic Query:** Select the desired columns and apply filtering.
2. **Create Table:** Generate a table using the selected values.
3. **Automatic Preprocessing:** BigQuery handles preprocessing automatically unless manual changes are needed.
   - Check data types, as some may require casting before preprocessing.
4. **Model Creation:**
   - Store the model in a new table.
   - Use `OPTIONS` to specify model type, input, and split method (e.g., `AUTO_SPLIT`).

### Additional Resources:
- [BigQuery ML Introduction](https://cloud.google.com/bigquery/docs/bqml-introduction)
- [BigQuery ML Syntax for Logistic Regression](https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm)
- [BigQuery ML Preprocessing Overview](https://cloud.google.com/bigquery/docs/preprocess-overview)