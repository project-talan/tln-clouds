# Description
## Cloud agnostic IaC based SaaS skeleton.
![Infrastructure Instance](ii.png)

## Features
* supports AWS, DO (Azure, GCP - in progress)
* provides Multi-tenancy feature via layers architecture (Provider, Network, Managed, Appl, Tenant)
* implements easy-to-construct multiple environment approach, controls by one environment variable - **TF_VAR_env_id**
* IaC - Terraform, Helm
* supports of multiple backend providers - Local, Cloud, PG (S3 - in progress)

## Quick start
* Install [tln](https://www.npmjs.com/package/tln-cli)
* Goto **projects** folder from tln-cli installation above and clone repository
  ```
  git clone --depth 1 --branch v23.9.0 git@github.com:project-talan/tln-clouds.git
  ```
> Important<br>
> Commands below assume that Terraform Cloud is used as a storage for states<br/>
> By skipping **--backend cloud** local backend will be used
* Use **.env.template** file as an examples and fill it with actual values
  * root .env
    ```
    TF_VAR_org_id=<your_terraform_cloud_org>
    TF_VAR_project_id=tln-clouds
    TF_VAR_env_id=dev
    TF_VAR_tenant_id=

    TF_TOKEN_app_terraform_io=<your_terraform_cloud_token>
    ```
### Digital Ocean
  * Create **do/.env** file using **do/.env.template** as an example
    ```
    DIGITALOCEAN_TOKEN=<your_do_token>

    TF_VAR_do_region=nyc3
    TF_VAR_do_k8s_version=1.27.4-do.0
    TF_VAR_do_k8s_nodes_min=1
    TF_VAR_do_k8s_nodes_max=2
    TF_VAR_do_k8s_nodes_size=s-2vcpu-2gb
    ```
* Install dependencies
  ```
  tln install do --depends
  ```
* Construct DO Dev infrastructure instance
  ```
  tln construct do -- --backend cloud --init --plan --apply
  ```
* Verify access to the k8s cluster and install/uninstall ingress
  ```
  tln shell do
  ```
  ```
  tln nginx-ingress-install@k8s -- --ver 4.7.2
  ```
  ```
  kubectl get pods --all-namespaces
  ```
  ```
  tln nginx-ingress-status@k8s
  ```
  Use IP address/DNS name from command below to check access to the cluster using browser/curl
  ```
  tln nginx-ingress-uninstall@k8s
  ```
  ```
  ^d
  ```
* Deconstruct DO Dev infrastructure instance
  ```
  tln deconstruct do -- --backend cloud --plan --apply
  ```
### AWS
  * Create **aws/.env** file using **aws/.env.template** as an example
    ```
    AWS_ACCESS_KEY_ID=<your_aws_id>
    AWS_SECRET_ACCESS_KEY=<your_aws_key>
    AWS_SESSION_TOKEN=

    AWS_DEFAULT_REGION=eu-central-1

    TF_VAR_aws_k8s_version=1.27
    TF_VAR_aws_k8s_nodes_min=1
    TF_VAR_aws_k8s_nodes_desired=2
    TF_VAR_aws_k8s_nodes_max=3
    TF_VAR_aws_k8s_nodes_size=t3a.medium
    TF_VAR_aws_k8s_nodes_disk=50
    ```

