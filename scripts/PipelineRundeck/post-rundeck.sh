#!/bin/sh

# protocol
protocol="https"

# basic rundeck info
rdeck_host="${HOST}"
rdeck_port="4443"
rdeck_api="38"

# specific api call info
rdeck_project="${ENV}"  # Utiliza a variável de ambiente ENV definida no GitHub Actions

# Obtendo a lista de arquivos YAML diretamente do script Python
yaml_files_csv=$(python templates/scripts/PipelineRundeck/identify-yaml.py)  # Modifique conforme necessário

# Iterando sobre a lista de arquivos e fazendo a chamada de API para cada um
IFS=',' read -ra yaml_files <<< "$yaml_files_csv"
for yaml_file in "${yaml_files[@]}"; do
  # api call
  curl -kSsv --header "X-Rundeck-Auth-Token:${RUNDECK_TOKEN}" \
   -F xmlBatch=@"$yaml_file" \
   "$protocol://$rdeck_host:$rdeck_port/api/$rdeck_api/project/$rdeck_project/jobs/import?fileformat=yaml"
done
