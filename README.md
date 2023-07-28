# Description
Cloud agnostic IaC based SaaS skeleton.
![Infrastructure Instance](ii.png)

## Features
Framework:
* supports AWS, DO (Azure, GCP - in progress)
* provides Multi-tenancy feature via layers architecture (provider, network, managed, appl, tenant)
* implements easy-to-construct multiple environment approach (single env var)
* is based on IaC (Terraform)
* supports of multiple backend providers - Local, Cloud (PG, S3 - in progress)

## Quick start
* Install [tln](https://www.npmjs.com/package/tln-cli)
* Goto **projects** folder from tln-cli installation above and clone repository
  ```
  git clone --depth 1 --branch v23.7.0 git@github.com:project-talan/tln-clouds.git
  ```
* Use **.env.template** file as an examples and fill it with actual values
  * dfdfdf
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
