# Jinteki Netrunner Terraform Deployment

Terraform script to deploy a Netrunner server to Azure using managed container instances.

## Setup
- Have an Azure account. Login with `az login`.
- Have a CloudFlare account.
- Have a domain managed in CloudFlare.
- Have the nameservers for the domain point to CloudFlare.
- Get the Global API Key for your CloudFlare account (don't generate an API Token)

## Configuration
Terraform variables needs to be configured. The easiest approach is to use a `terraform.tfvars` file.

```
% cp terraform.tfvars.example terraform.tfvars
% vim terraform.tfvars
```

## Usage
```
% terraform init
% terraform apply
```

## Cleanup
```
% terraform destroy
```

## Resources Created
- Azure Resource Group
  - Azure Storage Account
    - Azure File Share: MongoDB data
    - Azure File Share: Card images
  - Azure Container Instance
    - JNet Container
    - MongodDB Container
    - Nginx Container
- Cloudflare Record: A Record, domain -> IP of Azure Container Instance
- Cloudflare Record: CNAME Record, www.domain -> domain

