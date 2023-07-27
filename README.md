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
* Use **.env.template** files as an examples and fill it with actual values (create .env file at repository root level and inside every provider: do, aws, azure, gcp folders)
* NOTE. Commands below assume that Terraform Cloud is used as a storage for states
* Commands below will guide you to configure k8s infrastructure usign DO. By replacing <do> with <aws> you can have AWS based infrastructure

* Install dependencies
  ```
  tln install do --depends
  ```
* Construct DO Dev infrastructure i
  ```
  tln construct do -- --backend cloud --init --plan --apply
  ```
* Verify access to the k8s cluster and install/uninstall ingress
  ```
  tln shell do
  ```
  ```
  tln nginx-ingress-install@k8s
  ```
  ```
  kubectl get pods --all-namespaces
  ```
  ```
  tln nginx-ingress-status@k8s
  ```
  ```
  tln nginx-ingress-uninstall@k8s
  ```
  ```
  ^d
  ```
* Deconstruct DO Dev infrastructure instance
  ```
  tln deconstruct do -- --backend cloud --init --plan --apply
  ```
