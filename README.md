# Description
## Cloud Agnostic IaC based SaaS Skeleton.
![Infrastructure Instance](ii.png)

## Features
* Supports AWS (Azure, GCP - in progress)
* Provides Multi-tenancy feature via layers architecture (provider, group, network, managed, app, tenant)
* Implements easy-to-construct multiple environment approach, controls by single environment variable - **TF_VAR_env_id**
* IaC via Terraform and Helm
* Utilises multiple backend providers - Local, Cloud, PG (S3 - in progress)

## Infrastructure Instance layers
![Infrastructure Instance Layers](layers.png)

## Quick start
* Install [Nodejs 20.x or higher](https://nodejs.org)
* Install helpers [tln](https://www.npmjs.com/package/tln-cli) & [tpm](https://github.com/project-talan/tln-pm)
    ```
    npm i -g tln-cli@1.110.0 tln-pm@0.19.0 && brew install wget
    ```
* Goto **projects** folder from **tln** installation above and clone repository
  ```
  git clone --depth 1 --branch v25.5.0 git@github.com:project-talan/tln-clouds.git && cd tln-clouds
  ```
> Important<br>
> * Commands below assume that Terraform Cloud is used as a storage for states<br/>
> * By skipping **--backend cloud** local backend will be used<br/>
> * You will need **domain name** to configure all layers (myproject.io as an example below)
* Use **.env.template** file as an examples and fill it with actual values
  * root .env
    ```
    TF_TOKEN_app_terraform_io=<your_terraform_cloud_token>

    TF_VAR_org_id=<your_terraform_cloud_org>
    TF_VAR_project_id=myproject
    TF_VAR_group_id=dev
    TF_VAR_env_id=dev01
    TF_VAR_tenant_id=balenciaga
    
    TF_VAR_repositories=io.myproject.backend.services.api,io.myproject.web.landing

    TF_VAR_domain_name=myproject.io
    TF_VAR_dns_records=dev01.myproject.io,api
    TF_VAR_use_primary_domain=false

    TF_VAR_rds_pg_db_size=db.t3.micro
    TF_VAR_rds_pg_db_allocated_storage=20
    TF_VAR_rds_pg_max_allocated_storage=30
    TF_VAR_databases={ "iam" = { owner = "admin", password = "admin" }, "billing" = { owner = "admin", password = "admin" } }
    ```

### AWS
  * Create **aws/.env** file using **aws/.env.template** as an example
    ```
    AWS_ACCESS_KEY_ID=<your_aws_id>
    AWS_SECRET_ACCESS_KEY=<your_aws_key>
    AWS_DEFAULT_REGION=eu-central-1

    TF_VAR_aws_k8s_version=1.30
    TF_VAR_aws_k8s_nodes_min=1
    TF_VAR_aws_k8s_nodes_desired=2
    TF_VAR_aws_k8s_nodes_max=3
    TF_VAR_aws_k8s_nodes_size=t3a.medium
    TF_VAR_aws_k8s_nodes_disk=50
    ```
* **Install dependencies**
  ```
  tln install aws --depends
  ```
* Construct four AWS Infrastructure Instance layers

  1. **Provider layer - configure ERC**
    ```
    tln construct aws -- --backend cloud --init --apply --layers provider --state project,provider
    ```
  2. **Groupr layer - configure Route53, certificate & validation. You will need to modify DNS nameservers at your registrar side**
    ```
    tln construct aws -- --backend cloud --init --apply --layers group --state project,provider,group
    ```
  3. **Network and Managed layers - configure VPC, Bastion, K8s**
    ```
    tln construct aws -- --backend cloud --init --apply --layers network,managed --state project,provider,group,env,layer
    ```
* At this point you have ready to use cloud infrastructure with K8s and secure access via bastion
  
  1. **Initiate sshuttle connection to the cluster via bastion (first terminal)**
    ```
    tln connect aws
    ```
  2. **Open shell with necessary environment variables (second terminal)**
    ```
    tln shell aws
    ```
  3. **Check cluster (second terminal)**
    ```
    kubectl get pods -A
    ```
  4. **Close shell (second terminal)**
    ```
    ^D
    ```
  5. **Close sshuttle connection (first terminal)**
    ```
    ^C
    ```
* You can go extra mile and deploy your SaaS-specific resources

  1. **Start secure sshuttle connection (first terminal)**
    ```
    tln connect aws
    ```
  2. **Deploy App layer - configure Nginx ingress, Postgres DBs, DNS records (second terminal)**
    ```
    tln construct aws -- --backend cloud --init --apply --layers app --state project,provider,group,env,layer
    ```
  3. **You can check endpoints availability in browser https://dev01.myprojecy.io & https://api.dev01.myproject.io**

* Now you can deconstruct all layers and free all Cloud resources

  1. **Undeploy App layer (second terminal)**
    ```
    tln deconstruct aws -- --backend cloud --init --apply --layers app --state project,provider,group,env,layer
    ```
  2. **Close sshuttle connection (first terminal)**
    ```
    ^C
    ```
  3. **Delete Network and Managed layers**
    ```
    tln deconstruct aws -- --backend cloud --init --apply --layers network,managed --state project,provider,group,env,layer
    ```
  4. **Delete Groupr layer**
    ```
    tln deconstruct aws -- --backend cloud --init --apply --layers group --state project,provider,group
    ```
  5. **Delete Provider layer**
    ```
    tln deconstruct aws -- --backend cloud --init --apply --layers provider --state project,provider
    ```

### Azure
  In development

### GCP
  In development

## Command line options
General format
```
tln [construct | deconstruct] [do | aws] [-u] -- [option, [option], ...]
```
| Option  | Description | Example |
| ------------- | ------------- | ------------- |
| backend | Defines which backend provider should bu used (cloud, pg) | $ tln construct do -- --backend cloud <br /> $ tln construct aws -- --backend pg |
| state | Defines how store name will be built: project, provider, env, layer, tenant, <custom_string> | $ tln construct do -- --backend cloud -- state project,provider,env,layer <br /> will use tln-clouds-do-dev-managed Terraform Cloud workspace  |
| init | Run Terraform init | $ tln construct aws -- --backend cloud --init |
| upgrade | Run Terraform upgrade mode for init | $ tln construct aws -- --backend cloud --init --upgrade |
| plan | Run Terraform plan | $ tln construct aws -- --backend cloud --plan |
| apply | Run Terraform apply | $ tln construct aws -- --backend cloud --apply |
| auto-approve | Tun on auto approve for apply & destroy | $ tln construct aws -- --backend cloud --apply --auto-approve |
| layers | Select which layers will be included | $ tln construct aws -- --backend cloud --apply --layers tenant <br /> will construct infrastructure for tenant layer only |
| bastion | Bastion address in form user@ip | $ tln bridge aws -- --bastion devops@192.168.10.1 <br /> will establish ssh connection with local box and bastion |
| bridge-port | Local port for bridge to bastion | $ tln connect aws -- --bridge-port 8888 <br /> will run shell with ssh connection into k8s cluster |
