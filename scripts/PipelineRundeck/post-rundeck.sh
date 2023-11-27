#!/bin/bash

set -x  # Ativa o modo de depuração para imprimir comandos

# protocol
protocol="https"

# basic rundeck info
rdeck_host="${HOST}"
rdeck_port="4443"
rdeck_api="45"

# specific api call info
rdeck_project="${ENV}"  # Utiliza a variável de ambiente ENV definida no GitHub Actions

# Obtém os arquivos modificados do passo anterior
IFS=',' read -ra modified_files <<< "${{ steps.replace-with-envsubst.outputs.modified_files }}"

# Verifica se há arquivos YAML modificados
if [ "${#modified_files[@]}" -gt 0 ]; then
  for yaml_file in "${modified_files[@]}"; do
    # api call
    curl -kSsv --header "X-Rundeck-Auth-Token:${RUNDECK_TOKEN}" \
      -F xmlBatch=@"$(pwd)/$yaml_file" \
      "$protocol://$rdeck_host:$rdeck_port/api/$rdeck_api/project/$rdeck_project/jobs/import?fileformat=yaml"
  done
else
  echo "Nenhum arquivo YAML modificado encontrado após envsubst."
fi

# Desativa o modo de depuração
set +x
