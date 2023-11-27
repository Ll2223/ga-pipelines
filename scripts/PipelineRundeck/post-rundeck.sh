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

# Obtém o caminho do arquivo que contém os caminhos dos arquivos modificados
modified_files_path="${GITHUB_WORKSPACE}/modified_files.txt"  # Corrigido para o caminho correto

# Verifica se o arquivo existe
if [ -f "$modified_files_path" ]; then
  # Lê os caminhos dos arquivos modificados
  IFS=$'\n' read -d '' -ra modified_files < "$modified_files_path"

  # Verifica se há arquivos YAML modificados
  if [ "${#modified_files[@]}" -gt 0 ]; then
    for yaml_file in "${modified_files[@]}"; do
      # api call
      response=$(curl -kSsv --header "X-Rundeck-Auth-Token:${RUNDECK_TOKEN}" \
        -F "xmlBatch=@$yaml_file" \
        "$protocol://$rdeck_host:$rdeck_port/api/$rdeck_api/project/$rdeck_project/jobs/import?fileformat=yaml" 2>&1)

      # Captura e imprime o código de saída do último comando
      curl_exit_code=$?

      # Verifica o conteúdo da resposta para erros de autorização
      if [[ $response == *"\"error\":true"* && $response == *"\"errorCode\":\"unauthorized\""* ]]; then
        echo "Erro de autorização: Token não autorizado."
        exit 1
      fi

      # Verifica o código de saída do curl e termina com código de saída apropriado
      if [ $curl_exit_code -ne 0 ]; then
        echo "Erro no comando curl: $curl_exit_code"
        exit $curl_exit_code
      fi
    done
  else
    echo "Nenhum arquivo YAML modificado encontrado após envsubst."
    exit 1
  fi
else
  echo "Arquivo de caminhos modificados não encontrado."
  exit 1
fi

# Desativa o modo de depuração
set +x

# Captura e imprime o código de saída do script manualmente
script_exit_code=$?
echo "Código de saída do script: $script_exit_code"

# Retorna 0 (sucesso) se o código de saída for 0, caso contrário, retorna o código de saída
[ $script_exit_code -eq 0 ] || exit $script_exit_code
