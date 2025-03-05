# 5 - Batch

## 5.1.1 - Introduction to Batch Processing
Processamento de Dados: Batch e Streaming

Quando falamos de Batch, estamos falando de pacotes de atualizações de dados. São dados disponibilizados semanalmente, diariamente, toda hora, 3 vezes por hora, a cada 5 minutos… em suma: com alguma periodicidade de atualização. Diferente do streaming que não para de nos entregar os dados.

tecnologias:
- scripts com Python (Kubernets, AWS Batches)
- SQL
- Spark
- Kafka/Flink

workflow de batches: datalake -> python -> sql (dbt) -> spark -> python

1. vantagens:
convenientes, fáceis de gerenciar
podemos re-executar se algo der errado (é seguro)
fácil de escalar

2. desvantagens:
pode levar algum tempo para tentarmos novamente, se algo der errado (o tempo de cada etapa do workflow)
A maior parte da indústria (~80%) utiliza batch por causa das vantagens que oferece. E daí a importância de aprender esse método

## 5.1.2 - Introduction to Spark
engine multi linguagem (Java e Scala, mas também Python e R) de processamento de dados
PySpark é bastante popular
essa engine funciona tanto para Batch, como para Streaming
quando usar?
quando os dados estiverem em um datalake (s3 ou gcp)
em data warehouses usamos SQL, aqui para data lake usamos Hive, Presto/Athena, executamos em SQL e jogamos para data lake, mas quando não podemos expressar em SQL (colocamos em diferentes modelos, alguma expressão que não existe e tal), usamos Spark:
também usado para Machine Learning, já que não dá para expressar isso em SQL
um workflow aqui poderia ser:
dados crús -> data lake -> SQL Athena -> Spark -> Python para treinar ML -> Spark para aplicar o ML no data lake

## 5.2.1 - (Optional) Installing Spark on Linux
preciso do JDK 11 
wget https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz
tive um problema sucinto para exportar o PATH, precisei exportar o path depois de mover o spark para uma pasta
sudo mv spark-3.5.1-bin-hadoop3 /opt/spark
e então registrei tudo no .bashrc
sudo nano ~/.bashrc
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
instalar o pyspark 
há a necessidade de colocar o path do Pyspark junto com Python, me pareceu excessivo, que vai funcionar perfeitamente em uma VM, mas que pode bagunçar minha máquina local.
optei por fazer o download de pyspark na minha máquina através do Conda, vamos ver se funciona.

## 5.3.1 - First Look at Spark/PySpark
Como usar Spark e alguns comandos básicos de leitura e manipulação de schema. 

O PySpark usa uma sintaxe muito parecida com o que já conhecemos com o Pandas, mas ele lida com os arquivos de uma maneira muito diferente, sendo a função mais útil para nós a de particionamento.

Aqui o que foi mais importante foi a carga do arquivo, manipulação dos tipos de dados e particionamento. O arquivo original lidou com arquivos .csv, sendo que atualmente os datasets públicos disponibilizados são em .parquet, de modo que meu trabalho ficou ainda mais simples so que o que foi comentado em aula. O dataframe sempre é lido com várias opções entre elas `header True` e `inferSchema True` para pegarmos o schema, usamos `printSchema`, e no final para vermos o que está sendo pedido, precisamos pedir o show
a inicialização do spark é feita com 

``` python
spark = SparkSession.builder \
   .master("local[*]") \
   .appName('test') \
   .getOrCreate()
```

**isso cria uma sessão local em localhost:4040 onde podemos acompanhar todos os processos em detalhes.**

## 5.3.2 - Spark Dataframes
Actions vs Transformations:
Transformations: são do tipo lazy, você constrói elas concatenando, mas elas não realizam ações. São select, filter, join, group by, etc
Actions: são do tipo eager (executadas imediatamente), elas são acionadas assim que você concatena elas. São show, take, head, write, etc
Posso escrever as consultas em SQL também e posso importar as funções da biblioteca do spark como F e aplicar diretamente na consulta
por exemplo, nós adicionamos duas novas colunas: pickup_date e dropoff_date com .withColumn() e F.to_date() dentro de withColumn.

``` python
df \
   .withColumn('pickup_date', F.to_date(df.pickup_datetime)) \
   .withColumn('dropoff_date', F.to_date(df.dropoff_datetime)) \
   .select('pickup_date', 'dropoff_date', 'PULocationID', 'DOLocationID') \
   .show()
```
Podemos escrever nossas próprias funções, ainda que isso não seja algo usual no trabalho com data warehouses


# Running Spark in the Cloud

### Connecting to Google Cloud Storage 

Uploading data to GCS:

```bash
gsutil -m cp -r pq/ gs://dtc_data_lake_de-zoomcamp-nytaxi/pq
```

Download the jar for connecting to GCS to any location (e.g. the `lib` folder):

```bash
gsutil cp gs://hadoop-lib/gcs/gcs-connector-hadoop3-2.2.5.jar
```

See the notebook with configuration in [09_spark_gcs.ipynb](09_spark_gcs.ipynb)

(Thanks Alvin Do for the instructions!)


### Local Cluster and Spark-Submit

Creating a stand-alone cluster ([docs](https://spark.apache.org/docs/latest/spark-standalone.html)):

```bash
./sbin/start-master.sh
```

Creating a worker:

```bash
URL="spark://de-zoomcamp.europe-west1-b.c.de-zoomcamp-nytaxi.internal:7077"
./sbin/start-slave.sh ${URL}

# for newer versions of spark use that:
#./sbin/start-worker.sh ${URL}
```

Turn the notebook into a script:

```bash
jupyter nbconvert --to=script 06_spark_sql.ipynb
```

Edit the script and then run it:

```bash 
python 06_spark_sql.py \
    --input_green=data/pq/green/2020/*/ \
    --input_yellow=data/pq/yellow/2020/*/ \
    --output=data/report-2020
```

Use `spark-submit` for running the script on the cluster

```bash
URL="spark://de-zoomcamp.europe-west1-b.c.de-zoomcamp-nytaxi.internal:7077"

spark-submit \
    --master="${URL}" \
    06_spark_sql.py \
        --input_green=data/pq/green/2021/*/ \
        --input_yellow=data/pq/yellow/2021/*/ \
        --output=data/report-2021
```

### Data Proc

Upload the script to GCS:

```bash
TODO
```

Params for the job:

* `--input_green=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/green/2021/*/`
* `--input_yellow=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/yellow/2021/*/`
* `--output=gs://dtc_data_lake_de-zoomcamp-nytaxi/report-2021`


Using Google Cloud SDK for submitting to dataproc
([link](https://cloud.google.com/dataproc/docs/guides/submit-job#dataproc-submit-job-gcloud))

```bash
gcloud dataproc jobs submit pyspark \
    --cluster=de-zoomcamp-cluster \
    --region=europe-west6 \
    gs://dtc_data_lake_de-zoomcamp-nytaxi/code/06_spark_sql.py \
    -- \
        --input_green=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/green/2020/*/ \
        --input_yellow=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/yellow/2020/*/ \
        --output=gs://dtc_data_lake_de-zoomcamp-nytaxi/report-2020
```

### Big Query

Upload the script to GCS:

```bash
TODO
```

Write results to big query ([docs](https://cloud.google.com/dataproc/docs/tutorials/bigquery-connector-spark-example#pyspark)):

```bash
gcloud dataproc jobs submit pyspark \
    --cluster=de-zoomcamp-cluster \
    --region=europe-west6 \
    --jars=gs://spark-lib/bigquery/spark-bigquery-latest_2.12.jar \
    gs://dtc_data_lake_de-zoomcamp-nytaxi/code/06_spark_sql_big_query.py \
    -- \
        --input_green=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/green/2020/*/ \
        --input_yellow=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/yellow/2020/*/ \
        --output=trips_data_all.reports-2020
```

There can be issue with latest Spark version and the Big query connector. Download links to the jar file for respective Spark versions can be found at:
[Spark and Big query connector](https://github.com/GoogleCloudDataproc/spark-bigquery-connector)



