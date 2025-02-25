import os
import requests

# URL base do arquivo
base_url = "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/fhv/fhv_tripdata_2019-{:02d}.csv.gz"

# Diretório para salvar os arquivos
output_dir = "data"
os.makedirs(output_dir, exist_ok=True)

# Loop de 1 a 12 para baixar cada mês
for month in range(1, 13):
    # Formata o mês com dois dígitos (01, 02, ..., 12)
    url = base_url.format(month)
    filename = os.path.join(output_dir, f"fhv_tripdata_2019-{month:02d}.csv.gz")
    
    # Faz o download do arquivo
    print(f"Baixando {filename}...")
    response = requests.get(url, stream=True)
    
    if response.status_code == 200:
        with open(filename, "wb") as file:
            for chunk in response.iter_content(chunk_size=8192):
                file.write(chunk)
        print(f"Download concluído: {filename}")
    else:
        print(f"Erro ao baixar {filename}: Status code {response.status_code}")