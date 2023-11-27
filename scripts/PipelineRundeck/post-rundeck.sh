#!/bin/bash

set -x  # Ativa o modo de depuração para imprimir comandos

# Carrega as variáveis de ambiente do arquivo de ambiente gerado
source "$GITHUB_ENV"

# protocol
protocol="https"

# basic rundeck info
rdeck_host="${HOST}"
rdeck_port="4443"
rdeck_api="45"

# specific api call info
rdeck_project="${ENV}"  # Utiliza a variável de ambiente ENV definida no GitHub Actions

# Obtém os caminhos dos arquivos modificados
IFS=$'\n' read -d '' -ra modified_files < "$MODIFIED_FILES_PATH"

# Verifica se há arquivos YAML modificados
if [ "${#modified_files[@]}" -gt 0 ]; then
  for yaml_file in "${modified_files[@]}"; do
    # api call
    curl -kSsv --header "X-Rundeck-Auth-Token:${RUNDECK_TOKEN}" \
      -F "xmlBatch=@$yaml_file" \
      "$protocol://$rdeck_host:$rdeck_port/api/$rdeck_api/project/$rdeck_project/jobs/import?fileformat=yaml"
  done
else
  echo "Nenhum arquivo YAML modificado encontrado após envsubst."
fi

# Desativa o modo de depuração
set +x
