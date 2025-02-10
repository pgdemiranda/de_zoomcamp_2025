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

## 4.1 - Introduction to analytics engineering
### Tooling:
1. Data Loading
2. Data Storing: Snowflake, Bigquery, Redshift
3. Data Modelling: DBT, Terraform
4. Data Presentation: Data Studio, Looker, Mode, Tableau

### Conceitos de Data Modelling:
- ETL -> mais estável e ajustado à análise, alta necessidade de armazenamento e processamento de computador
- ELT -> mais rápido e flexível para a análise, baixo custo e manutenção

### Modelagem Dimensional de Kimball
- objetivo: entregar dados interpretáveis a usuários de negócio
- entregar a performance de queries rápidas
- aproximação: priorizar interpretabilidade e performance mais que redundância de dados (3NF)
- outras aproximações: Bill Inmon e Data Vault

### Elementos da Modelagem de Dados Dimensionais
- Tabelas-fato: fatos, métricas e medidas, corresponde a processos de negócio, e são VERBOS
- Tabelas-dimensões: são entidades do negócio, provendo contexto de negócio ao processo, são NOMES
- Arquitetura:
    1. STAGE AREA: dados crús, não são expostos
    2. PROCESSING AREA: modelos de dados feitos sobre os dados crús, focados em eficiência, mantendo padrões
    3. PRESENTATION AREA: apresentação final, exposto ao time de negócio e stakeholders

## 4.1.2 - What is DBT?
Transforma tabelas em modelos, onde cada modelo é um arquivo '.sql` com um SELECT, o DBT compila nossa seleção e joga ele de volta para o Data Warehouse

Há duas opções para rodar o DBT:
1. DBT Core -> rodando localmente
2. DBT Cloud -> utilizando uma gui web-based