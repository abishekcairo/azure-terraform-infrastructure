# Production-Style Azure Infrastructure with Terraform

Terraform project that builds a secure, multi-environment Azure setup and deploys it through a GitHub Actions pipeline.

## Architecture

Internet -> Load Balancer -> VM Scale Set (private subnet) -> PostgreSQL (private endpoint)
Key Vault stores the database password. Log Analytics and alerts monitor the system.
Terraform state is stored remotely in Azure Storage with locking.

(Add your architecture picture here: ![Architecture](docs/architecture.png))

## Tech stack
Azure, Terraform, GitHub Actions (OIDC), Key Vault, Log Analytics, Checkov

## What it builds
- Networking: VNet, subnets, NSG
- Compute: Load Balancer and VM Scale Set running nginx (cloud-init)
- Database: PostgreSQL Flexible Server with a private endpoint and no public access
- Security: Key Vault with RBAC, generated password, SSH keys only, OIDC login (no stored secrets)
- Monitoring: Log Analytics workspace and CPU alert with email
- Environments: dev and prod use the same modules with different settings

## Repository structure
(bootstrap, modules, environments, .github/workflows, docs)

## How to deploy
1. Run bootstrap to create the remote state storage
2. cd environments/dev, then terraform init, plan, apply
3. Or open a pull request: the pipeline runs the plan, and merging runs the apply

## CI/CD pipeline
Pull request: format check, validate, Checkov scan, terraform plan for dev and prod.
Merge to main: terraform apply for dev. Prod needs a manual approval gate.
(Add screenshots: green pull request, plan summary, apply run)

## Security decisions
- Only the load balancer is public. Servers have no public IPs.
- Database has public access disabled and uses a private endpoint.
- Secrets live in Key Vault, not in code.
- GitHub logs in to Azure with OIDC, so no client secret is stored.
- State is stored in a private, versioned storage account.

## Results
(Add screenshots: website, portal resources, Key Vault, database networking, drift demo)

## Cost
Free account credit. Resources were destroyed after each session. Budget alert enabled.

## Challenges and lessons learned
- VM size not available in Central India: checked restrictions with az vm list-skus and pinned the scale set to an available zone.
- Regional core quota (4 cores) prevented deploying prod at the same time as dev, so prod is validated through terraform plan in the pipeline.
- OIDC subject mismatch: GitHub sends the owner and repo IDs in the subject, so I added federated credentials with the exact subject.
- Terraform needed ARM_USE_OIDC to authenticate in the pipeline instead of the Azure CLI.

## Future improvements
AKS, hub-and-spoke network, Application Gateway with WAF, Terraform tests, Infracost
