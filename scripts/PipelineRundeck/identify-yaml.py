import requests
import os

def get_modified_yaml_files(username, repo_name, token):
    url = f'https://api.github.com/repos/{username}/{repo_name}/commits'
    headers = {'Authorization': f'token {token}'}

    # Obtém o último commit
    response = requests.get(url, headers=headers)
    commit = response.json()[0]  # Assume que o primeiro item é o último commit

    # Obtém a lista de arquivos modificados no último commit
    commit_sha = commit['sha']
    commit_url = f'https://api.github.com/repos/{username}/{repo_name}/commits/{commit_sha}'
    commit_response = requests.get(commit_url, headers=headers)
    files = commit_response.json()['files']

    # Filtra os arquivos YAML, excluindo os pipelines na pasta .github/workflows
    yaml_files = [file['filename'] for file in files if file['filename'].lower().endswith(('.yaml', '.yml')) and '.github/workflows' not in file['filename']]

    # Retorna a lista separada por vírgulas
    if yaml_files:
        return ','.join(yaml_files)
    else:
        return None

# Substitua 'LeoBGs1', 'app-cinema' e os.getenv('GH_TOKEN') pelos seus valores reais
username = 'Ll2223'
repo_name = 'teste-cicd'
token = os.getenv('GH_TOKEN')

result = get_modified_yaml_files(username, repo_name, token)

if result is not None:
    print(result)
else:
    print("Nenhum arquivo YAML modificado ou adicionado encontrado no último commit.")
