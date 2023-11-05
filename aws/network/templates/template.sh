#!/bin/bash

# tinyproxy
sudo apt update
sudo apt install -y tinyproxy
sudo systemctl enable tinyproxy
sudo systemctl start tinyproxy
# kubectl
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
sudo install kubectl /usr/local/bin
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl
# helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm completion bash | sudo tee /etc/bash_completion.d/helm