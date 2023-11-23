import requests
import os

def get_modified_yaml_files(repo_name, token):
    url = f'https://api.github.com/repos/{repo_name}/commits'
    headers = {'Authorization': f'token {token}'}

    # Obtém a lista de commits
    response = requests.get(url, headers=headers)

    # Verifica se há pelo menos um commit
    if response.status_code == 200 and response.json():
        # Assume que o primeiro item é o último commit
        commit = response.json()[0]

        # Obtém a lista de arquivos modificados no último commit
        commit_sha = commit['sha']
        commit_url = f'https://api.github.com/repos/{repo_name}/commits/{commit_sha}'
        commit_response = requests.get(commit_url, headers=headers)
        files = commit_response.json()['files']

        # Filtra os arquivos YAML, excluindo os pipelines na pasta .github/workflows
        yaml_files = [file['filename'] for file in files if file['filename'].lower().endswith(('.yaml', '.yml')) and '.github/workflows' not in file['filename']]

        # Retorna a lista separada por vírgulas
        if yaml_files:
            return ','.join(yaml_files)
        else:
            return None
    else:
        # Sem commits encontrados
        return None

# Substitua 'app-cinema' e os.getenv('GH_TOKEN') pelos seus valores reais
repo_name = os.environ.get('GITHUB_REPOSITORY')
token = os.getenv('GH_TOKEN')

result = get_modified_yaml_files(repo_name, token)

if result is not None:
    print(result)
else:
    print("Nenhum arquivo YAML modificado ou adicionado encontrado no último commit.")
