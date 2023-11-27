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

# Substituir variáveis nos arquivos YAML e obter a lista de arquivos modificados
for yaml_file in $(find . -type f \( -name '*.yml' -o -name '*.yaml' \) -not -path '*.github/workflows*' -print); do
  envsubst < "$yaml_file" > "$yaml_file.tmp" && mv "$yaml_file.tmp" "$yaml_file"
  yaml_files+=("$yaml_file")
done

# Verifica se há arquivos YAML modificados
if [ "${#yaml_files[@]}" -gt 0 ]; then
  for yaml_file in "${yaml_files[@]}"; do
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
