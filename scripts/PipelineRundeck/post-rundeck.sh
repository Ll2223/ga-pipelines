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

# Obtém os arquivos modificados diretamente do GitHub Actions
IFS=',' read -ra modified_files <<< "$MODIFIED_FILES"

# Verifica se há arquivos YAML modificados
if [ "${#modified_files[@]}" -gt 0 ]; then
  for yaml_file in "${modified_files[@]}"; do
    # Obtém o diretório do arquivo original
    dir=$(dirname "$yaml_file")

    # Cria o arquivo temporário no mesmo diretório do arquivo original
    temp_file="$dir/$(basename "$yaml_file").tmp"

    # api call
    curl -kSsv --header "X-Rundeck-Auth-Token:${RUNDECK_TOKEN}" \
      -F "xmlBatch=@$(pwd)/$yaml_file" \
      "$protocol://$rdeck_host:$rdeck_port/api/$rdeck_api/project/$rdeck_project/jobs/import?fileformat=yaml"

    # Move o arquivo temporário para o arquivo original
    mv "$yaml_file.tmp" "$yaml_file"
  done
else
  echo "Nenhum arquivo YAML modificado encontrado após envsubst."
fi

# Desativa o modo de depuração
set +x
