# ci-aws-test


## Infra

Crea un [Personal access token](https://github.com/settings/tokens) con los *scopes* **admin:repo_hook** y **repo** y guárdalo en Systems Manager Parameter Store con el nombre `GitHubToken`. Antes de ejecutar Terraform, debes tener la variable de entorno `GITHUB_TOKEN` disponible. Puedes establecerla con el siguiente comando:

```bash
export GITHUB_TOKEN=$(aws ssm get-parameter --name "GitHubToken" --with-decryption --query "Parameter.Value"  --output text)
```
