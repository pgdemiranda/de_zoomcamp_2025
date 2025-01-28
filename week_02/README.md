# 2.1 - Conceptual Material: Introduction to Orchestration and Kestra
## 2.1.1 - Workflow Orchestration Introduction

- What is orchestration?

- What is Kestra
    - All-in One automation & Orchestration Platform
    - ETL/ELT
    - API Orchestration
    - Scheduled & Event-Driven Workflows
    - Batch Data Pipelines
    - Interactive Conditional Inputs

- What will we cover this week?
    - Introduction to Kestra
    - ETL: Extract data and load it to Postgres
    - ETL: Extract data and load it to Google Cloud
    - Parametrizing Execution
    - Scheduling and Backfills
    - Instrall Kestra on the Cloud and sync your Flows with Git

## 2.1.2 - Learn Kestra
1. [Getting Started with Kestra](https://go.kestra.io/de-zoomcamp/quickstart)
2. [Kestra Tutorial Fundamentals](https://go.kestra.io/de-zoomcamp/tutorial)
3. [Install Kestra with Docker Compose](https://go.kestra.io/de-zoomcamp/docker-compose)
4. [What is an Orchestrator?](https://go.kestra.io/de-zoomcamp/what-is-an-orchestrator)

```
.
├── flows/
│   ├── 01_getting_started_data_pipeline.yaml
│   ├── 02_postgres_taxi.yaml
│   ├── 02_postgres_taxi_scheduled.yaml
│   ├── 03_postgres_dbt.yaml
│   ├── 04_gcp_kv.yaml
│   ├── 05_gcp_setup.yaml
│   ├── 06_gcp_taxi.yaml
│   ├── 06_gcp_taxi_scheduled.yaml
│   └── 07_gcp_dbt.yaml
```

# 2.2 - Hands-On Coding Project: Build Data Pipelines with Kestra
This week, we're gonna build ETL pipelines for Yellow and Green Taxi data from NYC’s Taxi and Limousine Commission (TLC). You will:
- Extract data from CSV files.
- Load it into Postgres or Google Cloud (GCS + BigQuery).
- Explore scheduling and backfilling workflows.

# 2.3 - ETL Pipelines in Kestra: detailed walkthrough
## 2.2.3 ETL With Postgres

Apesar do vídeo ser curto, ele traz muitas informações consigo e pra ser sincero me sobrecarregou. Precisei assistir algumas vezes para entender a sintaxe, e vou detalhar abaixo partes do código para que possa fazer mais sentido.

1. **id**: O id é um identificador único para o flow. Ele é usado para diferenciar um flow de outro dentro do mesmo namespace.

2. **namespace**: O namespace é uma forma de organizar e agrupar flows relacionados. Ele atua como um "espaço de nomes" que ajuda a evitar conflitos entre flows com o mesmo id em diferentes contextos.

    No exemplo dado no vídeo, o namespace é zoomcamp. Isso significa que todos os flows relacionados ao "zoomcamp" podem ser agrupados sob esse namespace.

    Namespaces são úteis em ambientes onde há muitos flows ou quando você deseja separar flows por equipes, projetos ou ambientes (como dev, prod, etc.).

3. **description**: Description é uma descrição textual do flow. Ela é usada para documentar o propósito, funcionalidade ou qualquer informação relevante sobre o flow.

4. **inputs**: Esses inputs permitem que o usuário forneça valores personalizados ao executar o flow. Os inputs aqui são taxi, year e month!

    id: Identificador único do input. Ele é usado para referenciar o valor fornecido pelo usuário dentro do flow.

    type: Tipo do input. No caso, é SELECT, o que significa que o usuário escolherá um valor de uma lista de opções.

    displayName: Nome amigável exibido na interface do usuário para esse input.

    values: Lista de valores possíveis que o usuário pode escolher.

    defaults: Valor padrão que será selecionado automaticamente se o usuário não escolher outro.

5. **variables**: Variáveis são valores dinâmicos que podem ser definidos e reutilizados em diferentes partes de um flow. Com elas posso: evitar repetição de código, tornar o flow dinâmico, facilitar a manutenção, melhorar a legibilidade. Essas são as variáveis presentes nesse flow com exemplos para ajudar no entendimento:

- file

    Definição: "{{inputs.taxi}}_tripdata_{{inputs.year}}-{{inputs.month}}.csv"

    Descrição: Essa variável cria o nome de um arquivo CSV dinamicamente, com base nos valores dos inputs taxi, year e month.

    Exemplo:

        Se taxi = yellow, year = 2019 e month = 01, o valor de file será:

        yellow_tripdata_2019-01.csv

- staging_table

    Definição: "public.{{inputs.taxi}}_tripdata_staging"

    Descrição: Essa variável define o nome de uma tabela de staging (tabela temporária) no banco de dados. O nome da tabela é construído com base no valor do input taxi.

    Exemplo:

        Se taxi = green, o valor de staging_table será:

        public.green_tripdata_staging

- table

    Definição: "public.{{inputs.taxi}}_tripdata"

    Descrição: Essa variável define o nome da tabela final no banco de dados. Assim como a staging_table, o nome é construído com base no valor do input taxi.

    Exemplo:

        Se taxi = yellow, o valor de table será:

        public.yellow_tripdata

- data

    Definição: "{{outputs.extract.outputFiles[inputs.taxi ~ '_tripdata_' ~ inputs.year ~ '-' ~ inputs.month ~ '.csv']}}"

    Descrição: Essa variável acessa o arquivo CSV gerado por uma task chamada extract. O nome do arquivo é construído dinamicamente com base nos valores dos inputs taxi, year e month.

    Explicação detalhada:

        outputs.extract.outputFiles: Acessa a lista de arquivos de saída da task extract.

        inputs.taxi ~ '_tripdata_' ~ inputs.year ~ '-' ~ inputs.month ~ '.csv': Concatena os valores dos inputs para formar o nome do arquivo.

    Exemplo:

        Se taxi = green, year = 2020 e month = 05, o valor de data será:
        Copy

        green_tripdata_2020-05.csv

6. **tasks**: Tasks são unidades básicas de trabalho que realizam uma ação específica dentro de um flow. Elas são como "blocos de construção" que você combina para criar um fluxo de trabalho automatizado. Cada task tem uma função específica, como baixar um arquivo, executar um comando, carregar dados em um banco de dados, enviar uma notificação, etc.

- set_label

    Definição: Define labels (etiquetas) para a execução do flow. Labels são metadados que podem ser usados para organizar, filtrar ou identificar execuções específicas.

    id: set_label:

        Identificador único da task. Neste caso, a task é chamada de set_label.

    type: io.kestra.plugin.core.execution.Labels:

        O tipo da task é Labels, que é usada para definir labels na execução do flow.

    labels:

        Aqui são definidos os labels que serão associados à execução.

        file: "{{render(vars.file)}}":

            Define um label chamado file com o valor da variável file. O render é usado para processar o valor da variável dinamicamente.

            Por exemplo, se vars.file for yellow_tripdata_2019-01.csv, o label será:

            file: yellow_tripdata_2019-01.csv

        taxi: "{{inputs.taxi}}":

            Define um label chamado taxi com o valor do input taxi.

            Por exemplo, se inputs.taxi for yellow, o label será:

            taxi: yellow


- extract - > baixa um arquivo compactado (.gz) de um repositório no GitHub, descompacta o arquivo e o salva como um arquivo CSV. O nome do arquivo e o tipo de táxi são definidos dinamicamente com base nos inputs e variáveis.

    id: extract:

        Identificador único da task. Neste caso, a task é chamada de extract.

    type: io.kestra.plugin.scripts.shell.Commands:

        O tipo da task é Commands, que permite executar comandos shell.

    outputFiles:

        Define quais arquivos gerados pela task devem ser capturados como saída.

        Neste caso, "*.csv" indica que todos os arquivos com extensão .csv serão considerados como saída.

    taskRunner:

        Define o ambiente onde o comando será executado.

        type: io.kestra.plugin.core.runner.Process:

            O comando será executado em um processo local.

    commands:

        Lista de comandos shell a serem executados.

**Uma observação importante**: foi adicionado um **IF** no type das próximas tasks para diferenciar as tarefas que serão feitas entre green taxis e yellow taxis. Então o que for feito aqui para o yellow taxi, também tem uma versão green taxi, selecionei só yellow taxi para não ficar redundante!

    id: if_yellow_taxi:

        Identificador único da task. Neste caso, a task é chamada de if_yellow_taxi.

    type: io.kestra.plugin.core.flow.If:

        O tipo da task é If, que permite executar um bloco de tasks condicionalmente.

    condition: "{{inputs.taxi == 'yellow'}}":

        Define a condição que será avaliada.

        Neste caso, a condição verifica se o input taxi é igual a "yellow".

        Se a condição for verdadeira, as tasks dentro do bloco then serão executadas.

    then:

        Bloco de tasks que será executado se a condição for verdadeira.

        Neste caso, várias tasks relacionadas ao táxi amarelo são executadas.

**OK, MAS O QUE ACONTECE?!**
    
1. yellow_create_table

O que faz?: Cria uma tabela no PostgreSQL se ela ainda não existir.

Detalhes:
    A tabela é criada com base no nome definido pela variável vars.table.
    A tabela contém colunas como unique_row_id, filename, VendorID, tpep_pickup_datetime, etc.

2. yellow_create_staging_table

    O que faz?: Cria uma tabela de staging (temporária) no PostgreSQL se ela ainda não existir.

    Detalhes:

        A tabela de staging tem a mesma estrutura da tabela principal.

        O nome da tabela é definido pela variável vars.staging_table.

3. yellow_truncate_staging_table

    O que faz?: Limpa (remove todos os dados) da tabela de staging.

    Detalhes:

        Isso garante que a tabela de staging esteja vazia antes de carregar novos dados.

4. yellow_copy_in_to_staging_table

    O que faz?: Carrega os dados do arquivo CSV (definido por vars.data) na tabela de staging.

    Detalhes:

        O formato do arquivo é CSV.

        O arquivo tem um cabeçalho (header: true).

        As colunas do CSV são mapeadas para as colunas da tabela de staging.

5. yellow_add_unique_id_and_filename

    O que faz?: Adiciona um identificador único (unique_row_id) e o nome do arquivo (filename) a cada linha da tabela de staging.

    Detalhes:

        O unique_row_id é gerado usando uma função de hash (md5) com base em várias colunas.

        O filename é o nome do arquivo CSV (definido por vars.file).

6. yellow_merge_data

    O que faz?: Mescla os dados da tabela de staging na tabela principal.

    Detalhes:

        Se uma linha com o mesmo unique_row_id já existir na tabela principal, ela não será inserida novamente (evita duplicação).

        Se a linha não existir, ela será inserida na tabela principal.

- purge_files -> Essa task remove os arquivos de saída gerados durante a execução atual do flow. Ela é usada para limpar o armazenamento de arquivos temporários ou desnecessários após a execução.

    id: purge_files:
        
        Identificador único da task. Neste caso, a task é chamada de purge_files.
        
    type: io.kestra.plugin.core.storage.PurgeCurrentExecutionFiles:
        
        O tipo da task é PurgeCurrentExecutionFiles, que é usada para remover arquivos de saída da execução atual.

7. **pluginDefaults**> porque estamos armazenando os dados em um banco postgres que não é o que veio junto com o docker compose do Kestra, precisamos nos conectar com ele e usar nossas credenciais. Como eu estou acessando o banco por fora do network, uma simples url deu certo para mim:

- Essa é a versão disponibilizada no docker compose do curso:
    ```
    - type: io.kestra.plugin.jdbc.postgresql
        values:
            url: jdbc:postgresql://host.docker.internal:5432/postgres-zoomcamp
            username: kestra
            password: k3str4
    ```
- Essa é a minha versão:
    ```
    - type: io.kestra.plugin.jdbc.postgresql
        values:
          url: jdbc:postgresql://db-postgres:5432/ny-taxi_db
          username: postgres
          password: postgres
    ```

## 2.2.4 Backfills with Postgres

O vídeo é mais curto e o código de backfill é um complemento do flow apresentado anteriormente. Eu vou tentar ir atrás dos componentes que estão faltando e por qual razão eles estão ali. Aqui não vamos esperar o flow rodar no horário esperado, vamos rodar à partir da aba de triggers, selecionamos "backfill executions" colocamos o período desejado para a extração dos dados. Para identificar melhor, na label de execução, assinalamos como backfill true e é isso. O período escolhido foram todos os meses de 2019 para green taxi. Na aba de Executions podemos ver o processo sendo executado.

**Atenção**, aqui o truncate é usado para  limpar a tabela de staging antes de carregar novos dados.

    Tabela de staging:

        A tabela de staging (staging_table) é uma tabela temporária usada para carregar dados brutos antes de processá-los e movê-los para a tabela final (table).

        Ela é usada como uma área de preparação para garantir que os dados sejam validados, transformados ou enriquecidos antes de serem inseridos na tabela principal.

    Por que limpar a tabela de staging?

        Evitar duplicação de dados: Se a tabela de staging não for limpa antes de carregar novos dados, os dados antigos podem permanecer e serem mesclados com os novos, causando duplicação.

        Garantir consistência: Limpar a tabela de staging antes de carregar novos dados garante que apenas os dados mais recentes sejam processados.

        Otimização de desempenho: O TRUNCATE é mais eficiente do que o DELETE para remover todos os registros de uma tabela, especialmente em tabelas grandes.

- concurrency:
    limit: 1

    Define que apenas uma execução do flow pode ocorrer por vez.

    Se uma nova execução for disparada enquanto outra ainda está em andamento, a nova execução ficará em espera até que a execução atual seja concluída.

    Para que serve? Evitar conflitos: se o flow acessa recursos compartilhados (como um banco de dados ou arquivos), executar múltiplas instâncias ao mesmo tempo pode causar problemas (por exemplo, tentar escrever no mesmo arquivo ou tabela simultaneamente).

    Sem concurrency:
    Execução 1 começa às 10:00 e demora 10 minutos.
    Execução 2 começa às 10:05, enquanto a Execução 1 ainda está em andamento.
        Isso pode causar conflitos ou sobrecarga.

    Com concurrency: 1:
    Execução 1 começa às 10:00 e demora 10 minutos.
    Execução 2 só começa às 10:10, após a conclusão da Execução 1.

- triggers
    Triggers são mecanismos que disparam a execução de um flow automaticamente. Eles podem ser baseados em:

        Agendamento (cron). <- que é o nosso caso, pois usamos Schedule no código usando cron

        Eventos (como a chegada de um arquivo em um diretório).

        Condições específicas.

## 2.2.5 dbt Models with Postgres in Kestra
Não tem muita coisa para ser adicionado aqui, pra ser sincero... mas foi necessário fazer um ajuste no arquivo yaml do flow (por alguma razão não estou conseguindo, abaixo minha modificação para Linux porque ele não estava reconhecendo host.docker.internal), e no arquivo yml do dbt (ajuste das credenciais do postgres).

    profiles: |
      default:
        outputs:
          dev:
            type: postgres
            host: 172.17.0.1 # era host.docker.internal
            user: postgres
            password: postgres
            port: 5432
            dbname: ny-taxi_db
            schema: public
            threads: 8
            connect_timeout: 10
            priority: interactive
        target: dev

# 2.4 - ETL Pipelines in Kestra: Google Cloud Platform
## 2.6 - ETL with BigQuery
KV - Key-Value
O Kestra tem uma aba chamada Namespaces e lá há o espaço do Zoomcamp para armazenarmos credenciais como variáveis de ambiente.

Para o flow 04_gcp_kv.yaml, ele foi sobre repassar as credenciais, o nome do bucket e do BigQuery.
- criamos uma nova service account no IAM, demos role de Storage e BigQuery Admin, e ele adicionou um e-mail como o administrador (ele colocou o próprio e-mail, no caso).
- fazemos o download de uma nova chave em json, e colamos toda a informação da chave no próprio flow (perigo de segurança?) na task de gcp_creds -> ou podemos adicionar diretamente na KV Store.
- preenchemos todos os campos do flow:
    - gcp_creds: json da chave
    - gcp_project_id: id do projeto
    - gco_location: location
    - gcp_bucket_name: um nome de bucket que já não exista
    - gcp_dataset: nome do dataset no BigQuery

Para o flow 05_gcp_setup.yaml, se todas as variáveis estiverem setadas no KV Store, esse flow apenas constrói toda a infraestrutura!



