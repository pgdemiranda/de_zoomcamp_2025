# 1. Docker and Terraform
## 1.1.1 - Introduction to Google Cloud

Google Cloud Platform (GCP) provides a wide range of services tailored to various needs, including compute, storage, big data, machine learning, and more. Below, we outline each service category with examples and its relevance to Data Engineering.

---

### Compute
GCP’s compute services allow for scalable processing power, suitable for various workloads.

**Examples:**
- **Google Compute Engine**: Provides virtual machines for scalable processing tasks.
- **Google Kubernetes Engine (GKE)**: Manages containerized applications in a cluster environment.
- **Cloud Run**: Serverless computing for deploying and running applications without infrastructure management.

**Relevance to Data Engineering:**
- Running ETL pipelines or data transformation scripts.
- Hosting data processing frameworks like Apache Spark.

---

### Management
Management services ensure optimal monitoring, deployment, and organization of cloud resources.

**Examples:**
- **Cloud Deployment Manager**: Automates the creation and management of GCP resources.
- **Cloud Console**: A unified interface to manage and monitor resources.
- **Operations Suite (formerly Stackdriver)**: Tools for logging, monitoring, and diagnostics.

**Relevance to Data Engineering:**
- Monitoring data pipelines to ensure performance and reliability.
- Automating infrastructure provisioning for data workflows.

---

### Networking
Networking services provide connectivity and security for data communication.

**Examples:**
- **Cloud VPN**: Securely connects on-premises networks to GCP.
- **Cloud Load Balancing**: Distributes traffic across multiple instances for reliability and performance.
- **VPC (Virtual Private Cloud)**: Configures isolated networking environments.

**Relevance to Data Engineering:**
- Managing secure connections for data ingestion from external sources.
- Ensuring high availability of data pipelines.

---

### Storage & Databases
GCP offers robust storage and database options, ideal for storing structured and unstructured data.

**Examples:**
- **Cloud Storage**: Stores unstructured data, including logs and media files.
- **BigQuery**: A serverless, scalable data warehouse for querying large datasets.
- **Cloud SQL**: Fully-managed relational databases (e.g., MySQL, PostgreSQL).
- **Firestore**: NoSQL database for real-time data applications.

**Relevance to Data Engineering:**
- Storing raw and processed data in scalable and secure formats.
- Executing complex analytical queries on large datasets.

---

### Big Data
Big Data services support the analysis and processing of massive datasets.

**Examples:**
- **BigQuery**: Enables SQL-based analytics on large datasets.
- **Dataflow**: Processes real-time and batch data using Apache Beam.
- **Dataproc**: Manages Apache Spark and Hadoop clusters for big data processing.

**Relevance to Data Engineering:**
- Building data pipelines for real-time and batch data processing.
- Performing advanced analytics on large datasets.

---

### Identity & Security
Identity and security services safeguard data and resources on GCP.

**Examples:**
- **Cloud IAM (Identity and Access Management)**: Manages permissions and access control.
- **Cloud KMS (Key Management Service)**: Encrypts sensitive data using managed keys.
- **Security Command Center**: Provides centralized security management.

**Relevance to Data Engineering:**
- Ensuring sensitive data in pipelines is encrypted and access-controlled.
- Managing access to databases and storage resources.

---

### Machine Learning
Machine learning services enable the development and deployment of predictive models.

**Examples:**
- **AI Platform**: Builds and deploys machine learning models.
- **TensorFlow on GCP**: Trains machine learning models at scale.
- **AutoML**: Creates custom machine learning models without extensive expertise.

**Relevance to Data Engineering:**
- Integrating predictive models into data pipelines for enhanced analytics.
- Preprocessing and feature engineering for ML workflows.

---

### Navigation in GCP
**Drop-down Menu:** Provides access to all GCP services categorized by type.
**Search Menu:** Quickly locates specific services or features within GCP.

By leveraging these GCP services, data engineers can build robust, scalable, and secure data solutions for diverse business needs.



## 1.2.1 - Introduction to Docker

**What is Docker? Why do we need it?**
Docker is an open platform for developing, shipping, and running applications. It enables you to separate your applications from your infrastructure, allowing for faster software delivery. With Docker, infrastructure can be managed like applications. By leveraging Docker's methodologies for shipping, testing, and deploying code, the delay between writing and running code in production is significantly reduced.
(Source: [Docker Overview](https://docs.docker.com/get-started/docker-overview/))

**Data Pipeline**
A data pipeline is a process service that ingests data and produces more processed data.

---

### Containers

**What are Containers?**
Containers are isolated processes for each of your app’s components. Each component—the frontend React app, the Python API engine, and the database—runs in its own isolated environment, completely separate from everything else on your machine.

**Containers vs. Virtual Machines (VMs)**

- **VMs**: Full operating systems with their own kernel, hardware drivers, programs, and applications. Spinning up a VM to isolate a single application involves significant overhead.
- **Containers**: Isolated processes with only the files needed to run. Multiple containers share the same kernel, enabling more applications to run on less infrastructure.

**Benefits of Containers**

- **Self-contained**: Each container includes everything it needs to run, without relying on pre-installed dependencies on the host machine.
- **Isolated**: Containers operate independently, with minimal influence on the host and other containers, enhancing application security.
- **Independent**: Each container is managed separately. Deleting one container doesn’t affect others.
- **Portable**: Containers can run anywhere. The same container can operate seamlessly on development machines, data centers, or in the cloud.
  (Source: [Docker Concepts](https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-a-container/))

---

### Why Should We Care About Docker?

- **Reproducibility**: Ensures consistent behavior across environments.
- **Local experiments and tests**: Streamlines development workflows.
- **Integration tests (CI/CD)**: Facilitates continuous integration and delivery. Example: [GitHub CI/CD](https://github.com/resources/articles/devops/ci-cd).
- **Cloud pipelines**: Running pipelines on AWS Batch, Kubernetes jobs, etc.
- **Scalable frameworks**: Compatible with Spark, Serverless (AWS Lambda, Google Functions), and more.

---

### Running PostgreSQL Locally with Docker

1. Create a directory for the project:
   ```bash
   mkdir 2_docker_sql
   ```
2. Run a test Docker image:
   ```bash
   docker run hello-world
   ```
3. Run an Ubuntu container interactively:
   ```bash
   docker run -it ubuntu bash
   ```
4. Run a Python container interactively:
   ```bash
   docker run -it python:3.9
   ```
5. Run Python with an alternative entry point:
   ```bash
   docker run -it --entrypoint=bash python:3.9
   ```
6. Inside the Python container:
   ```bash
   pip install pandas
   python
   >>> import pandas
   >>> pandas.__version__
   ```

---

### Automating with Dockerfile

**Dockerfile Example:**

```dockerfile
FROM python:3.9

RUN pip install pandas

ENTRYPOINT ["bash"]
```

**Build and Run the Docker Image:**

1. Build the image:

   ```bash
   docker build -t test:pandas .
   ```

   > Note: Don’t forget the period (.) at the end of the command.

2. Run the container:

   ```bash
   docker run -it test:pandas
   ```

3. Test Python and Pandas within the container:

   ```python
   import pandas
   pandas.__version__
   ```

---

### Adding a Python Script to the Container

**Python Script (pipeline.py):**

```python
import pandas as pd
import sys

print(sys.argv)
day = sys.argv[1]
print(f"Job finished successfully for day = {day}")
```

**Updated Dockerfile:**

```dockerfile
FROM python:3.9

RUN pip install pandas

WORKDIR /app

COPY pipeline.py pipeline.py

ENTRYPOINT ["python", "pipeline.py"]
```

**Build and Run the Updated Docker Image:**

1. Build the image:
   ```bash
   docker build -t test:pandas .
   ```
2. Run the container with a specific argument (e.g., date):
   ```bash
   docker run -it test:pandas 2021-01-15
   ```
## 1.2.2 - Ingesting NY Taxi Data to Postgres

**Purpose:**
This lesson introduces the use of `pgcli`.

The NYC taxi data format has changed from CSV to Parquet, requiring ingestion through a Jupyter notebook with Parquet handling. However, the CSV files were backed up and are available in the DataTalks repository.

Example command to download the data:

```bash
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz
```

---

### Docker Setup for PostgreSQL

To connect to the database, the following parameters were used. This won’t be necessary in future setups as everything will run together, but it’s included here for reference.

**Command for Linux:**

```bash
docker run -it \
   -e POSTGRES_USER="root" \
   -e POSTGRES_PASSWORD="root" \
   -e POSTGRES_DB="ny_taxi" \
   -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data \
   -p 5432:5432 \
   postgres:13
```

**Note for Windows:**
You’ll need to pass the volume with the global path.

---

### Connecting to PostgreSQL

To connect to the database in another terminal tab, use:

```bash
pgcli -h localhost -p 5432 -u root -d ny_taxi
```

The password is `root`.

---

### Ingesting Data

After ingesting the data using the Jupyter notebook (`upload-data.ipynb`), verify the data in the table by running SQL queries.

### Testing Data

The following terminal commands can be helpful:

- Export the first 100 rows:
  ```bash
  head -n 100 yellow_tripdata_2011-01.csv > yellow_head.csv
  ```
- Count the number of lines:
  ```bash
  wc -l yellow_tripdata_2011-01.csv
  ```

---

### Handling DateTime Columns

In the notebook, two columns needed to be converted to `datetime` to ensure they were recognized as `TIMESTAMP` when generating the schema using DDL. 

The schema was created using IO operations, while SQL operations were performed using `SQLAlchemy`. The goal was to generate a DDL compatible with PostgreSQL.

---

### Additional Notes

- If `psycopg2` is not installed correctly, there is a separate notebook, `pg-test-connection.ipynb`, to test the connection with the database.

---

## 1.2.3 - Connecting pgAdmin and Postgres

**Overview:**
pgAdmin provides a more convenient way to create databases, interact with PostgreSQL, and manage data compared to `pgcli`. The official image of `pgadmin4` can be found on [DockerHub](https://hub.docker.com/r/dpage/pgadmin4/).

**Running pgAdmin in Docker:**

```bash
sudo docker run -it \
   -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
   -e PGADMIN_DEFAULT_PASSWORD="root" \
   -p 8080:80 \
   dpage/pgadmin4
```

This command sets up a new instance of `pgadmin4` running in Docker.

---

### Connecting pgAdmin to PostgreSQL

To enable communication between the PostgreSQL database and `pgadmin4`, create a Docker network and connect the containers:

1. Create a network:

   ```bash
   sudo docker network create pg-network
   ```

2. Run the PostgreSQL database container:

   ```bash
   sudo docker run -it \
      -e POSTGRES_USER="root" \
      -e POSTGRES_PASSWORD="root" \
      -e POSTGRES_DB="ny_taxi" \
      -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data \
      -p 5432:5432 \
      --network=pg-network \
      --name pg-database \
      postgres:13
   ```

3. Run the `pgadmin4` container:

   ```bash
   sudo docker run -it \
      -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
      -e PGADMIN_DEFAULT_PASSWORD="root" \
      -p 8080:80 \
      --network=pg-network \
      --name pgadmin \
      dpage/pgadmin4
   ```

---

### Accessing pgAdmin

Open a browser and navigate to `localhost:8080`. Log in with the credentials:

- Email: `admin@admin.com`
- Password: `root`

### Setting Up the Connection in pgAdmin

In the pgAdmin interface, create a new server connection:
   ```bash
   **Server Name:** Docker localhost
   **Database Name:** pg-database
   **Port:** 5432
   **Username:** root
   **Password:** root
   ```

## 1.2.4 - Dockerizing the Ingestion Script

**Overview:**
This lesson focuses on creating a Dockerized pipeline for automating the ingestion of NYC taxi data using Python. While the process will be automated with Airflow later, this step demonstrates the manual approach.

---

### Key Steps in Dockerizing the Script

#### 1. Using `argparse`
The ingestion script (`data_ingestion.py`) uses the `argparse` library to handle command-line arguments.

#### 2. Converting Jupyter Notebook to Python Script
To convert the notebook to a Python script, use the following command:

```bash
jupyter nbconvert --to=script upload-data.ipynb
```

---

### Dockerfile
The following Dockerfile was created to define the ingestion environment:

```dockerfile
FROM python:3.9.1

RUN apt-get update && apt-get install -y wget

RUN pip install pandas sqlalchemy psycopg2 pyarrow

WORKDIR /app

COPY ingest_data.py ingest_data.py

ENTRYPOINT ["python", "ingest_data.py"]
```

> **Note:** Anytime the Dockerfile is modified, rebuild the container to apply changes.

---

### Building the Docker Container
After creating the Dockerfile, build the container:

```bash
docker build -t taxi_ingest:v001 .
```

---

### Running the Ingestion Script
Pass the required parameters to the ingestion script. Below is an example of running it locally:

#### Local Execution
```bash
URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"
python ingest_data.py \
   --user=root \
   --password=root \
   --host=localhost \
   --port=5432 \
   --db=ny_taxi \
   --tb=ny_taxi_data \
   --url=${URL}
```

#### Dockerized Execution
URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"

Run the Docker container with the following command:

```bash
docker run -it \
   --network=pg-network \
   taxi_ingest:v001 \
   --user=root \
   --password=root \
   --host=pg-database \
   --port=5432 \
   --db=ny_taxi \
   --tb=ny_taxi_data \
   --url=${URL}
```

## 1.2.5 - Running Postgres and pgAdmin with Docker-Compose

**Overview:**
This chapter was concise but incredibly insightful as it demonstrated the convenience and power of Docker Compose.

---

### Key Observations:
1. If you are using a recent version of Python, the command `docker-compose` with a hyphen may not work. Instead, use `docker compose` without the hyphen.

2. A `docker-compose.yaml` file was created to manage all container-related configurations.

   - Each service is defined with its respective image, environment variables, volume (for persistence), and ports.

3. To run Docker Compose, navigate to the directory containing the YAML file and authorize the commands with `sudo` if necessary.

---

### Commands:

- To start the containers:
  ```bash
  docker compose up
  ```

- To start the containers in detached mode (release the terminal):
  ```bash
  docker compose up -d
  ```

- To stop and remove containers:
  ```bash
  docker compose down
  ```

- To verify which containers are running:
  ```bash
  docker ps
  ```

## 1.2.5 - SQL Refresher

- **Objective:** This chapter provides a brief recap of basic SQL operations using preloaded tables in the database.  
- **Prerequisite:** Ensure the data has been loaded. Use the following resources:  
  - [docker-compose.yaml](./docker-compose.yaml)  
  - [Dockerfile](./Dockerfile)  
  - [upload-data.ipynb](./upload-data.ipynb)  

#### Steps to Load Data  
1. **Setup infrastructure using `docker-compose.yaml`:**  
   Run:  
   ```bash
   docker compose up -d
   ```  

2. **Build and run the Docker image:**  
   - Build the image:  
     ```bash
     sudo docker build -t taxi_ingest:v001 .
     ```  
   - Ingest data:  
     ```bash
     URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"
     python ingest_data.py \
         --user=root \
         --password=root \
         --host=localhost \
         --port=5432 \
         --db=ny_taxi \
         --tb=ny_taxi_data \
         --url=${URL}
     ```  
   - Load zone data:  
     Use the file:  
     `https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv`  

3. **Alternative method for step 2:** Use the `upload-data.ipynb` notebook (recommended, as it includes zone data).  

#### SQL Operations Covered  

- **Joining tables (implicit inner join):**  
  ```sql
  SELECT
      tpep_pickup_datetime,
      tpep_dropoff_datetime,
      total_amount,
      CONCAT(zpu."Borough", ' / ', zpu."Zone") AS "pickup_loc",
      CONCAT(zdo."Borough", ' / ', zdo."Zone") AS "dropoff_loc"
  FROM
      yellow_taxi_data t,
      zones zpu,
      zones zdo
  WHERE
      t."PULocationID" = zpu."LocationID" AND
      t."DOLocationID" = zdo."LocationID"
  LIMIT 100;
  ```

- **Explicit inner join:**  
  ```sql
  SELECT
      tpep_pickup_datetime,
      tpep_dropoff_datetime,
      total_amount,
      CONCAT(zpu."Borough", ' / ', zpu."Zone") AS "pickup_loc",
      CONCAT(zdo."Borough", ' / ', zdo."Zone") AS "dropoff_loc"
  FROM
      yellow_taxi_data t
      JOIN zones zpu ON t."PULocationID" = zpu."LocationID"
      JOIN zones zdo ON t."DOLocationID" = zdo."LocationID"
  LIMIT 100;
  ```

- **Check for records with missing `LocationID`:**  
  ```sql
  SELECT
      tpep_pickup_datetime,
      tpep_dropoff_datetime,
      total_amount,
      "PULocationID",
      "DOLocationID"
  FROM
      yellow_taxi_data t
  WHERE
      "PULocationID" IS NULL OR "DOLocationID" IS NULL;
  ```

- **Check for unmatched `LocationID` in `zones`:**  
  ```sql
  SELECT
      tpep_pickup_datetime,
      tpep_dropoff_datetime,
      total_amount,
      "PULocationID",
      "DOLocationID"
  FROM
      yellow_taxi_data t
  WHERE
      "DOLocationID" NOT IN (
      SELECT "LocationID" FROM zones
      )
  LIMIT 100;
  ```

- **Joins (Left, Right, Outer):**  
  Example for `LEFT JOIN`:  
  ```sql
  SELECT
      tpep_pickup_datetime,
      tpep_dropoff_datetime,
      total_amount,
      "PULocationID",
      "DOLocationID"
  FROM
      yellow_taxi_data t
      LEFT JOIN zones zpu ON t."PULocationID" = zpu."LocationID"
      LEFT JOIN zones zdo ON t."DOLocationID" = zdo."LocationID"
  LIMIT 100;
  ```

- **Group by to calculate trips per day:**  
  ```sql
  SELECT
      CAST(tpep_dropoff_datetime AS DATE) AS "day",
      COUNT(1) AS "count",
      MAX(total_amount),
      MAX(passenger_count)
  FROM
      yellow_taxi_data t
  GROUP BY
      CAST(tpep_dropoff_datetime AS DATE)
  ORDER BY "count" DESC;
  ```

## 1.3.1 - Terraform Primer

This section serves as an introduction to Terraform, providing enough knowledge to become proficient, though it is not a comprehensive course.

### Overview of Terraform

**Definition**
HashiCorp Terraform is an infrastructure-as-code (IaC) tool that allows you to define cloud and on-premises resources in human-readable configuration files. These files can be versioned, reused, and shared. Terraform offers a consistent workflow to provision and manage infrastructure throughout its lifecycle, covering both low-level components (e.g., compute, storage, and networking) and high-level components (e.g., DNS entries and SaaS features).

> Reference: [HashiCorp Terraform Introduction](https://developer.hashicorp.com/terraform/intro)

**Benefits of Using Terraform**
- Simplifies infrastructure tracking
- Facilitates easier collaboration
- Enhances reproducibility
- Ensures proper removal of resources

**What Terraform Is Not**
- Does not manage or update code on infrastructure
- Does not provide the ability to modify immutable resources
- Cannot manage resources not defined in your Terraform files

### Core Concepts

**Infrastructure as Code**
Terraform enables you to define infrastructure using declarative configuration files, ensuring a codified and consistent approach to managing resources.

**Providers**
Providers are plugins that enable Terraform to manage and communicate with various services and platforms. Examples include:
- AWS
- Azure
- Google Cloud Platform (GCP)
- Kubernetes
- VSphere
- Alibaba Cloud
- Oracle Cloud Infrastructure
- Active Directory

Explore a complete list of providers at: [Terraform Providers Registry](https://registry.terraform.io/browse/providers)

### Key Commands

1. **`terraform init`**
   Initializes the Terraform working directory and downloads the necessary provider plugins.

2. **`terraform plan`**
   Previews the changes Terraform will apply to the infrastructure based on the configuration files.

3. **`terraform apply`**
   Executes the planned changes and provisions the resources defined in the Terraform files.

4. **`terraform destroy`**
   Destroys all resources defined in the Terraform files, ensuring a clean teardown of the infrastructure.

### Summary
Terraform is a powerful tool for managing infrastructure as code. By using providers, you can interface with various platforms to create, modify, and destroy resources efficiently. Its commands facilitate a clear workflow, making infrastructure management simpler and more reliable.

### 1.3.2 - Terraform Basics

#### Objective:
The goal is to create and manage buckets and infrastructure using Terraform. This involves setting up a new project called `terraform-demo` and using Terraform to simplify resource creation and destruction.

---

#### Steps to Configure and Use Terraform

**1. Set Up a Service Account:**
- Navigate to the IAM section of your cloud provider.
- Create a new service account named `terraform-runner`.
- Assign the following roles to the service account:
  - **Storage Admin**
  - **BigQuery Admin**
  - **Compute Admin** (optional, can be added later by editing the service account).

**2. Generate and Manage Service Account Keys:**
- Go to the Service Accounts section, locate `terraform-runner`, and click on the three dots.
- Select **Manage Keys** and create a new JSON key.
- Save this key to `terraform-demo/keys/my-creds.json`.

**3. Prepare Your Environment:**
- Install the Terraform extension in VS Code.
- Search online for the Google Terraform provider documentation: [Google Terraform Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs).
- Copy the provider configuration into your `main.tf` file.
- Format the file by running `terraform fmt` in the terminal.

**4. Configure Project Credentials:**
- Obtain your `project-id` from the Cloud Console (Dashboard > Overview).
- Pass credentials to Terraform in one of the following ways:
  - **Hardcoded:** Add `credentials = "./keys/my-creds.json"` in the `provider "google"` block of `main.tf`.
  - **Environment Variable:**
    ```bash
    export GOOGLE_CREDENTIALS='./keys/my-creds.json'
    ```
    Verify with:
    ```bash
    echo $GOOGLE_CREDENTIALS
    ```

**5. Initialize Terraform:**
- Run `terraform init` in the terminal to initialize the provider.

**6. Add a Resource:**
- Search for the `google_storage_bucket` resource documentation: [Google Storage Bucket Resource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket).
- Add the resource configuration to `main.tf`.
- Ensure bucket names are globally unique in GCP by appending the project name or adding a suffix (e.g., `terra-bucket`, `bucket-demo`).

**7. Plan and Apply Changes:**
- Run `terraform plan` to review changes.
- Run `terraform apply` to create the resources.

**8. Destroy Resources:**
- Use `terraform destroy` to remove all resources defined in `main.tf`.

**9. Update .gitignore:**
- Before pushing your repository to a remote server, add a Terraform-specific `.gitignore` template to avoid exposing sensitive files like credentials.

---

#### Notes:
- Use Terraform to manage infrastructure efficiently and ensure proper resource tracking.
- Always validate configurations and review planned changes before applying.
- Maintain security by excluding sensitive files from version control.

### Useful Command
- **`terraform fmt`**
   Format the file to a better, more readable fit

## 1.3.3 - Terraform Variables

This section focuses on modifying the `main.tf` file by introducing variables stored in a separate file, `variables.tf`.

### Purpose
Separating variables into a dedicated file offers the following benefits:
- Keeps the `main.tf` file organized.
- Facilitates easy modifications when needed.

### BigQuery Dataset Example
To demonstrate the use of variables, we will create a BigQuery Dataset.
- Reference: [BigQuery Dataset Basic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset.html).
- Use `Ctrl + F` in the documentation to identify required fields.

### Preliminary Steps
1. **Enable the BigQuery API:** Ensure that the BigQuery API is enabled in the GCP console.
2. **Clean Up Existing Infrastructure:** Destroy any existing Terraform-managed resources before proceeding.

### Creating the `variables.tf` File
- Define different variables in `variables.tf` to be used in `main.tf`. Variables should be called using `var.<variable_name>`.
- Variables to define:
  - **credentials**: Path to the JSON file with Google Cloud credentials.
  - **project**: Name of the project.
  - **region** and **location**: Both point to the same variable since `SOUTHAMERICA-EAST1` does not support multi-regions. For other regions, such as the US or Europe, you could use `US` or `EU`.
  - **bq_dataset_name**: Name of the BigQuery dataset.
  - **gcs_bucket_name**: Name of the GCS bucket to store data.
  - **gcs_storage_class**: Configuration for the bucket.

#### Notes:
- When referencing the credentials location in variables, use the `file()` function to specify that it is a file.

### Updating Credentials
If you previously exported Google credentials using:
```bash
export GOOGLE_CREDENTIALS=./keys/my-creds.json
```
Remove the export with:
```bash
unset GOOGLE_CREDENTIALS
```
This ensures the credentials are now passed as a variable instead of an environment variable.

### Best Practices
- Always destroy the infrastructure when it is no longer needed to avoid consuming unnecessary resources.
- Use `terraform destroy` to clean up resources created by Terraform.

By implementing these changes, your Terraform configuration will be more flexible, maintainable, and aligned with best practices for managing infrastructure as code.

## 1.4.1 Setting Up the Environment on Google Cloud (Cloud VM + SSH Access)

### Overview
Since this is the longest video of the first week and covers many topics discussed, it's worth providing a brief overview of our steps beforehand.

1. Generate SSH Keys: Create and add an SSH key pair to GCP metadata for access.

2. Create VM: Use GCP Console to create an Ubuntu VM (E2-standard-4, 30GB storage).

3. SSH into VM: Connect to the VM using the SSH key (ssh -i ~/.ssh/gcp user@<external-ip>).

4. Configure VM:

   - Install Anaconda and Docker.
   - Set up SSH config for easier access.
   - Configure Docker to run without sudo.

5. SSH with VS Code: Use the "Remote - SSH" extension to connect via the alias in the SSH config.

6. Clone Repo & Run Docker Compose: Clone the repository and run Docker containers with docker-compose up -d.

7. Install pgcli: Install pgcli and mycli for database access.

8. Set Up Port Forwarding: Forward ports 5432 (PostgreSQL) and 8888 (Jupyter) using VS Code.

9. Run Jupyter Notebook: Start Jupyter Notebook and access locally for analysis.

10. Install Terraform: Download and configure Terraform, then run terraform init, terraform plan, and terraform apply.

11. Shut Down VM: Stop the VM using the Console or sudo shutdown now.

#### Generating SSH Keys
- Referenced GCP documentation links:
  - [Connecting to Instances with Advanced SSH](https://cloud.google.com/compute/docs/instances/connecting-advanced#provide-key)
  - [Creating SSH Keys](https://cloud.google.com/compute/docs/connect/create-ssh-keys)
  - [Adding SSH Keys](https://cloud.google.com/compute/docs/connect/add-ssh-keys)
- Steps:
  1. Navigate to `~/.ssh/` directory.
  2. Generate a new SSH key using `ssh-keygen`, instructions here: https://cloud.google.com/compute/docs/connect/create-ssh-keys. For this setup, the username can be set as your preference with or without a password, but the key was named gcp.
  3. Retrieve the generated public key using `cat gcp.pub`.
  4. Add the public key to the GCP metadata under SSH keys in Compute Engine settings.

#### Creating a Virtual Machine (VM)
- Choose "Create Instance" in the GCP Console.
- Configuration:
  - Instance type: E2-standard-4
  - Storage: 30 GB
  - OS: Ubuntu
- No additional changes were made to the default setup.

#### SSH into the VM
- From the `~/` directory, connect to the VM:
  ```bash
  ssh -i ~/.ssh/gcp user@<external-ip>
  ```
- Verify connection:
  - Use `htop` to check system resources.
  - Use `gcloud --version` to confirm gcloud setup.

#### Configuring the VM and SSH Settings
1. **Install Anaconda**:
   - Download with `wget`.
   - Run the installer using `bash <filename>`.
   - After installation, activate with `source .bashrc`.
2. **Set Up SSH Config File**:
   - Create a `config` file in `~/.ssh/` with the following:
     ```
     Host <simple alias like de-zoomcamp>
     HostName <public-ip>
     User <user>
     IdentityFile ~/.ssh/gcp
     ```
   - Logout using `Ctrl+D` and reconnect using:
     ```bash
     ssh <alias>
     ```
   - example:
      ssh de-zoomcamp
3. **Install Docker**:
   - Update and install Docker:
     ```bash
     sudo apt-get update
     sudo apt-get install docker.io
     ```
   - Install Docker Compose:
     1. Locate the desired version on [Docker Compose GitHub releases](https://github.com/docker/compose).
     2. Make directory & Download:
        ```bash
        mkdir bin
        cd bin/
        wget <docker-compose-link> -O ~/bin/docker-compose
        chmod +x ~/bin/docker-compose
        ```
        for linux we are using this: https://github.com/docker/compose/releases/download/v2.32.4/docker-compose-linux-x86_64
     3. Add `~/bin` to PATH in `.bashrc`:
        ```bash
        nano .bashrc
        export PATH="${HOME}/bin:${PATH}"
        source .bashrc
        ```
   - Confirm installation with `which docker-compose`.
4. **Set Up Docker Without Sudo**:
   - Follow the guide: [Docker Without Sudo](https://github.com/sindresorhus/guides/blob/main/docker-without-sudo.md).
   -`sudo groupadd docker`
   -`sudo gpasswd -a $USER docker`
   - Logout and log back in to apply changes.
   -`sudo service docker restart`

#### SSH with VS Code
- Install the "Remote - SSH" extension.
- In VS Code, select "Connect to Host" and choose the alias from the `config` file.
- Note: If the external IP changes, update the `HostName` in the `config` file.

#### Cloning the Repository and Running Docker Compose
1. Clone the Zoomcamp repository:
   ```bash
   git clone <repo-url>
   ```
2. Navigate to the `2_docker_sql` directory and run:
   ```bash
   docker-compose up -d
   ```
3. Verify running containers with `docker ps`.

### Installing pgcli with conda
1. Install with conda:
   ```bash
   conda install -c conda-forge pgcli
   ```
2. Install mycli with pip
   ```bash
   pip install -U mycli
   ```

#### Setting Up Port Forwarding
- Use the VS Code "Ports" tab to forward ports:
  - Port `5432` for PostgreSQL.
  - Port `8888` for Jupyter Notebook.
- Access services locally, e.g., pgAdmin on `localhost:8080` or Jupyter on `localhost:8888`.

#### Running Jupyter Notebook
1. Start Jupyter Notebook in the `2_docker_sql` directory:
   ```bash
   jupyter notebook
   ```
2. Access the notebook using the provided URL.
3. Download required datasets using `wget` and proceed with analysis.
4. When necessary, access pgcli with `pgcli -h localhost -U root -d ny_taxi` and analyze if the schema is inside with `\dt\`

#### Installing and Configuring Terraform
1. Download Terraform binaries:
   - Visit the [Terraform Downloads page](https://www.terraform.io/downloads) and look for the binaries link.
   - Download and unzip:
     ```bash
     cd bin/
     wget <terraform-link>
     sudo apt-get install unzip
     unzip <filename>
     ```
2. Transfer credentials to the VM using SFTP:
   ```bash
   sftp de-zoomcamp
   mkdir .gc
   put my-creds.json .gc/my-creds.json
   ```
3. Configure Gcloud:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS=~/.gc/ny-taxi.json
   gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS
   ```
4. Initialize Terraform:
   - Update variables in the cloned repository as needed.
   - You can edit directly from the repo that was cloned, just update the variables.tf and that's it!
   - Run:
     ```bash
     terraform init
     terraform plan
     terraform apply
     ```

#### Shutting Down the VM
- Stop the machine using either:
  - Console interface.
  - Terminal command:
    ```bash
    sudo shutdown now
    ```
