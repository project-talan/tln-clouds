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

* Install dependencies
  ```
  tln install do --depends
  ```
* Construct DO Infrastructure Instance (remove -u when you are ready to exually interact with cloud provider)
  ```
  tln construct do -u -- --backend cloud
  ```
* Verify access to the k8s cluster
  ```
  tln shell do
  ```
  ```
  kubectl get pods --all-namespaces
  ```
  ```
  ^d
  ```
* Deconstruct DO Infrastructure Instance (remove -u when you are ready to exually interact with cloud provider)
  ```
  tln deconstruct do -u -- --backend cloud
  ```
