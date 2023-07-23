# Description
Cloud agnostic, enterprise grade, bulletproof, battle tested IaC skeleton for SaaS solutions.
![Infrastructure Instance](ii.png)

## Features
Framework:
* supports AWS, Azure, GCP, Digitalocean provider
* provides Multi-tenancy feature via layers architecture
* implements nested configurations for Infrastructure Instance and Environments
* is based on IaC (Terraform)
* includes support of multiple backend providers - Local, Cloud, Remote, PG, S3

## Quick start
* Install [tln](https://www.npmjs.com/package/tln-cli)
* Goto **projects** and clone repository
  ```
  git clone git@github.com:project-talan/tln-clouds.git
  ```
* Use **.env.template** files as an examples and fiil them with actial values
* NOTE. Commands below assume that Terraform Cloud is used as a storage for states

* Install dependencies
  ```
  tln install do --depends
  ```
* Construct DO Dev infrastructure i
  ```
  tln construct do -- --backend cloud --init --plan --apply
  ```
* Install Nginx ingress controller
  ```
  tln nginx-ingress-install@k8s do
  ```
* Verify access to the k8s cluster and ingress status
  ```
  tln shell do
  ```
  ```
  kubectl get pods --all-namespaces
  ```
  ```
  tln nginx-ingress-status@k8s
  ```
  ```
  ^d
  ```
* Uninstall Nginx ingress controller
  ```
  tln nginx-ingress-uninstall@k8s do
  ```

* Deconstruct DO Dev infrastructure instance
  ```
  tln deconstruct do -- --backend cloud --init --plan --apply
  ```
