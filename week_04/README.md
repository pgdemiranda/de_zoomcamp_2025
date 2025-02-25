# 4 - Analytics Engineering

** Quick Hack to Rebuild the dataset in BigQuery to start experimenting **
https://www.youtube.com/watch?v=Mork172sK_c&list=PLaNLNpjZpzwgneiI-Gl8df8GCsPYp_6Bs

No Marketplace do Google Cloud eu selecionei o NYC TLC Trips, que é o conjunto de dados que estamos utilizando, abrindo eles no BigQuery Studio
A ideia aqui é criar uma tabela com as viagens dos táxis amarelos e do táxis verdes em um dataset chamado trips_data_all
Primeiro tive que criar os schemas:

```sql
CREATE TABLE `projeto-taxi-431301.trips_data_all.green_tripdata` AS
SELECT * FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2019`;
CREATE TABLE `projeto-taxi-431301.trips_data_all.yellow_tripdata` AS
SELECT * FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2019`;
```

E depois inserir os dados:

```sql
INSERT INTO `projeto-taxi-431301.trips_data_all.green_tripdata`
SELECT * FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2020`;
INSERT INTO `projeto-taxi-431301.trips_data_all.yellow_tripdata`
SELECT * FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2020`;
```

## 4.1 - Introduction to Analytics Engineering

### Tooling
1. **Data Loading**: Tools for ingesting data into the system.
2. **Data Storing**: Platforms like Snowflake, BigQuery, and Redshift.
3. **Data Modeling**: Tools like DBT and Terraform.
4. **Data Presentation**: Tools like Data Studio, Looker, Mode, and Tableau.


### Data Modeling Concepts
- **ETL (Extract, Transform, Load)**:
  - More stable and tailored for analysis.
  - Requires high storage and computational processing.
- **ELT (Extract, Load, Transform)**:
  - Faster and more flexible for analysis.
  - Lower cost and maintenance.


### Kimball's Dimensional Modeling
- **Objective**: Deliver interpretable data to business users.
- **Goal**: Provide fast query performance.
- **Approach**: Prioritize interpretability and performance over data redundancy (3NF).
- **Other Approaches**: Bill Inmon and Data Vault.


### Elements of Dimensional Data Modeling
- **Fact Tables**:
  - Represent facts, metrics, and measures.
  - Correspond to business processes (VERBS).
- **Dimension Tables**:
  - Represent business entities.
  - Provide business context to processes (NOUNS).


### Architecture
1. **Stage Area**:
   - Contains raw data.
   - Not exposed to end-users.
2. **Processing Area**:
   - Data models built on raw data.
   - Focused on efficiency and maintaining standards.
3. **Presentation Area**:
   - Final presentation layer.
   - Exposed to business teams and stakeholders.

## 4.1.2 - What is DBT?
DBT (Data Build Tool) transforms tables into models. Each model is a `.sql` file containing a `SELECT` statement. DBT compiles the SQL query and pushes the result back into the Data Warehouse.

---

### How DBT Works
- **Transformation**: Converts raw tables into structured models.
- **Compilation**: Compiles the SQL queries and executes them in the Data Warehouse.

---

### Running DBT
There are two options for running DBT:
1. **DBT Core**:
   - Runs locally on your machine.
   - Requires setup and configuration in your local environment.

2. **DBT Cloud**:
   - Utilizes a web-based GUI.
   - Provides a more user-friendly interface for managing and running DBT projects.

## 4.2.1 - Start Your dbt Project: BigQuery and dbt Cloud (alternative A)

## 4.2.2. - Start Your dbt Project: Postgres and dbt Core Locally (alternative B)

# 4.3.1 - Build the First dbt Models

## Modular Data Modeling Approach
The modular data modeling approach involves loading tables and then creating models (SQL files) to perform various transformation functions. These transformations are then aggregated into data marts.

---

## Materialization Strategies
- **Table**: Representations of data that are created and stored in the database.
- **View**: Virtual tables created as queries from normal tables.
- **Incremental**: Materializations that exist for updating tables.
- **Ephemeral**: Temporary and only last during a run.

---

## Sources
- **Sources**: Data sources.
- **Configurations**: Settings in YML files.
- **Automated Dependency Construction**: Automated construction of dependencies.

---

## Seeds
- **CSV Files**: Archived in folders.
- **Version Control**: Recommended for data that does not change frequently.
- **Command**: `dbt seed -s <file_name>`.

---

## Project Step-by-Step
1. In the `models` directory, create a new folder called `staging`.
2. Inside the `staging` folder, create a file named `schema.yml`.
3. As you build the models, the lineage relationship will appear at the bottom, and you can access these databases.

---

## Macros
- **Creation**: Create tasks in the `macros` folder by creating an SQL file.
- **Usage**: After creation, specify `{{ name_of_the_macro('coluna_afetada') }}` in the table.
- **Configuration**: In `macros_properties.yml`, specify the column and the expected data type.

---

## Packages
- **Importing Packages**: Similar to importing libraries in Python, specify these packages in `packages.yml` (located in the project root) and import using `dbt deps`.
- **Package Listing**: Find a list of packages at [https://hub.getdbt.com/](https://hub.getdbt.com/).

---

## dbt Utils
- **Usage**: From the `dbt utils` package, we will use `surrogate_keys`.

---

## Config Macro
- **Usage**: The `tripdatas` table files have macros at the beginning and end. You can bring them in by using `__` and typing `config`, then pointing to the configuration of that table.

---

## Example Schema for `stg_green_tripdata.sql`
- **Config Macro**: Indicates that it is a materialized view.
- **Initial CTE**: Has a `row_number()` filter to filter out duplicate rows by ID and selects non-null rows.
- **Data Selection**: Selects data with comments and casting for each dimension.
- **Macro**: `payment_type` macro at the end.
- **Test Variable**: A variable to test the build at the end.

---

## Variables
- **Usage**: Variables are used as `{{ var(' ') }}`.
- **Definition**: Can be defined in the `dbt_project.yml` file or as a command line argument.

---

## Fact and Dimension Tables
- **Creation**: Create a `core` table in `models` with a master table called `dim_zones.sql`.
- **Seed**: Upload the `taxi_zone_lookup.csv` as a seed.
- **BigQuery Format**: For BigQuery, the format is sensitive. I copied it directly from the course repo, but there is no way to pass this.
- **Writing `dim_zones.sql`**: Use `__ref` as a shortcut and select everything from `taxi_zone_lookup`.
- **Special Case**: Since I know there is an issue where `Boro` is a region that only green taxis go to, we need to signal this in `dim_zones.sql`.
- **Fact Table Creation**: The creation of the fact table was quite extensive, but I saved the project on GitHub as a reference.

## 4.3.2 - Testing and Documenting the Project

### Testing
- **Definition**: Tests are defined in a column within a `.yml` file.
- **Basic Tests**:
  - `Unique`
  - `Not null`
  - `Accepted values`
  - `A foreign key to another table`
- **Custom Tests**: It is possible to create new types of tests, such as custom queries.

---

### Documentation
- **Tool**: Documentation is created with the help of a package called `codegen`.
- **Process**:
  1. Create a new tab.
  2. Enter the code provided in the `codegen` documentation.
  3. Point to `compile`, then copy and paste the compiled section into the `schema.yml` file in the `staging` area.
  
  Example:
  ```sql
  {% set models_to_generate = codegen.get_models(directory="staging", prefix="stg") %}
  {{ codegen.generate_model_yaml(model_names=models_to_generate) }}
  ```

Adding Tests
- Location: Tests are added directly in the schema.yml file.
- Purpose: Tests serve as warnings if something falls outside the expected parameters.
- Example: Since the tests are repetitive, I will leave them on my GitHub. We use the variable for values created earlier.

Generating Documentation:

Command: Documentation is generated using the command:
    `dbt docs generate`

## 4.4.1 - Deployment Using dbt Cloud (Alternative A)

### Overview
The dbt Cloud IDE has a **scheduler tab** for creating jobs that run in production. A single job can contain multiple commands, and jobs can be triggered either automatically or manually. Each job maintains a log for every command, which is updated whenever the job runs.

---

### Key Features
- **Documentation Generation**: A job can generate documentation.
- **Source Freshness**: If **FRESHNESS** is enabled in the dbt source, it can be visualized in the job's **GIM** (Graphical Interface for Monitoring).

---

### Creating a Job
1. **Job Creation**:
   - Created a job named **Noturno** by selecting the "Create Job" option.
   - Scheduled it to run at a specific time (12:00 AM).
   - The job ran successfully, generated a branch, and is set to run continuously at 12:00 AM.

2. **Documentation Setup**:
   - In the **Explore** tab, selected **Settings**.
   - Enabled the job to generate documentation under the **Artifacts** section.
   - The documentation generated was the one I had previously been unable to create.

---

### Continuous Integration (CI) and Continuous Deployment (CD)
- **Definition**:
  - CI/CD is the practice of continuously merging development branches into a central repository, where automated tests are run.
  - The goal is to reduce production bugs and maintain stability.

- **CI in dbt**:
  - CI is activated during **pull requests**.
  - Enabled via **webhooks** from GitHub or GitLab.
  - CI runs against a temporary schema, and the pull request is not completed unless the CI process succeeds.

- **Creating a CI Job**:
  - Created a new job of type **CI**.
  - Left all settings as default (no additional commands were added, as the existing setup was sufficient).

## 4.5.1 - Visualizing the Data With Looker (Alternative A)

### Overview
[Looker Studio](https://lookerstudio.google.com/) is a powerful tool for data visualization. During the dashboard creation process, a limit of **100 queries** was encountered in the staging tables, which inadvertently carried over to production. This issue was noticed during the dashboard construction.

---

### Fixing the Query Limit Issue
1. **Update in IDE**: Updated the query limit in the IDE.
2. **Upload with dbt**: Ran `dbt build` to upload the changes.
3. **Update Connection in Looker**: Updated the connection in BigQuery within Looker Studio to reflect the changes.

---

### Creating a Data Source in Looker
1. **Steps**:
   - **Create** -> **Datasource** -> **BigQuery**.
   - Select the project, dataset, and table.
   - Chose the `fact_trips` table.

2. **Table Adjustments**:
   - When accessed in Looker, the table displayed some unwanted aggregations (e.g., Sum).
   - Changed most aggregations to **None**, except for `passenger_count`.

3. **Customization**:
   - In the connection area, you can rename the table, modify its components, add elements, etc.

---

### Building the Dashboard
- **Process**: Building a dashboard in Looker is similar to using tools like **Power BI** or **Tableau**.
- **Features**:
  - Add charts, titles, and dynamic fields.
  - Include filters and other interactive elements.
  - Continuously add components as needed.

- **Filters**:
  - Added a **date range filter** and a **dropdown filter** for enhanced interactivity.