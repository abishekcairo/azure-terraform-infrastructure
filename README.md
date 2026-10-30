# Production-Style Azure Infrastructure with Terraform

Terraform project that builds a secure, multi-environment Azure setup and deploys it through a GitHub Actions pipeline.

## Architecture

Internet -> Load Balancer -> VM Scale Set (private subnet) -> PostgreSQL (private endpoint)
Key Vault stores the database password. Log Analytics and alerts monitor the system.
Terraform state is stored remotely in Azure Storage with locking.

(Add your architecture picture here: ![Architecture](<img width="2600" height="2400" alt="architecture" src="https://github.com/user-attachments/assets/ed39d624-e5dc-4187-bcbf-762f650e196f" />

)

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
(Add screenshots: website, portal resources, Key Vault, database networking, drift demo)<img width="1535" height="812" alt="Screenshot 2026-10-24 190607" src="https://github.com/user-attachments/assets/161ec8e9-be0f-4d6e-b065-5182a96f805d" />
<img width="1535" height="773" alt="Screenshot 2026-10-25 182611" src="https://github.com/user-attachments/assets/98db8aff-7cc9-4b5a-8149-26c8157402c1" />
<img width="1527" height="690" alt="Screenshot 2026-10-25 183552" src="https://github.com/user-attachments/assets/c6f843c6-3190-4250-bcfb-c7e0a027ff3d" />
<img width="1535" height="690" alt="Screenshot 2026-10-25 183632" src="https://github.com/user-attachments/assets/27be498c-5c6e-43d2-ad01-4968a6dfc0d6" />
<img width="1535" height="695" alt="Screenshot 2026-10-25 184036" src="https://github.com/user-attachments/assets/3d2e7fdc-ec42-4562-a96c-af0ebd89d470" />
<img width="1535" height="693" alt="Screenshot 2026-10-25 184841" src="https://github.com/user-attachments/assets/f2c0ede7-8907-4f6b-a56e-07ffc9198a13" />
<img width="1535" height="691" alt="Screenshot 2026-10-25 184936" src="https://github.com/user-attachments/assets/598999c9-a67f-461f-bae0-50c600f173bb" />
<img width="1535" height="692" alt="Screenshot 2026-10-25 185328" src="https://github.com/user-attachments/assets/e4e10bb5-3f96-43d1-83f7-788ab3106776" />
<img width="1535" height="692" alt="Screenshot 2026-10-25 185347" src="https://github.com/user-attachments/assets/a546dc54-a27f-4c86-8ab5-653462c9cd0e" />
<img width="1535" height="773" alt="Screenshot 2026-10-25 201145" src="https://github.com/user-attachments/assets/ef082d10-56ac-4fbb-9de0-26ca5f96f53b" />
<img width="1531" height="678" alt="Screenshot 2026-10-27 195717" src="https://github.com/user-attachments/assets/4ed9c080-198e-4301-9275-fe6b6b8dda7d" />
<img width="1535" height="686" alt="Screenshot 2026-10-27 201620" src="https://github.com/user-attachments/assets/43f60cbb-c386-451c-90a5-eed267a33c43" />
<img width="1535" height="680" alt="Screenshot 2026-10-28 172632" src="https://github.com/user-attachments/assets/10817799-a4fd-4d8c-87bf-da661c307903" />
<img width="1535" height="682" alt="Screenshot 2026-10-28 172928" src="https://github.com/user-attachments/assets/3e6d19d7-2eda-4a78-a852-9f4cdef9a20f" />
<img width="1535" height="816" alt="Screenshot 2026-10-28 173752" src="https://github.com/user-attachments/assets/c5e8a5fd-eda5-4707-a721-802acfdde121" />




## Cost
Free account credit. Resources were destroyed after each session. Budget alert enabled.

## Challenges and lessons learned
- VM size not available in Central India: checked restrictions with az vm list-skus and pinned the scale set to an available zone.
- Regional core quota (4 cores) prevented deploying prod at the same time as dev, so prod is validated through terraform plan in the pipeline.
- OIDC subject mismatch: GitHub sends the owner and repo IDs in the subject, so I added federated credentials with the exact subject.
- Terraform needed ARM_USE_OIDC to authenticate in the pipeline instead of the Azure CLI.

## Future improvements
AKS, hub-and-spoke network, Application Gateway with WAF, Terraform tests, Infracost
