## Install gcloud
### Linux
Install Guide [Found Here](https://cloud.google.com/sdk/docs/install)
```
sudo apt-get install -y apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-sdk
```
Then login to the GCLOUD toolkit with:
```
gcloud init
```

### Mac OSX
Install Guide [Found Here](https://cloud.google.com/sdk/docs/install-sdk#mac)

## Install TF
### Linux
Install Guide [Found Here](https://learn.hashicorp.com/tutorials/terraform/install-cli)
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
terraform -install-autocomplete
```
### Mac OSX
Install Guide [Found Here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

## Install Kubectl
### Linux
```bash
sudo apt-get install kubectl
```
### Mac OSX
Install Guide [Found Here](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/)

## Install SKAFFOLD
### Linux
```bash
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
sudo install skaffold /usr/local/bin/
```
### Mac OSX
```bash
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-darwin-amd64 && \
sudo install skaffold /usr/local/bin/
```


[Main Page](../../)